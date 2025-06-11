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

class OptimizePropositionTests: XCTestCase {

    func testProposition_valid() throws {
        // Decode
        guard
            let propositionData = PropositionsTestData.PROPOSITION_VALID.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", proposition.id)
        XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition.scope)
        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", offer.id)
        XCTAssertEqual("xcore:offer-activity:1111111111111111", proposition.activity["id"] as? String)
        XCTAssertEqual("8", proposition.activity["etag"] as? String)
        XCTAssertEqual("10", offer.etag)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-html", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 3), offer.type)
        XCTAssertEqual("<h1>This is a HTML content</h1>", offer.content)
        XCTAssertNil(offer.language)
        XCTAssertNil(offer.characteristics)

        // Encode
        guard let data = try? JSONEncoder().encode(proposition) else {
            XCTFail("Proposition data should be valid.")
            return
        }
        let propositionDict = try XCTUnwrap((try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] })
        let propositionAsDict = try XCTUnwrap(proposition.asDictionary())
        XCTAssertTrue(propositionAsDict == propositionDict)
    }

    func testProposition_validFromTarget() throws {
        // Decode
        guard
            let propositionData = PropositionsTestData.PROPOSITION_VALID_TARGET.data(using: .utf8),
            let proposition = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData)
        else {
            XCTFail("Proposition should be valid.")
            return
        }

        XCTAssertEqual("AT:eyJhY3Rpdml0eUlkIjoiMTI1NTg5IiwiZXhwZXJpZW5jZUlkIjoiMCJ9", proposition.id)
        XCTAssertEqual("myMbox", proposition.scope)

        XCTAssertEqual(4, proposition.scopeDetails.count)
        XCTAssertEqual("TGT", proposition.scopeDetails["decisionProvider"] as? String)
        let activity = proposition.scopeDetails["activity"] as? [String: Any]
        XCTAssertEqual("125589", activity?["id"] as? String)
        let experience = proposition.scopeDetails["experience"] as? [String: Any]
        XCTAssertEqual("0", experience?["id"] as? String)
        let strategies = proposition.scopeDetails["strategies"] as? [[String: Any]]
        XCTAssertEqual(1, strategies?.count)
        XCTAssertEqual("0", strategies?[0]["algorithmID"] as? String)
        XCTAssertEqual("0", strategies?[0]["trafficType"] as? String)

        XCTAssertEqual(1, proposition.offers.count)
        let offer = proposition.offers[0]
        XCTAssertEqual("246315", offer.id)
        XCTAssertTrue(offer.etag.isEmpty)
        XCTAssertEqual("https://ns.adobe.com/personalization/json-content-item", offer.schema)
        XCTAssertEqual(OfferType.init(rawValue: 1), offer.type)
        XCTAssertEqual("{\"device\":\"mobile\"}", offer.content)
        XCTAssertNil(offer.language)
        XCTAssertNil(offer.characteristics)

        // Encode
        guard let data = try? JSONEncoder().encode(proposition) else {
            XCTFail("Proposition data should be valid.")
            return
        }
        let propositionDict = try XCTUnwrap((try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] })
        let propositionAsDict = try XCTUnwrap(proposition.asDictionary())
        XCTAssertTrue(propositionAsDict == propositionDict)
    }

    func testProposition_invalid() throws {
        guard let propositionData = PropositionsTestData.PROPOSITION_INVALID.data(using: .utf8) else {
            XCTFail("Proposition json data should be valid.")
            return
        }
        let proposition = try? JSONDecoder().decode(OptimizeProposition.self, from: propositionData)
        XCTAssertNil(proposition)
    }
    
    func testInitFromData() throws {
        guard let propositionData = PropositionsTestData.PROPOSITION_VALID_WITH_LANGUAGE_AND_CHARACTERISTICS.data(using: .utf8) else {
            XCTFail("Proposition json data should be valid.")
            return
        }
        
        guard let data = try? JSONSerialization.jsonObject(with: propositionData, options: []) as? [String: Any] else {
            XCTFail("Unable to convert proposition json data to Dictionary.")
            return
        }
        
        let proposition = OptimizeProposition.initFromData(data)
        XCTAssertNotNil(proposition)
        XCTAssertEqual("de03ac85-802a-4331-a905-a57053164d35", proposition?.id)
        XCTAssertEqual("eydhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", proposition?.scope)
        XCTAssertEqual(1, proposition?.offers.count)
        XCTAssertEqual("xcore:personalized-offer:1111111111111111", proposition?.offers[0].id)
        XCTAssertTrue(proposition?.scopeDetails.isEmpty ?? false)
        XCTAssertEqual(proposition?.activity.count, 2)
        XCTAssertEqual("10", proposition?.offers[0].etag)
        XCTAssertEqual("https://ns.adobe.com/experience/offer-management/content-component-html", proposition?.offers[0].schema)
        XCTAssertEqual(OfferType.html, proposition?.offers[0].type)
        XCTAssertEqual("<h1>This is a HTML content</h1>", proposition?.offers[0].content)
        XCTAssertEqual("en-us", proposition?.offers[0].language?[0])
        XCTAssertEqual("true", proposition?.offers[0].characteristics?["mobile"])

    }
    
    func testInitFromData_emptyData() throws {
        let data = [String: Any]()
        let proposition = OptimizeProposition.initFromData(data)
        XCTAssertNil(proposition)
    }
    
    func testInitFromData_missingData() throws {
        let data = ["fake_key": "fake_value"] //Should return nil since Proposition id is missing
        let proposition = OptimizeProposition.initFromData(data)
        XCTAssertNil(proposition)
    }
}
