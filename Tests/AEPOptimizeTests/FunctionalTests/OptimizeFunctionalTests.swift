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
        XCTAssertEqual(5, mockRuntime.listeners.count)
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.generic.identity-com.adobe.eventSource.requestReset"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.optimize-com.adobe.eventSource.requestReset"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.edge-com.adobe.eventSource.errorResponseContent"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.optimize-com.adobe.eventSource.requestContent"])
        XCTAssertNotNil(mockRuntime.listeners["com.adobe.eventType.edge-personalization:decisions"])
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
                                        data: (nil, .pending))

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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let decisionScopes = personalization?["decisionScopes"] as? [String]
        let schemas = personalization?["schemas"] as? [String]
        XCTAssertEqual(7, schemas?.count)
        XCTAssertEqual(Optimize.supportedSchemas, schemas)
        XCTAssertEqual(1, decisionScopes?.count)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes?[0])
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let schemas = personalization?["schemas"] as? [String]
        XCTAssertEqual(7, schemas?.count)
        XCTAssertEqual(Optimize.supportedSchemas, schemas)
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let schemas = personalization?["schemas"] as? [String]
        XCTAssertEqual(7, schemas?.count)
        XCTAssertEqual(Optimize.supportedSchemas, schemas)
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

        // Verify no override dataset Identifier is present.
        XCTAssertNil(dispatchedEvent?.data?["datasetId"])
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let schemas = personalization?["schemas"] as? [String]
        XCTAssertEqual(7, schemas?.count)
        XCTAssertEqual(Optimize.supportedSchemas, schemas)
        let decisionScopes = personalization?["decisionScopes"] as? [String]
        XCTAssertEqual(2, decisionScopes?.count)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes?[0])
        XCTAssertEqual("myMbox", decisionScopes?[1])
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
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
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
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
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
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
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
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent?.source)
        let query = dispatchedEvent?.data?["query"] as? [String: Any]
        let personalization = query?["personalization"] as? [String: Any]
        let schemas = personalization?["schemas"] as? [String]
        XCTAssertEqual(7, schemas?.count)
        XCTAssertEqual(Optimize.supportedSchemas, schemas)
        let decisionScopes = personalization?["decisionScopes"] as? [String]
        XCTAssertEqual(1, decisionScopes?.count)
        XCTAssertEqual("myMbox", decisionScopes?[0])
    }

    func testEdgeResponse_validProposition() {
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.notification", dispatchedEvent?.source)

        guard let propositionsDictionary: [DecisionScope: Proposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
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
    }
    
    func testEdgeResponse_validPropositionFromTargetWithClickTracking() {
        // setup
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

        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.notification", dispatchedEvent?.source)

        guard let propositionsDictionary: [DecisionScope: Proposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
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
    }

    func testEdgeResponse_emptyProposition() {
        // setup
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
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
    }

    func testEdgeResponse_unsupportedItemInProposition() {
        // setup
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
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
    }

    func testEdgeResponse_missingEventHandleInData() {
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
                                "requestId": "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
                              ])

        mockRuntime.simulateSharedState(for: ("com.adobe.module.configuration", testEvent),
                                        data: ([
                                            "edge.configId": "ffffffff-ffff-ffff-ffff-ffffffffffff"] as [String: Any], .set))

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
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

        guard let propositions = try? JSONDecoder().decode(Proposition.self, from: propositionsData) else {
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

        // test
        mockRuntime.simulateComingEvents(testEvent)

        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
        XCTAssertNil(dispatchedEvent?.data?["responseerror"])

        guard let propositionsDictionary: [DecisionScope: Proposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
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

        guard let propositions = try? JSONDecoder().decode(Proposition.self, from: propositionsData) else {
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

        // verify
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
        XCTAssertNil(dispatchedEvent?.data?["responseerror"])

        guard let propositionsDictionary: [DecisionScope: Proposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
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

        guard let propositions = try? JSONDecoder().decode(Proposition.self, from: propositionsData) else {
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
        XCTAssertNil(dispatchedEvent?.data?["responseerror"])

        guard let propositionsDictionary: [DecisionScope: Proposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
            XCTFail("Propositions dictionary should be valid.")
            return
        }
        XCTAssertTrue(propositionsDictionary.isEmpty)
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

        guard let propositions = try? JSONDecoder().decode(Proposition.self, from: propositionsData) else {
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
        XCTAssertEqual(AEPError.invalidRequest, AEPError(rawValue: dispatchedEvent?.data?["responseerror"] as? Int ?? 1000))
        XCTAssertNil(dispatchedEvent?.data?["propositions"])
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = mockRuntime.dispatchedEvents.first
        XCTAssertEqual("com.adobe.eventType.optimize", dispatchedEvent?.type)
        XCTAssertEqual("com.adobe.eventSource.responseContent", dispatchedEvent?.source)
        XCTAssertNil(dispatchedEvent?.data?["responseerror"])

        guard let propositionsDictionary: [DecisionScope: Proposition] = dispatchedEvent?.getTypedData(for: "propositions") else {
            XCTFail("Propositions dictionary should be valid.")
            return
        }
        XCTAssertTrue(propositionsDictionary.isEmpty)
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

        guard let propositions = try? JSONDecoder().decode(Proposition.self, from: propositionsData) else {
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)

        let dispatchedEvent = try XCTUnwrap(mockRuntime.dispatchedEvents.first)
        XCTAssertEqual("com.adobe.eventType.edge", dispatchedEvent.type)
        XCTAssertEqual("com.adobe.eventSource.requestContent", dispatchedEvent.source)

        let xdm = try XCTUnwrap(dispatchedEvent.data?["xdm"] as? [String: Any])
        let eventType = try XCTUnwrap(xdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionDisplay", eventType)

        let experience = try XCTUnwrap(xdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
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

        // test
        mockRuntime.simulateComingEvents(testEvent)

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

        // test
        mockRuntime.simulateComingEvents(testEvent)

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

        guard let propositions = try? JSONDecoder().decode(Proposition.self, from: propositionsData) else {
            XCTFail("Proposition should be valid.")
            return
        }

        optimize.cachedPropositions[DecisionScope(name: "myScope")] = propositions
        XCTAssertEqual(1, optimize.cachedPropositions.count)

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
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
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

        guard let propositions = try? JSONDecoder().decode(Proposition.self, from: propositionsData) else {
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
        XCTAssertEqual(0, mockRuntime.dispatchedEvents.count)
        XCTAssertTrue(optimize.cachedPropositions.isEmpty)
    }
}
