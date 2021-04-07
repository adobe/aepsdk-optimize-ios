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

/// `Offer` class
@objc(AEPOffer)
public class Offer: NSObject, Decodable {
    /// Unique Offer identifier
    @objc public let id: String

    /// Offer schema string
    @objc public let schema: String

    /// Offer type as represented in enum `OfferType`
    @objc public let type: OfferType

    /// Optional Offer language array
    @objc public let language: [String]?

    /// Offer content string
    @objc public let content: String

    /// Optional Offer characteristics dictionary
    @objc public let characteristics: [String: String]?

    enum CodingKeys: String, CodingKey {
        case id
        case schema
        case data
    }

    enum DataKeys: String, CodingKey {
        case format
        case language
        case content
        case deliveryURL
        case characteristics
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        schema = try container.decode(String.self, forKey: .schema)

        let nestedContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        let format = try nestedContainer.decodeIfPresent(String.self, forKey: .format)
        type = OfferType(from: format ?? "")
        language = try nestedContainer.decodeIfPresent([String].self, forKey: .language)
        characteristics = try nestedContainer.decodeIfPresent([String: String].self, forKey: .characteristics)

        guard let data = try? nestedContainer.decode(AnyCodable.self, forKey: .content) else {
            // For image type offer, deliveryURL contains the image link.
            content = try nestedContainer.decode(String.self, forKey: .deliveryURL)
            return
        }

        if let offerContent = data.stringValue {
            content = offerContent
            return
        }

        if
            let jsonData = data.dictionaryValue,
            let encodedData = try? JSONSerialization.data(withJSONObject: jsonData),
            let offerContent = String(data: encodedData, encoding: .utf8)
        {
            content = offerContent
            return
        }
        throw DecodingError.typeMismatch(Offer.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Offer content is not of an expected type."))
    }
}
