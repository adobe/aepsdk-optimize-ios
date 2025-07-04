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

/// `OptimizeProposition` class
@objc(AEPOptimizeProposition)
public class OptimizeProposition: NSObject, Codable {
    private let items: [Offer]

    /// Unique proposition identifier
    @objc public let id: String

    /// Array containing proposition decision options
    @objc public lazy var offers: [Offer] = {
        for item in items {
            item.proposition = self
        }
        return items
    }()

    /// Decision scope string
    @objc public let scope: String

    /// Scope details dictionary
    @objc public var scopeDetails: [String: Any]

    /// Scope details dictionary
    @objc public var activity: [String: Any]

    /// Scope details dictionary
    @objc public var placement: [String: Any]

    enum CodingKeys: String, CodingKey {
        case id
        case items
        case scope
        case scopeDetails
        case activity
        case placement
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        scope = try container.decode(String.self, forKey: .scope)
        let scopeDetailsCodableDict = try? container.decode([String: AnyCodable].self, forKey: .scopeDetails)
        // Fix this once ODE supports scopeDetails in personalization query response,
        // refer to https://jira.corp.adobe.com/browse/CSMO-12405
        scopeDetails = AnyCodable.toAnyDictionary(dictionary: scopeDetailsCodableDict) ?? [:]
        let activityCodableDict = try? container.decode([String: AnyCodable].self, forKey: .activity)
        activity = AnyCodable.toAnyDictionary(dictionary: activityCodableDict) ?? [:]
        let placementCodableDict = try? container.decode([String: AnyCodable].self, forKey: .placement)
        placement = AnyCodable.toAnyDictionary(dictionary: placementCodableDict) ?? [:]
        items = (try? container.decode([Offer].self, forKey: .items, ignoreInvalid: true)) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(scope, forKey: .scope)
        try container.encode(AnyCodable.from(dictionary: scopeDetails), forKey: .scopeDetails)
        try container.encode(AnyCodable.from(dictionary: activity), forKey: .activity)
        try container.encode(AnyCodable.from(dictionary: placement), forKey: .placement)
        try container.encode(offers, forKey: .items)
    }

    /// Creates Object of `Proposition` type from given data dictionary.
    /// - Parameters:
    ///       - data: A dictionary containing data for instantiating `Proposition`
    /// - Returns: instance of `Proposition`
    @objc
    public static func initFromData(_ data: [String: Any]) -> OptimizeProposition? {
        guard !data.isEmpty else {
            Log.warning(label: OptimizeConstants.LOG_TAG, "Cannot create Proposition object, provided data dictionary is empty.")
            return nil
        }
        guard
            let jsonData = try? JSONSerialization.data(withJSONObject: data),
            let proposition = try? JSONDecoder().decode(OptimizeProposition.self, from: jsonData)
        else {
            Log.warning(label: OptimizeConstants.LOG_TAG,
                        "Cannot create Proposition object, unable to serialize dictionary to JSON data or decode Proposition from JSON.")
            return nil
        }

        return proposition
    }
}
