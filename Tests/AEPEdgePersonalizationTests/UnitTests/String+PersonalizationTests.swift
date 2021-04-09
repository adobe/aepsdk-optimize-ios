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

@testable import AEPEdgePersonalization
import XCTest

class String_PersonalizationTests: XCTestCase {
    private let TEST_STR_VALID = "This is a test string!"
    private let TEST_STR_VALID_ENCODED = "VGhpcyBpcyBhIHRlc3Qgc3RyaW5nIQ=="
    private let TEST_STR_EMPTY = ""

    func testBase64Encode_validString() {
        XCTAssertEqual("VGhpcyBpcyBhIHRlc3Qgc3RyaW5nIQ==", TEST_STR_VALID.base64Encode())
    }

    func testBase64Encode_emptyString() {
        XCTAssertEqual("", TEST_STR_EMPTY.base64Encode())
    }

    func testBase64Decode_validString() {
        XCTAssertEqual("This is a test string!", TEST_STR_VALID_ENCODED.base64Decode())
    }

    func testBase64Decode_invalidString() {
        XCTAssertNil("VGhp=".base64Decode())
    }

    func testBase64Decode_emptyString() {
        XCTAssertEqual("", TEST_STR_EMPTY.base64Decode())
    }
}
