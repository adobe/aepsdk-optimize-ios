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

import Foundation

@objc(AEPExperienceData)
public class ExperienceData: NSObject {
    /// XDM formatted data
    @objc public let xdm: [String: Any]

    /// Optional free-form data
    @objc public let data: [String: Any]?

    /// Adobe Experience Platform dataset identifier, if not set the default dataset identifier set in the Edge Configuration is used
    @objc public let datasetIdentifier: String?

    /// Initializes Experience Data with the provided data.
    /// - Parameters:
    ///   - xdm:  XDM formatted data for this event, passed as a raw XDM Schema data dictionary.
    ///   - data: Any free form data in a [String : Any] dictionary structure.
    ///   - datasetIdentifier: The Experience Platform dataset identifier where this event should be sent to; if not provided, the default dataset identifier set in the Edge configuration is used.
    @objc
    public init(xdm: [String: Any], data: [String: Any]? = nil, datasetIdentifier: String? = nil) {
        self.xdm = xdm
        self.data = data
        self.datasetIdentifier = datasetIdentifier
    }

    internal func asDictionary() -> [String: Any]? {
        var dictionary: [String: Any] = [:]
        dictionary[PersonalizationConstants.EventDataKeys.XDM] = xdm

        if let data = data {
            dictionary[PersonalizationConstants.EventDataKeys.DATA] = data
        }
        if let datasetIdentifier = datasetIdentifier {
            dictionary[PersonalizationConstants.EventDataKeys.DATASET_ID] = datasetIdentifier
        }
        return dictionary.isEmpty ? nil : dictionary
    }
}
