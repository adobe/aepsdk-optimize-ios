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

@objc(AEPMobileEdgePersonalization)
public class Personalization: NSObject, Extension {
    // MARK: Extension

    public let name = PersonalizationConstants.EXTENSION_NAME
    public let friendlyName = PersonalizationConstants.FRIENDLY_NAME
    public static let extensionVersion = PersonalizationConstants.EXTENSION_VERSION
    public let metadata: [String: String]? = nil
    public let runtime: ExtensionRuntime

    public required init?(runtime: ExtensionRuntime) {
        self.runtime = runtime
        super.init()
    }

    public func onRegistered() {
        registerListener(type: EventType.offerDecisioning, source: EventSource.requestContent, listener: updatePropositions(event:))
    }

    public func onUnregistered() {}

    public func readyForEvent(_ event: Event) -> Bool {
        if event.source == EventSource.requestContent {
            return getSharedState(extensionName: PersonalizationConstants.Configuration.EXTENSION_NAME, event: event)?.value != nil
        }
        return true
    }

    // MARK: Event Listeners

    /// Processes the update propositions request event, dispatched with type `EventType.offerDecisioning` and source `EventSource.requestContent`.
    ///
    /// It dispatches an event to the Edge extension to send personalization query request to the Experience Edge network.
    /// - Parameter event: Update propositions request event
    private func updatePropositions(event: Event) {
        guard let decisionScopes = event.data?[PersonalizationConstants.EventDataKeys.DECISION_SCOPES] as? [[String: Any]],
              !decisionScopes.isEmpty
        else {
            Log.debug(label: PersonalizationConstants.LOG_TAG, "Decision scopes, in event data, is either not present or empty.")
            return
        }

        let targetDecisionScopes = decisionScopes.compactMap { $0[PersonalizationConstants.DECISION_SCOPE_NAME] as? String }
        if targetDecisionScopes.isEmpty {
            Log.debug(label: PersonalizationConstants.LOG_TAG, "No valid decision scopes found for the Edge personalization request!")
            return
        }

        var eventData: [String: Any] = [:]

        // Add query
        eventData[PersonalizationConstants.JsonKeys.XDM_QUERY] = [
            PersonalizationConstants.JsonKeys.QUERY_PERSONALIZATION: [
                PersonalizationConstants.JsonKeys.DECISION_SCOPES: targetDecisionScopes
            ]
        ]

        // Add xdm
        var xdmData: [String: Any] = [
            PersonalizationConstants.JsonKeys.XDM_EVENT_TYPE: PersonalizationConstants.JsonValues.XDM_EVENT_TYPE_PERSONALIZATION
        ]
        if let additionalXdmData = event.data?[PersonalizationConstants.EventDataKeys.XDM] as? [String: Any] {
            xdmData.merge(additionalXdmData) { old, _ in old }
        }
        eventData[PersonalizationConstants.JsonKeys.XDM] = xdmData

        // Add data
        if let data = event.data?[PersonalizationConstants.EventDataKeys.DATA] as? [String: Any] {
            eventData[PersonalizationConstants.JsonKeys.DATA] = data
        }

        // Add datasetId
        if let datasetId = event.data?[PersonalizationConstants.EventDataKeys.DATASET_ID] as? String {
            eventData[PersonalizationConstants.JsonKeys.DATASET_ID] = datasetId
        }

        let event = Event(name: PersonalizationConstants.EventNames.EDGE_PERSONALIZATION_REQUEST,
                          type: EventType.edge,
                          source: EventSource.requestContent,
                          data: eventData)
        dispatch(event: event)
    }
}
