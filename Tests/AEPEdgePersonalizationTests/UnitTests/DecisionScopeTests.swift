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

import AEPEdgePersonalization
import XCTest

class DecisionScopeTests: XCTestCase {

    func testInit_validName() {
        guard let decisionScope = DecisionScope(name: "myMbox") else {
            XCTFail("Decision Scope should not be nil.")
            return
        }
        XCTAssertEqual("myMbox", decisionScope.name)
    }

    func testInit_emptyName() {
        let decisionScope = DecisionScope(name: "")
        XCTAssertNil(decisionScope)
    }
    
    func testConvenienceInit_withDefaultItemCount() {
        guard let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                                placementId: "xcore:offer-placement:1111111111111111")
        else {
            XCTFail("Decision Scope should not be nil.")
            return
        }
            
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScope.name)
    }
    
    func testConvenienceInit_withItemCount() {
        guard let decisionScope = DecisionScope(activityId:"xcore:offer-activity:1111111111111111",
                                                placementId: "xcore:offer-placement:1111111111111111",
                                                itemCount: 10)
        else {
            XCTFail("Decision Scope should not be nil.")
            return
        }
        
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEiLCJpdGVtQ291bnQiOjEwfQ==", decisionScope.name)
    }
    
    func testConvenienceInit_withEmptyActivityId() {
        let decisionScope = DecisionScope(activityId: "",
                                          placementId: "xcore:offer-placement:1111111111111111")
        XCTAssertNil(decisionScope)
    }
    
    func testConvenienceInit_withEmptyPlacementId() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "")
        XCTAssertNil(decisionScope)
    }
    
    func testConvenienceInit_withZeroItemCount() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111",
                                          itemCount: 0)
        XCTAssertNil(decisionScope)
    }

}
