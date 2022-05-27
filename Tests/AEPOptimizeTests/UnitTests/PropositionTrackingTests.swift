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

import AEPOptimize
import XCTest

extension PropositionTests {

    func testGenerateReferenceXdm_validProposition() throws {
        guard
            let propositionData = PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
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
            let propositionData = PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(Proposition.self, from: propositionData)
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
}
