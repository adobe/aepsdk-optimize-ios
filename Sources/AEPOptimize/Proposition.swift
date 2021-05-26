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

import Foundation

/// `Proposition` class
@objc(AEPProposition)
public class Proposition: NSObject, Codable {
    /// Unique proposition identifier
    @objc public let id: String

    /// Array containing proposition decisions
    @objc public let offers: [Offer]

    /// Decision scope string
    @objc public let scope: String

    enum CodingKeys: String, CodingKey {
        case id
        case items
        case scope
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        scope = try container.decode(String.self, forKey: .scope)
        offers = try container.decode([Offer].self, forKey: .items)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(scope, forKey: .scope)
        try container.encode(offers, forKey: .items)
    }
}
