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

@objc
public extension Personalization {
    /// This API dispatches an Event for the Edge network extension to fetch decision propositions for the provided decision scopes from the Decisioning Services enabled behind Experience Edge.
    ///
    /// The returned decision propositions are cached in memory in the personalization SDK extension and can be retrieved using `getPropositions(for:_:)` API.
    /// - Parameter decisionScopes: An array of decision scopes.
    /// - Parameter experienceData: Additional experience data to be sent in the personalization request.
    @objc(updatePropositionsFor:withXdm:)
    static func updatePropositions(for decisionScopes: [DecisionScope], with experienceData: ExperienceData? = nil) {
        let flattenedDecisionScopes = decisionScopes
            .filter { $0.isValid }
            .compactMap { $0.asDictionary() }

        guard !flattenedDecisionScopes.isEmpty else {
            Log.warning(label: PersonalizationConstants.LOG_TAG,
                        "Cannot update propositions, provided decision scopes array is empty or has invalid items.")
            return
        }

        var eventData: [String: Any] = [
            PersonalizationConstants.EventDataKeys.REQUEST_TYPE: PersonalizationConstants.EventDataValues.REQUEST_TYPE_UPDATE,
            PersonalizationConstants.EventDataKeys.DECISION_SCOPES: flattenedDecisionScopes
        ]

        if let experienceData = experienceData?.asDictionary() {
            eventData.merge(experienceData) { old, _ in old }
        }

        let event = Event(name: PersonalizationConstants.EventNames.UPDATE_PROPOSITIONS_REQUEST,
                          type: EventType.offerDecisioning,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event)
    }

    /// This API retrieves the previously fetched decisions for the provided decision scopes from the in-memory extension cache.
    ///
    /// The completion handler will be invoked with the decision propositions corresponding to the given decision scopes. If a certain decision scope has not already been fetched prior to this API call, it will not be contained in the returned propositions.
    /// - Parameters:
    ///   - decisionScopes: An array of decision scopes.
    ///   - completion: The completion handler to be invoked when the decisions are retrieved from cache.
    @objc(getPropositionsFor:completion:)
    static func getPropositions(for decisionScopes: [DecisionScope], _ completion: @escaping ([DecisionScope: Proposition]?, Error?) -> Void) {
        let flattenedDecisionScopes = decisionScopes
            .filter { $0.isValid }
            .compactMap { $0.asDictionary() }

        guard !flattenedDecisionScopes.isEmpty else {
            completion(nil, AEPError.invalidRequest)
            Log.warning(label: PersonalizationConstants.LOG_TAG,
                        "Cannot get propositions, provided decision scopes array is empty or has invalid items.")
            return
        }

        let eventData: [String: Any] = [
            PersonalizationConstants.EventDataKeys.REQUEST_TYPE: PersonalizationConstants.EventDataValues.REQUEST_TYPE_GET,
            PersonalizationConstants.EventDataKeys.DECISION_SCOPES: flattenedDecisionScopes
        ]

        let event = Event(name: PersonalizationConstants.EventNames.GET_PROPOSITIONS_REQUEST,
                          type: EventType.offerDecisioning,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event) { responseEvent in
            guard let responseEvent = responseEvent else {
                completion(nil, AEPError.callbackTimeout)
                return
            }

            if let error = responseEvent.data?[PersonalizationConstants.EventDataKeys.RESPONSE_ERROR] as? AEPError {
                completion(nil, error)
                return
            }

            guard let propositions: [Proposition] = responseEvent.getTypedData(for: PersonalizationConstants.EventDataKeys.PROPOSITIONS) else {
                completion(nil, AEPError.unexpected)
                return
            }
            completion(propositions.toDictionary { DecisionScope(name: $0.scope) }, .none)
        }
    }

    /// This API registers a permanent callback which will be invoked whenever the Edge extension dispatches an Event handle,
    /// upon a personalization decisions response from the Experience Edge Network.
    ///
    /// The personalization query requests can be triggered by the `updatePropositions(for:with:)` API,
    /// Edge extension `sendEvent(experienceEvent:_:)` API or launch rules consequence.
    ///
    /// - Parameter completion: The completion handler to be invoked with the decision propositions.
    @objc(onPropositionsUpdate:)
    static func onPropositionsUpdate(perform action: @escaping ([DecisionScope: Proposition]?) -> Void) {
        MobileCore.registerEventListener(type: EventType.offerDecisioning,
                                         source: EventSource.notification) { event in

            guard
                let propositions: [DecisionScope: Proposition] = event.getTypedData(for: PersonalizationConstants.EventDataKeys.PROPOSITIONS),
                !propositions.isEmpty
            else {
                Log.warning(label: PersonalizationConstants.LOG_TAG, "No valid propositions found in the notification event.")
                return
            }

            action(propositions)
        }
    }

    /// This API clears the in-memory propositions cache.
    @objc(clearCachedPropositions)
    static func clearCachedPropositions() {
        let event = Event(name: PersonalizationConstants.EventNames.CLEAR_PROPOSITIONS_REQUEST,
                          type: EventType.offerDecisioning,
                          source: EventSource.requestReset,
                          data: nil)

        MobileCore.dispatch(event: event)
    }
}
