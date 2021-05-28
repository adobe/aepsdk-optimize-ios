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

    func testUpdatePropositions_validDecisionScope() {
        // setup
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)
        
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
                              type: "com.adobe.eventType.optimize",
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)
        
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
                              type: "com.adobe.eventType.optimize",
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
        XCTAssertEqual(1, mockRuntime.dispatchedEvents.count)
        
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
                              type: "com.adobe.eventType.optimize",
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

    func testUpdatePropositions_invalidDecisionScope() {
            // setup
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatedecisions",
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
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "updatedecisions",
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
                                            "etag": 8,
                                            "id": "xcore:offer-activity:1111111111111111"
                                        ],
                                        "placement": [
                                            "etag": 1,
                                            "id": "xcore:offer-placement:1111111111111111"
                                        ],
                                        "items": [
                                            [
                                                "id": "xcore:personalized-offer:1111111111111111",
                                                "etag": 10,
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
                  "etag": 8,
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": 1,
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": 10,
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

        let testEvent = Event(name: "Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getdecisions",
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
                  "etag": 8,
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": 1,
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": 10,
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

        let testEvent = Event(name: "Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getdecisions",
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

        let scope = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")
        XCTAssertNotNil(propositionsDictionary[scope])

        let proposition = propositionsDictionary[scope]
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
                  "etag": 8,
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": 1,
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": 10,
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

        let testEvent = Event(name: "Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getdecisions",
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
                  "etag": 8,
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": 1,
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": 10,
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

        let testEvent = Event(name: "Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getdecisions",
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

        let testEvent = Event(name: "Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: [
                                "requesttype": "getdecisions",
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

    func testClearCachedPropositions() {
        // setup
        let propositionsData =
        """
          {
              "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
              "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
              "activity": {
                  "etag": 8,
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": 1,
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": 10,
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

        let testEvent = Event(name: "Clear Propositions Request",
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
                  "etag": 8,
                  "id": "xcore:offer-activity:1111111111111111"
              },
              "placement": {
                  "etag": 1,
                  "id": "xcore:offer-placement:1111111111111111"
              },
              "items": [
                  {
                      "id": "xcore:personalized-offer:1111111111111111",
                      "etag": 10,
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
