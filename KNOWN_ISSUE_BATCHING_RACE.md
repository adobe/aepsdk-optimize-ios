# Known Issue: `propositionsInProgress` shared-state race under Edge batching

**Status:** Flagged, not fixed. **Date:** 2026-07-14
**Affects:** `Sources/AEPOptimize/Optimize.swift`
**Trigger:** Edge iOS's new Experience Event batching (`edge.batching.enabled = true`), currently
shipping disabled by default. This is a latent bug today — Optimize's own hit queue is still
single-hit-at-a-time, so it is very unlikely two `updateProposition()` requests are ever actually
in flight, unconsumed, at once. Batching removes that accidental protection.

## The bug

`Optimize` accumulates all in-flight proposition data into one shared, unscoped map:

```swift
private var propositionsInProgress = ThreadSafeDictionary<DecisionScope, OptimizeProposition>(...)
```

- `processEdgeResponse` (line 429) merges every incoming proposition into this map unconditionally,
  regardless of which `updateProposition()` call it belongs to.
- The response callback inside `processUpdatePropositions` (line 299) reads the **entire** map
  unfiltered (`propositionsInProgress.shallowCopy`) — not scoped to that specific call's own
  `validDecisionScopes`.
- `processUpdatePropositionsCompleted` (line 339) and the timeout path (line 290) both
  unconditionally `.removeAll()` the map.

This is safe only when at most one `updateProposition()` request can have data "in flight,
unconsumed" at a time. Two overlapping requests break it in two ways:

1. **Wrong-data contamination:** if request A's callback fires after request B's data has already
   landed in the shared map (but before A's own completion), A's callback can read B's propositions —
   scopes A never asked for.
2. **Data loss:** if request B's completion clears the map (`.removeAll()`) between request A's data
   being written and A's own callback reading it, A gets an empty result despite the server having
   answered.

This is the exact same architectural shape as a bug found and partially fixed this session in
`aepsdk-edge-android`'s Optimize extension (see `aepsdk-edge-android/batching-validation/POST_IMPLEMENTATION_FINDINGS.md`,
§4) — confirmed there via direct instrumented-log evidence, not just code reading.

## Root cause (confirmed in `aepsdk-core-ios/AEPCore/Sources/eventhub/EventHub.swift`)

`Optimize.processUpdatePropositions` uses `MobileCore.dispatch(event:timeout:responseCallback:)` for
its own Edge round trip. Per-request response-callback listeners (`registerResponseListener`) run
**inline on the central `eventQueue`**. Optimize's own normal listeners — `processEdgeResponse`
(writes the shared map) and `processUpdatePropositionsCompleted` (clears it) — run on **Optimize's
own separate per-extension `eventOrderer`**. These are two independently-scheduled queues with no
ordering guarantee between them, so a completion clear and a sibling request's data write/read can
interleave in any order.

Edge iOS's own ordering discipline (shipped alongside Edge's batching port, see
`aepsdk-edge-ios`'s `NetworkResponseHandler.swift`, `earlyPerEventCompletionEnabled`) narrows this —
Edge now guarantees completion(N) is dispatched before handle(N+1) for events sharing one batch — but
it cannot close this race, because the race is entirely downstream of Edge, between Optimize's own
clear (on `eventOrderer`) and Optimize's own callback read (on the central `eventQueue`). This mirrors
exactly what was found and documented for Android: the Edge-side fix is defense-in-depth, not a
complete fix.

## Recommended fix (not implemented here)

Scope the accumulator per update-request instead of one global dict, e.g.:

```swift
private var propositionsInProgress = ThreadSafeDictionary<String /* edgeEvent.id.uuidString */,
                                                          [DecisionScope: OptimizeProposition]>(...)
```

- `processEdgeResponse` merges only into the specific request's own sub-dictionary (keyed by the
  update request's edge event id — `updateRequestEventIdsInProgress` already tracks per-request scopes
  and can supply this key).
- Each request's own callback reads only its own key.
- `processUpdatePropositionsCompleted` clears only its own key, not the whole map.

This removes the race at its root — no shared mutable structure for two in-flight requests to collide
on — rather than depending on any Edge-side ordering discipline, which can only narrow, not close, this
class of bug.

## Recommended verification test (should exist regardless of when the fix lands)

A test dispatching two overlapping `Optimize.updateProposition()` calls with a mock responder that
deliberately delays until both are "sent" (forcing them into the same batch under
`edge.batching.enabled = true`), returning two disjoint per-event proposition payloads — asserting
each call's callback receives only its own scope's data. Run three ways:

1. Batching disabled — expect pass (today's default, matches current shipped behavior).
2. Batching enabled, without the fix — expect **fail** (proves the bug is real and batching-introduced).
3. Batching enabled, with the fix — expect pass.

## Recommendation

Land the scoped-accumulator fix (or at least the verification test proving the bug) before
`edge.batching.enabled` is turned on by default in production on iOS, to avoid ever shipping this
window live — matching the same recommendation made for Android.
