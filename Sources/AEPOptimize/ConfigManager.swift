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

import AEPCore
import AEPServices

@objc
class ConfigManager: NSObject {
    @objc static let shared = ConfigManager()

    private(set) var optimizeTimeout: TimeInterval = OptimizeConstants.DEFAULT_TIMEOUT
    private var isFetchingTimeout = false

    private override init() {
        super.init()
    }

    /// Fetches the timeout configuration and updates the cached value.
    ///
    /// - Parameter completion: A closure invoked with the retrieved timeout value as a `TimeInterval`.
    func fetchTimeoutConfiguration(completion: ((TimeInterval) -> Void)? = nil) {
        /// Ensure timeout is not already cached or being fetched
        guard optimizeTimeout == OptimizeConstants.DEFAULT_TIMEOUT, !isFetchingTimeout else {
            completion?(optimizeTimeout)
            return
        }

        /// Mark that the timeout fetch is in progress
        isFetchingTimeout = true

        let event = Event(name: "Get Timeout Request",
                          type: EventType.optimize,
                          source: EventSource.requestConfiguration,
                          data: nil)

        MobileCore.dispatch(event: event) {[weak self] responseEvent in
            guard let self else { return }
            if let responseEvent = responseEvent,
               let timeout = responseEvent.data?[OptimizeConstants.EventDataKeys.TIMEOUT] as? TimeInterval {
                self.optimizeTimeout = timeout
                Log.debug(label: OptimizeConstants.LOG_TAG, "Timeout value cached: \(timeout)")
            } else {
                Log.warning(label: OptimizeConstants.LOG_TAG, "Timeout not found in the response event. Using default timeout.")
            }

            /// Mark that the timeout fetch is complete
            self.isFetchingTimeout = false
            completion?(self.optimizeTimeout)
        }
    }
}
