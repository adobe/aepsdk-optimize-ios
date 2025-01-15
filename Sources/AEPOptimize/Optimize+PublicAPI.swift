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
public extension Optimize {
    /// This API dispatches an Event for the Edge network extension to fetch decision propositions for the provided decision scopes from the decisioning Services enabled behind Experience Edge.
    ///
    /// The returned decision propositions are cached in memory in the Optimize SDK extension and can be retrieved using `getPropositions(for:_:)` API.
    /// - Parameter decisionScopes: An array of decision scopes.
    /// - Parameter xdm: Additional XDM-formatted data to be sent in the personalization request.
    /// - Parameter data: Additional free-form data to be sent in the personalization request.
    @available(*, deprecated, message: "This API is deprecated. Use `updatePropositions(for:withXdm:andData:completion:)` instead.")
    @objc(updatePropositions:withXdm:andData:)
    static func updatePropositions(for decisionScopes: [DecisionScope], withXdm xdm: [String: Any]?, andData data: [String: Any]? = nil) {
        updatePropositions(for: decisionScopes, withXdm: xdm, andData: data, nil)
    }

    /// This API dispatches an Event for the Edge network extension to fetch decision propositions for the provided decision scopes from the decisioning Services enabled behind Experience Edge.
    ///
    /// The returned decision propositions are cached in memory in the Optimize SDK extension and can be retrieved using `getPropositions(for:_:)` API.
    /// - Parameter decisionScopes: An array of decision scopes.
    /// - Parameter xdm: Additional XDM-formatted data to be sent in the personalization request.
    /// - Parameter data: Additional free-form data to be sent in the personalization request.
    /// - Parameter completion: Optional completion handler invoked with map of successful decision scopes to propositions and errors, if any
    @objc(updatePropositions:withXdm:andData:completion:)
    static func updatePropositions(for decisionScopes: [DecisionScope], withXdm xdm: [String: Any]?, andData data: [String: Any]? = nil, _ completion: (([DecisionScope: OptimizeProposition]?, Error?) -> Void)? = nil) {
        updatePropositions(for: decisionScopes, withXdm: xdm, andData: data, timeout: OptimizeConstants.DEFAULT_TIMEOUT, completion)
    }

    /// This API dispatches an Event for the Edge network extension to fetch decision propositions for the provided decision scopes from the decisioning Services enabled behind Experience Edge.
    ///
    /// The returned decision propositions are cached in memory in the Optimize SDK extension and can be retrieved using `getPropositions(for:_:)` API.
    /// - Parameter decisionScopes: An array of decision scopes.
    /// - Parameter xdm: Additional XDM-formatted data to be sent in the personalization request.
    /// - Parameter data: Additional free-form data to be sent in the personalization request.
    /// - Parameter timeout: Timeout for the event.
    /// - Parameter completion: Optional completion handler invoked with map of successful decision scopes to propositions and errors, if any
    @objc(updatePropositions:withXdm:timeout:andData:completion:)
    static func updatePropositions(for decisionScopes: [DecisionScope], withXdm xdm: [String: Any]?, andData data: [String: Any]? = nil, timeout: TimeInterval, _ completion: (([DecisionScope: OptimizeProposition]?, Error?) -> Void)? = nil) {
        let flattenedDecisionScopes = decisionScopes
            .filter { $0.isValid }
            .compactMap { $0.asDictionary() }

        guard !flattenedDecisionScopes.isEmpty else {
            Log.warning(label: OptimizeConstants.LOG_TAG,
                        "Cannot update propositions, provided decision scopes array is empty or has invalid items.")
            let aepOptimizeError = AEPOptimizeError.createAEPOptimizInvalidRequestError()
            completion?(nil, aepOptimizeError)
            return
        }

        var eventData: [String: Any] = [
            OptimizeConstants.EventDataKeys.REQUEST_TYPE: OptimizeConstants.EventDataValues.REQUEST_TYPE_UPDATE,
            OptimizeConstants.EventDataKeys.DECISION_SCOPES: flattenedDecisionScopes
        ]
        // Add XDM data
        if let xdm = xdm {
            eventData[OptimizeConstants.EventDataKeys.XDM] = xdm
        }

        // Add free-form data
        if let data = data {
            eventData[OptimizeConstants.EventDataKeys.DATA] = data
        }

        eventData[OptimizeConstants.EventDataKeys.TIMEOUT] = timeout
        let event = Event(name: OptimizeConstants.EventNames.UPDATE_PROPOSITIONS_REQUEST,
                          type: EventType.optimize,
                          source: EventSource.requestContent,
                          data: eventData)
        MobileCore.dispatch(event: event, timeout: timeout) { responseEvent in
            guard let responseEvent = responseEvent else {
                let timeoutError = AEPOptimizeError.createAEPOptimizeTimeoutError()
                completion?(nil, timeoutError)
                return
            }
            let result = responseEvent.data?[OptimizeConstants.EventDataKeys.PROPOSITIONS] as? [DecisionScope: OptimizeProposition]
            let error = responseEvent.data?[OptimizeConstants.EventDataKeys.RESPONSE_ERROR] as? AEPOptimizeError
            completion?(result, error)
        }
    }

    /// This API retrieves the previously fetched decisions for the provided decision scopes from the in-memory extension cache.
    ///
    /// The completion handler will be invoked with the decision propositions corresponding to the given decision scopes. If a certain decision scope has not already been fetched prior to this API call, it will not be contained in the returned propositions.
    /// - Parameters:
    ///   - decisionScopes: An array of decision scopes.
    ///   - completion: The completion handler to be invoked when the decisions are retrieved from cache.
    @objc(getPropositions:completion:)
    static func getPropositions(for decisionScopes: [DecisionScope], _ completion: @escaping ([DecisionScope: OptimizeProposition]?, Error?) -> Void) {
        getPropositions(for: decisionScopes, timeout: OptimizeConstants.DEFAULT_TIMEOUT, completion)
    }

    /// This API retrieves the previously fetched decisions for the provided decision scopes from the in-memory extension cache.
    ///
    /// The completion handler will be invoked with the decision propositions corresponding to the given decision scopes. If a certain decision scope has not already been fetched prior to this API call, it will not be contained in the returned propositions.
    /// - Parameters:
    ///   - decisionScopes: An array of decision scopes.
    ///   - timeout: Timeout for the event.
    ///   - completion: The completion handler to be invoked when the decisions are retrieved from cache.
    @objc(getPropositions:timeout:completion:)
    static func getPropositions(for decisionScopes: [DecisionScope], timeout: TimeInterval, _ completion: @escaping ([DecisionScope: OptimizeProposition]?, Error?) -> Void) {
        let flattenedDecisionScopes = decisionScopes
            .filter { $0.isValid }
            .compactMap { $0.asDictionary() }

        guard !flattenedDecisionScopes.isEmpty else {
            completion(nil, AEPError.invalidRequest)
            Log.warning(label: OptimizeConstants.LOG_TAG,
                        "Cannot get propositions, provided decision scopes array is empty or has invalid items.")
            return
        }

        let eventData: [String: Any] = [
            OptimizeConstants.EventDataKeys.REQUEST_TYPE: OptimizeConstants.EventDataValues.REQUEST_TYPE_GET,
            OptimizeConstants.EventDataKeys.DECISION_SCOPES: flattenedDecisionScopes
        ]

        let event = Event(name: OptimizeConstants.EventNames.GET_PROPOSITIONS_REQUEST,
                          type: EventType.optimize,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event, timeout: timeout) { responseEvent in
            guard let responseEvent = responseEvent else {
                completion(nil, AEPError.callbackTimeout)
                return
            }

            if let error = responseEvent.data?[OptimizeConstants.EventDataKeys.RESPONSE_ERROR] as? AEPOptimizeError {
                completion(nil, error.aepError)
                return
            }

            guard
                let propositions: [DecisionScope: OptimizeProposition] = responseEvent.getTypedData(for: OptimizeConstants.EventDataKeys.PROPOSITIONS)
            else {
                completion(nil, AEPError.unexpected)
                return
            }
            completion(propositions, .none)
        }
    }

    /// This API registers a permanent callback which will be invoked whenever the Edge extension dispatches an Event handle,
    /// upon a personalization decisions response from the Experience Edge Network.
    ///
    /// The personalization query requests can be triggered by the `updatePropositions(for:withXdm:andData:)` API,
    /// Edge extension `sendEvent(experienceEvent:_:)` API or launch rules consequence.
    ///
    /// - Parameter action: The completion handler to be invoked with the decision propositions.
    @objc(onPropositionsUpdate:)
    static func onPropositionsUpdate(perform action: @escaping ([DecisionScope: OptimizeProposition]) -> Void) {
        MobileCore.registerEventListener(type: EventType.optimize, source: EventSource.notification) { event in
            guard
                let propositions: [DecisionScope: OptimizeProposition] = event.getTypedData(for: OptimizeConstants.EventDataKeys.PROPOSITIONS),
                !propositions.isEmpty
            else {
                Log.warning(label: OptimizeConstants.LOG_TAG, "No valid propositions found in the notification event.")
                return
            }

            action(propositions)
        }
    }

    /// This API clears the in-memory propositions cache.
    @objc(clearCachedPropositions)
    static func clearCachedPropositions() {
        let event = Event(name: OptimizeConstants.EventNames.CLEAR_PROPOSITIONS_REQUEST,
                          type: EventType.optimize,
                          source: EventSource.requestReset,
                          data: nil)

        MobileCore.dispatch(event: event)
    }
}
