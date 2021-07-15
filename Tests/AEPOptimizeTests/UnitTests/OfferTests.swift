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

import AEPOptimize
import XCTest

class OfferTests: XCTestCase {

    private let JSON_OFFER =
"""
{\
    "id": "xcore:personalized-offer:1111111111111111",\
    "etag": "8",\
    "schema": "https://ns.adobe.com/experience/offer-management/content-component-json",\
    "data": {\
        "id": "xcore:personalized-offer:1111111111111111",\
        "format": "application/json",\
        "content": {\"testing\": \"ho-ho\"},\
        "language": [\
            "en-us"\
        ],\
        "characteristics": {\
            "mobile": "true"\
        }\
    }\
}
"""

    private let TEXT_OFFER =
"""
{\
    "id": "xcore:personalized-offer:2222222222222222",\
    "etag": "7",\
    "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
    "data": {\
        "id": "xcore:personalized-offer:2222222222222222",\
        "format": "text/plain",\
        "content": "This is a plain text content!",\
        "language": [\
            "en-us"\
        ],\
        "characteristics": {\
            "mobile": "true"\
        }\
    }\
}
"""

    private let HTML_OFFER =
"""
{\
    "id": "xcore:personalized-offer:3333333333333333",\
    "etag": "8",\
    "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",\
    "data": {\
        "id": "xcore:personalized-offer:3333333333333333",\
        "format": "text/html",\
        "content": "<h1>Hello, Welcome!</h1>",\
        "language": [\
            "en-us"\
        ],\
        "characteristics": {\
            "mobile": "true"\
        }\
    }\
}
"""

    private let IMAGE_OFFER =
"""
{\
    "id": "xcore:personalized-offer:4444444444444444",\
    "etag": "8",\
    "schema": "https://ns.adobe.com/experience/offer-management/content-component-imagelink",\
    "data": {\
        "id": "xcore:personalized-offer:4444444444444444",\
        "format": "image/png",\
        "deliveryURL": "https://example.com/avatar1.png?alt=media",\
        "language": [\
            "en-us"\
        ],\
        "characteristics": {\
            "mobile": "true"\
        }\
    }\
}
"""

    // PDCL-4528 & PDCL-4703
    private let TARGET_OFFER =
"""
{\
    "id": "0",\
    "schema": "https://ns.adobe.com/personalization/json-content-item",\
    "data": {\
        "id": "0",\
        "content": {\"device\": \"mobile\"}\
    }\
}
"""

    private let OFFER_MINIMAL =
"""
{\
    "id": "xcore:personalized-offer:2222222222222222",\
    "etag": "7",\
    "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
    "data": {\
        "id": "xcore:personalized-offer:2222222222222222",\
        "format": "text/plain",\
        "content": "This is a plain text content!",\
    }\
}
"""

    private let OFFER_INVALID =
"""
{\
    "id": "xcore:personalized-offer:2222222222222222",\
    "etag": "7",\
    "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",\
    "data": {\
        "id": "xcore:personalized-offer:2222222222222222",\
        "format": "text/plain"\
    }\
}
"""

    func testJsonOffer() throws {
        guard let offerData = JSON_OFFER.data(using: .utf8),
              let offer = try? JSONDecoder().decode(Offer.self, from: offerData)
        else {
            XCTFail("Offer should be valid.")
            return
        }

        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)
        XCTAssertEqual("8", offer.etag)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-json", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 1), offer.type)
        XCTAssertEqual("{\"testing\":\"ho-ho\"}", offer.content)
        XCTAssertEqual(1, offer.language?.count)
        XCTAssertEqual("en-us", offer.language?[0])
        XCTAssertEqual(1, offer.characteristics?.count)
        XCTAssertEqual("true", offer.characteristics?["mobile"])
    }

    func testTextOffer() throws {
        guard let offerData = TEXT_OFFER.data(using: .utf8),
              let offer = try? JSONDecoder().decode(Offer.self, from: offerData)
        else {
            XCTFail("Offer should be valid.")
            return
        }

        XCTAssertEqual("xcore:personalized-offer:2222222222222222", offer.id)
        XCTAssertEqual("7", offer.etag)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-text", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 2), offer.type)
        XCTAssertEqual("This is a plain text content!", offer.content)
        XCTAssertEqual(1, offer.language?.count)
        XCTAssertEqual("en-us", offer.language?[0])
        XCTAssertEqual(1, offer.characteristics?.count)
        XCTAssertEqual("true", offer.characteristics?["mobile"])
    }

    func testHtmlOffer() throws {
        guard let offerData = HTML_OFFER.data(using: .utf8),
              let offer = try? JSONDecoder().decode(Offer.self, from: offerData)
        else {
            XCTFail("Offer should be valid.")
            return
        }

        XCTAssertEqual("xcore:personalized-offer:3333333333333333", offer.id)
        XCTAssertEqual("8", offer.etag)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-html", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 3), offer.type)
        XCTAssertEqual("<h1>Hello, Welcome!</h1>", offer.content)
        XCTAssertEqual(1, offer.language?.count)
        XCTAssertEqual("en-us", offer.language?[0])
        XCTAssertEqual(1, offer.characteristics?.count)
        XCTAssertEqual("true", offer.characteristics?["mobile"])
    }

    func testImageOffer() throws {
        guard let offerData = IMAGE_OFFER.data(using: .utf8),
              let offer = try? JSONDecoder().decode(Offer.self, from: offerData)
        else {
            XCTFail("Offer should be valid.")
            return
        }

        XCTAssertEqual("xcore:personalized-offer:4444444444444444", offer.id)
        XCTAssertEqual("8", offer.etag)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-imagelink", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 4), offer.type)
        XCTAssertEqual("https://example.com/avatar1.png?alt=media", offer.content)
        XCTAssertEqual(1, offer.language?.count)
        XCTAssertEqual("en-us", offer.language?[0])
        XCTAssertEqual(1, offer.characteristics?.count)
        XCTAssertEqual("true", offer.characteristics?["mobile"])
    }

    func testOffer_validFromTarget() throws {
        guard let offerData = TARGET_OFFER.data(using: .utf8),
              let offer = try? JSONDecoder().decode(Offer.self, from: offerData)
        else {
            XCTFail("Offer should be valid.")
            return
        }

        XCTAssertEqual("0", offer.id)
        XCTAssertTrue(offer.etag.isEmpty)
        XCTAssertEqual("https://ns.adobe.com/personalization/json-content-item", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 0), offer.type)
        XCTAssertEqual("{\"device\":\"mobile\"}", offer.content)
        XCTAssertNil(offer.language)
        XCTAssertNil(offer.characteristics)
    }

    func testOffer_minimal() throws {
        guard let offerData = OFFER_MINIMAL.data(using: .utf8),
              let offer = try? JSONDecoder().decode(Offer.self, from: offerData)
        else {
            XCTFail("Offer should be valid.")
            return
        }

        XCTAssertEqual("xcore:personalized-offer:2222222222222222", offer.id)
        XCTAssertEqual("7", offer.etag)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-text", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 2), offer.type)
        XCTAssertEqual("This is a plain text content!", offer.content)
        XCTAssertNil(offer.language)
        XCTAssertNil(offer.characteristics)
    }

    func testOffer_invalid() throws {
        guard let offerData = OFFER_INVALID.data(using: .utf8) else {
            XCTFail("Offer json data should be valid.")
            return
        }
        let offer = try? JSONDecoder().decode(Offer.self, from: offerData)
        XCTAssertNil(offer)
    }
}
