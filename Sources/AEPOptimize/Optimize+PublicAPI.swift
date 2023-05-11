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
    #if DEBUG
        /// Checks whether Optimize notification listener is registered with Mobile Core.
        static var isPropositionsListenerRegistered = false
    #else
        /// Checks whether Optimize notification listener is registered with Mobile Core.
        private static var isPropositionsListenerRegistered = false
    #endif

    /// This API dispatches an Event for the Edge network extension to fetch decision propositions for the provided decision scopes from the decisioning Services enabled behind Experience Edge.
    ///
    /// The returned decision propositions are cached in memory in the Optimize SDK extension and can be retrieved using `getPropositions(for:_:)` API.
    /// - Parameter decisionScopes: An array of decision scopes.
    /// - Parameter xdm: Additional XDM-formatted data to be sent in the personalization request.
    /// - Parameter data: Additional free-form data to be sent in the personalization request.
    @available(*, deprecated, message: "Use updatePropositions(for: [String], withXdm: [String: Any]?, andData: [String: Any]? = nil) instead")
    @objc(updatePropositions:withXdm:andData:)
    static func updatePropositions(for decisionScopes: [DecisionScope], withXdm xdm: [String: Any]?, andData data: [String: Any]? = nil) {
        let flattenedDecisionScopes = decisionScopes
            .filter { $0.isValid }
            .compactMap { $0.asDictionary() }

        guard !flattenedDecisionScopes.isEmpty else {
            Log.warning(label: OptimizeConstants.LOG_TAG,
                        "Cannot update propositions, provided decision scopes array is empty or has invalid items.")
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

        let event = Event(name: OptimizeConstants.EventNames.UPDATE_PROPOSITIONS_REQUEST,
                          type: EventType.optimize,
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
    @available(*, deprecated, message: "Use getPropositions(for: [String], _: @escaping ([String: Proposition]?, Error?) -> Void instead")
    @objc(getPropositions:completion:)
    static func getPropositions(for decisionScopes: [DecisionScope], _ completion: @escaping ([DecisionScope: Proposition]?, Error?) -> Void) {
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

        MobileCore.dispatch(event: event) { responseEvent in
            guard let responseEvent = responseEvent else {
                completion(nil, AEPError.callbackTimeout)
                return
            }

            if let error = responseEvent.data?[OptimizeConstants.EventDataKeys.RESPONSE_ERROR] as? AEPError {
                completion(nil, error)
                return
            }

            guard
                let propositions: [Proposition] = responseEvent.getTypedData(for: OptimizeConstants.EventDataKeys.PROPOSITIONS)
            else {
                completion(nil, AEPError.unexpected)
                return
            }
            completion(propositions.toDictionary { DecisionScope(name: $0.scope) }, .none)
        }
    }

    /// This API registers a permanent callback which will be invoked whenever the Edge extension dispatches an Event handle,
    /// upon a personalization decisions response from the Experience Edge Network.
    ///
    /// The personalization query requests can be triggered by the `updatePropositions(for:withXdm:andData:)` API.
    ///
    /// - Parameter action: The completion handler to be invoked with the decision propositions.
    @available(*, deprecated, message: "Use onPropositionsUpdate(perform: @escaping ([String: Proposition]) -> Void) instead")
    @objc(onPropositionsUpdate:)
    static func onPropositionsUpdate(perform action: @escaping ([DecisionScope: Proposition]) -> Void) {
        MobileCore.registerEventListener(type: EventType.optimize, source: EventSource.notification) { event in
            guard
                let propositions: [Proposition] = event.getTypedData(for: OptimizeConstants.EventDataKeys.PROPOSITIONS),
                !propositions.isEmpty
            else {
                Log.warning(label: OptimizeConstants.LOG_TAG, "No valid propositions found in the notification event.")
                return
            }

            action(propositions.toDictionary { DecisionScope(name: $0.scope) })
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

    // MARK: - Mobile Surface Support

    /// This API dispatches an Event for the Edge network extension to fetch decision propositions for the provided mobile surfaces from the decisioning services enabled behind Experience Edge.
    ///
    /// The returned decision propositions are cached in memory in the Optimize SDK extension and can be retrieved using `getPropositionsForSurfacePaths(_:_:)` API.
    /// - Parameter surfacePaths: An array of mobile surface paths.
    /// - Parameter xdm: Additional XDM-formatted data to be sent in the personalization request.
    /// - Parameter data: Additional free-form data to be sent in the personalization request.
    @objc(updatePropositionsForSurfacePaths:withXdm:andData:)
    static func updatePropositionsForSurfacePaths(_ surfacePaths: [String], withXdm xdm: [String: Any]?, andData data: [String: Any]? = nil) {
        let surfacePaths = surfacePaths
            .filter { !$0.isEmpty }

        guard !surfacePaths.isEmpty else {
            Log.warning(label: OptimizeConstants.LOG_TAG,
                        "Cannot update propositions, provided surfaces array is empty or has invalid items.")
            return
        }

        var eventData: [String: Any] = [
            OptimizeConstants.EventDataKeys.REQUEST_TYPE: OptimizeConstants.EventDataValues.REQUEST_TYPE_UPDATE,
            OptimizeConstants.EventDataKeys.SURFACES: surfacePaths
        ]

        // Add XDM data
        if let xdm = xdm {
            eventData[OptimizeConstants.EventDataKeys.XDM] = xdm
        }

        // Add free-form data
        if let data = data {
            eventData[OptimizeConstants.EventDataKeys.DATA] = data
        }

        let event = Event(name: OptimizeConstants.EventNames.UPDATE_PROPOSITIONS_REQUEST,
                          type: EventType.optimize,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event)
    }

    /// This API retrieves the previously fetched decisions for the provided mobile surfaces from the in-memory extension cache.
    ///
    /// The completion handler will be invoked with the decision propositions corresponding to the given surface strings. If a certain surface has not already been fetched prior to this API call, it will not be contained in the returned propositions.
    /// - Parameters:
    ///   - surfacePaths: An array of mobile surface paths.
    ///   - completion: The completion handler to be invoked when the decisions are retrieved from cache.
    @objc(getPropositionsForSurfacePaths:completion:)
    static func getPropositionsForSurfacePaths(_ surfacePaths: [String], _ completion: @escaping ([String: Proposition]?, Error?) -> Void) {
        let surfacePaths = surfacePaths
            .filter { !$0.isEmpty }

        guard !surfacePaths.isEmpty else {
            completion(nil, AEPError.invalidRequest)
            Log.warning(label: OptimizeConstants.LOG_TAG,
                        "Cannot get propositions, provided surfaces array is empty or has invalid items.")
            return
        }

        let eventData: [String: Any] = [
            OptimizeConstants.EventDataKeys.REQUEST_TYPE: OptimizeConstants.EventDataValues.REQUEST_TYPE_GET,
            OptimizeConstants.EventDataKeys.SURFACES: surfacePaths
        ]

        let event = Event(name: OptimizeConstants.EventNames.GET_PROPOSITIONS_REQUEST,
                          type: EventType.optimize,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event) { responseEvent in
            guard let responseEvent = responseEvent else {
                completion(nil, AEPError.callbackTimeout)
                return
            }

            if let error = responseEvent.data?[OptimizeConstants.EventDataKeys.RESPONSE_ERROR] as? AEPError {
                completion(nil, error)
                return
            }

            guard
                let propositions: [Proposition] = responseEvent.getTypedData(for: OptimizeConstants.EventDataKeys.PROPOSITIONS)
            else {
                completion(nil, AEPError.unexpected)
                return
            }

            completion(propositions.toDictionary { retrieveSurfacePathFromScope($0.scope) }, .none)
        }
    }

    /// This API registers a permanent callback which will be invoked whenever the Edge extension dispatches an Event handle,
    /// upon a personalization decisions response from the Experience Edge Network.
    ///
    /// The personalization query requests can be triggered by the `updatePropositionsForSurfacePaths(_:withXdm:andData:)` API.
    ///
    /// - Parameter completion: The completion handler to be invoked with the decision propositions.
    @objc(setPropositonsHandler:)
    static func setPropositionsHandler(_ completion: @escaping ([String: Proposition]) -> Void) {
        if !isPropositionsListenerRegistered {
            MobileCore.registerEventListener(type: EventType.optimize, source: EventSource.notification) { event in
                guard
                    let propositions: [Proposition] = event.getTypedData(for: OptimizeConstants.EventDataKeys.PROPOSITIONS),
                    !propositions.isEmpty
                else {
                    Log.warning(label: OptimizeConstants.LOG_TAG, "No valid propositions found in the notification event.")
                    return
                }

                completion(propositions.toDictionary { retrieveSurfacePathFromScope($0.scope) })
            }
            isPropositionsListenerRegistered = true
        }
    }

    /// Retrieves surface path from the provided scope string.
    ///
    /// - Parameter scope: A string containing the surface URI to extract surface path from.
    private static func retrieveSurfacePathFromScope(_ scope: String) -> String {
        if scope.isEmpty {
            return scope
        }

        let pathPrefix = Bundle.main.mobileappSurface
        if scope.hasPrefix(pathPrefix) {
            return String(scope.dropFirst(pathPrefix.count + 1))
        }
        return scope
    }
}
