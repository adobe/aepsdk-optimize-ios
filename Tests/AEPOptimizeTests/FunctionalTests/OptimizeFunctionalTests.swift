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
@testable import AEPOptimize
import XCTest

class OptimizeFunctionalTests: XCTestCase {
    var optimize: Optimize!
    var mockRuntime: TestableExtensionRuntime!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        mockRuntime = TestableExtensionRuntime()
        optimize = Optimize(runtime: mockRuntime)
        optimize.onRegistered()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOnRegistered() {
        // setup
        // onRegistered() invoked in setUp()

        // verify
        XCTAssertEqual(7, mockRuntime.listeners.count)
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.generic.identity-com.adobe.eventSource.requestReset"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.optimize-com.adobe.eventSource.requestReset"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.edge-com.adobe.eventSource.errorResponseContent"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.optimize-com.adobe.eventSource.requestContent"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.edge-personalization:decisions"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.optimize-com.adobe.eventSource.contentComplete"])
    }

    func testReadyForEvent_validConfig() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration"),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        let result = optimize.readyForEvent(testEvent)

        // verify
        XCTAssertTrue(result)
    }
    
    func testReadyForEvent_configPending() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration"),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .pending))

        // test
        let result = optimize.readyForEvent(testEvent)

        // verify
        XCTAssertFalse(result)
    }
    
    func testReadyForEvent_configPendingNoData() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration"),
                                        data: (nil, .pending))

        // test
        let result = optimize.readyForEvent(testEvent)

        // verify
        XCTAssertFalse(result)
    }

    func testReadyForEvent_configNotAvailable() {
        // setup
        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration"),
                                        data: (nil, .none))

        // test
        let result = optimize.readyForEvent(testEvent)

        // verify
        XCTAssertFalse(result)
    }

    func testReadyForEvent_configNotAvailableAndNotRequestEvent() {
        // setup
        let testEvent = Event(name: "Optimize Clear Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestReset",
                              data: nil)

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration"),
                                        data: (nil, .pending))

        // test
        let result = optimize.readyForEvent(testEvent)

        // verify
        XCTAssertTrue(result)
    }

    func testUpdatePropositions_validDecisionScope() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
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
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            XCTAssertEqual([DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")], updateEventIdsInProgress.values.first)
        }
    }

    func testUpdatePropositions_validDecisionScopeWithXdmAndDataAndDatasetId() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
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
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff",
                                            "optimize.datasetId": "111111111111111111111111"
                                        ] as [String: Any], .set))
        
        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            XCTAssertEqual([DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")], updateEventIdsInProgress.values.first)
        }
    }

    func testUpdatePropositions_validDecisionScopeWithXdmAndDataAndNoDatasetId() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
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
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"
                                        ] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            XCTAssertEqual([DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")], updateEventIdsInProgress.values.first)
        }
    }

    func testUpdatePropositions_multipleValidDecisionScopes() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
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
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            
            XCTAssertEqual([DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="), DecisionScope(name: "myMbox")], updateEventIdsInProgress.values.first)
        }
    }

    func testUpdatePropositions_missingEventRequestTypeInData() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
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
        let updateEventIdsInProgress = optimize.getUpdateRequestEventIdsInProgress()
        XCTAssertEqual(0, updateEventIdsInProgress.count)
    }

    func testUpdatePropositions_configNotUnavailable() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        let updateEventIdsInProgress = optimize.getUpdateRequestEventIdsInProgress()
        XCTAssertEqual(0, updateEventIdsInProgress.count)
    }

    func testUpdatePropositions_noDecisionScopes() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": []
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        let updateEventIdsInProgress = optimize.getUpdateRequestEventIdsInProgress()
        XCTAssertEqual(0, updateEventIdsInProgress.count)
    }

    func testUpdatePropositions_invalidDecisionScope() {
            // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoiIn0="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        let updateEventIdsInProgress = optimize.getUpdateRequestEventIdsInProgress()
        XCTAssertEqual(0, updateEventIdsInProgress.count)
    }

    func testUpdatePropositions_validAndInvalidDecisionScopes() {
        // setup
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoiIiwicGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MTExMTExMTExMTExMTExMSJ9"
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
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            XCTAssertEqual([DecisionScope(name: "myMbox")], updateEventIdsInProgress.values.first)
        }
    }

    func testEdgeResponse_validProposition() {
        // setup
        optimize.setUpdateRequestEventIdsInProgress("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA", expectedScopes: [DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")])
        let testEvent = Event(name: "AEP Response Event Handle",
                              type: "com.adobe.eventType.edge",
                              source: "personalization:decisions",
                              data: [
                                  "payload": [
                                    [
                                        "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                                        "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
                                        "activity": [
                                            "etag": "8",
                                            "id": "xcore:offer-activity:1111111111111111"
                                        ],
                                        "placement": [
                                            "etag": "1",
                                            "id": "xcore:offer-placement:1111111111111111"
                                        ],
                                        "items": [
                                            [
                                                "id": "xcore:personalized-offer:1111111111111111",
                                                "etag": "10",
                                                "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",
                                                "data": [
                                                    "id": "xcore:personalized-offer:1111111111111111",
                                                    "format": "text/html",
                                                    "content": "<h1>This is HTML content</h1>",
                                                    "characteristics": [
                                                        "testing": "true"
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                  ],
                                "requestEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
                                "requestId": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
                                "type": "personalization:decisions"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)
        
        let exp = expectation(description: "Test event should dispatch an event to mockRuntime.")
        mockRuntime.onEventDispatch  = { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.notification", dispatchedEvent?.source)

        guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
            XCTFail("Propositions dictionary should be valid.")
            return
        }
        let scope = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")
        XCTAssertNotNil(propositionsDictionary[scope])

        let proposition = propositionsDictionary[scope]
        XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", proposition?.id)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition?.scope)
        XCTAssertEqual(1, proposition?.offers.count)
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", proposition?.offers[0].id)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-html", proposition?.offers[0].schema)
        XCTAssertEqual(.html, proposition?.offers[0].type)
        XCTAssertEqual("<h1>This is HTML content</h1>", proposition?.offers[0].content)
        XCTAssertEqual(1, proposition?.offers[0].characteristics?.count)
        XCTAssertEqual("true", proposition?.offers[0].characteristics?["testing"])
        
        // the incoming proposition is accumulated
        XCTAssertEqual(1, optimize.getPropositionsInProgress().count)
    }
    
    func testEdgeResponse_validPropositionFromTargetWithClickTracking() {
        // setup
        optimize.setUpdateRequestEventIdsInProgress("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA", expectedScopes: [DecisionScope(name: "myMbox1")])
        let testScopeDetails: [String: Any] = [
            "decisionProvider": "TGT",
            "activity": [
                "id": "111111"
            ],
            "experience": [
                "id": "0"
            ],
            "strategies": [
                [
                    "step": "entry",
                    "algorithmID": "0",
                    "trafficType": "0"
                ],
                [
                    "step": "display",
                    "algorithmID": "0",
                    "trafficType": "0"
                ]
            ],
            "characteristics": [
                "stateToken": "SGFZpwAqaqFTayhAT2xsgzG3+2fw4m+O9FK8c0QoOHfxVkH1ttT1PGBX3/jV8a5uFF0fAox6CXpjJ1PGRVQBjHl9Zc6mRxY9NQeM7rs/3Es1RHPkzBzyhpVS6eg9q+kw",
                "eventTokens": [
                    "display": "MmvRrL5aB4Jz36JappRYg2qipfsIHvVzTQxHolz2IpSCnQ9Y9OaLL2gsdrWQTvE54PwSz67rmXWmSnkXpSSS2Q==",
                    "click": "EZDMbI2wmAyGcUYLr3VpmA=="
                ]
            ]
        ]

        let testEvent = Event(name: "AEP Response Event Handle",
                              type: "com.adobe.eventType.edge",
                              source: "personalization:decisions",
                              data: [
                                  "payload": [
                                    [
                                        "id": "AT:eyJhY3Rpdml0eUlkIjoiMTExMTExIiwiZXhwZXJpZW5jZUlkIjoiMCJ9",
                                        "scope": "myMbox1",
                                        "scopeDetails": testScopeDetails,
                                        "items": [
                                            [
                                                "id": "0",
                                                "schema": "https://ns.adobe.com/personalization/json-content-item",
                                                "data": [
                                                    "id": "0",
                                                    "format": "application/json",
                                                    "content": [
                                                        "device": "mobile"
                                                    ]
                                                ]
                                            ],
                                            [
                                                "id": "111111",
                                                "schema": "https://ns.adobe.com/personalization/measurement",
                                                "data": [
                                                    "type": "click",
                                                    "format": "application/vnd.adobe.target.metric"
                                                ]
                                            ]
                                        ]
                                    ]
                                  ],
                                "requestEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
                                "requestId": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
                                "type": "personalization:decisions"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)
        
        let exp = XCTestExpectation(description: "Test Event should dispatch an event to mockRuntime.")
        mockRuntime.onEventDispatch = { _ in
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.notification", dispatchedEvent?.source)

        guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
            XCTFail("Propositions dictionary should be valid.")
            return
        }
        let scope = DecisionScope(name: "myMbox1")
        XCTAssertNotNil(propositionsDictionary[scope])

        let proposition = propositionsDictionary[scope]
        XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTExMTExIiwiZXhwZXJpZW5jZUlkIjoiMCJ9", proposition?.id)
        XCTAssertEqual("myMbox1", proposition?.scope)
        let scopeDetails = proposition?.scopeDetails ?? [:]
        XCTAssertTrue(testScopeDetails == scopeDetails)
        
        XCTAssertEqual(1, proposition?.offers.count)
        XCTAssertEqual("0", proposition?.offers[0].id)
        XCTAssertEqual("https://ns.adobe.com/personalization/json-content-item", proposition?.offers[0].schema)
        XCTAssertEqual(.json, proposition?.offers[0].type)
        XCTAssertEqual("{\"device\":\"mobile\"}", proposition?.offers[0].content)
        XCTAssertNil(proposition?.offers[0].characteristics)
        XCTAssertNil(proposition?.offers[0].language)
        
        // the incoming proposition is accumulated
        XCTAssertEqual(1, optimize.getPropositionsInProgress().count)
    }

    func testEdgeResponse_emptyProposition() {
        // setup
        optimize.setUpdateRequestEventIdsInProgress("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA", expectedScopes: [])
        let testEvent = Event(name: "AEP Response Event Handle",
                              type: "com.adobe.eventType.edge",
                              source: "personalization:decisions",
                              data: [
                                "payload": [],
                                "requestEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
                                "requestId": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
                                "type": "personalization:decisions"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
        XCTAssertEqual(0, optimize.getPropositionsInProgress().count)
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
    }

    func testEdgeResponse_unsupportedItemInProposition() {
        // setup
        optimize.setUpdateRequestEventIdsInProgress("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA", expectedScopes: [DecisionScope(name: "myMbox1")])
        let testEvent = Event(name: "AEP Response Event Handle",
                              type: "com.adobe.eventType.edge",
                              source: "personalization:decisions",
                              data: [
                                "payload": [
                                    [
                                        "id": "AT:eyJhY3Rpdml0eUlkIjoiMTExMTExIiwiZXhwZXJpZW5jZUlkIjoiMCJ9",
                                        "scope": "myMbox1",
                                        "scopeDetails": [
                                            "activity": [
                                                "id": "111111"
                                            ],
                                            "decisionProvider": "TGT"
                                        ],
                                        "items": [
                                            [
                                                "id": "111111",
                                                "schema": "https://ns.adobe.com/personalization/measurement",
                                                "data": [
                                                    "type": "click",
                                                    "format": "application/vnd.adobe.target.metric"
                                                ]
                                            ]
                                        ]
                                    ]
                                ],
                                "requestEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
                                "requestId": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
                                "type": "personalization:decisions"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
        XCTAssertEqual(0, optimize.getPropositionsInProgress().count)
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
    }
    
    func testEdgeResponse_requestEventIdNotBeingTracked() {
        // setup
        let testEvent = Event(name: "AEP Response Event Handle",
                              type: "com.adobe.eventType.edge",
                              source: "personalization:decisions",
                              data: [
                                  "payload": [
                                    [
                                        "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                                        "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
                                        "activity": [
                                            "etag": "8",
                                            "id": "xcore:offer-activity:1111111111111111"
                                        ],
                                        "placement": [
                                            "etag": "1",
                                            "id": "xcore:offer-placement:1111111111111111"
                                        ],
                                        "items": [
                                            [
                                                "id": "xcore:personalized-offer:1111111111111111",
                                                "etag": "10",
                                                "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",
                                                "data": [
                                                    "id": "xcore:personalized-offer:1111111111111111",
                                                    "format": "text/html",
                                                    "content": "<h1>This is HTML content</h1>",
                                                    "characteristics": [
                                                        "testing": "true"
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                  ],
                                "requestEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
                                "requestId": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
                                "type": "personalization:decisions"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
        XCTAssertEqual(0, optimize.getPropositionsInProgress().count)
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
    }

    func testEdgeErrorResponse() {
        // setup
        let testEvent = Event(name: "AEP Error Response",
                              type: "com.adobe.eventType.edge",
                              source: "com.adobe.eventSource.errorResponseContent",
                              data: [
                                "requestId": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBBA",
                                "detail": "The following scope was not found: xcore:offer-activity:1111111111111111/xcore:offer-placement:1111111111111111",
                                "status": 404,
                                "requestEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
                                "type": "https://ns.adobe.com/aep/errors/ODE-0001-404",
                                "title": "Not Found"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
        XCTAssertEqual(0, optimize.getPropositionsInProgress().count)
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
    }

    func testGetPropositions_decisionScopeInCache() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "score": 1,
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-json",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "application/json",
                          "content": {\"key\": \"value\"},
                          "characteristics": {
                              "testing": "true"
                          }
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        let expectation = XCTestExpectation(description: "Get propositions request should dispatch response event.")
        mockRuntime.onEventDispatch = { _ in
            expectation.fulfill()
        }
        
        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
        XCTAssertNil(dispatchedEvent?.data?["responseerror"])

        guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
            XCTFail("Propositions dictionary should be valid.")
            return
        }
        XCTAssertEqual(1, propositionsDictionary.count)

        let scope = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")
        XCTAssertNotNil(propositionsDictionary[scope])

        let proposition = propositionsDictionary[scope]
        XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", proposition?.id)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition?.scope)
        XCTAssertEqual(1, proposition?.offers.count)
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", proposition?.offers[0].id)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-json", proposition?.offers[0].schema)
        XCTAssertEqual(1, proposition?.offers[0].score)
        XCTAssertEqual(.json, proposition?.offers[0].type)
        XCTAssertEqual("{\"key\":\"value\"}", proposition?.offers[0].content)
        XCTAssertEqual(1, proposition?.offers[0].characteristics?.count)
        XCTAssertEqual("true", proposition?.offers[0].characteristics?["testing"])
    }

    func testGetPropositions_dispatchPropositionFromCacheBeforeNextUpdate() throws {
        /// Setup
        let decisionScopeA = DecisionScope(name: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpdml0eUlkIjoic2NvcGUtYSIsInBsYWNlbWVudElkIjoic2NvcGUtYV9wbGFjZW1lbnQifQ.KW1HKVJHTTdmUkJZUmM5UEhNdURtOGdT")
        
        let decisionScopeB = DecisionScope(name: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpdml0eUlkIjoic2NvcGUtYiIsInBsYWNlbWVudElkIjoic2NvcGUtYl9wbGFjZW1lbnQifQ.QzNxT1dBZ1Z1M0Z5dW84SjdKak1nY2c1")

        let propositionA = """
        {
            "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
            "scope": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpdml0eUlkIjoic2NvcGUtYSIsInBsYWNlbWVudElkIjoic2NvcGUtYV9wbGFjZW1lbnQifQ.KW1HKVJHTTdmUkJZUmM5UEhNdURtOGdT"
        }
        """.data(using: .utf8)!

        guard let propositionForScopeA = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionA) else {
            XCTFail("Propositions should be valid.")
            return
        }

        /// Cache decisionScopeA
        optimize.cachedPropositions[decisionScopeA] = propositionForScopeA
        
        let getEvent = Event(
            name: "Get Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "getpropositions",
                "decisionscopes": [
                    ["name": decisionScopeA.name]
                ]
            ]
        )

        let updateEvent = Event(
            name: "Update Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "updatepropositions",
                "decisionscopes": [
                    ["name": decisionScopeB.name]
                ]
            ]
        )
        
        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", updateEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        /// Dispatch the Update event
        mockRuntime.simulateComingEvents(updateEvent)
        
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            
            let optimizeContentComplete = Event(
                name: "Optimize Update Propositions Complete",
                type: "com.adobe.eventType.optimize",
                source: "com.adobe.eventSource.contentComplete",
                data: [
                    "completedUpdateRequestForEventId": updateEvent.id.uuidString
                ]
            )
            
            let expectationGet = XCTestExpectation(description: "Get event should be processed first.")
            
            var dispatchedEvents = [Event]()
            
            self.mockRuntime.onEventDispatch = { event in
                dispatchedEvents.append(event)
                expectationGet.fulfill()
            }
            
            /// Dispatch the events
            self.mockRuntime.simulateComingEvents(getEvent)
            self.mockRuntime.simulateComingEvents(optimizeContentComplete)
            
            /// Verify
            self.wait(for: [expectationGet], timeout: 5)
            
            XCTAssertEqual(self.mockRuntime.firstEvent?.type, "com.adobe.eventType.optimize")
            XCTAssertEqual(self.mockRuntime.firstEvent?.source, "com.adobe.eventSource.responseContent")
            
            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = self.mockRuntime.firstEvent?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            
            XCTAssertEqual(propositionsDictionary[decisionScopeA]?.id, self.optimize.cachedPropositions[decisionScopeA]?.id)
            XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", propositionsDictionary[decisionScopeA]?.id)
            XCTAssertEqual("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpdml0eUlkIjoic2NvcGUtYSIsInBsYWNlbWVudElkIjoic2NvcGUtYV9wbGFjZW1lbnQifQ.KW1HKVJHTTdmUkJZUmM5UEhNdURtOGdT", propositionsDictionary[decisionScopeA]?.scope)
        }
    }
    
    func testGetPropositions_ScopesFromEventIsUpdateInProgress() {
        // Setup
        let decisionScopeA = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")
        
        let cachedPropositionJSON = """
        {
            "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
            "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
        }
        """.data(using: .utf8)!
        
        let updatedPropositionJSON = """
        {
            "id": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
            "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
        }
        """.data(using: .utf8)!

        guard let cachedPropositionForScopeA = try? JSONDecoder().decode(OptimizeProposition.self, from: cachedPropositionJSON),
              let updatedPropositionForScopeA = try? JSONDecoder().decode(OptimizeProposition.self, from: updatedPropositionJSON) else {
            XCTFail("Propositions should be valid.")
            return
        }

        /// Same Decision Scope is already cached with old propositions
        optimize.cachedPropositions[decisionScopeA] = cachedPropositionForScopeA

        let updateEvent = Event(
            name: "Optimize Update Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "updatepropositions",
                "decisionscopes": [
                    ["name": decisionScopeA.name]
                ]
            ]
        )

        let getEvent = Event(
            name: "Optimize Get Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "getpropositions",
                "decisionscopes": [
                    ["name": decisionScopeA.name]
                ]
            ]
        )

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", updateEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        /// Simulating update & get events
        mockRuntime.simulateComingEvents(updateEvent)
        mockRuntime.simulateComingEvents(getEvent)

        XCTAssertTrue(mockRuntime.dispatchedEvents.isEmpty)

        optimize.setUpdateRequestEventIdsInProgress(updateEvent.id.uuidString, expectedScopes: [decisionScopeA])
        optimize.setPropositionsInProgress([decisionScopeA : updatedPropositionForScopeA])
        
        let optimizeContentComplete = Event(
            name: "Optimize Update Propositions Complete",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.contentComplete",
            data: [
                "completedUpdateRequestForEventId": updateEvent.id.uuidString,
                "propositions" : [updatedPropositionJSON]
            ]
        )
        
        mockRuntime.simulateComingEvents(optimizeContentComplete)
        
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            /// After the update is complete, the get event should now dispatch
            let expectation = XCTestExpectation(description: "Get propositions request should now dispatch response event after update completion.")
            
            self.mockRuntime.onEventDispatch = { event in
                if event.responseID == getEvent.id {
                    expectation.fulfill()
                }
            }
            
            self.wait(for: [expectation], timeout: 2)
            XCTAssertEqual(self.mockRuntime.dispatchedEvents.count, 1)
            
            let dispatchedEvent = self.mockRuntime.firstEvent
            XCTAssertEqual(dispatchedEvent?.type, "com.adobe.eventType.optimize")
            XCTAssertEqual(dispatchedEvent?.source, "com.adobe.eventSource.responseContent")
            
            /// Validate that the Get proposition response contains the updated proposition
            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertEqual(propositionsDictionary[decisionScopeA]?.id, updatedPropositionForScopeA.id)
            XCTAssertEqual("BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB", propositionsDictionary[decisionScopeA]?.id)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", propositionsDictionary[decisionScopeA]?.scope)
        }
    }

    func testGetPropositions_fewDecisionScopesNotInCacheAndGetToBeQueued() {
        /// Setup
        let decisionScopeA = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")
        let decisionScopeB = DecisionScope(name: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpdml0eUlkIjoic2NvcGUtYiIsInBsYWNlbWVudElkIjoic2NvcGUtYl9wbGFjZW1lbnQifQ.QzNxT1dBZ1Z1M0Z5dW84SjdKak1nY2c1")
        
        let propositionA = """
        {
            "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
            "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
        }
        """.data(using: .utf8)!
        
        let propositionB = """
        {
            "id": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB",
            "scope": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhY3Rpdml0eUlkIjoic2NvcGUtYiIsInBsYWNlbWVudElkIjoic2NvcGUtYl9wbGFjZW1lbnQifQ.QzNxT1dBZ1Z1M0Z5dW84SjdKak1nY2c1"
        }
        """.data(using: .utf8)!

        guard let cachedPropositionForScopeA = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionA),
              let cachedPropositionForScopeB = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionB) else {
            XCTFail("Propositions should be valid.")
            return
        }

        /// decisionScopeA is already cached.
        optimize.cachedPropositions[decisionScopeA] = cachedPropositionForScopeA

        /// Creating a get event with a decisionScopeB that is currently not present in the cache.
        let getEvent = Event(
            name: "Optimize Get Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "getpropositions",
                "decisionscopes": [
                    ["name": decisionScopeA.name],
                    ["name": decisionScopeB.name]
                ]
            ]
        )
        
        /// Update event with decisionScopeB.
        let updateEvent = Event(
            name: "Optimize Update Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "updatepropositions",
                "decisionscopes": [
                    ["name": decisionScopeB.name]
                ]
            ]
        )

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", updateEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        /// Dispatching the update event.
        mockRuntime.simulateComingEvents(updateEvent)
        optimize.setUpdateRequestEventIdsInProgress(updateEvent.id.uuidString, expectedScopes: [decisionScopeB])
        optimize.setPropositionsInProgress([decisionScopeB : cachedPropositionForScopeB])
        
        let optimizeContentComplete = Event(
            name: "Optimize Update Propositions Complete",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.contentComplete",
            data: [
                "completedUpdateRequestForEventId": updateEvent.id.uuidString,
                "propositions" : [propositionB]
            ]
        )

        let expectationGet = XCTestExpectation(description: "Get event should be queued.")
        mockRuntime.onEventDispatch = { event in
            if event.responseID == getEvent.id {
                expectationGet.fulfill()
            }
        }

        /// Dispatch the get event Immediately.
        mockRuntime.simulateComingEvents(getEvent)
        
        /// Dispatching the proposition complete event after a delay of 1 second to simulate a real use case.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {[weak self] in
            self?.mockRuntime.simulateComingEvents(optimizeContentComplete)
        })

        wait(for: [expectationGet], timeout: 12)
        
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            /// Verify that the get proposition event was queued & is the last event to be executed.
            XCTAssertEqual(self.mockRuntime.firstEvent?.type, "com.adobe.eventType.optimize")
            XCTAssertEqual(self.mockRuntime.firstEvent?.source, "com.adobe.eventSource.responseContent")
            
            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = self.mockRuntime.firstEvent?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            /// Verify that the proposition for decisionScopeB is present in the reponse event as well as in the cache.
            XCTAssertTrue(propositionsDictionary.keys.contains(decisionScopeB))
            XCTAssertEqual("BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB", propositionsDictionary[decisionScopeB]?.id)
            XCTAssertEqual("BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB", self.optimize.cachedPropositions[decisionScopeB]?.id)
            XCTAssertEqual(propositionsDictionary[decisionScopeB]?.id, self.optimize.cachedPropositions[decisionScopeB]?.id)
        }
    }
    
    func testGetPropositions_notAllDecisionScopesInCache() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "text/plain",
                          "content": "This is a plain text content."
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name": "myMbox"
                                    ],
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
        
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(1, self.mockRuntime.dispatchedEvents.count)

            let dispatchedEvent = self.mockRuntime.dispatchedEvents.first
            XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
            XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
            XCTAssertNil(dispatchedEvent?.data?["responseerror"])

            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertEqual(1, propositionsDictionary.count)
            
            let scope1 = DecisionScope(name: "myMbox")
            XCTAssertNil(propositionsDictionary[scope1])

            let scope2 = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")
            XCTAssertNotNil(propositionsDictionary[scope2])

            let proposition = propositionsDictionary[scope2]
            XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", proposition?.id)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition?.scope)
            XCTAssertEqual(1, proposition?.offers.count)
            XCTAssertEqual("xcore:personalized-offer:1111111111111111", proposition?.offers[0].id)
            XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-text", proposition?.offers[0].schema)
            XCTAssertEqual(.text, proposition?.offers[0].type)
            XCTAssertEqual("This is a plain text content.", proposition?.offers[0].content)
        }
    }

    func testGetPropositions_noDecisionScopeInCache() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "text/html",
                          "content": "<h1>This is a html content.</h1>"
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name": "myMbox1"
                                    ],
                                    [
                                        "name": "myMbox2"
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(1, self.mockRuntime.dispatchedEvents.count)
            
            let dispatchedEvent = self.mockRuntime.dispatchedEvents.first
            XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
            XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
            XCTAssertNil(dispatchedEvent?.data?["responseerror"])
            
            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertTrue(propositionsDictionary.isEmpty)
        }
    }

    func testGetPropositions_invalidDecisionScopesArray() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "text/plain",
                          "content": "This is a plain text content.</h1>"
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name1": "myMbox1"
                                    ],
                                    [
                                        "name2": "myMbox2"
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(1, self.mockRuntime.dispatchedEvents.count)
            
            let dispatchedEvent = self.mockRuntime.dispatchedEvents.first
            let errorData = dispatchedEvent?.data?["responseerror"] as? AEPOptimizeError
            XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
            XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
            XCTAssertEqual(AEPError.invalidRequest, errorData?.aepError)
            XCTAssertNil(dispatchedEvent?.data?["propositions"])
        }
    }

    func testGetPropositions_emptyCache() {
        // setup
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
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
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(1, self.mockRuntime.dispatchedEvents.count)

            let dispatchedEvent = self.mockRuntime.dispatchedEvents.first
            XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
            XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
            XCTAssertNil(dispatchedEvent?.data?["responseerror"])

            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertTrue(propositionsDictionary.isEmpty)
        }
        
    }

    func testGetPropositions_missingEventRequestTypeInData() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-json",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "application/json",
                          "content": {\"key\": \"value\"},
                          "characteristics": {
                              "testing": "true"
                          }
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
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
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
    }

    func testGetPropositions_whenUpdateIsInProgress() {
        // setup
        let testUpdateEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testUpdateEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        // simulate update event
        mockRuntime.simulateComingEvents(testUpdateEvent)
        
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            
            let testGetEvent = Event(name: "Optimize Get Propositions Request",
                                  type: "com.adobe.eventType.optimize",
                                  source: "com.adobe.eventSource.requestContent",
                                  data: [
                                    "requesttype": "getpropositions",
                                    "decisionscopes": [
                                        [
                                            "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                        ]
                                    ]
                                  ])
            
            let expectation = XCTestExpectation(description: "Get propositions request should not dispatch response event when update is in progress.")
            expectation.isInverted = true
            self.mockRuntime.onEventDispatch = { event in
                if event.type == EventType.optimize && event.source == EventSource.responseContent {
                    expectation.fulfill()
                }
            }

            // test
            self.mockRuntime.simulateComingEvents(testGetEvent)

            // verify
            self.wait(for: [expectation], timeout: 2)
        }
        
    }

    func testGetPropositions_whenUpdateIsComplete() throws {
        // setup
        let testUpdateEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatepropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])
        
        let testGetEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ]
                                ]
                              ])
        
        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testUpdateEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        // simulate update event
        mockRuntime.simulateComingEvents(testUpdateEvent)
        
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let updateEventIdsInProgress = self.optimize.getUpdateRequestEventIdsInProgress()
            XCTAssertEqual(1, updateEventIdsInProgress.count)
            
            // simulate optimize content complete event
            let optimizeContentComplete = Event(name: "Optimize Update Propositions Complete",
                                                type: "com.adobe.eventType.optimize",
                                                source: "com.adobe.eventSource.contentComplete",
                                                data: [
                                                    "completedUpdateRequestForEventId": updateEventIdsInProgress.keys.first as Any
                                                ])

            let expectation = XCTestExpectation(description: "Get propositions request should dispatch response event when update is complete.")
            expectation.expectedFulfillmentCount = 1
            self.mockRuntime.onEventDispatch = { _ in
                expectation.fulfill()
            }

            // test
            self.mockRuntime.simulateComingEvents(testGetEvent)
            self.mockRuntime.simulateComingEvents(optimizeContentComplete)

            // verify
            self.wait(for: [expectation], timeout: 2)
            XCTAssertEqual(1, self.mockRuntime.dispatchedEvents.count)
            
            do {
                let dispatchedEvent = try XCTUnwrap(self.mockRuntime.dispatchedEvents.first)
                XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent.type)
                XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent.source)
            } catch {
                XCTFail("Failed to parse dispatched event.")
            }
           
        }
    }

    func testTrackPropositions_validPropositionInteractionsForDisplay() throws {
        // setup
        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "trackpropositions",
                                "propositioninteractions": [
                                    "eventType": "decisioning.propositionDisplay",
                                    "_experience": [
                                        "decisioning": [
                                            "propositionEventType": [
                                                "display": 1
                                            ],
                                            "propositions": [
                                                [
                                                    "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                                                    "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
                                                    "scopeDetails": [:],
                                                    "items": [
                                                        [
                                                            "id": "xcore:personalized-offer:1111111111111111"
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        let exp = XCTestExpectation(description: "Test Event should dispatch an event to mockRuntime.")
        mockRuntime.onEventDispatch = { _ in
            exp.fulfill()
        }
        
        // test
        mockRuntime.simulateComingEvents(testEvent)
        wait(for: [exp], timeout: 2)
        
        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = try XCTUnwrap(mockRuntime.dispatchedEvents.first)
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent.source)

        let xdm = try XCTUnwrap(dispatchedEvent.data?["xdm"] as? [String: Any])
        let eventType = try XCTUnwrap(xdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionDisplay", eventType)

        let experience = try XCTUnwrap(xdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["display"] as? Int)
        let propositionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(1, propositionDetailsArray.count)

        let propositionDetailsData = try XCTUnwrap(propositionDetailsArray[0])
        XCTAssertEqual("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa", propositionDetailsData["id"] as? String)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", propositionDetailsData["scope"] as? String)

        // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
        let scopeDetails = propositionDetailsData["scopeDetails"] as? [String: Any] ?? [:]
        XCTAssertTrue(scopeDetails.isEmpty)

        let items = try XCTUnwrap(propositionDetailsData["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = try XCTUnwrap(items[0])
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", item["id"] as? String)
    }

    func testTrackPropositions_validPropositionInteractionsForTap() throws {
        // setup
        let testScopeDetails: [String: Any] = [
            "decisionProvider": "TGT",
            "activity": [
                "id": "125589"
            ],
            "experience": [
                "id": "0"
            ],
            "strategies": [
                [
                    "algorithmID": "0",
                    "trafficType": "0"
                ]
            ]
        ]

        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "trackpropositions",
                                "propositioninteractions": [
                                    "eventType": "decisioning.propositionInteract",
                                    "_experience": [
                                        "decisioning": [
                                            "propositionEventType": [
                                                "interact": 1
                                            ],
                                            "propositions": [
                                                [
                                                    "id": "AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9",
                                                    "scope": "myMbox",
                                                    "scopeDetails": testScopeDetails,
                                                    "items": [
                                                        [
                                                            "id": "246315"
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        let exp = XCTestExpectation(description: "Test Event should dispatch an event to mockRuntime.")
        mockRuntime.onEventDispatch = { _ in
            exp.fulfill()
        }
        // test
        mockRuntime.simulateComingEvents(testEvent)
        wait(for: [exp], timeout: 2)
        
        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = try XCTUnwrap(mockRuntime.dispatchedEvents.first)
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent.source)

        let xdm = try XCTUnwrap(dispatchedEvent.data?["xdm"] as? [String: Any])
        let eventType = try XCTUnwrap(xdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionInteract", eventType)

        let experience = try XCTUnwrap(xdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["interact"] as? Int)
        let propositionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(1, propositionDetailsArray.count)

        let propositionDetailsData = try XCTUnwrap(propositionDetailsArray[0])
        XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", propositionDetailsData["id"] as? String)
        XCTAssertEqual("myMbox", propositionDetailsData["scope"] as? String)

        let scopeDetails = try XCTUnwrap(propositionDetailsData["scopeDetails"] as? [String: Any])
        XCTAssertTrue(testScopeDetails == scopeDetails)

        let items = try XCTUnwrap(propositionDetailsData["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = try XCTUnwrap(items[0])
        XCTAssertEqual("246315", item["id"] as? String)
    }

    func testTrackPropositions_validPropositionInteractionsWithDatasetConfig() throws {
        // setup
        let testScopeDetails: [String: Any] = [
            "decisionProvider": "TGT",
            "activity": [
                "id": "125589"
            ],
            "experience": [
                "id": "0"
            ],
            "strategies": [
                [
                    "algorithmID": "0",
                    "trafficType": "0"
                ]
            ]
        ]

        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "trackpropositions",
                                "propositioninteractions": [
                                    "eventType": "decisioning.propositionInteract",
                                    "_experience": [
                                        "decisioning": [
                                            "propositionEventType": [
                                                "interact": 1
                                            ],
                                            "propositions": [
                                                [
                                                    "id": "AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9",
                                                    "scope": "myMbox",
                                                    "scopeDetails": testScopeDetails,
                                                    "items": [
                                                        [
                                                            "id": "246315"
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff",
                                            "optimize.datasetId": "111111111111111111111111"
                                        ] as [String: Any], .set))
        
        let exp = XCTestExpectation(description: "Test Event should dispatch an event to mockRuntime.")
        mockRuntime.onEventDispatch = { _ in
            exp.fulfill()
        }
        // test
        mockRuntime.simulateComingEvents(testEvent)
        wait(for: [exp], timeout: 2)
        
        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = try XCTUnwrap(mockRuntime.dispatchedEvents.first)
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent.source)

        let xdm = try XCTUnwrap(dispatchedEvent.data?["xdm"] as? [String: Any])
        let eventType = try XCTUnwrap(xdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionInteract", eventType)

        let experience = try XCTUnwrap(xdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["interact"] as? Int)
        let propositionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(1, propositionDetailsArray.count)

        let propositionDetailsData = try XCTUnwrap(propositionDetailsArray[0])
        XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", propositionDetailsData["id"] as? String)
        XCTAssertEqual("myMbox", propositionDetailsData["scope"] as? String)

        let scopeDetails = try XCTUnwrap(propositionDetailsData["scopeDetails"] as? [String: Any])
        XCTAssertTrue(testScopeDetails == scopeDetails)

        let items = try XCTUnwrap(propositionDetailsData["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = try XCTUnwrap(items[0])
        XCTAssertEqual("246315", item["id"] as? String)

        let datasetId = try XCTUnwrap(dispatchedEvent.data?["datasetId"] as? String)
        XCTAssertEqual("111111111111111111111111", datasetId)
    }

    func testTrackPropositions_missingEventRequestTypeInData() throws {
        // setup
        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "propositioninteractions": [
                                    "eventType": "decisioning.propositionDisplay",
                                    "_experience": [
                                        "decisioning": [
                                            "propositions": [
                                                [
                                                    "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                                                    "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
                                                    "scopeDetails": [:],
                                                    "items": [
                                                        [
                                                            "id": "xcore:personalized-offer:1111111111111111"
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
    }

    func testTrackPropositions_configNotAvailable() throws {
        // setup
        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "trackpropositions",
                                "propositioninteractions": [
                                    "eventType": "decisioning.propositionDisplay",
                                    "_experience": [
                                        "decisioning": [
                                            "propositionEventType": [
                                                "display": 1
                                            ],
                                            "propositions": [
                                                [
                                                    "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                                                    "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
                                                    "scopeDetails": [:],
                                                    "items": [
                                                        [
                                                            "id": "xcore:personalized-offer:1111111111111111"
                                                        ]
                                                    ]
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                              ])

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
    }

    func testTrackPropositions_noPropositionInteractions() throws {
        // setup
        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "trackpropositions",
                                "propositioninteractions": []
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
    }

    func testTrackPropositions_emptyPropositionInteractions() throws {
        // setup
        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "trackpropositions"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
    }

    func testClearCachedPropositions() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "text/plain",
                          "content": "This is a plain text content!",
                          "characteristics": {
                              "testing": "true"
                          }
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "myScope")] = propositions
        optimize.previewCachedPropositions[DecisionScope(name: "myScope")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)
        XCTAssertEqual(1, optimize.previewCachedPropositions.count)

        let testEvent = Event(name: "Optimize Clear Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestReset",
                              data: nil)

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)
        
        // verify
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension 
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(0, self.mockRuntime.dispatchedEvents.count)
            XCTAssertTrue(self.optimize.cachedPropositions.isEmpty)
            XCTAssertTrue(self.optimize.previewCachedPropositions.isEmpty)
        }
    }

    func testCoreResetIdentities() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "text/plain",
                          "content": "This is a plain text content!",
                          "characteristics": {
                              "testing": "true"
                          }
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "myScope")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)

        let testEvent = Event(name: "Reset Identities Request",
                              type: "com.adobe.eventType.generic.identity",
                              source: "com.adobe.eventSource.requestReset",
                              data: nil)

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        
        mockRuntime.simulateComingEvents(testEvent)
        
        // verify
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(0, self.mockRuntime.dispatchedEvents.count)
            XCTAssertTrue(self.optimize.cachedPropositions.isEmpty)
        }
    }
    
    func testUpdatePropositionsComplete_updatesPropositionsCache() {
        // setup
        optimize.setUpdateRequestEventIdsInProgress("AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA", expectedScopes: [DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")])

        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "score": 1,
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-json",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "application/json",
                          "content": {\"key\": \"value\"},
                          "characteristics": {
                              "testing": "true"
                          }
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.setPropositionsInProgress([DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="): propositions])
        XCTAssertEqual(1, optimize.getPropositionsInProgress().count)

        let testEvent = Event(name: "Optimize Update Propositions Complete",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.contentComplete",
                              data: [
                                "completedUpdateRequestForEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        // using DispatchQueue to change the run loop as the events are now being processed inside a serial queue in optimize extension
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            XCTAssertEqual(1, self.optimize.cachedPropositions.count)
            XCTAssertEqual(self.optimize.cachedPropositions[DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")], propositions)
            XCTAssertEqual(0, self.optimize.getUpdateRequestEventIdsInProgress().count)
            XCTAssertEqual(0, self.optimize.getPropositionsInProgress().count)
        }
    }
    
    func testUpdatePropositionsComplete_requestEventIdNotBeingTracked() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": "8",
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": "1",
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": "10",
                      "score": 1,
                      "schema": "https://ns.adobe.com/experience/offer-management/content-component-json",
                      "data": {
                          "id": "xcore:personalized-offer:1111111111111111",
                          "format": "application/json",
                          "content": {\"key\": \"value\"},
                          "characteristics": {
                              "testing": "true"
                          }
                      }
                  }
              ]
          }
        """.data(using: .utf8)!

        guard let propositions = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.setPropositionsInProgress([DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="): propositions])
        XCTAssertEqual(1, optimize.getPropositionsInProgress().count)

        let testEvent = Event(name: "Optimize Update Propositions Complete",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.contentComplete",
                              data: [
                                "completedUpdateRequestForEventId": "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, optimize.cachedPropositions.count)
        XCTAssertEqual(0, optimize.getUpdateRequestEventIdsInProgress().count)
        XCTAssertEqual(0, optimize.getPropositionsInProgress().count)
    }
    
    func testDebugEventTriggeredByExternalSystem(){
            //setUp
            let decisionScope = DecisionScope(name: "optimize-tutorial-loc")
            let testEvent = Event(name: "AEP Response Event Handle (Spoof)",
                                  type: "com.adobe.eventType.system",
                                  source: "com.adobe.eventSource.debug",
                                  data: [
                                    "payload": [
                                      [
                                          "id": "AT:Spoofed",
                                          "scope": "\(decisionScope.name)",
                                          "scopeDetails": [
                                              "activity": [
                                                "id" : "0"
                                                ],
                                              "decisionProvider": "TGT"
                                          ],
                                          "items": [
                                              [
                                                  "id": "xcore:personalized-offer:1111111111111111",
                                                  "etag": "10",
                                                  "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",
                                                  "data": [
                                                      "id": "xcore:personalized-offer:1111111111111111",
                                                      "format": "text/html",
                                                      "content": "<h1>This is HTML content</h1>",
                                                      "characteristics": [
                                                          "testing": "true"
                                                      ]
                                                  ]
                                              ]
                                          ]
                                      ]
                                    ],
                                    "type": "personalization:decisions"
                                  ])
            let expectatation = XCTestExpectation(description: "Test event should dispatch an event to mockRuntime.")
            mockRuntime.onEventDispatch = { event in
                expectatation.fulfill()
            }
            // test
            mockRuntime.simulateComingEvents(testEvent)

            wait(for: [expectatation], timeout: 5)
            //verify
            XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

            let dispatchedEvent = mockRuntime.dispatchedEvents.first
            XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
            XCTAssertEqual("com.adobe.eventSource.notification", dispatchedEvent?.source)
            
            XCTAssertEqual(1, optimize.previewCachedPropositions.count)
            XCTAssertTrue(optimize.cachedPropositions.isEmpty)
        
            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            
            XCTAssertNotNil(propositionsDictionary[decisionScope])
            XCTAssertEqual(propositionsDictionary[decisionScope]?.id, optimize.previewCachedPropositions[decisionScope]?.id)
        
        }
    
        func testDebugEvent_getPropositionForMultipleScopes() {
            // Setup
            let decisionScopeA = DecisionScope(name: "optimize-tutorial-loc")
            
            let decisionScopeB = DecisionScope(name: "eyJ4ZG06YWN0aXZpdHlJZCI6Inhjb3JlOm9mZmVyLWFjdGl2aXR5OjE4ZTBlZjZlZDg5MWI5NTEiLCJ4ZG06cGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MThlMGVlMDQ5NGRkMTdjNCJ9")
            
            let propositionA = """
            {
                "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                "scope": "optimize-tutorial-loc"
            }
            """.data(using: .utf8)!
            
            let propositionB = """
            {
                "id": "bbbbbbbb-bbbb-bbbb-bbbbbbbbbbbb",
                "scope": "eyJ4ZG06YWN0aXZpdHlJZCI6Inhjb3JlOm9mZmVyLWFjdGl2aXR5OjE4ZTBlZjZlZDg5MWI5NTEiLCJ4ZG06cGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MThlMGVlMDQ5NGRkMTdjNCJ9"
            }
            """.data(using: .utf8)!
            
            guard let propositionForScopeA = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionA),
                  let propositionForScopeB = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionB) else {
                XCTFail("Propositions should be valid.")
                return
            }
            
            /// Cache decisionScopes
            optimize.cachedPropositions[decisionScopeA] = propositionForScopeA
            optimize.cachedPropositions[decisionScopeB] = propositionForScopeB
            
            //test
            let expectationDebugEvent = XCTestExpectation(description: "Test Debug Event should get dispatched.")
            
            let testEvent = Event(name: "AEP Response Event Handle (Spoof)",
                                  type: "com.adobe.eventType.system",
                                  source: "com.adobe.eventSource.debug",
                                  data: [
                                    "payload": [
                                      [
                                          "id": "AT:Spoofed",
                                          "scope": "optimize-tutorial-loc",
                                          "scopeDetails": [
                                              "activity": [
                                                "id" : "0"
                                                ],
                                              "decisionProvider": "TGT"
                                          ],
                                          "items": [
                                              [
                                                  "id": "xcore:personalized-offer:1111111111111111",
                                                  "etag": "10",
                                                  "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",
                                                  "data": [
                                                      "id": "xcore:personalized-offer:1111111111111111",
                                                      "format": "text/html",
                                                      "content": "<h1>This is HTML content</h1>",
                                                      "characteristics": [
                                                          "testing": "true"
                                                      ]
                                                  ]
                                              ]
                                          ]
                                      ]
                                    ],
                                    "type": "personalization:decisions"
                                  ])
            
            
            mockRuntime.onEventDispatch = { [weak self] event in
                XCTAssertEqual("com.adobe.eventType.optimize", event.type)
                XCTAssertEqual("com.adobe.eventSource.notification", event.source)
                XCTAssertEqual(1, self?.optimize.previewCachedPropositions.count)
                expectationDebugEvent.fulfill()
            }
            
            // simulate debug event
            mockRuntime.simulateComingEvents(testEvent)
            
            wait(for: [expectationDebugEvent], timeout: 2)
            
            let expectationGetEvent = XCTestExpectation(description: "Get propositions request should dispatch response event for scope A and B.")
            let testGetEventA = Event(name: "Optimize Get Propositions Request",
                                  type: "com.adobe.eventType.optimize",
                                  source: "com.adobe.eventSource.requestContent",
                                  data: [
                                    "requesttype": "getpropositions",
                                    "decisionscopes": [
                                        [
                                            "name": "optimize-tutorial-loc"
                                        ]
                                    ]
                                  ])
            
            let testGetEventB = Event(name: "Optimize Get Propositions Request",
                                  type: "com.adobe.eventType.optimize",
                                  source: "com.adobe.eventSource.requestContent",
                                  data: [
                                    "requesttype": "getpropositions",
                                    "decisionscopes": [
                                        [
                                            "name": "eyJ4ZG06YWN0aXZpdHlJZCI6Inhjb3JlOm9mZmVyLWFjdGl2aXR5OjE4ZTBlZjZlZDg5MWI5NTEiLCJ4ZG06cGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MThlMGVlMDQ5NGRkMTdjNCJ9"
                                        ]
                                    ]
                                  ])
            
            var dispatchedEvents = [Event]()
            mockRuntime.onEventDispatch = { event in
                dispatchedEvents.append(event)
                XCTAssertEqual(2, self.optimize.cachedPropositions.count)
                expectationGetEvent.fulfill()
            }
            
            mockRuntime.simulateComingEvents(testGetEventA, testGetEventB)
            
            //verify
            wait(for: [expectationGetEvent], timeout: 5)
            
            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvents.first?.getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            XCTAssertNotNil(propositionsDictionary[decisionScopeA])
            XCTAssertEqual(propositionsDictionary[decisionScopeA]?.id, "AT:Spoofed") // verifies that proposition id is receieved from debug event from preview cache for scope A which was already present in main cache.
            
            guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvents[1].getTypedData(for: "propositions") else {
                XCTFail("Propositions dictionary should be valid.")
                return
            }
            
            XCTAssertNotNil(propositionsDictionary[decisionScopeB])
            XCTAssertEqual(propositionsDictionary[decisionScopeB]?.id, "bbbbbbbb-bbbb-bbbb-bbbbbbbbbbbb") // verifies that proposition data for scope B is returned from main cache.
        }
    
    func testDebugEvents_UpdateAndGetForMultipleDecisionScopes() {
        // Setup
        let decisionScopeA = DecisionScope(name: "optimize-tutorial-loc")
        
        let decisionScopeB = DecisionScope(name: "eyJ4ZG06YWN0aXZpdHlJZCI6Inhjb3JlOm9mZmVyLWFjdGl2aXR5OjE4ZTBlZjZlZDg5MWI5NTEiLCJ4ZG06cGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MThlMGVlMDQ5NGRkMTdjNCJ9")
        
        let propositionA = """
        {
            "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
            "scope": "optimize-tutorial-loc"
        }
        """.data(using: .utf8)!
        
        let propositionB = """
        {
            "id": "bbbbbbbb-bbbb-bbbb-bbbbbbbbbbbb",
            "scope": "eyJ4ZG06YWN0aXZpdHlJZCI6Inhjb3JlOm9mZmVyLWFjdGl2aXR5OjE4ZTBlZjZlZDg5MWI5NTEiLCJ4ZG06cGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MThlMGVlMDQ5NGRkMTdjNCJ9"
        }
        """.data(using: .utf8)!
        
        guard let propositionForScopeA = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionA),
              let propositionForScopeB = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionB) else {
            XCTFail("Propositions should be valid.")
            return
        }
        
        let expectationDebugEvent = XCTestExpectation(description: "Test Debug Event should get dispatched.")
        
        let testEvent = Event(name: "AEP Response Event Handle (Spoof)",
                              type: "com.adobe.eventType.system",
                              source: "com.adobe.eventSource.debug",
                              data: [
                                "payload": [
                                  [
                                      "id": "AT:Spoofed",
                                      "scope": "optimize-tutorial-loc",
                                      "scopeDetails": [
                                          "activity": [
                                            "id" : "0"
                                            ],
                                          "decisionProvider": "TGT"
                                      ],
                                      "items": [
                                          [
                                              "id": "xcore:personalized-offer:1111111111111111",
                                              "etag": "10",
                                              "schema": "https://ns.adobe.com/experience/offer-management/content-component-html",
                                              "data": [
                                                  "id": "xcore:personalized-offer:1111111111111111",
                                                  "format": "text/html",
                                                  "content": "<h1>This is HTML content</h1>",
                                                  "characteristics": [
                                                      "testing": "true"
                                                  ]
                                              ]
                                          ]
                                      ]
                                  ]
                                ],
                                "type": "personalization:decisions"
                              ])
        
        
        mockRuntime.onEventDispatch = { [weak self] event in
            XCTAssertEqual("com.adobe.eventType.optimize", event.type)
            XCTAssertEqual("com.adobe.eventSource.notification", event.source)
            XCTAssertEqual(1, self?.optimize.previewCachedPropositions.count)
            expectationDebugEvent.fulfill()
        }
        
        // simulate debug event
        mockRuntime.simulateComingEvents(testEvent)
        
        wait(for: [expectationDebugEvent], timeout: 2)
        
        let expectationUpdateEvent = XCTestExpectation(description: "Update propositions request should dispatch response event for scope A.")
        
        let updateEventA = Event(
            name: "Update Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "updatepropositions",
                "decisionscopes": [
                    ["name": decisionScopeA.name]
                ]
            ]
        )
        
        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", updateEventA),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        
        
        mockRuntime.onEventDispatch = { event in
            expectationUpdateEvent.fulfill()
        }
        mockRuntime.simulateComingEvents(updateEventA)
        
        wait(for: [expectationUpdateEvent], timeout: 12)
        let expectationUpdateEventB = XCTestExpectation(description: "Update propositions request should dispatch response event for scope B.")
        let updateEventB = Event(
            name: "Update Propositions Request",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.requestContent",
            data: [
                "requesttype": "updatepropositions",
                "decisionscopes": [
                    ["name": decisionScopeB.name]
                ]
            ]
        )
        
        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", updateEventB),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))
        mockRuntime.onEventDispatch = { event in
            expectationUpdateEventB.fulfill()
        }
        mockRuntime.simulateComingEvents(updateEventB)
        
        wait(for: [expectationUpdateEventB], timeout: 12)
        
        
        optimize.setUpdateRequestEventIdsInProgress(updateEventA.id.uuidString, expectedScopes: [decisionScopeA])
        optimize.setPropositionsInProgress([decisionScopeA : propositionForScopeA])
        
        let optimizeContentCompleteA = Event(
            name: "Optimize Update Propositions Complete",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.contentComplete",
            data: [
                "completedUpdateRequestForEventId": updateEventA.id.uuidString
            ]
        )
        
        mockRuntime.simulateComingEvents(optimizeContentCompleteA)
        
        optimize.setUpdateRequestEventIdsInProgress(updateEventB.id.uuidString, expectedScopes: [decisionScopeB])
        optimize.setPropositionsInProgress([decisionScopeB : propositionForScopeB])
    
        let optimizeContentCompleteB = Event(
            name: "Optimize Update Propositions Complete",
            type: "com.adobe.eventType.optimize",
            source: "com.adobe.eventSource.contentComplete",
            data: [
                "completedUpdateRequestForEventId": updateEventB.id.uuidString
            ]
        )
        
        mockRuntime.simulateComingEvents(optimizeContentCompleteB)
        
        let expectationGetEvent = XCTestExpectation(description: "Get propositions request should dispatch response event for scope A and B.")
        let testGetEventA = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name": "optimize-tutorial-loc"
                                    ]
                                ]
                              ])
        
        let testGetEventB = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getpropositions",
                                "decisionscopes": [
                                    [
                                        "name": "eyJ4ZG06YWN0aXZpdHlJZCI6Inhjb3JlOm9mZmVyLWFjdGl2aXR5OjE4ZTBlZjZlZDg5MWI5NTEiLCJ4ZG06cGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MThlMGVlMDQ5NGRkMTdjNCJ9"
                                    ]
                                ]
                              ])
        
        var dispatchedEvents = [Event]()
        mockRuntime.onEventDispatch = { event in
            dispatchedEvents.append(event)
            if dispatchedEvents.count == 2 {
                expectationGetEvent.fulfill()
            }
        }
        
        mockRuntime.simulateComingEvents(testGetEventA)
        mockRuntime.simulateComingEvents(testGetEventB)
        
        //verify
        wait(for: [expectationGetEvent], timeout: 24)
        
        guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvents[0].getTypedData(for: "propositions") else {
            XCTFail("Propositions dictionary should be valid.")
            return
        }
        XCTAssertNotNil(propositionsDictionary[decisionScopeA])
        XCTAssertEqual(propositionsDictionary[decisionScopeA]?.id, "AT:Spoofed") // verifies that proposition id is receieved from debug event from preview cache for scope A which was already present in main cache.
        
        guard let propositionsDictionary: [DecisionScope: OptimizeProposition] = dispatchedEvents[1].getTypedData(for: "propositions") else {
            XCTFail("Propositions dictionary should be valid.")
            return
        }
        XCTAssertNotNil(propositionsDictionary[decisionScopeB])
        XCTAssertEqual(propositionsDictionary[decisionScopeB]?.id, "bbbbbbbb-bbbb-bbbb-bbbbbbbbbbbb") // verifies that proposition data for scope B is returned from main cache.
    }

}
