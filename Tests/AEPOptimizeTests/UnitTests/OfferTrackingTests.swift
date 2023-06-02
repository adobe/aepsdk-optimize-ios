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

extension PropositionTests {

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

    func testGenerateDisplayInteractionXdm_validProposition() throws {

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", proposition.id)
        XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition.scope)

        // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
        XCTAssertTrue(proposition.scopeDetails.isEmpty)

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        guard let propositionInteractionXdm = offer.generateDisplayInteractionXdm() else {
            XCTFail("Generated proposition display interaction XDM should be valid.")
            return
            
        }
        
        let eventType = try XCTUnwrap(propositionInteractionXdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionDisplay", eventType)

        let experience = try XCTUnwrap(propositionInteractionXdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["display"] as? Int)
        let propositionInteractionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(1, propositionInteractionDetailsArray.count)

        let propositionInteractionDetails = try XCTUnwrap(propositionInteractionDetailsArray[0])
        XCTAssertEqual(proposition.id, propositionInteractionDetails["id"] as? String)
        XCTAssertEqual(proposition.scope, propositionInteractionDetails["scope"] as? String)

        let scopeDetails = propositionInteractionDetails["scopeDetails"] as? [String: Any] ?? [:]
        XCTAssertTrue(proposition.scopeDetails == scopeDetails)

        let items = try XCTUnwrap(propositionInteractionDetails["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = items[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", item["id"] as? String)
    }

    func testGenerateDisplayInteractionXdm_validPropositionFromTarget() throws {

        guard
            let propositionData = PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", proposition.id)
        XCTAssertEqual("myMbox", proposition.scope)

        XCTAssertEqual(4, proposition.scopeDetails.count)
        XCTAssertEqual("TGT", proposition.scopeDetails["decisionProvider"] as? String)
        let sdActivity = proposition.scopeDetails["activity"] as? [String: Any]
        XCTAssertEqual("125589", sdActivity?["id"] as? String)
        let sdExperience = proposition.scopeDetails["experience"] as? [String: Any]
        XCTAssertEqual("0", sdExperience?["id"] as? String)
        let sdStrategies = proposition.scopeDetails["strategies"] as? [[String: Any]]
        XCTAssertEqual(1, sdStrategies?.count)
        XCTAssertEqual("0", sdStrategies?[0]["algorithmID"] as? String)
        XCTAssertEqual("0", sdStrategies?[0]["trafficType"] as? String)

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("246315", offer.id)

        guard let propositionInteractionXdm = offer.generateDisplayInteractionXdm() else {
            XCTFail("Generated proposition display interaction XDM should be valid.")
            return
        }
    
        let eventType = try XCTUnwrap(propositionInteractionXdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionDisplay", eventType)

        let experience = try XCTUnwrap(propositionInteractionXdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["display"] as? Int)
        let propositionInteractionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(1, propositionInteractionDetailsArray.count)

        let propositionInteractionDetails = try XCTUnwrap(propositionInteractionDetailsArray[0])
        XCTAssertEqual(proposition.id, propositionInteractionDetails["id"] as? String)
        XCTAssertEqual(proposition.scope, propositionInteractionDetails["scope"] as? String)

        let scopeDetails = propositionInteractionDetails["scopeDetails"] as? [String: Any] ?? [:]
        XCTAssertTrue(proposition.scopeDetails == scopeDetails)

        let items = try XCTUnwrap(propositionInteractionDetails["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = items[0]
        XCTAssertEqual("246315", item["id"] as? String)
    }

    func testGenerateDisplayInteractionXdm_nilPropositionReference() throws {

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", proposition.id)
        XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition.scope)

        // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
        XCTAssertTrue(proposition.scopeDetails.isEmpty)

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        offer.proposition = nil // set proposition reference to nil
        let propositionInteractionXdm = offer.generateDisplayInteractionXdm()
        
        XCTAssertNil(propositionInteractionXdm)
    }

    func testGenerateTapInteractionXdm_validProposition() throws {

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", proposition.id)
        XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition.scope)

        // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
        XCTAssertTrue(proposition.scopeDetails.isEmpty)

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        guard let propositionInteractionXdm = offer.generateTapInteractionXdm() else {
            XCTFail("Generated proposition tap interaction XDM should be valid.")
            return
        }
        let eventType = try XCTUnwrap(propositionInteractionXdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionInteract", eventType)

        let experience = try XCTUnwrap(propositionInteractionXdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["interact"] as? Int)
        let propositionInteractionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(1, propositionInteractionDetailsArray.count)

        let propositionInteractionDetails = try XCTUnwrap(propositionInteractionDetailsArray[0])
        XCTAssertEqual(proposition.id, propositionInteractionDetails["id"] as? String)
        XCTAssertEqual(proposition.scope, propositionInteractionDetails["scope"] as? String)

        let scopeDetails = try XCTUnwrap(propositionInteractionDetails["scopeDetails"] as? [String: Any])
        XCTAssertTrue(proposition.scopeDetails == scopeDetails)

        let items = try XCTUnwrap(propositionInteractionDetails["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = items[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", item["id"] as? String)
    }

    func testGenerateTapInteractionXdm_validPropositionFromTarget() throws {

        guard
            let propositionData = PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", proposition.id)
        XCTAssertEqual("myMbox", proposition.scope)

        XCTAssertEqual(4, proposition.scopeDetails.count)
        XCTAssertEqual("TGT", proposition.scopeDetails["decisionProvider"] as? String)
        let sdActivity = proposition.scopeDetails["activity"] as? [String: Any]
        XCTAssertEqual("125589", sdActivity?["id"] as? String)
        let sdExperience = proposition.scopeDetails["experience"] as? [String: Any]
        XCTAssertEqual("0", sdExperience?["id"] as? String)
        let sdStrategies = proposition.scopeDetails["strategies"] as? [[String: Any]]
        XCTAssertEqual(1, sdStrategies?.count)
        XCTAssertEqual("0", sdStrategies?[0]["algorithmID"] as? String)
        XCTAssertEqual("0", sdStrategies?[0]["trafficType"] as? String)

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("246315", offer.id)

        guard let propositionInteractionXdm = offer.generateTapInteractionXdm() else {
            XCTFail("Generated proposition tap interaction XDM should be valid.")
            return
        }
        
        let eventType = try XCTUnwrap(propositionInteractionXdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionInteract", eventType)

        let experience = try XCTUnwrap(propositionInteractionXdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["interact"] as? Int)
        let propositionInteractionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(1, propositionInteractionDetailsArray.count)

        let propositionInteractionDetails = try XCTUnwrap(propositionInteractionDetailsArray[0])
        XCTAssertEqual(proposition.id, propositionInteractionDetails["id"] as? String)
        XCTAssertEqual(proposition.scope, propositionInteractionDetails["scope"] as? String)

        let scopeDetails = propositionInteractionDetails["scopeDetails"] as? [String: Any] ?? [:]
        XCTAssertTrue(proposition.scopeDetails == scopeDetails)

        let items = try XCTUnwrap(propositionInteractionDetails["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = items[0]
        XCTAssertEqual("246315", item["id"] as? String)
    }

    func testGenerateTapInteractionXdm_nilPropositionReference() throws {

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", proposition.id)
        XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition.scope)

        // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
        XCTAssertTrue(proposition.scopeDetails.isEmpty)

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        offer.proposition = nil // set proposition reference to nil
        let propositionInteractionXdm = offer.generateTapInteractionXdm()
        
        XCTAssertNil(propositionInteractionXdm)
    }

    func testDisplayed_validProposition() throws {
        let expectation = XCTestExpectation(description: "Offer displayed should dispatch an event.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "trackpropositions",
            "propositioninteractions": [
                "eventType": "decisioning.propositionDisplay",
                "decisioning": [
                    "propositions": [
                        [
                            "id": "de03ac85-802a-4331-a905-a57053164d35",
                            "scope": "eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
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

        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?
            .registerListener(type: testEvent.type,
                              source: testEvent.source) { event in
                XCTAssertEqual(testEvent.name, event.name)
                XCTAssertNotNil(event.data)
                XCTAssertEqual("trackpropositions", event.data?["requesttype"] as? String)

                let propositioninteractions = event.data?["propositioninteractions"] as? [String: Any]
                XCTAssertEqual("decisioning.propositionDisplay", propositioninteractions?["eventType"] as? String)

                let experience = propositioninteractions?["_experience"] as? [String: Any]
                let decisioning = experience?["decisioning"] as? [String: Any]
                let propositionEventType = decisioning?["propositionEventType"] as? [String: Any]
                XCTAssertEqual(1, propositionEventType?["display"] as? Int)
                let propositionDetailsArray = decisioning?["propositions"] as? [[String: Any]]
                guard let propositionDetailsData = propositionDetailsArray?[0] else {
                    XCTFail("Propositions array should contain proposition details data.")
                    return
                }
                XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", propositionDetailsData["id"] as? String)
                XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", propositionDetailsData["scope"] as? String)

                // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
                let scopeDetails = propositionDetailsData["scopeDetails"] as? [String: Any] ?? [:]
                XCTAssertTrue(scopeDetails.isEmpty)

                let items = propositionDetailsData["items"] as? [[String: Any]]
                XCTAssertEqual(1, items?.count)

                let item = items?[0]
                XCTAssertEqual("xcore:personalized-offer:1111111111111111", item?["id"] as? String)

                expectation.fulfill()
            }

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        offer.displayed()

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testDisplayed_validPropositionFromTarget() throws {
        let expectation = XCTestExpectation(description: "Offer displayed should dispatch an event.")
        expectation.assertForOverFulfill = true

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

        let testEventData: [String: Any] = [
            "requesttype": "trackpropositions",
            "propositioninteractions": [
                "eventType": "decisioning.propositionDisplay",
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

        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?
            .registerListener(type: testEvent.type,
                              source: testEvent.source) { event in
                XCTAssertEqual(testEvent.name, event.name)
                XCTAssertNotNil(event.data)
                XCTAssertEqual("trackpropositions", event.data?["requesttype"] as? String)

                let propositioninteractions = event.data?["propositioninteractions"] as? [String: Any]
                XCTAssertEqual("decisioning.propositionDisplay", propositioninteractions?["eventType"] as? String)

                let experience = propositioninteractions?["_experience"] as? [String: Any]
                let decisioning = experience?["decisioning"] as? [String: Any]
                let propositionEventType = decisioning?["propositionEventType"] as? [String: Any]
                XCTAssertEqual(1, propositionEventType?["display"] as? Int)

                let propositionDetailsArray = decisioning?["propositions"] as? [[String: Any]]
                guard let propositionDetailsData = propositionDetailsArray?[0] else {
                    XCTFail("Propositions array should contain proposition details data.")
                    return
                }
                XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", propositionDetailsData["id"] as? String)
                XCTAssertEqual("myMbox", propositionDetailsData["scope"] as? String)

                let scopeDetails = propositionDetailsData["scopeDetails"] as? [String: Any] ?? [:]
                XCTAssertTrue(testScopeDetails == scopeDetails)

                let items = propositionDetailsData["items"] as? [[String: Any]]
                XCTAssertEqual(1, items?.count)

                let item = items?[0]
                XCTAssertEqual("246315", item?["id"] as? String)

                expectation.fulfill()
        }

        guard
            let propositionData = PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("246315", offer.id)

        offer.displayed()

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testDisplayed_nilPropositionReference() throws {
        let expectation = XCTestExpectation(description: "Offer displayed should dispatch an event.")
        expectation.isInverted = true

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?
            .registerListener(type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent") { _ in
                expectation.fulfill()
            }

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        offer.proposition = nil // set proposition reference to nil.
        offer.displayed()

        // verify
        wait(for: [expectation], timeout: 2)
    }

    func testTapped_validProposition() throws {
        let expectation = XCTestExpectation(description: "Offer tap should dispatch an event.")
        expectation.assertForOverFulfill = true

        let testEventData: [String: Any] = [
            "requesttype": "trackpropositions",
            "propositioninteractions": [
                "eventType": "decisioning.propositionInteract",
                "decisioning": [
                    "propositions": [
                        [
                            "id": "de03ac85-802a-4331-a905-a57053164d35",
                            "scope": "eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==",
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

        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?
            .registerListener(type: testEvent.type,
                              source: testEvent.source) { event in
                XCTAssertEqual(testEvent.name, event.name)
                XCTAssertNotNil(event.data)
                XCTAssertEqual("trackpropositions", event.data?["requesttype"] as? String)

                let propositioninteractions = event.data?["propositioninteractions"] as? [String: Any]
                XCTAssertEqual("decisioning.propositionInteract", propositioninteractions?["eventType"] as? String)

                let experience = propositioninteractions?["_experience"] as? [String: Any]
                let decisioning = experience?["decisioning"] as? [String: Any]
                let propositionEventType = decisioning?["propositionEventType"] as? [String: Any]
                XCTAssertEqual(1, propositionEventType?["interact"] as? Int)

                let propositionDetailsArray = decisioning?["propositions"] as? [[String: Any]]
                guard let propositionDetailsData = propositionDetailsArray?[0] else {
                    XCTFail("Propositions array should contain proposition details data.")
                    return
                }
                XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", propositionDetailsData["id"] as? String)
                XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", propositionDetailsData["scope"] as? String)

                // To fix, once https://jira.corp.adobe.com/browse/CSMO-12405 is resolved.
                let scopeDetails = propositionDetailsData["scopeDetails"] as? [String: Any] ?? [:]
                XCTAssertTrue(scopeDetails.isEmpty)

                let items = propositionDetailsData["items"] as? [[String: Any]]
                XCTAssertEqual(1, items?.count)

                let item = items?[0]
                XCTAssertEqual("xcore:personalized-offer:1111111111111111", item?["id"] as? String)

                expectation.fulfill()
        }

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        offer.tapped()

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testTapped_validPropositionFromTarget() throws {
        let expectation = XCTestExpectation(description: "Offer tap should dispatch an event.")
        expectation.assertForOverFulfill = true

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

        let testEventData: [String: Any] = [
            "requesttype": "trackpropositions",
            "propositioninteractions": [
                "eventType": "decisioning.propositionInteract",
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

        let testEvent = Event(name: "Optimize Track Propositions Request",
                              type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent",
                              data: testEventData)

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?
            .registerListener(type: testEvent.type,
                              source: testEvent.source) { event in
                XCTAssertEqual(testEvent.name, event.name)
                XCTAssertNotNil(event.data)
                XCTAssertEqual("trackpropositions", event.data?["requesttype"] as? String)

                let propositioninteractions = event.data?["propositioninteractions"] as? [String: Any]
                XCTAssertEqual("decisioning.propositionInteract", propositioninteractions?["eventType"] as? String)

                let experience = propositioninteractions?["_experience"] as? [String: Any]
                let decisioning = experience?["decisioning"] as? [String: Any]
                let propositionEventType = decisioning?["propositionEventType"] as? [String: Any]
                XCTAssertEqual(1, propositionEventType?["interact"] as? Int)

                let propositionDetailsArray = decisioning?["propositions"] as? [[String: Any]]
                guard let propositionDetailsData = propositionDetailsArray?[0] else {
                    XCTFail("Propositions array should contain proposition details data.")
                    return
                }

                XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", propositionDetailsData["id"] as? String)
                XCTAssertEqual("myMbox", propositionDetailsData["scope"] as? String)

                let scopeDetails = propositionDetailsData["scopeDetails"] as? [String: Any] ?? [:]
                XCTAssertTrue(testScopeDetails == scopeDetails)

                let items = propositionDetailsData["items"] as? [[String: Any]]
                XCTAssertEqual(1, items?.count)

                let item = items?[0]
                XCTAssertEqual("246315", item?["id"] as? String)

                expectation.fulfill()
        }

        guard
            let propositionData = PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("246315", offer.id)

        offer.tapped()

        // verify
        wait(for: [expectation], timeout: 1)
    }

    func testTapped_nilPropositionReference() throws {
        let expectation = XCTestExpectation(description: "Offer tapped should dispatch an event.")
        expectation.isInverted = true

        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?
            .registerListener(type: "com.adobe.eventType.optimize",
                              source: "com.adobe.eventSource.requestContent") { _ in
                expectation.fulfill()
            }

        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)

        offer.proposition = nil // set proposition reference to nil.
        offer.tapped()

        // verify
        wait(for: [expectation], timeout: 2)
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
