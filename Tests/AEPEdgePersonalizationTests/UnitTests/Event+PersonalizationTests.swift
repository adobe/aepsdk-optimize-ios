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

import AEPCore
@testable import AEPEdgePersonalization
import XCTest

class Event_PersonalizationTests: XCTestCase {
    private let TEST_EVENT_DATA_VALID: [String: Any] = [
        "requesttype": "testrequest",
        "decisionscopes": [
            [
                "name": "testMbox1"
            ],
            [
                "name": "testMbox2"
            ]
        ]
    ]

    private let TEST_EVENT_DATA_INVALID: [String: Any] = [
        "requesttype": "testrequest",
        "decisionscopes": [
            [
                "name": "testMbox1"
            ],
            [
                "foo": "bar"
            ]
        ]
    ]

    private let TEST_EVENT_DATA_MISSING_KEY: [String: Any] = [
        "requesttype": "testrequest"
    ]

    private let TEST_EVENT_DATA_NO_TYPEKEY: [String: Any] = [
            "name": "testMbox1"
    ]

    func testGetTypedData_keyInEventDataValid() {

        let testEvent = Event(name: "Test Event",
                              type: "com.adobe.eventType.mockExtension",
                              source: "com.adobe.eventSource.requestContent",
                              data: TEST_EVENT_DATA_VALID)

        guard let scopesArray: [DecisionScope] = testEvent.getTypedData(for: "decisionscopes") else {
            XCTFail("Decision Scopes Array should be valid.")
            return
        }
        XCTAssertEqual(2, scopesArray.count)
        XCTAssertEqual("testMbox1", scopesArray[0].name)
        XCTAssertEqual("testMbox2", scopesArray[1].name)
    }

    func testGetTypedData_keyInEventDataInvalid() {

        let testEvent = Event(name: "Test Event",
                              type: "com.adobe.eventType.mockExtension",
                              source: "com.adobe.eventSource.requestContent",
                              data: TEST_EVENT_DATA_INVALID)

        let scopesArray: [DecisionScope]? = testEvent.getTypedData(for: "decisionscopes")
        XCTAssertNil(scopesArray)
    }

    func testGetTypedData_keyNotInEventData() {

        let testEvent = Event(name: "Test Event",
                              type: "com.adobe.eventType.mockExtension",
                              source: "com.adobe.eventSource.requestContent",
                              data: TEST_EVENT_DATA_MISSING_KEY)

        let scopesArray: [DecisionScope]? = testEvent.getTypedData(for: "decisionscopes")
        XCTAssertNil(scopesArray)
    }

    func testGetTypedData_EventData() {

        let testEvent = Event(name: "Test Event",
                              type: "com.adobe.eventType.mockExtension",
                              source: "com.adobe.eventSource.requestContent",
                              data: TEST_EVENT_DATA_NO_TYPEKEY)

        guard let scope: DecisionScope = testEvent.getTypedData() else {
            XCTFail("Decision Scope should be valid.")
            return
        }
        XCTAssertEqual("testMbox1", scope.name)
    }
}
