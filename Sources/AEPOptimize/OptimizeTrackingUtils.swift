/*
 Copyright 2024 Adobe. All rights reserved.
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

/// Internal helper enum for tracking functionality
enum OptimizeTrackingUtils {
    /// Creates a dictionary containing XDM formatted data for `Experience Event - Proposition Interactions` field group from the given list of propositions and for the provided event type.
    ///
    /// - Parameter propositions: An array of optimize propositions.
    /// - Parameter eventType: The Experience Event event type for the proposition interaction.
    /// - Returns: A dictionary containing XDM data for the proposition interactions.
    static func generateInteractionXdm(for propositions: [OptimizeProposition], for eventType: String) -> [String: Any]? {
        let propositionDetailsData: [[String: Any]] = propositions.map { proposition in
            [
                OptimizeConstants.JsonKeys.DECISIONING_PROPOSITIONS_ID: proposition.id,
                OptimizeConstants.JsonKeys.DECISIONING_PROPOSITIONS_SCOPE: proposition.scope,
                OptimizeConstants.JsonKeys.DECISIONING_PROPOSITIONS_SCOPEDETAILS: proposition.scopeDetails,
                OptimizeConstants.JsonKeys.DECISIONING_PROPOSITIONS_ITEMS: proposition.offers.map { offer in
                    [
                        OptimizeConstants.JsonKeys.DECISIONING_PROPOSITIONS_ITEMS_ID: offer.id
                    ]
                }
            ]
        }

        var propositionEventType: [String: Any] = [:]
        let propEventType = (eventType == OptimizeConstants.JsonValues.EE_EVENT_TYPE_PROPOSITION_DISPLAY) ?
            OptimizeConstants.JsonKeys.PROPOSITION_EVENT_TYPE_DISPLAY :
            OptimizeConstants.JsonKeys.PROPOSITION_EVENT_TYPE_INTERACT
        propositionEventType[propEventType] = 1

        let xdmData: [String: Any] = [
            OptimizeConstants.JsonKeys.EXPERIENCE_EVENT_TYPE: eventType,
            OptimizeConstants.JsonKeys.EXPERIENCE: [
                OptimizeConstants.JsonKeys.EXPERIENCE_DECISIONING: [
                    OptimizeConstants.JsonKeys.DECISIONING_PROPOSITION_EVENT_TYPE: propositionEventType,
                    OptimizeConstants.JsonKeys.DECISIONING_PROPOSITIONS: propositionDetailsData
                ]
            ]
        ]
        return xdmData
    }

    /// Dispatches the track propositions request event with type `EventType.optimize` and source `EventSource.requestContent` and given proposition interactions data.
    ///
    /// No event is dispatched if the input xdm data is `nil`.
    ///
    /// - Parameter xdmData: A dictionary containing XDM data for the proposition interactions.
    static func trackWithData(_ xdmData: [String: Any]?) {
        guard let xdmData = xdmData else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot send track propositions request event, the provided xdmData is nil.")
            return
        }

        let eventData: [String: Any] = [
            OptimizeConstants.EventDataKeys.REQUEST_TYPE: OptimizeConstants.EventDataValues.REQUEST_TYPE_TRACK,
            OptimizeConstants.EventDataKeys.PROPOSITION_INTERACTIONS: xdmData
        ]

        let event = Event(name: OptimizeConstants.EventNames.TRACK_PROPOSITIONS_REQUEST,
                          type: EventType.optimize,
                          source: EventSource.requestContent,
                          data: eventData)

        MobileCore.dispatch(event: event)
    }
}
