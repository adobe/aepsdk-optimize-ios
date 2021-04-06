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
    /// This initializer returns `nil` if the provided scope `name` is empty.
    /// - Parameter name: string representation for the decision scope.
    @objc
    public init?(name: String) {
        if name.isEmpty {
            Log.debug(label: PersonalizationConstants.LOG_TAG, "DecisionScope init failed! Provided scope name is empty.")
            return nil
        }
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
    ///
    /// The initializer returns `nil` in the following cases:
    /// - `activityId` or `placementId` is empty.
    /// - `itemCount` is 0.
    /// - Base64 encode fails for the JSON string from the provided data.
    /// - Parameters:
    ///   - activityId: unique activity identifier for the decisioning activity.
    ///   - placementId: unique placement identifier for the decisioning activity offer.
    ///   - itemCount: number of offers to be returned from the server.
    @objc
    public convenience init?(activityId: String, placementId: String, itemCount: UInt = 1) {
        if activityId.isEmpty || placementId.isEmpty || itemCount == 0 {
            Log.debug(label: PersonalizationConstants.LOG_TAG,
                      "DecisionScope init failed! Provided activityId/ placementId is empty or itemCount is 0.")
            return nil
        }

        guard let name = "\(activityId: activityId, placementId: placementId, itemCount: itemCount)".base64Encode() else {
            Log.debug(label: PersonalizationConstants.LOG_TAG, "DecisionScope init failed! Unable to create Base64 encoded scope string.")
            return nil
        }

        self.init(name: name)
    }
}
