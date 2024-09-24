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

// MARK: Offer extension

@objc
public extension Offer {
    /// Creates a dictionary containing XDM formatted data for `Experience Event - Proposition Interactions` field group from the given proposition option.
    ///
    /// The Edge `sendEvent(experienceEvent:_:)` API can be used to dispatch this data in an Experience Event along with any additional XDM, free-form data, or override dataset identifier.
    /// If the proposition reference within the option is released and no longer valid, the method returns `nil`.
    ///
    /// - Note: The returned XDM data also contains the `eventType` for the Experience Event with value `decisioning.propositionDisplay`.
    /// - Returns A dictionary containing XDM data for the propositon interactions.
    /// - SeeAlso: `interactionXdm(for:)`
    func generateDisplayInteractionXdm() -> [String: Any]? {
        guard let proposition = proposition else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot send display proposition interaction event for option \(id), proposition reference is not available.")
            return nil
        }
        return Optimize.generateInteractionXdm(for: [proposition], for: OptimizeConstants.JsonValues.EE_EVENT_TYPE_PROPOSITION_DISPLAY)
    }

    /// Creates a dictionary containing XDM formatted data for `Experience Event - Proposition Interactions` field group from the given proposition option.
    ///
    /// The Edge `sendEvent(experienceEvent:_:)` API can be used to dispatch this data in an Experience Event along with any additional XDM, free-form data, or override dataset identifier.
    /// If the proposition reference within the option is released and no longer valid, the method returns `nil`.
    ///
    /// - Note: The returned XDM data also contains the `eventType` for the Experience Event with value `decisioning.propositionInteract`.
    /// - Returns A dictionary containing XDM data for the propositon interactions.
    /// - SeeAlso: `interactionXdm(for:)`
    func generateTapInteractionXdm() -> [String: Any]? {
        guard let proposition = proposition else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot send tap proposition interaction event for option \(id), proposition reference is not available.")
            return nil
        }
        return Optimize.generateInteractionXdm(for: [proposition], for: OptimizeConstants.JsonValues.EE_EVENT_TYPE_PROPOSITION_INTERACT)
    }

    /// Dispatches an event for the Edge extension to send an Experience Event to the Edge network with the display interaction data for the given proposition item.
    ///
    /// - SeeAlso: `trackWithData(_:)`
    func displayed() {
        Optimize.trackWithData(generateDisplayInteractionXdm())
    }

    /// Dispatches an event for the Edge extension to send an Experience Event to the Edge network with the tap interaction data for the given proposition item.
    ///
    /// - SeeAlso: `trackWithData(_:)`
    func tapped() {
        Optimize.trackWithData(generateTapInteractionXdm())
    }
}
