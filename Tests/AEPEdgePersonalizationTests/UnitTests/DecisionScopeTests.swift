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

@testable import AEPEdgePersonalization
import XCTest

class DecisionScopeTests: XCTestCase {

    func testInit_validName() {
        let decisionScope = DecisionScope(name: "myMbox")
        XCTAssertEqual("myMbox", decisionScope.name)
    }

    func testInit_emptyName() {
        let decisionScope = DecisionScope(name: "")
        XCTAssertEqual("", decisionScope.name)
    }

    func testConvenienceInit_withDefaultItemCount() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")

        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScope.name)
    }

    func testConvenienceInit_withItemCount() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111",
                                          itemCount: 10)

        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEiLCJpdGVtQ291bnQiOjEwfQ==", decisionScope.name)
    }

    func testConvenienceInit_withEmptyActivityId() {
        let decisionScope = DecisionScope(activityId: "",
                                          placementId: "xcore:offer-placement:1111111111111111")
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoiIiwicGxhY2VtZW50SWQiOiJ4Y29yZTpvZmZlci1wbGFjZW1lbnQ6MTExMTExMTExMTExMTExMSJ9", decisionScope.name)
    }

    func testConvenienceInit_withEmptyPlacementId() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "")
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoiIn0=", decisionScope.name)
    }

    func testConvenienceInit_withZeroItemCount() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111",
                                          itemCount: 0)
        XCTAssertEqual("eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==", decisionScope.name)
    }

    func testIsValid_scopeWithValidName() {
        let decisionScope = DecisionScope(name: "myMbox")
        XCTAssertTrue(decisionScope.isValid)
    }

    func testIsValid_scopeWithEmptyName() {
        let decisionScope = DecisionScope(name: "")
        XCTAssertFalse(decisionScope.isValid)
    }

    func testIsValid_scopeWithDefaultItemCount() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111")
        XCTAssertTrue(decisionScope.isValid)
    }

    func testIsValid_scopeWithItemCount() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111",
                                          itemCount: 10)
        XCTAssertTrue(decisionScope.isValid)
    }

    func testIsValid_withEmptyActivityId() {
        let decisionScope = DecisionScope(activityId: "",
                                          placementId: "xcore:offer-placement:1111111111111111")
        XCTAssertFalse(decisionScope.isValid)
    }

    func testIsValid_withEmptyPlacementId() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "")
        XCTAssertFalse(decisionScope.isValid)
    }

    func testIsValid_withZeroItemCount() {
        let decisionScope = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                          placementId: "xcore:offer-placement:1111111111111111",
                                          itemCount: 0)
        XCTAssertTrue(decisionScope.isValid)
    }

    func testIsEqual() {
        let decisionScope1 = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEifQ==")

        let decisionScope2 = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                           placementId: "xcore:offer-placement:1111111111111111")
        XCTAssertTrue(decisionScope1 == decisionScope2)
    }

    func testIsEqual_withItemCount() {
        let decisionScope1 = DecisionScope(name: "eyJhY3Rpdml0eUlkIjoieGNvcmU6b2ZmZXItYWN0aXZpdHk6MTExMTExMTExMTExMTExMSIsInBsYWNlbWVudElkIjoieGNvcmU6b2ZmZXItcGxhY2VtZW50OjExMTExMTExMTExMTExMTEiLCJpdGVtQ291bnQiOjEwMH0=")

        let decisionScope2 = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                           placementId: "xcore:offer-placement:1111111111111111",
                                           itemCount: 100)
        XCTAssertTrue(decisionScope1 == decisionScope2)
    }

    func testIsEqual_scopesNotEqual() {
        let decisionScope1 = DecisionScope(name: "myMbox")

        let decisionScope2 = DecisionScope(activityId: "xcore:offer-activity:1111111111111111",
                                           placementId: "xcore:offer-placement:1111111111111111")
        XCTAssertFalse(decisionScope1 == decisionScope2)
    }
}
