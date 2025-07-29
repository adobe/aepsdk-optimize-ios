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
import AEPServices
import Foundation

/// AEPOptimizeError class used to create AEPOptimizeError from error details received from Experience Edge.
@objc(AEPOptimizeError)
public class AEPOptimizeError: NSObject, Error, Codable {
    typealias HTTPResponseCodes = OptimizeConstants.HTTPResponseCodes
    public let type: String?
    public let status: Int?
    public let title: String?
    public let detail: String?
    public let report: [String: Any]?
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

    public init(type: String?, status: Int?, title: String?, detail: String?, report: [String: Any]?, aepError: AEPError? = nil) {
        self.type = type
        self.status = status
        self.title = title
        self.detail = detail
        self.report = report
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
            } else if (400 ... 499).contains(status) {
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
            report: nil,
            aepError: AEPError.callbackTimeout
        )
    }

    static func createAEPOptimizInvalidRequestError() -> AEPOptimizeError {
        AEPOptimizeError(
            type: nil,
            status: OptimizeConstants.ErrorData.InvalidRequest.STATUS,
            title: OptimizeConstants.ErrorData.InvalidRequest.TITLE,
            detail: OptimizeConstants.ErrorData.InvalidRequest.DETAIL,
            report: nil,
            aepError: AEPError.invalidRequest
        )
    }

    // MARK: - Codable Implementation

    enum CodingKeys: String, CodingKey {
        case type
        case status
        case title
        case detail
        case report
        case aepError
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decodeIfPresent(String.self, forKey: .type)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)

        // Handle [String: Any] using AnyCodable
        let anyCodableReport = try container.decodeIfPresent([String: AnyCodable].self, forKey: .report)
        report = AnyCodable.toAnyDictionary(dictionary: anyCodableReport)

        super.init()

        // Map error response to AEPError
        if let status = status {
            if status == HTTPResponseCodes.clientTimeout.rawValue {
                aepError = .callbackTimeout
            } else if serverErrors.contains(status) {
                aepError = .serverError
            } else if networkError.contains(status) {
                aepError = .networkError
            } else if (400 ... 499).contains(status) {
                aepError = .invalidRequest
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(detail, forKey: .detail)

        // Handle [String: Any] using AnyCodable
        try container.encodeIfPresent(AnyCodable.from(dictionary: report), forKey: .report)

        // Encode aepError as string representation
        try container.encode(String(describing: aepError), forKey: .aepError)
    }

    @objc
    public func asNSError() -> NSError {
        var info: [String: Any] = [:]
        info["status"] = status
        info["title"] = title
        info["detail"] = detail
        info["report"] = report
        info["aepError"] = aepError

        return NSError(domain: "com.adobe.AEPOptimize.AEPOptimizeError", code: status ?? -1, userInfo: info)
    }
}
