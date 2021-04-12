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

import AEPServices
import Foundation

/// `DecisionScope` class is used to create decision scopes for personalization requests to Experience Edge Network.
@objc(AEPDecisionScope)
public class DecisionScope: NSObject, Codable {
    /// Decision scope name
    @objc public let name: String

    /// Creates a new decision scope using the given scope `name`.
    ///
    /// - Parameter name: string representation for the decision scope.
    @objc
    public init(name: String) {
        self.name = name
    }

    /// Creates a new decision scope using the given `activityId`, `placementId` and `itemCount`.
    ///
    /// This initializer creates a scope name by Base64 encoding the JSON string created using the provided data.
    ///
    /// If `itemCount` > 1, JSON string is
    ///
    ///     {"activityId":#activityId,"placementId":#placementId,"itemCount":#itemCount}
    /// otherwise,
    ///
    ///     {"activityId":#activityId,"placementId":#placementId}
    /// - Parameters:
    ///   - activityId: unique activity identifier for the decisioning activity.
    ///   - placementId: unique placement identifier for the decisioning activity offer.
    ///   - itemCount: number of offers to be returned from the server.
    @objc
    public convenience init(activityId: String, placementId: String, itemCount: UInt = 1) {
        let name = "\(activityId: activityId, placementId: placementId, itemCount: itemCount)".base64Encode()

        self.init(name: name ?? "")
    }

    /// Checks whether the decision scope has a valid name.
    var isValid: Bool {
        if name.isEmpty {
            Log.debug(label: PersonalizationConstants.LOG_TAG, "Invalid scope! Scope name is empty.")
            return false
        }

        if let decodedName = name.base64Decode() {
            guard
                let decodedData = decodedName.data(using: .utf8),
                let dictionary = try? JSONSerialization.jsonObject(with: decodedData) as? [String: Any]
            else {
                Log.debug(label: PersonalizationConstants.LOG_TAG, "Failed to decode data for scope \(name).")
                return false
            }

            guard let activityId = dictionary[PersonalizationConstants.ACTIVITY_ID] as? String,
                  !activityId.isEmpty
            else {
                Log.debug(label: PersonalizationConstants.LOG_TAG, "Invalid scope \(name)! Activity Id is nil or empty.")
                return false
            }

            guard let placementId = dictionary[PersonalizationConstants.PLACEMENT_ID] as? String,
                  !placementId.isEmpty
            else {
                Log.debug(label: PersonalizationConstants.LOG_TAG, "Invalid scope \(name)! Placement Id is nil or empty.")
                return false
            }

            let itemCount = dictionary[PersonalizationConstants.ITEM_COUNT] as? Int ?? 1
            if itemCount == 0 {
                Log.debug(label: PersonalizationConstants.LOG_TAG, "Invalid scope \(name)! itemCount is 0.")
                return false
            }
        }
        Log.trace(label: PersonalizationConstants.LOG_TAG, "Decision scope is valid.")
        return true
    }
}
