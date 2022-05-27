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

class Array_OptimizeTests: XCTestCase {

    enum ColorError: Error {
        case invalid
    }

    class Color: Equatable {
        let name: String
        let hexString: String

        init(_ name: String, with hexString: String) {
            self.name = name
            self.hexString = hexString
        }

        func getValidColor() throws -> String {
            if name.isEmpty || hexString.isEmpty {
                throw ColorError.invalid
            }
            return name
        }

        static func == (lhs: Color, rhs: Color) -> Bool {
            return lhs.name == rhs.name && lhs.hexString == rhs.hexString
        }
    }

    private var color: [Color] = []

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        color = [
            Color("red", with: "0xFF0000"),
            Color("green", with: "0x00FF00"),
            Color("blue", with: "0x0000FF")
        ]
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testToDictionary() {
        let dict: [String: Color] = color.toDictionary { $0.name }

        XCTAssertEqual(3, dict.count)
        XCTAssertEqual(color[0], dict["red"])
        XCTAssertEqual(color[1], dict["green"])
        XCTAssertEqual(color[2], dict["blue"])
    }

    func testToDictionary_throws() throws {
        color.append(Color("", with: ""))

        XCTAssertThrowsError(try color.toDictionary { try $0.getValidColor() })
    }
}
