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
public class Offer: NSObject, Codable {
    /// Unique Offer identifier
    @objc public let id: String

    /// Offer revision detail at the time of the request
    @objc public let etag: String

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

    /// Weak reference to Proposition instance
    @objc weak var proposition: Proposition?

    enum CodingKeys: String, CodingKey {
        case id
        case etag
        case schema
        case data
    }

    enum DataKeys: String, CodingKey {
        case id
        case format
        case type
        case language
        case content
        case deliveryURL
        case characteristics
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)

        // Try and decode format, if present. Target response doesn't contain etag, so setting the default value to empty string.
        etag = try container.decodeIfPresent(String.self, forKey: .etag) ?? ""

        schema = try container.decode(String.self, forKey: .schema)

        let nestedContainer = try container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        let nestedId = try nestedContainer.decode(String.self, forKey: .id)

        if nestedId != id {
            throw DecodingError.dataCorruptedError(forKey: DataKeys.id, in: nestedContainer, debugDescription: "Data id should be same as items id.")
        }

        // Try and decode format, if present, usually in Edge response. Optimize extension parses format into a public
        // enum for customers to easily identify how to parse the decision content. Thereon, type field is encoded in EventData
        // for events dispatched by this extension indicating the type of content.
        if let format = try nestedContainer.decodeIfPresent(String.self, forKey: .format) {
            type = OfferType(from: format)
        } else {
            type = try nestedContainer.decodeIfPresent(OfferType.self, forKey: .type) ?? .unknown
        }

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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(etag, forKey: .etag)
        try container.encode(schema, forKey: .schema)

        var data = container.nestedContainer(keyedBy: DataKeys.self, forKey: .data)
        try data.encode(id, forKey: .id)
        try data.encode(type, forKey: .type)
        try data.encode(language, forKey: .language)
        try data.encode(content, forKey: .content)
        try data.encode(characteristics, forKey: .characteristics)
    }
    
    public static func fromEventData(eventData: [String: Any]) -> Offer?{
        guard !eventData.isEmpty else {
            Log.warning(label: OptimizeConstants.LOG_TAG,
                      "Cannot create Offer object, provided data Dictionary is empty or null.")
            return nil
        }
        

        
        guard let data = try? JSONSerialization.data(withJSONObject: eventData, options: .prettyPrinted) else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot create Offer object, unable to parse the  data dictionary.")
            return nil
        }
        
        guard let offer = try? JSONDecoder().decode(Offer.self, from: data) as? Offer else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot create Offer object, unable to convert the  data dictionary to Offer.")
            return nil
        }
                        
        return offer
    }
}


//static Offer fromEventData(final Map<String, Object> data) {
//        if (OptimizeUtils.isNullOrEmpty(data)) {
//            MobileCore.log(LoggingMode.DEBUG, LOG_TAG, "Cannot create Offer object, provided data Map is empty or null.");
//            return null;
//        }
//
//        try {
//            final String id = (String) data.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_ID);
//            final String etag = (String) data.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_ETAG);
//            final String schema = (String) data.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_SCHEMA);
//
//            final Map<String, Object> offerData = (Map<String, Object>) data.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA);
//            if (OptimizeUtils.isNullOrEmpty(offerData)) {
//                MobileCore.log(LoggingMode.DEBUG, LOG_TAG, "Cannot create Offer object, provided data Map doesn't contain valid item data.");
//                return null;
//            }
//
//            final String nestedId = (String) offerData.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_ID);
//            if (OptimizeUtils.isNullOrEmpty(id) || !nestedId.equals(id)) {
//                MobileCore.log(LoggingMode.DEBUG, LOG_TAG, "Cannot create Offer object, provided item id is null or empty or it doesn't match item data id.");
//                return null;
//            }
//
//            final String format = (String) offerData.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_FORMAT);
//            if (OptimizeUtils.isNullOrEmpty(format)) {
//                MobileCore.log(LoggingMode.DEBUG, LOG_TAG, "Cannot create Offer object, provided data Map doesn't contain valid item data format.");
//                return null;
//            }
//
//            final List<String> language = (List<String>) offerData.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_LANGUAGE);
//            final Map<String, String> characteristics = (Map<String, String>) offerData.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_CHARACTERISTICS);
//
//
//            String content = null;
//            if (offerData.containsKey(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_CONTENT)) {
//                final Object offerContent = offerData.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_CONTENT);
//                if (offerContent instanceof String) {
//                    content = (String) offerContent;
//                } else {
//                    final JSONObject offerContentJson = new JSONObject((Map<String, Object>)offerContent);
//                    content = offerContentJson.toString();
//                }
//            } else if (offerData.containsKey(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_DELIVERYURL)) {
//                content = (String) offerData.get(OptimizeConstants.JsonKeys.PAYLOAD_ITEM_DATA_DELIVERYURL);
//            }
//            if (content == null) {
//                MobileCore.log(LoggingMode.DEBUG, LOG_TAG, "Cannot create Offer object, provided data Map doesn't contain valid item data content or deliveryURL.");
//                return null;
//            }
//
//            return new Builder(id, OfferType.from(format), content)
//                    .setEtag(etag)
//                    .setSchema(schema)
//                    .setLanguage(language)
//                    .setCharacteristics(characteristics)
//                    .build();
//
//        } catch (Exception e) {
//            MobileCore.log(LoggingMode.WARNING, LOG_TAG, "Cannot create Offer object, provided data contains invalid fields.");
//            return null;
//        }
//    }
