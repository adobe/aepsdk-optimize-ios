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

extension OptimizePropositionTests {

    func testGenerateReferenceXdm_validProposition() throws {
        guard
            let propositionData = PropositionsTestData.PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", proposition.id)

        let propositionReferenceXdm = proposition.generateReferenceXdm()
        XCTAssertFalse(propositionReferenceXdm.isEmpty)

        // verify no event type is present
        XCTAssertNil(propositionReferenceXdm["eventType"] as? String)

        let experience = propositionReferenceXdm["_experience"] as? [String: Any]
        let decisioning = experience?["decisioning"] as? [String: Any]
        XCTAssertEqual(proposition.id, decisioning?["propositionID"] as? String)
    }

    func testGenerateReferenceXdm_validPropositionFromTarget() throws {
        guard
            let propositionData = PropositionsTestData.PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", proposition.id)

        let propositionReferenceXdm = proposition.generateReferenceXdm()
        XCTAssertFalse(propositionReferenceXdm.isEmpty)

        // verify no event type is present
        XCTAssertNil(propositionReferenceXdm["eventType"] as? String)

        let experience = propositionReferenceXdm["_experience"] as? [String: Any]
        let decisioning = experience?["decisioning"] as? [String: Any]
        XCTAssertEqual(proposition.id, decisioning?["propositionID"] as? String)
    }
    
    func testGenerateInteractionXdm_multiplePropositions() throws {
        guard
            let propositionData1 = PropositionsTestData.PROPOSITION_VALID.data(using: .utf8),
            let proposition1 = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData1),
            let propositionData2 = PropositionsTestData.PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition2 = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData2)
        else {
            XCTFail("Proposition should be valid.")
            return
        }
        
        guard let propositionInteractionXdm = OptimizeTrackingUtils.generateInteractionXdm(for: [proposition1, proposition2],
                                                                              for: OptimizeConstants.JsonValues.EE_EVENT_TYPE_PROPOSITION_DISPLAY) else {
            XCTFail("Generated proposition interaction XDM should be valid.")
            return
        }
        
        let eventType = try XCTUnwrap(propositionInteractionXdm["eventType"] as? String)
        XCTAssertEqual("decisioning.propositionDisplay", eventType)

        let experience = try XCTUnwrap(propositionInteractionXdm["_experience"] as? [String: Any])
        let decisioning = try XCTUnwrap(experience["decisioning"] as? [String: Any])
        let propositionEventType = try XCTUnwrap(decisioning["propositionEventType"] as? [String: Any])
        XCTAssertEqual(1, propositionEventType["display"] as? Int)
        let propositionInteractionDetailsArray = try XCTUnwrap(decisioning["propositions"] as? [[String: Any]])
        XCTAssertEqual(2, propositionInteractionDetailsArray.count)

        let propositionInteractionDetails1 = try XCTUnwrap(propositionInteractionDetailsArray[0])
        XCTAssertEqual(proposition1.id, propositionInteractionDetails1["id"] as? String)
        XCTAssertEqual(proposition1.scope, propositionInteractionDetails1["scope"] as? String)

        let scopeDetails = propositionInteractionDetails1["scopeDetails"] as? [String: Any] ?? [:]
        XCTAssertTrue(scopeDetails == [:])

        XCTAssertEqual("xcore:offer-activity:1111111111111111", proposition1.activity["id"] as? String)
        XCTAssertEqual("8", proposition1.activity["etag"] as? String)

        let items = try XCTUnwrap(propositionInteractionDetails1["items"] as? [[String: Any]])
        XCTAssertEqual(1, items.count)

        let item = items[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", item["id"] as? String)
        
        let propositionInteractionDetails2 = try XCTUnwrap(propositionInteractionDetailsArray[1])
        XCTAssertEqual(proposition2.id, propositionInteractionDetails2["id"] as? String)
        XCTAssertEqual(proposition2.scope, propositionInteractionDetails2["scope"] as? String)

        let scopeDetails2 = propositionInteractionDetails2["scopeDetails"] as? [String: Any] ?? [:]
        XCTAssertTrue(proposition2.scopeDetails == scopeDetails2)

        let items2 = try XCTUnwrap(propositionInteractionDetails2["items"] as? [[String: Any]])
        XCTAssertEqual(1, items2.count)

        let item2 = items2[0]
        XCTAssertEqual("246315", item2["id"] as? String)
    }
}
