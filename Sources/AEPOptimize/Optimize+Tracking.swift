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

@objc
public extension Optimize {
    /// This API dispatches an event for the Edge extension to send an Experience Event to the Edge network with the display interaction data for list of offers passed.
    ///
    /// - Parameter offers: An array of offer.
    @objc(displayed:)
    static func displayed(for offers: [Offer]) {
        guard !offers.isEmpty else { return }

        // Generate XDM data and track
        if let xdmData = OptimizeTrackingUtils.generateInteractionXdm(
            for: OptimizeTrackingUtils.mapToUniquePropositions(offers),
            for: OptimizeConstants.JsonValues.EE_EVENT_TYPE_PROPOSITION_DISPLAY
        ) {
            OptimizeTrackingUtils.trackWithData(xdmData)
        }
    }

    /// This API returns a dictionary containing XDM formatted data for `Experience Event - Proposition Interactions` field group for the list of offers
    ///
    /// The Edge `sendEvent(experienceEvent:_:)` API can be used to dispatch this data in an Experience Event along with any additional XDM, free-form data, or override dataset identifier.
    ///
    /// - Parameter offers: An array of offer.
    /// - Note: The returned XDM data also contains the `eventType` for the Experience Event with value `decisioning.propositionInteract`.
    /// - Returns A dictionary containing XDM data for the propositon interactions.
    /// - SeeAlso: `interactionXdm(for:)`
    @objc(generateDisplayInteractionXdm:)
    static func generateDisplayInteractionXdm(for offers: [Offer]) -> [String: Any]? {
        guard !offers.isEmpty else { return nil }

        return OptimizeTrackingUtils.generateInteractionXdm(
            for: OptimizeTrackingUtils.mapToUniquePropositions(offers),
            for: OptimizeConstants.JsonValues.EE_EVENT_TYPE_PROPOSITION_DISPLAY
        )
    }
}
