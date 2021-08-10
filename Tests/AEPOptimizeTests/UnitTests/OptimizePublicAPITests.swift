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

@testable import AEPCore
@testable import AEPOptimize
import XCTest

class OptimizePublicAPITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        EventHub.shared.start()
        registerMockExtension(MockExtension.self)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        MockExtension.reset()
        EventHub.reset()
    }

    func testUpdatePropositions_validDecisionScope() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should dispatch an event with expected data.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "updatepropositions",
            "decisionscopes": [
                [ "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                ]
            ]
        ]
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(testEvent.name, event.name)
            XCTAssertEqual("updatepropositions", event.data?["requesttype"] as? String)
            guard let decisionScopes: [DecisionScope] = event.getTypedData(for: "decisionscopes") else {
                XCTFail("Decision Scope array should be valid.")
                return
            }
            XCTAssertEqual(1, decisionScopes.count)
            XCTAssertTrue(decisionScopes[0].isValid)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes[0].name)

            XCTAssertNil(event.data?["xdm"])
            XCTAssertNil(event.data?["data"])
            expectation.fulfill()
        }

        // test
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testUpdatePropositions_validDecisionScopeWithXdmAndData() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should dispatch an event with expected data.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "updatepropositions",
            "decisionscopes": [
                [ "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                ]
            ],
            "xdm": [
                "myXdmKey": "myXdmValue"
            ],
            "data": [
                "myKey": "myValue"
            ]
        ]
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(testEvent.name, event.name)
            XCTAssertEqual("updatepropositions", event.data?["requesttype"] as? String)
            guard let decisionScopes: [DecisionScope] = event.getTypedData(for: "decisionscopes") else {
                XCTFail("Decision Scope array should be valid.")
                return
            }
            XCTAssertEqual(1, decisionScopes.count)
            XCTAssertTrue(decisionScopes[0].isValid)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes[0].name)

            guard let xdm = event.data?["xdm"] as? [String: Any] else {
                XCTFail("Xdm data should be valid.")
                return
            }
            XCTAssertEqual(1, xdm.count)
            XCTAssertEqual("myXdmValue", xdm["myXdmKey"] as? String)

            guard let data = event.data?["data"] as? [String: Any] else {
                XCTFail("Freeform data should be valid.")
                return
            }
            XCTAssertEqual(1, data.count)
            XCTAssertEqual("myValue", data["myKey"] as? String)

            expectation.fulfill()
        }

        // test
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        Optimize.updatePropositions(for: [decisionScope],
                                    withXdm: ["myXdmKey": "myXdmValue"] as [String: Any],
                                    andData: ["myKey": "myValue"] as [String: Any])

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testUpdatePropositions_multipleValidDecisionScopes() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should dispatch an event with expected data.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "updatepropositions",
            "decisionscopes": [
                [
                    "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                ],
                [
                    "name": "myMbox"
                ]
            ]
        ]
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(testEvent.name, event.name)
            XCTAssertEqual("updatepropositions", event.data?["requesttype"] as? String)
            guard let decisionScopes: [DecisionScope] = event.getTypedData(for: "decisionscopes") else {
                XCTFail("Decision Scope array should be valid.")
                return
            }
            XCTAssertEqual(2, decisionScopes.count)
            XCTAssertTrue(decisionScopes[0].isValid)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes[0].name)
            XCTAssertTrue(decisionScopes[1].isValid)
            XCTAssertEqual("myMbox", decisionScopes[1].name)
            expectation.fulfill()
        }

        // test
        let decisionScope1 = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                           placementId: "xcore:offer-placement:1111111111111111")
        let decisionScope2 = DecisionScope(name: "myMbox")

        Optimize.updatePropositions(for: [decisionScope1, decisionScope2], withXdm: nil)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testUpdatePropositions_noDecisionScope() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should not dispatch an event.")
        expectation.isInverted = true

        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { _ in
            expectation.fulfill()
        }

        // test
        Optimize.updatePropositions(for: [], withXdm: nil)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testUpdatePropositions_emptyDecisionScope() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should not dispatch an event.")
        expectation.isInverted = true

        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { _ in
            expectation.fulfill()
        }

        // test
        let decisionScope = DecisionScope(name: "")

        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testUpdatePropositions_invalidDecisionScope() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should not dispatch an event.")
        expectation.isInverted = true

        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { _ in
            expectation.fulfill()
        }

        // test
        let decisionScope = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoiIn0=")

        Optimize.updatePropositions(for: [decisionScope], withXdm: nil)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testUpdatePropositions_validAndInvalidDecisionScopes() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should dispatch an event.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "updatepropositions",
            "decisionscopes": [
                [
                    "name": "myMbox"
                ]
            ]
        ]
        let testEvent = Event(name: "Optimize Update Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(testEvent.name, event.name)
            XCTAssertEqual("updatepropositions", event.data?["requesttype"] as? String)
            guard let decisionScopes: [DecisionScope] = event.getTypedData(for: "decisionscopes") else {
                XCTFail("Decision Scope array should be valid.")
                return
            }
            XCTAssertEqual(1, decisionScopes.count)
            XCTAssertTrue(decisionScopes[0].isValid)
            XCTAssertEqual("myMbox", decisionScopes[0].name)
            expectation.fulfill()
        }

        // test
        let decisionScope1 = DecisionScope(activityId: "",
                                           placementId: "xcore:offer-placement:1111111111111111")
        let decisionScope2 = DecisionScope(name: "myMbox")

        Optimize.updatePropositions(for: [decisionScope1, decisionScope2], withXdm: nil)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testGetPropositions() {
        // setup
        let expectation = XCTestExpectation(description: "getPropositions should dispatch an event with expected data.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "getpropositions",
            "decisionscopes": [
                [ "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                ]
            ]
        ]
        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertEqual("getpropositions", event.data?["requesttype"] as? String)
            guard let decisionScopes: [DecisionScope] = event.getTypedData(for: "decisionscopes") else {
                XCTFail("Decision Scope array should be valid.")
                return
            }
            XCTAssertEqual(1, decisionScopes.count)
            XCTAssertTrue(decisionScopes[0].isValid)
            XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScopes[0].name)
            expectation.fulfill()
        }

        // test
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        Optimize.getPropositions(for: [decisionScope]) { _, _ in }

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testGetPropositions_noDecisionScope() {
        // setup
        let expectation = XCTestExpectation(description: "getPropositions should not dispatch an event.")
        expectation.isInverted = true

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { _ in
            expectation.fulfill()
        }

        // test
        Optimize.getPropositions(for: []) { _, _ in }

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testGetPropositions_emptyDecisionScope() {
        // setup
        let expectation = XCTestExpectation(description: "getPropositions should not dispatch an event.")
        expectation.isInverted = true

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { _ in
            expectation.fulfill()
        }

        // test
        let decisionScope = DecisionScope(name: "")

        Optimize.getPropositions(for: [decisionScope]) { _, _ in }

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testGetPropositions_invalidDecisionScope() {
        // setup
        let expectation = XCTestExpectation(description: "getPropositions should not dispatch an event.")
        expectation.isInverted = true

        let testEvent = Event(name: "Optimize Get Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { _ in
            expectation.fulfill()
        }

        // test
        let decisionScope = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoiIn0=")

        Optimize.getPropositions(for: [decisionScope]) { _, _ in }

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testOnPropositionsUpdate_validProposition() {
        // setup
        let expectation = XCTestExpectation(description: "onPropositionsUpdate should be called with response event upon personalization notification.")
        expectation.assertForOverFulfill = true

        let testEvent = Event(name: "Personalization Notification",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.notification",
                              data: [
                                "propositions": [
                                    [
                                    "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                                    ],
                                    [
                                        "id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
                                        "scope": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
                                        "items": [
                                            [
                                                "id": "xcore:personalized-offer:1111111111111111",
                                                "schema": "https://ns.adobe.com/experience/offer-management/content-component-text",
                                                "data": [
                                                    "id": "xcore:personalized-offer:1111111111111111",
                                                    "type": 2,
                                                    "content": "This is a plain text content!"
                                                ]
                                            ]
                                        ]
                                    ]
                                ]
                              ])

        // test
        Optimize.onPropositionsUpdate { propositionsDictionary in
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
            XCTAssertEqual("This is a plain text content!", proposition?.offers[0].content)

            expectation.fulfill()
        }

        EventHub.shared.dispatch(event: testEvent)

        // verify
        wait(for: [expectation], timeout: 2)
    }

    func testOnPropositionsUpdate_emptyProposition() {
        // setup
        let expectation = XCTestExpectation(description: "onPropositionsUpdate should not be called for empty propositions in personalization notification response.")
        expectation.isInverted = true

        let testEvent = Event(name: "Personalization Notification",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.notification",
                              data: [
                                "propositions": [:]
                              ])

        // test
        Optimize.onPropositionsUpdate { _ in
            expectation.fulfill()
        }

        EventHub.shared.dispatch(event: testEvent)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testOnPropositionsUpdate_invalidEvent() {
        // setup
        let expectation = XCTestExpectation(description: "onPropositionsUpdate should not be called for no propositions in personalization notification response.")
        expectation.isInverted = true
        let testEvent = Event(name: "Personalization Notification",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.notification",
                              data: nil)

        // test
        Optimize.onPropositionsUpdate { _ in
            expectation.fulfill()
        }

        EventHub.shared.dispatch(event: testEvent)

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testClearCachedPropositions() {
        // setup
        let expectation = XCTestExpectation(description: "clearCachedPropositions should dispatch an event.")
        expectation.assertForOverFulfill = true
        let testEvent = Event(name: "Optimize Clear Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestReset",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertNil(event.data)
            expectation.fulfill()
        }

        Optimize.clearCachedPropositions()

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testCoreResetIdentities() {
        // setup
        let expectation = XCTestExpectation(description: "Reset Identities should dispatch an event.")
        expectation.assertForOverFulfill = true
        let testEvent = Event(name: "Reset Identities Request",
                              type: "com.adobe.eventType.generic.identity",
                              source: "com.adobe.eventSource.requestReset",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertNil(event.data)
            expectation.fulfill()
        }

        MobileCore.resetIdentities()

        // verify
        wait(for: [expectation], timeout: 1)
    }

    // MARK: Helper functions

    private func registerMockExtension<T: Extension>(_ type: T.Type) {
        let semaphore = DispatchSemaphore(value: 0)
        EventHub.shared.registerExtension(type) { error in
            XCTAssertNil(error)
            semaphore.signal()
        }
        semaphore.wait()
    }
}
