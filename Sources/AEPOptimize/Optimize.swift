/*
 Copyright 2021 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
import AEPServices
import Foundation

@objc(AEPMobileOptimize)
public class Optimize: NSObject, Extension {
    // MARK: Extension

    public let name = OptimizeConstants.EXTENSION_NAME
    public let friendlyName = OptimizeConstants.FRIENDLY_NAME
    public static let extensionVersion = OptimizeConstants.EXTENSION_VERSION
    public let metadata: [String: String]? = nil
    public let runtime: ExtensionRuntime

    // Operation orderer used to maintain the order of update and get propositions events.
    // It ensures any update propositions requests issued before a get propositions call are completed
    // and the get propositions request is fulfilled from the latest cached content.
    private let eventsQueue = OperationOrderer<Event>("OptimizeEvents")

    /// Dispatch queue used to protect against simultaneous access of our containers from multiple threads
    private let queue: DispatchQueue = .init(label: "com.adobe.optimize.containers.queue")

    /// a dictionary containing the update event IDs and corresponding errors as received from Edge SDK
    private var _updateRequestEventIdsErrors: [String: AEPOptimizeError] = [:]
    private var updateRequestEventIdsErrors: [String: AEPOptimizeError] {
        get { queue.sync { self._updateRequestEventIdsErrors } }
        set { queue.async { self._updateRequestEventIdsErrors = newValue } }
    }

    /// a dictionary containing the update event IDs (and corresponding requested scopes) for Edge events that haven't yet received an Edge completion response.
    private var _updateRequestEventIdsInProgress: [String: [DecisionScope]] = [:]
    private var updateRequestEventIdsInProgress: [String: [DecisionScope]] {
        get { queue.sync { self._updateRequestEventIdsInProgress } }
        set { queue.async { self._updateRequestEventIdsInProgress = newValue } }
    }

    /// a dictionary to accumulate propositions returned in various personalization:decisions events for the same Edge personalization request.
    private var _propositionsInProgress: [DecisionScope: OptimizeProposition] = [:]
    private var propositionsInProgress: [DecisionScope: OptimizeProposition] {
        get { queue.sync { self._propositionsInProgress } }
        set { queue.async { self._propositionsInProgress = newValue } }
    }

    /// Dictionary containing decision propositions currently cached in-memory in the SDK.
    private var _cachedPropositions: [DecisionScope: OptimizeProposition] = [:]
    #if DEBUG
        var cachedPropositions: [DecisionScope: OptimizeProposition] {
            get { queue.sync { self._cachedPropositions } }
            set { queue.async { self._cachedPropositions = newValue } }
        }
    #else
        private(set) var cachedPropositions: [DecisionScope: OptimizeProposition] {
            get { queue.sync { self._cachedPropositions } }
            set { queue.async { self._cachedPropositions = newValue } }
        }
    #endif

    /// Dictionary containing  propositions simulated for preview and cached in-memory in the SDK
    private var _previewCachedPropositions: [DecisionScope: OptimizeProposition] = [:]
    #if DEBUG
        var previewCachedPropositions: [DecisionScope: OptimizeProposition] {
            get { queue.sync { self._previewCachedPropositions } }
            set { queue.async { self._previewCachedPropositions = newValue } }
        }
    #else
        private(set) var previewCachedPropositions: [DecisionScope: OptimizeProposition] {
            get { queue.sync { self._previewCachedPropositions } }
            set { queue.async { self._previewCachedPropositions = newValue } }
        }
    #endif

    /// Array containing recoverable network error codes being retried by Edge Network Service
    private let recoverableNetworkErrorCodes: [Int] = [OptimizeConstants.HTTPResponseCodes.clientTimeout.rawValue,
                                                       OptimizeConstants.HTTPResponseCodes.tooManyRequests.rawValue,
                                                       OptimizeConstants.HTTPResponseCodes.badGateway.rawValue,
                                                       OptimizeConstants.HTTPResponseCodes.serviceUnavailable.rawValue,
                                                       OptimizeConstants.HTTPResponseCodes.gatewayTimeout.rawValue]

    /// Array containing the schema strings for the proposition items supported by the SDK, sent in the personalization query request.
    static let supportedSchemas = [
        // Target schemas
        OptimizeConstants.JsonValues.SCHEMA_TARGET_HTML,
        OptimizeConstants.JsonValues.SCHEMA_TARGET_JSON,
        OptimizeConstants.JsonValues.SCHEMA_TARGET_DEFAULT,

        // Offer Decisioning schemas
        OptimizeConstants.JsonValues.SCHEMA_OFFER_HTML,
        OptimizeConstants.JsonValues.SCHEMA_OFFER_JSON,
        OptimizeConstants.JsonValues.SCHEMA_OFFER_IMAGE,
        OptimizeConstants.JsonValues.SCHEMA_OFFER_TEXT
    ]

    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        super.init()
    }

    public func onRegistered() {
        registerListener(type: EventType.optimize,
                         source: EventSource.requestContent,
                         listener: processOptimizeRequestContent(event:))

        registerListener(type: EventType.edge,
                         source: OptimizeConstants.EventSource.EDGE_PERSONALIZATION_DECISIONS,
                         listener: processEdgeResponse(event:))

        registerListener(type: EventType.edge,
                         source: OptimizeConstants.EventSource.EDGE_ERROR_RESPONSE,
                         listener: processEdgeErrorResponse(event:))

        registerListener(type: EventType.optimize,
                         source: EventSource.requestReset,
                         listener: processClearPropositions(event:))

        // Register listener - Core `resetIdentities()` API dispatches generic identity request reset event.
        registerListener(type: EventType.genericIdentity,
                         source: EventSource.requestReset,
                         listener: processClearPropositions(event:))

        // Register listener for handling internal personalization request complete events
        registerListener(type: EventType.optimize,
                         source: EventSource.contentComplete,
                         listener: processUpdatePropositionsCompleted(event:))

        // register listener for handling debug events
        registerListener(type: EventType.system,
                         source: EventSource.debug,
                         listener: processDebugEvent)

        // Handler function called for each queued event. If the queued event is a get propositions event, process it
        // otherwise if it is an Edge event to update propositions, process it only if it is completed.
        eventsQueue.setHandler { event -> Bool in
            if event.isGetEvent {
                self.processGetPropositions(event: event)
            } else if event.type == EventType.edge {
                return !self.updateRequestEventIdsInProgress.keys.contains(event.id.uuidString)
            }
            return true
        }
        eventsQueue.start()
    }

    public func onUnregistered() {}

    public func readyForEvent(_ event: Event) -> Bool {
        if event.source == EventSource.requestContent {
            return getSharedState(extensionName: OptimizeConstants.Configuration.EXTENSION_NAME, event: event)?.status == .set
        }
        return true
    }

    /// Processes the propositions request event, dispatched with type `EventType.optimize` and source `EventSource.requestContent`.
    ///
    /// It processes events based on the "requesttype" in the event data
    /// - Parameter event: propositions request event
    private func processOptimizeRequestContent(event: Event) {
        if event.isUpdateEvent {
            processUpdatePropositions(event: event)
        } else if event.isGetEvent {
            guard let eventDecisionScopes: [DecisionScope] = event.getTypedData(for: OptimizeConstants.EventDataKeys.DECISION_SCOPES),
                  !eventDecisionScopes.isEmpty
            else {
                Log.debug(label: OptimizeConstants.LOG_TAG, "Decision scopes, in event data, is either not present or empty.")
                let aepOptimizeError = AEPOptimizeError.createAEPOptimizInvalidRequestError()
                dispatch(event: event.createErrorResponseEvent(aepOptimizeError))
                return
            }
            /// Fetch propositions and check if all of the decision scopes are present in the cache
            let fetchedPropositions = eventDecisionScopes.filter { self.cachedPropositions.keys.contains($0) }
            /// Check if the decision scopes are currently in progress in `updateRequestEventIdsInProgress`
            let scopesInProgress = eventDecisionScopes.filter { scope in
                updateRequestEventIdsInProgress.values.flatMap { $0 }.contains(scope)
            }
            if eventDecisionScopes.count == fetchedPropositions.count && scopesInProgress.isEmpty {
                processGetPropositions(event: event)
            } else {
                /// Not all decision scopes are present in the cache or requested scopes are currently in progress, adding it to the event queue
                eventsQueue.add(event)
                Log.trace(label: OptimizeConstants.LOG_TAG, "Decision scopes are either not present or currently in progress.")
            }
        } else if event.isTrackEvent {
            processTrackPropositions(event: event)
        } else {
            Log.warning(label: OptimizeConstants.LOG_TAG, "Ignoring event! Cannot determine the type of request event.")
            return
        }
    }

    // MARK: Event Listeners

    /// Processes the update propositions request event, dispatched with type `EventType.optimize` and source `EventSource.requestContent`.
    ///
    /// It dispatches an event to the Edge extension to send personalization query request to the Experience Edge network.
    /// - Parameter event: Update propositions request event
    private func processUpdatePropositions(event: Event) {
        guard
            let configSharedState = getSharedState(extensionName: OptimizeConstants.Configuration.EXTENSION_NAME,
                                                   event: event)?.value
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot process the update propositions request event, Configuration shared state is not available.")
            return
        }

        guard let decisionScopes: [DecisionScope] = event.getTypedData(for: OptimizeConstants.EventDataKeys.DECISION_SCOPES),
              !decisionScopes.isEmpty
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG, "Decision scopes, in event data, is either not present or empty.")
            return
        }

        let validDecisionScopes = decisionScopes
            .filter { $0.isValid }

        guard !validDecisionScopes.isEmpty else {
            Log.debug(label: OptimizeConstants.LOG_TAG, "No valid decision scopes found for the Edge personalization request!")
            return
        }

        // Timeout value
        let apiTimeout: TimeInterval? = event.data?[OptimizeConstants.EventDataKeys.TIMEOUT] as? TimeInterval
        let finalTimeout = calculateTimeout(apiTimeout: apiTimeout)

        // Construct Edge event data
        var eventData: [String: Any] = [:]

        // Add query
        eventData[OptimizeConstants.JsonKeys.QUERY] = [
            OptimizeConstants.JsonKeys.QUERY_PERSONALIZATION: [
                OptimizeConstants.JsonKeys.SCHEMAS: Optimize.supportedSchemas,
                OptimizeConstants.JsonKeys.DECISION_SCOPES: validDecisionScopes.compactMap { $0.name }
            ]
        ]

        // Add xdm
        var xdmData: [String: Any] = [
            OptimizeConstants.JsonKeys.EXPERIENCE_EVENT_TYPE: OptimizeConstants.JsonValues.EE_EVENT_TYPE_PERSONALIZATION
        ]
        if let additionalXdmData = event.data?[OptimizeConstants.EventDataKeys.XDM] as? [String: Any] {
            xdmData.merge(additionalXdmData) { old, _ in old }
        }
        eventData[OptimizeConstants.JsonKeys.XDM] = xdmData

        // Add data
        if let data = event.data?[OptimizeConstants.EventDataKeys.DATA] as? [String: Any] {
            eventData[OptimizeConstants.JsonKeys.DATA] = data
        }

        // Add the flag to request sendCompletion
        eventData[OptimizeConstants.JsonKeys.REQUEST] = [
            OptimizeConstants.JsonKeys.REQUEST_SEND_COMPLETION: true
        ]

        // Add override datasetId
        if let datasetId = configSharedState[OptimizeConstants.Configuration.OPTIMIZE_OVERRIDE_DATASET_ID] as? String {
            eventData[OptimizeConstants.JsonKeys.DATASET_ID] = datasetId
        }

        let edgeEvent = event.createChainedEvent(name: OptimizeConstants.EventNames.EDGE_PERSONALIZATION_REQUEST,
                                                 type: EventType.edge,
                                                 source: EventSource.requestContent,
                                                 data: eventData)

        // In AEP Response Event handle, `requestEventId` corresponds to the UUID for the Edge request.
        // Storing the request event UUID to compare and process only the anticipated response in the extension.
        updateRequestEventIdsInProgress[edgeEvent.id.uuidString] = validDecisionScopes

        // add the Edge event to update propositions in the events queue.
        eventsQueue.add(edgeEvent)

        // Dispatch Edge event with synchronized timeout
        MobileCore.dispatch(event: edgeEvent, timeout: finalTimeout) { responseEvent in
            guard let responseEvent = responseEvent, let requestEventId = responseEvent.requestEventId else {
                // response event failed or timed out, remove this event's ID from the requested event IDs dictionary, dispatch an error response event and kick-off queue.
                self.updateRequestEventIdsInProgress.removeValue(forKey: edgeEvent.id.uuidString)
                self.propositionsInProgress.removeAll()
                let timeoutError = AEPOptimizeError.createAEPOptimizeTimeoutError()
                self.dispatch(event: event.createErrorResponseEvent(timeoutError))
                self.eventsQueue.start()
                return
            }
            // Error response received for Edge request event UUID (if any)
            let edgeError = self.updateRequestEventIdsErrors[requestEventId]

            // response event to provide success callback to updateProposition public api
            let responseEventToSend = event.createResponseEvent(
                name: OptimizeConstants.EventNames.OPTIMIZE_RESPONSE,
                type: EventType.optimize,
                source: EventSource.responseContent,
                data: [
                    OptimizeConstants.EventDataKeys.PROPOSITIONS: self.propositionsInProgress,
                    OptimizeConstants.EventDataKeys.RESPONSE_ERROR: edgeError as Any
                ]
            )
            self.dispatch(event: responseEventToSend)

            let updateCompleteEvent = responseEvent.createChainedEvent(name: OptimizeConstants.EventNames.OPTIMIZE_UPDATE_COMPLETE,
                                                                       type: EventType.optimize,
                                                                       source: EventSource.contentComplete,
                                                                       data: [
                                                                           OptimizeConstants.EventDataKeys.COMPLETED_UPDATE_EVENT_ID: requestEventId
                                                                       ])
            self.dispatch(event: updateCompleteEvent)
        }
    }

    /// Processes the internal Optimize content complete event, dispatched with type `EventType.optimize` and source `EventSource.contentComplete`.
    ///
    /// The event is dispatched internally upon receiving an Edge content complete response for an update propositions request.
    /// - Parameter event: Optimize content complete event.
    private func processUpdatePropositionsCompleted(event: Event) {
        defer {
            propositionsInProgress.removeAll()

            // kick off processing the internal events queue after processing is completed for an update propositions request.
            eventsQueue.start()
        }

        guard let requestCompletedForEventId = event.data?[OptimizeConstants.EventDataKeys.COMPLETED_UPDATE_EVENT_ID] as? String,
              let requestedScopes = updateRequestEventIdsInProgress[requestCompletedForEventId]
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      """
                      Ignoring Optimize complete event, either event Id for the completed event is not present in event data,
                      or the event Id is not being tracked for completion.
                      """)
            return
        }

        // Update propositions in cache
        updateCachedPropositions(for: requestedScopes)

        // remove completed event's ID from the request event IDs dictionary.
        updateRequestEventIdsInProgress.removeValue(forKey: requestCompletedForEventId)
    }

    /// Updates the in-memory propositions cache with the returned propositions.
    ///
    /// Any requested scopes for which no propositions are returned in personalization: decisions events are removed from the cache.
    /// - Parameter requestedScope: an array of decision scopes for which propositions are requested.
    private func updateCachedPropositions(for requestedScopes: [DecisionScope]) {
        // update cache with accumulated propositions
        cachedPropositions.merge(propositionsInProgress) { _, new in new }

        // remove cached propositions for requested scopes for which no propositions are returned.
        let returnedScopes = Array(propositionsInProgress.keys) as [DecisionScope]
        let scopesToRemove = requestedScopes.minus(returnedScopes)
        for scope in scopesToRemove {
            cachedPropositions.removeValue(forKey: scope)
        }
    }

    /// Processes the Edge response event, dispatched with type `EventType.edge` and source `personalization: decisions`.
    ///
    /// It dispatches a personalization notification event with the propositions received from the decisioning services configured behind
    /// Experience Edge network.
    /// - Parameter event: Edge response event.
    private func processEdgeResponse(event: Event) {
        guard
            event.isPersonalizationDecisionResponse,
            let requestEventId = event.requestEventId,
            updateRequestEventIdsInProgress.contains(where: { $0.key == requestEventId })
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      """
                      Ignoring Edge event, either handle type is not personalization:decisions, or the response isn't intended for this extension.
                      """)
            return
        }

        guard let propositions: [OptimizeProposition] = event.getTypedData(for: OptimizeConstants.Edge.PAYLOAD),
              !propositions.isEmpty
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG, "Failed to read Edge response, propositions array is invalid or empty.")
            return
        }

        let propositionsDict = propositions
            .filter { !$0.offers.isEmpty }
            .toDictionary { DecisionScope(name: $0.scope) }

        guard !propositionsDict.isEmpty else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      """
                      No propositions with valid offers are present in the Edge response event for the provided scopes(\
                      \(propositions
                          .map { $0.scope }
                          .joined(separator: ","))
                      ).
                      """)
            return
        }

        // accumulate propositions in in-progress propositions dictionary
        propositionsInProgress.merge(propositionsDict) { _, new in new }

        let eventData = [OptimizeConstants.EventDataKeys.PROPOSITIONS: propositionsDict].asDictionary()

        let event = Event(name: OptimizeConstants.EventNames.OPTIMIZE_NOTIFICATION,
                          type: EventType.optimize,
                          source: EventSource.notification,
                          data: eventData)
        dispatch(event: event)
    }

    /// Processes the Edge error response event, dispatched with type `EventType.edge` and source `com.adobe.eventSource.errorResponseContent`.
    ///
    /// It logs error related information specifying error type along with a detailed message.
    /// - Parameter event: Edge error response event.
    private func processEdgeErrorResponse(event: Event) {
        guard
            event.isEdgeErrorResponseEvent,
            let requestEventId = event.requestEventId,
            updateRequestEventIdsInProgress.contains(where: { $0.key == requestEventId })
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      """
                      Ignoring Edge event, either handle type is not errorResponseContent, or the response isn't intended for this extension.
                      """)
            return
        }
        let errorType = event.data?[OptimizeConstants.Edge.ErrorKeys.TYPE] as? String
        let errorStatus = event.data?[OptimizeConstants.Edge.ErrorKeys.STATUS] as? Int
        let errorTitle = event.data?[OptimizeConstants.Edge.ErrorKeys.TITLE] as? String
        let errorDetail = event.data?[OptimizeConstants.Edge.ErrorKeys.DETAIL] as? String
        let errorReport = event.data?[OptimizeConstants.Edge.ErrorKeys.REPORT] as? [String: Any]

        let errorString =
            """
            Decisioning Service error, type: \(errorType ?? OptimizeConstants.ERROR_UNKNOWN), \
            status: \(errorStatus ?? OptimizeConstants.UNKNOWN_STATUS), \
            title: \(errorTitle ?? OptimizeConstants.ERROR_UNKNOWN), \
            detail: \(errorDetail ?? OptimizeConstants.ERROR_UNKNOWN), \
            report: \(errorReport ?? [:])"
            """

        Log.warning(label: OptimizeConstants.LOG_TAG, errorString)

        if let errorStatus = errorStatus, !shouldSuppressRecoverableError(status: errorStatus) {
            let aepOptimizeError = AEPOptimizeError(type: errorType, status: errorStatus, title: errorTitle, detail: errorDetail, report: errorReport)
            guard let edgeEventRequestId = event.requestEventId else {
                Log.debug(label: OptimizeConstants.LOG_TAG, "No valid edge event request ID found for error response event.")
                return
            }
            // store the error response as an AEPOptimizeError in error dictionary per edge request
            updateRequestEventIdsErrors[edgeEventRequestId] = aepOptimizeError
        }
    }

    /// Processes the get propositions request event, dispatched with type `EventType.optimize` and source `EventSource.requestContent`.
    ///
    ///  It returns previously cached propositions for the requested decision scopes. Any decision scope(s) not already present in the cache are ignored.
    /// - Parameter event: Get propositions request event
    private func processGetPropositions(event: Event) {
        guard let decisionScopes: [DecisionScope] = event.getTypedData(for: OptimizeConstants.EventDataKeys.DECISION_SCOPES),
              !decisionScopes.isEmpty
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG, "Decision scopes, in event data, is either not present or empty.")
            let aepOptimizeError = AEPOptimizeError.createAEPOptimizInvalidRequestError()
            dispatch(event: event.createErrorResponseEvent(aepOptimizeError))
            return
        }

        // check if the requested scopes are present in preview cache
        let previewPropositionDict = previewCachedPropositions.filter { decisionScopes.contains($0.key) }
        let propositionsDict = cachedPropositions.filter { decisionScopes.contains($0.key) }

        var eventData: [String: Any]?
        if !previewPropositionDict.isEmpty {
            Log.debug(label: OptimizeConstants.LOG_TAG, "Preview Mode is enabled")
            // if preview cache has requested scope, send propositions to be previewed in eventData
            eventData = [OptimizeConstants.EventDataKeys.PROPOSITIONS: previewPropositionDict].asDictionary()
        } else {
            eventData = [OptimizeConstants.EventDataKeys.PROPOSITIONS: propositionsDict].asDictionary()
        }

        let responseEvent = event.createResponseEvent(
            name: OptimizeConstants.EventNames.OPTIMIZE_RESPONSE,
            type: EventType.optimize,
            source: EventSource.responseContent,
            data: eventData
        )
        dispatch(event: responseEvent)
    }

    /// Processes the track propositions request event, dispatched with type `EventType.optimize` and source `EventSource.requestContent`.
    ///
    ///  It dispatches an event for the Edge extension to send an Experience Event containing proposition interactions data to the Experience Edge network.
    /// - Parameter event: Track propositions request event
    private func processTrackPropositions(event: Event) {
        guard
            let configSharedState = getSharedState(extensionName: OptimizeConstants.Configuration.EXTENSION_NAME,
                                                   event: event)?.value
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot process the track propositions request event, Configuration shared state is not available.")
            return
        }

        guard
            let propositionInteractionsXdm = event.data?[OptimizeConstants.EventDataKeys.PROPOSITION_INTERACTIONS] as? [String: Any],
            !propositionInteractionsXdm.isEmpty
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG, "Cannot track proposition options, interaction data is not present.")
            return
        }

        var eventData: [String: Any] = [:]
        eventData[OptimizeConstants.JsonKeys.XDM] = propositionInteractionsXdm

        // Add override datasetId
        if let datasetId = configSharedState[OptimizeConstants.Configuration.OPTIMIZE_OVERRIDE_DATASET_ID] as? String {
            eventData[OptimizeConstants.JsonKeys.DATASET_ID] = datasetId
        }

        let event = Event(name: OptimizeConstants.EventNames.EDGE_PROPOSITION_INTERACTION_REQUEST,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: eventData)
        dispatch(event: event)
    }

    /// Clears propositions cached in-memory in the extension.
    ///
    /// This method is also invoked upon Core`resetIdentities` to clear the propositions cached locally.
    /// - Parameter event: Personalization request reset event.
    private func processClearPropositions(event _: Event) {
        // Clear propositions cache
        cachedPropositions.removeAll()
        previewCachedPropositions.removeAll()
    }

    /// Processes debug events triggered by the system.
    ///
    /// A debug event allows the optimize extension to processes non-production workflows.
    /// - Parameter event: the debug `Event` to be handled.
    private func processDebugEvent(event: Event) {
        guard event.debugEventType == EventType.edge && event.debugEventSource == EventSource.personalizationDecisions
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      " Ignoring Debug event, either debug type is not com.adobe.eventType.edge or debug source is not personalization:decisions")
            return
        }

        guard let propositions: [OptimizeProposition] = event.getTypedData(for: OptimizeConstants.Edge.PAYLOAD),
              !propositions.isEmpty
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG, "Failed to read Debug Event's Edge response, propositions array is invalid or empty.")
            return
        }

        let propositionsDict = propositions
            .filter { !$0.offers.isEmpty }
            .toDictionary { DecisionScope(name: $0.scope) }

        guard !propositionsDict.isEmpty else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      """
                      No propositions with valid offers are present in the Debug Event's Edge response event for the provided scopes(\
                      \(propositions
                          .map { $0.scope }
                          .joined(separator: ","))
                      ).
                      """)
            return
        }

        // accumulate in preview cache
        previewCachedPropositions.merge(propositionsDict) { _, new in new }

        let eventData = [OptimizeConstants.EventDataKeys.PROPOSITIONS: propositionsDict].asDictionary()

        let event = Event(name: OptimizeConstants.EventNames.OPTIMIZE_NOTIFICATION,
                          type: EventType.optimize,
                          source: EventSource.notification,
                          data: eventData)
        dispatch(event: event)
    }

    /// Helper function to check if edge error response received should be suppressed as it is already being retried on Edge
    private func shouldSuppressRecoverableError(status: Int) -> Bool {
        if recoverableNetworkErrorCodes.contains(status) {
            return true
        }
        return false
    }

    /// Calculates the final timeout value based on API timeout, shared state, and default timeout.
    ///
    /// - Parameter apiTimeout: The timeout value provided in the API request.
    /// - Returns: The final timeout value to be used.
    private func calculateTimeout(apiTimeout: TimeInterval?) -> TimeInterval {
        /// Fetch the timeout value from the shared state.
        var configTimeout: TimeInterval?
        if let sharedState = getSharedState(extensionName: OptimizeConstants.CONFIGURATION_NAME, event: nil)?.value,
           let timeout = sharedState[OptimizeConstants.Configuration.OPTIMIZE_TIMEOUT_VALUE] as? Int {
            configTimeout = TimeInterval(timeout)
        }
        guard let apiTimeout, apiTimeout != Double.infinity else {
            return configTimeout ?? OptimizeConstants.DEFAULT_TIMEOUT
        }
        return apiTimeout
    }

    #if DEBUG
        /// For testing purposes only
        func setUpdateRequestEventIdsInProgress(_ eventId: String, expectedScopes: [DecisionScope]) {
            updateRequestEventIdsInProgress[eventId] = expectedScopes
        }

        /// For testing purposes only
        func getUpdateRequestEventIdsInProgress() -> [String: [DecisionScope]] {
            updateRequestEventIdsInProgress
        }

        /// For testing purposes only
        func setPropositionsInProgress(_ propositions: [DecisionScope: OptimizeProposition]) {
            propositionsInProgress = propositions
        }

        /// For testing purposes only
        func getPropositionsInProgress() -> [DecisionScope: OptimizeProposition] {
            propositionsInProgress
        }
    #endif
}
