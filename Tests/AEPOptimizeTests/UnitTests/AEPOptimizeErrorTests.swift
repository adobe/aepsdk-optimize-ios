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

class AEPOptimizeErrorTests: XCTestCase {

    func testAEPOptimizeError_BasicProperties() {
        // Setup
        let optimizeError = AEPOptimizeError(
            type: "invalid-request",
            status: 400,
            title: "Bad Request",
            detail: "Invalid decision scope provided",
            report: ["requestId": "12345"],
            aepError: AEPError.invalidRequest
        )
        
        // Verify
        XCTAssertEqual(optimizeError.type, "invalid-request")
        XCTAssertEqual(optimizeError.status, 400)
        XCTAssertEqual(optimizeError.title, "Bad Request")
        XCTAssertEqual(optimizeError.detail, "Invalid decision scope provided")
        XCTAssertEqual(optimizeError.aepError, AEPError.invalidRequest)
        XCTAssertEqual(optimizeError.report?["requestId"] as? String, "12345")
    }
    
    func testAsNSError_ObjectiveCBridging() {
        // Setup
        let optimizeError = AEPOptimizeError(
            type: "server-error",
            status: 500,
            title: "Server Error",
            detail: "Internal server error occurred",
            report: ["errorCode": "E001"],
            aepError: AEPError.serverError
        )
        
        // Test
        let nsError = optimizeError.asNSError()
        
        // Verify NSError properties for Objective-C
        XCTAssertEqual(nsError.domain, "com.adobe.AEPOptimize.AEPOptimizeError")
        XCTAssertEqual(nsError.code, 500)
        
        // Verify all fields are accessible in userInfo for Objective-C
        XCTAssertEqual(nsError.userInfo["status"] as? Int, 500)
        XCTAssertEqual(nsError.userInfo["title"] as? String, "Server Error")
        XCTAssertEqual(nsError.userInfo["detail"] as? String, "Internal server error occurred")
        XCTAssertEqual(nsError.userInfo["aepError"] as? AEPError, AEPError.serverError)
        
        let report = nsError.userInfo["report"] as? [String: Any]
        XCTAssertEqual(report?["errorCode"] as? String, "E001")
    }
}
