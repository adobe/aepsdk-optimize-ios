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

@testable import AEPOptimize
import XCTest

class OfferTypeTests: XCTestCase {

    func testOfferTypeInit_jsonFromRawValue() {
        let jsonOfferType = OfferType(rawValue: 1)
        XCTAssertEqual(.json, jsonOfferType)
    }

    func testOfferTypeInit_textFromRawValue() {
        let textOfferType = OfferType(rawValue: 2)
        XCTAssertEqual(.text, textOfferType)
    }

    func testOfferTypeInit_htmlFromRawValue() {
        let htmlOfferType = OfferType(rawValue: 3)
        XCTAssertEqual(.html, htmlOfferType)
    }

    func testOfferTypeInit_ImageFromRawValue() {
        let imageOfferType = OfferType(rawValue: 4)
        XCTAssertEqual(.image, imageOfferType)
    }

    func testOfferTypeInit_unknownFromRawValue() {
        let unknownOfferType = OfferType(rawValue: 0)
        XCTAssertEqual(.unknown, unknownOfferType)
    }

    func testOfferTypeInit_invalidFromRawValue() {
        let invalidOfferType = OfferType(rawValue: 100)
        XCTAssertNil(invalidOfferType)
    }

    func testOfferTypeInit_jsonFromFormat() {
        let offerType = OfferType(from: "application/json")
        XCTAssertEqual(.json, offerType)
    }

    func testOfferTypeInit_textFromFormat() {
        let offerType = OfferType(from: "text/plain")
        XCTAssertEqual(.text, offerType)
    }

    func testOfferTypeInit_htmlFromFormat() {
        let offerType = OfferType(from: "text/html")
        XCTAssertEqual(.html, offerType)
    }

    func testOfferTypeInit_imageFromFormat() {
        let offerType = OfferType(from: "image/png")
        XCTAssertEqual(.image, offerType)
    }

    func testOfferTypeInit_unknownFromFormat() {
        let offerType = OfferType(from: "*/*")
        XCTAssertEqual(.unknown, offerType)
    }
}
