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

class StringInterpolation_PersonalizationTests: XCTestCase {

    private let ACTIVITY_ID = "xcore:offer-activity:1111111111111111"
    private let PLACEMENT_ID = "xcore:offer-placement:1111111111111111"
    private let DEFAULT_ITEM_COUNT: UInt = 1

    func testAppendInterpolation_defaultItemCount() {
        let message = "\(activityId: ACTIVITY_ID, placementId: PLACEMENT_ID, itemCount: DEFAULT_ITEM_COUNT)"
        XCTAssertEqual("{\"activityId\":\"xcore:offer-activity:1111111111111111\",\"placementId\":\"xcore:offer-placement:1111111111111111\"}", message)
    }

    func testAppendInterpolation_withItemCount() {
        let message = "\(activityId: ACTIVITY_ID, placementId: PLACEMENT_ID, itemCount: 100)"
        XCTAssertEqual("{\"activityId\":\"xcore:offer-activity:1111111111111111\",\"placementId\":\"xcore:offer-placement:1111111111111111\",\"itemCount\":100}", message)
    }

    func testAppendInterpolation_withZeroItemCount() {
        let message = "\(activityId: ACTIVITY_ID, placementId: PLACEMENT_ID, itemCount: 0)"
        XCTAssertEqual("{\"activityId\":\"xcore:offer-activity:1111111111111111\",\"placementId\":\"xcore:offer-placement:1111111111111111\",\"itemCount\":0}", message)
    }
}
