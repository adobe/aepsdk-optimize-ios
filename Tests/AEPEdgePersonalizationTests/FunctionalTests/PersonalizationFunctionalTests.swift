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
import AEPEdgePersonalization
import XCTest

class PersonalizationFunctionalTests: XCTestCase {
    var personalization: Personalization!
    var mockRuntime: TestableExtensionRuntime!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        mockRuntime = TestableExtensionRuntime()
        personalization = Personalization(runtime: mockRuntime)
        personalization.onRegistered()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdatePropositions_validDecisionScope() {
        // setup
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatedecisions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let decisionScopes = personalization?["decisionScopes"] as? [String]
        XCTAssertEqual(1, decisionScopes?.count)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes?[0])
    }

    func testUpdatePropositions_validDecisionScopeWithExperienceData() {
        // setup
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatedecisions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ],
                                "xdm": [
                                    "myXdmKey": "myXdmValue"
                                ],
                                "data": [
                                    "myKey": "myValue"
                                ],
                                "datasetid": "111111111111111111111111"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let decisionScopes = personalization?["decisionScopes"] as? [String]
        XCTAssertEqual(1, decisionScopes?.count)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes?[0])

        let xdm = dispatchedEvent?.data?["xdm"] as? [String: Any]
        XCTAssertEqual(2, xdm?.count)
        XCTAssertEqual("personalization.request", xdm?["eventType"] as? String)
        XCTAssertEqual("myXdmValue", xdm?["myXdmKey"] as? String)

        let data = dispatchedEvent?.data?["data"] as? [String: Any]
        XCTAssertEqual(1, data?.count)
        XCTAssertEqual("myValue", data?["myKey"] as? String)

        XCTAssertEqual("111111111111111111111111", dispatchedEvent?.data?["datasetId"] as? String)
    }

    func testUpdatePropositions_multipleValidDecisionScopes() {
        // setup
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatedecisions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ],
                                    [
                                        "name": "myMbox"
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let decisionScopes = personalization?["decisionScopes"] as? [String]
        XCTAssertEqual(2, decisionScopes?.count)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes?[0])
        XCTAssertEqual("myMbox", decisionScopes?[1])
    }

    func testUpdatePropositions_noDecisionScopes() {
        // setup
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatedecisions",
                                "decisionscopes": []
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
    }
}
