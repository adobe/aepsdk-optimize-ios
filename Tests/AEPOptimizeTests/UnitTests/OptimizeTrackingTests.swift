// Delete this line
/*
Copyright 2025 Adobe. All rights reserved.
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

extension OptimizePublicAPITests {
    
    func testDisplayedOffers() {
        // setup
        let expectation = XCTestExpectation(description: "displayed should dispatch an event with expected data.")
        expectation.assertForOverFulfill = true
        
        // Create test offers
        guard let offer1 = try? JSONDecoder().decode(Offer.self, from: PropositionsTestData.OFFER_1.data(using: .utf8)!),
              let offer2 = try? JSONDecoder().decode(Offer.self, from: PropositionsTestData.OFFER_2.data(using: .utf8)!),
              let offer3 = try? JSONDecoder().decode(Offer.self, from: PropositionsTestData.OFFER_3.data(using: .utf8)!) else {
            XCTFail("Offers should be valid.")
            return
        }
        
        // Create propositions
        guard let proposition1 = try? JSONDecoder().decode(OptimizeProposition.self, from: PropositionsTestData.PROPOSITION_1.data(using: .utf8)!),
              let proposition2 = try? JSONDecoder().decode(OptimizeProposition.self, from: PropositionsTestData.PROPOSITION_2.data(using: .utf8)!) else {
            XCTFail("Propositions should be valid.")
            return
        }
        
        // Manually associate offers with propositions
        offer1.proposition = proposition1
        offer2.proposition = proposition1
        offer3.proposition = proposition2
        
        let testEvent = Event(name: "Optimize Track Propositions Request",
                             type: "com.adobe.eventType.optimize",
                             source: "com.adobe.eventSource.requestContent",
                             data: nil)
        
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                  source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertEqual(event.type, testEvent.type)
            XCTAssertEqual(event.source, testEvent.source)
            
            XCTAssertNotNil(event.data)
            XCTAssertEqual("trackpropositions", event.data?["requesttype"] as? String)

            let propositioninteractions = event.data?["propositioninteractions"] as? [String: Any]
            XCTAssertEqual("decisioning.propositionDisplay", propositioninteractions?["eventType"] as? String)

            let experience = propositioninteractions?["_experience"] as? [String: Any]
            let decisioning = experience?["decisioning"] as? [String: Any]
            let propositionEventType = decisioning?["propositionEventType"] as? [String: Any]
            XCTAssertEqual(1, propositionEventType?["display"] as? Int)
            
            // Verify propositions
            guard let propositions = decisioning?["propositions"] as? [[String: Any]] else {
                XCTFail("Propositions should be present")
                return
            }
            XCTAssertEqual(propositions.count, 2)
            
            // Verify propositions
            for proposition in propositions {
                if proposition["id"] as? String == offer1.proposition?.id {
                    XCTAssertEqual(proposition["scope"] as? String, offer1.proposition?.scope)
                }
                else if proposition["id"] as? String == offer3.proposition?.id {
                    XCTAssertEqual(proposition["scope"] as? String, offer3.proposition?.scope)
                }
                else {
                    XCTFail("Invalid proposition")
                }
            }
            
            expectation.fulfill()
        }
        
        // test
        Optimize.displayed(for: [offer1, offer2, offer3])
        
        // verify
        wait(for: [expectation], timeout: 2)
    }
    
    func testTrackPropositions_validPropositionInteractionsForDisplay_MultiplePropositions() throws {
        // setup
        let expectation = XCTestExpectation(description: "Track propositions request should dispatch event with expected data.")
        expectation.assertForOverFulfill = true
        
        // Create multiple offers from different propositions
        guard
            let propositionData1 = PropositionsTestData.PROPOSITION_VALID.data(using: .utf8),
            let proposition1 = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData1),
            let propositionData2 = PropositionsTestData.PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition2 = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData2)
        else {
            XCTFail("Propositions should be valid.")
            return
        }
        
        // Create offers from propositions
        let offer1 = proposition1.offers[0]
        let offer2 = proposition2.offers[0]
        
        // Manually associate offers with propositions
        offer1.proposition = proposition1
        offer2.proposition = proposition2
        
        let testEvent = Event(name: "Optimize Track Propositions Request",
                             type: "com.adobe.eventType.optimize",
                             source: "com.adobe.eventSource.requestContent",
                             data: nil)
        
        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                  source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertEqual(event.type, testEvent.type)
            XCTAssertEqual(event.source, testEvent.source)
            
            XCTAssertNotNil(event.data)
            XCTAssertEqual("trackpropositions", event.data?["requesttype"] as? String)

            let propositioninteractions = event.data?["propositioninteractions"] as? [String: Any]
            XCTAssertEqual("decisioning.propositionDisplay", propositioninteractions?["eventType"] as? String)

            let experience = propositioninteractions?["_experience"] as? [String: Any]
            let decisioning = experience?["decisioning"] as? [String: Any]
            let propositionEventType = decisioning?["propositionEventType"] as? [String: Any]
            XCTAssertEqual(1, propositionEventType?["display"] as? Int)
            
            // Verify propositions
            guard let propositions = decisioning?["propositions"] as? [[String: Any]] else {
                XCTFail("Propositions should be present")
                return
            }
            XCTAssertEqual(propositions.count, 2)
            
            // Verify propositions
            for proposition in propositions {
                if proposition["id"] as? String == offer1.proposition?.id {
                    XCTAssertEqual(proposition["scope"] as? String, offer1.proposition?.scope)
                }
                else if proposition["id"] as? String == offer2.proposition?.id {
                    XCTAssertEqual(proposition["scope"] as? String, offer2.proposition?.scope)
                }
                else {
                    XCTFail("Invalid proposition")
                }
            }
            
            expectation.fulfill()
        }
        
        // test
        Optimize.displayed(for: [offer1, offer2])
        
        // verify
        wait(for: [expectation], timeout: 2)
    }
    
    func testTrackPropositions_validPropositionInteractionsForDisplay_SameProposition() throws {
        // setup
        let expectation = XCTestExpectation(description: "Track propositions request should dispatch event with expected data.")
        expectation.assertForOverFulfill = true
        
        // Create multiple offers from same proposition
        guard let propositionData = PropositionsTestData.PROPOSITION_VALID.data(using: .utf8),
              let proposition = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        
        // Create two offers from same proposition
        let offer1 = proposition.offers[0]
        let offer2 = proposition.offers[0]
        
        // Manually associate offers with proposition
        offer1.proposition = proposition
        offer2.proposition = proposition
        
        let testEvent = Event(name: "Optimize Track Propositions Request",
                             type: "com.adobe.eventType.optimize",
                             source: "com.adobe.eventSource.requestContent",
                             data: nil)
        
        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                  source: testEvent.source) { event in
            XCTAssertEqual(event.name, testEvent.name)
            XCTAssertEqual(event.type, testEvent.type)
            XCTAssertEqual(event.source, testEvent.source)
            
            XCTAssertNotNil(event.data)
            XCTAssertEqual("trackpropositions", event.data?["requesttype"] as? String)

            let propositioninteractions = event.data?["propositioninteractions"] as? [String: Any]
            XCTAssertEqual("decisioning.propositionDisplay", propositioninteractions?["eventType"] as? String)

            let experience = propositioninteractions?["_experience"] as? [String: Any]
            let decisioning = experience?["decisioning"] as? [String: Any]
            let propositionEventType = decisioning?["propositionEventType"] as? [String: Any]
            XCTAssertEqual(1, propositionEventType?["display"] as? Int)
            
            // Verify propositions
            guard let propositions = decisioning?["propositions"] as? [[String: Any]] else {
                XCTFail("Propositions should be present")
                return
            }
            XCTAssertEqual(propositions.count, 1)
            
            // Verify proposition
            let propositionData = propositions[0]
            XCTAssertEqual(propositionData["id"] as? String, offer1.proposition?.id)
            XCTAssertEqual(propositionData["scope"] as? String, offer1.proposition?.scope)
            
            expectation.fulfill()
        }
        
        // test
        Optimize.displayed(for: [offer1, offer2])
        
        // verify
        wait(for: [expectation], timeout: 2)
    }
    
    func testTrackPropositions_validPropositionInteractionsForDisplay_EmptyOffers() {
        // setup
        let expectation = XCTestExpectation(description: "Track propositions request should not dispatch event for empty offers.")
        expectation.isInverted = true
        
        let testEvent = Event(name: "Optimize Track Propositions Request",
                             type: "com.adobe.eventType.optimize",
                             source: "com.adobe.eventSource.requestContent",
                             data: nil)
        
        // test
        EventHub.shared.getExtensionContainer(MockExtension.self)?.registerListener(type: testEvent.type,
                                                                                  source: testEvent.source) { _ in
            expectation.fulfill()
        }
        
        // test
        Optimize.displayed(for: [])
        
        // verify
        wait(for: [expectation], timeout: 1)
    }
    
}
