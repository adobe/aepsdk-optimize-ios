// Delete this line
/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */

import AEPCore
import Foundation

/// AEPOptimizeError class used to create AEPOptimizeError from error details received from Experience Edge.
@objc(AEPOptimizeError)
public class AEPOptimizeError: NSObject, Error {
    typealias HTTPResponseCodes = OptimizeConstants.HTTPResponseCodes
    public let type: String?
    public let status: Int?
    public let title: String?
    public let detail: String?
    public var aepError = AEPError.unexpected

    private let serverErrors = [
        HTTPResponseCodes.tooManyRequests.rawValue,
        HTTPResponseCodes.internalServerError.rawValue,
        HTTPResponseCodes.serviceUnavailable.rawValue
    ]

    private let networkError = [
        HTTPResponseCodes.badGateway.rawValue,
        HTTPResponseCodes.gatewayTimeout.rawValue
    ]

    public init(type: String?, status: Int?, title: String?, detail: String?, aepError: AEPError? = nil) {
        self.type = type
        self.status = status
        self.title = title
        self.detail = detail
        if let aepError {
            self.aepError = aepError
        } else {
            // map edge error response to AEPError on the basis of status (if received)
            guard let status else {
                return
            }
            if status == HTTPResponseCodes.clientTimeout.rawValue {
                self.aepError = .callbackTimeout
            } else if serverErrors.contains(status) {
                self.aepError = .serverError
            } else if networkError.contains(status) {
                self.aepError = .networkError
            } else if (400...499).contains(status) {
                self.aepError = .invalidRequest
            }
        }
    }

    static func createAEPOptimizeTimeoutError() -> AEPOptimizeError {
        AEPOptimizeError(
            type: nil,
            status: OptimizeConstants.ErrorData.Timeout.STATUS,
            title: OptimizeConstants.ErrorData.Timeout.TITLE,
            detail: OptimizeConstants.ErrorData.Timeout.DETAIL,
            aepError: AEPError.callbackTimeout
        )
    }

    static func createAEPOptimizInvalidRequestError() -> AEPOptimizeError {
        AEPOptimizeError(
            type: nil,
            status: OptimizeConstants.ErrorData.InvalidRequest.STATUS,
            title: OptimizeConstants.ErrorData.InvalidRequest.TITLE,
            detail: OptimizeConstants.ErrorData.InvalidRequest.DETAIL,
            aepError: AEPError.invalidRequest
        )
    }
}
