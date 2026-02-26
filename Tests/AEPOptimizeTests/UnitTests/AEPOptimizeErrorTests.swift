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
        
        // Verify NSError properties for Objective-C
        XCTAssertEqual(AEPOptimizeError.errorDomain, "com.adobe.AEPOptimize.AEPOptimizeError")
        XCTAssertEqual(optimizeError.errorCode, 500)
        
        // Verify all fields are accessible in userInfo for Objective-C
        let errorUserInfo = optimizeError.errorUserInfo
        
        XCTAssertEqual(errorUserInfo["status"] as? Int, 500)
        XCTAssertEqual(errorUserInfo["title"] as? String, "Server Error")
        XCTAssertEqual(errorUserInfo["detail"] as? String, "Internal server error occurred")
        XCTAssertEqual(errorUserInfo["aepError"] as? AEPError, AEPError.serverError)
        
        let report = errorUserInfo["report"] as? [String: Any]
        XCTAssertEqual(report?["errorCode"] as? String, "E001")
    }
    
    func testAEPOptimizeError_WithRequestEventId() {
        // Setup
        let requestEventId = "test-request-event-id-12345"
        let optimizeError = AEPOptimizeError(
            type: "timeout-error",
            status: 408,
            title: "Request Timeout",
            detail: "Update proposition request resulted in a timeout.",
            report: nil,
            aepError: AEPError.callbackTimeout,
            requestEventId: requestEventId
        )
        
        // Verify requestEventId is correctly stored
        XCTAssertEqual(optimizeError.requestEventId, requestEventId)
        XCTAssertEqual(optimizeError.status, 408)
        XCTAssertEqual(optimizeError.title, "Request Timeout")
        XCTAssertEqual(optimizeError.aepError, AEPError.callbackTimeout)
    }
    
    func testAEPOptimizeError_RequestEventIdInErrorUserInfo() {
        // Setup
        let requestEventId = "edge-request-uuid-67890"
        let optimizeError = AEPOptimizeError(
            type: "edge-error",
            status: 500,
            title: "Server Error",
            detail: "Edge server error",
            report: nil,
            aepError: AEPError.serverError,
            requestEventId: requestEventId
        )
        
        // Verify requestEventId is accessible in errorUserInfo for Objective-C compatibility
        let errorUserInfo = optimizeError.errorUserInfo
        XCTAssertEqual(errorUserInfo["requestEventId"] as? String, requestEventId)
    }
    
    func testCreateAEPOptimizeTimeoutError_WithRequestEventId() {
        // Setup
        let requestEventId = "timeout-request-id-abc123"
        
        // Test
        let timeoutError = AEPOptimizeError.createAEPOptimizeTimeoutError(requestEventId: requestEventId)
        
        // Verify
        XCTAssertEqual(timeoutError.status, 408)
        XCTAssertEqual(timeoutError.title, "Request Timeout")
        XCTAssertEqual(timeoutError.detail, "Update/Get proposition request resulted in a timeout.")
        XCTAssertEqual(timeoutError.aepError, AEPError.callbackTimeout)
        XCTAssertEqual(timeoutError.requestEventId, requestEventId)
    }
    
    func testCreateAEPOptimizeInvalidRequestError_WithRequestEventId() {
        // Setup
        let requestEventId = "invalid-request-id-xyz789"
        
        // Test
        let invalidRequestError = AEPOptimizeError.createAEPOptimizInvalidRequestError(requestEventId: requestEventId)
        
        // Verify
        XCTAssertEqual(invalidRequestError.status, 400)
        XCTAssertEqual(invalidRequestError.title, "Invalid Request")
        XCTAssertEqual(invalidRequestError.detail, "Decision scopes, in event data, is either not present or empty.")
        XCTAssertEqual(invalidRequestError.aepError, AEPError.invalidRequest)
        XCTAssertEqual(invalidRequestError.requestEventId, requestEventId)
    }
    
    func testAEPOptimizeError_CodableWithRequestEventId() throws {
        // Setup
        let requestEventId = "codable-test-request-id"
        let originalError = AEPOptimizeError(
            type: "test-type",
            status: 400,
            title: "Test Title",
            detail: "Test Detail",
            report: ["key": "value"],
            aepError: AEPError.invalidRequest,
            requestEventId: requestEventId
        )
        
        // Encode
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(originalError)
        
        // Decode
        let decoder = JSONDecoder()
        let decodedError = try decoder.decode(AEPOptimizeError.self, from: encodedData)
        
        // Verify all properties including requestEventId survive encode/decode
        XCTAssertEqual(decodedError.type, originalError.type)
        XCTAssertEqual(decodedError.status, originalError.status)
        XCTAssertEqual(decodedError.title, originalError.title)
        XCTAssertEqual(decodedError.detail, originalError.detail)
        XCTAssertEqual(decodedError.requestEventId, requestEventId)
    }
}
