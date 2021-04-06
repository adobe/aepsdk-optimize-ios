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
@testable import AEPEdgePersonalization
import XCTest

class PersonalizationPublicAPITests: XCTestCase {

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

    func testUpdatePropositions() {
        // setup
        let expectation = XCTestExpectation(description: "updatePropositions should dispatch an event with expected data.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "updatedecisions",
            "decisionscopes": [
                [ "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                ]
            ]
        ]
        let testEvent = Event(name: "Update Propositions Request",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertEqual("updatedecisions", event.data?["requesttype"] as? String)
            guard let decisionScopes: [DecisionScope] = event.decodeTypedData(for: "decisionscopes") else {
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

        Personalization.updatePropositions(for: [decisionScope])

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testGetPropositions() {
        // setup
        let expectation = XCTestExpectation(description: "getPropositions should dispatch an event with expected data.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "getdecisions",
            "decisionscopes": [
                [ "name": "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ=="
                ]
            ]
        ]
        let testEvent = Event(name: "Get Propositions Request",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertEqual("getdecisions", event.data?["requesttype"] as? String)
            guard let decisionScopes: [DecisionScope] = event.decodeTypedData(for: "decisionscopes") else {
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

        Personalization.getPropositions(for: [decisionScope]) { _, _ in }

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testOnPropositionsUpdate_invalidEvent() {
        // setup
        let expectation = XCTestExpectation(description: "onPropositionsUpdate should be called with response event upon personalization notification.")
        expectation.isInverted = true
        let testEvent = Event(name: "Propositions Notification Event",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.notification",
                              data: [:])

        // test
        Personalization.onPropositionsUpdate { _ in
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
        let testEvent = Event(name: "Clear Propositions Request",
                              type: "com.adobe.eventType.offerDecisioning",
                              source: "com.adobe.eventSource.requestReset",
                              data: nil)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                    source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertNil(event.data)
            expectation.fulfill()
        }

        Personalization.clearCachedPropositions()

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
