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

import AEPServices
import Foundation

// MARK: JSONSerialization extension

public extension JSONSerialization {
    static func getTypedData<T: Decodable>(from data: [String: Any]) -> T? {
        guard !data.isEmpty else {
            Log.warning(label: OptimizeConstants.LOG_TAG, "Cannot create \(String(describing: T.self)) object, provided data Dictionary is empty or null.")
            return nil
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) else {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot create \(String(describing: T.self)) object, unable to parse the data dictionary.")
            return nil
        }

        let object = try? JSONDecoder().decode(T.self, from: jsonData)
        if object == nil {
            Log.debug(label: OptimizeConstants.LOG_TAG,
                      "Cannot create \(String(describing: T.self)) object, unable to convert the  data dictionary to Offer.")
        }
        return object
    }
}
