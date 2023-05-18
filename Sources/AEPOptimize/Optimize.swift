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

    private var personalizationRequestEventId: String = ""

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
        OptimizeConstants.JsonValues.SCHEMA_OFFER_TEXT,
        
        OptimizeConstants.JsonValues.SCHEMA_AJO_DECISION
    ]

    /// Dictionary containing decision propositions currently cached in-memory in the SDK.
    #if DEBUG
        var cachedPropositions: [String: Proposition]
    #else
        private(set) var cachedPropositions: [String: Proposition]
    #endif

    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        cachedPropositions = [:]
        super.init()
    }

    public func onRegistered() {
        registerListener(type: EventType.optimize, source: EventSource.requestContent) { event in
            guard let requestType = event.data?[OptimizeConstants.EventDataKeys.REQUEST_TYPE] as? String else {
                Log.warning(label: OptimizeConstants.LOG_TAG, "Ignoring event! Cannot determine the type of request event.")
                return
            }
            if requestType == OptimizeConstants.EventDataValues.REQUEST_TYPE_UPDATE {
                self.processUpdatePropositions(event: event)
            } else if requestType == OptimizeConstants.EventDataValues.REQUEST_TYPE_GET {
                self.processGetPropositions(event: event)
            } else if requestType == OptimizeConstants.EventDataValues.REQUEST_TYPE_TRACK {
                self.processTrackPropositions(event: event)
            }
        }

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
    }

    public func onUnregistered() {}

    public func readyForEvent(_ event: Event) -> Bool {
        if event.source == EventSource.requestContent {
            return getSharedState(extensionName: OptimizeConstants.Configuration.EXTENSION_NAME, event: event)?.value != nil
        }
        return true
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

        var validDecisionScopes = [String]()
        var validSurfaces = [String]()
        if
            let decisionScopes: [DecisionScope] = event.getTypedData(for: OptimizeConstants.EventDataKeys.DECISION_SCOPES),
            !decisionScopes.isEmpty
        {
            validDecisionScopes = decisionScopes
                .filter { $0.isValid }
                .compactMap { $0.name }

            if validDecisionScopes.isEmpty {
                Log.debug(label: OptimizeConstants.LOG_TAG, "No valid decision scopes found for the Edge personalization request!")
                return
            }
        } else if
            let surfacePaths: [String] = event.getTypedData(for: OptimizeConstants.EventDataKeys.SURFACES),
            !surfacePaths.isEmpty
        {
            validSurfaces = surfacePaths
                .map { $0.prefixedSurface(Bundle.main.mobileappSurface) }
                .filter { $0.isValidSurface() }

            if validSurfaces.isEmpty {
                Log.debug(label: OptimizeConstants.LOG_TAG, "No valid surfaces found for the Edge personalization request!")
                return
            }
        } else {
            Log.debug(label: OptimizeConstants.LOG_TAG, """
                      Cannot process the update propositions request event, \
                      surfaces or decision scopes in the event data are either not present or empty.
            """)
            return
        }

        var eventData: [String: Any] = [:]

        // Add query
        eventData[OptimizeConstants.JsonKeys.QUERY] = [
            OptimizeConstants.JsonKeys.QUERY_PERSONALIZATION: [
                OptimizeConstants.JsonKeys.SCHEMAS: Optimize.supportedSchemas,
                OptimizeConstants.JsonKeys.DECISION_SCOPES: validDecisionScopes,
                OptimizeConstants.JsonKeys.SURFACES: validSurfaces
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

        // Add override datasetId
        if let datasetId = configSharedState[OptimizeConstants.Configuration.OPTIMIZE_OVERRIDE_DATASET_ID] as? String {
            eventData[OptimizeConstants.JsonKeys.DATASET_ID] = datasetId
        }

        let event = Event(name: OptimizeConstants.EventNames.EDGE_PERSONALIZATION_REQUEST,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: eventData)

        // In AEP Response Event handle, `requestEventId` corresponds to the UUID for the Edge request.
        // Storing the request event UUID to compare and process only the anticipated response in the extension.
        personalizationRequestEventId = event.id.uuidString

        dispatch(event: event)
    }

    /// Processes the Edge response event, dispatched with type `EventType.edge` and source `personalization:decisions`.
    ///
    /// It dispatches a personalization notification event with the propositions received from the decisioning services configured behind
    /// Experience Edge network.
    /// - Parameter event: Edge response event.
    private func processEdgeResponse(event: Event) {
        guard event.isPersonalizationDecisionResponse,
              personalizationRequestEventId == event.requestEventId
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      """
                        Ignoring Edge response event, either response handle is not personalization:decisions, \
                      or the response is not for a request the extension issued.
                      """)
            return
        }

        guard let propositions: [Proposition] = event.getTypedData(for: OptimizeConstants.Edge.PAYLOAD),
              !propositions.isEmpty
        else {
            Log.debug(label: OptimizeConstants.LOG_TAG, "Failed to read Edge response, propositions array is invalid or empty.")
            return
        }

        let propositionsDict = propositions
            .filter { !$0.offers.isEmpty }
            .toDictionary { $0.scope }

        if propositionsDict.isEmpty {
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

        // Update propositions cache
        cachedPropositions.merge(propositionsDict) { _, new in new }

        let eventData = [OptimizeConstants.EventDataKeys.PROPOSITIONS: propositionsDict.map { $0.value }].asDictionary()

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
        let errorType = event.data?[OptimizeConstants.Edge.ErrorKeys.TYPE] as? String
        let errorDetail = event.data?[OptimizeConstants.Edge.ErrorKeys.DETAIL] as? String

        let errorString =
            """
            Decisioning Service error, type: \(errorType ?? OptimizeConstants.ERROR_UNKNOWN), \
            detail: \(errorDetail ?? OptimizeConstants.ERROR_UNKNOWN)"
            """

        Log.warning(label: OptimizeConstants.LOG_TAG, errorString)
    }

    /// Processes the get propositions request event, dispatched with type `EventType.optimize` and source `EventSource.requestContent`.
    ///
    ///  It returns previously cached propositions for the requested decision scopes. Any decision scope(s) not already present in the cache are ignored.
    /// - Parameter event: Get propositions request event
    private func processGetPropositions(event: Event) {
        var propositionsDict: [String: Proposition] = [:]
        if
            let decisionScopes: [DecisionScope] = event.getTypedData(for: OptimizeConstants.EventDataKeys.DECISION_SCOPES),
            !decisionScopes.isEmpty
        {
            propositionsDict = cachedPropositions.filter { decisionScopes.contains(DecisionScope(name: $0.key)) }
        } else if
            let surfacePaths: [String] = event.getTypedData(for: OptimizeConstants.EventDataKeys.SURFACES),
            !surfacePaths.isEmpty
        {
            for surfacePath in surfacePaths {
                let prefixedSurface = surfacePath.prefixedSurface(Bundle.main.mobileappSurface)
                if
                    prefixedSurface.isValidSurface(),
                    let cachedProposition = cachedPropositions[prefixedSurface]
                {
                    propositionsDict[surfacePath] = cachedProposition
                }
            }
        } else {
            Log.debug(label: OptimizeConstants.LOG_TAG, """
                Cannot process the get propositions request event,\
                decision scopes or surfaces in event data are either not present or empty.
            """)
            dispatch(event: event.createErrorResponseEvent(AEPError.invalidRequest))
            return
        }

        let eventData = [OptimizeConstants.EventDataKeys.PROPOSITIONS: propositionsDict.map { $0.value }].asDictionary()

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
    }

    #if DEBUG
        /// Used for testing purposes only
        internal func setPersonalizationRequestEventId(_ id: String) {
            personalizationRequestEventId = id
        }
    #endif
}
