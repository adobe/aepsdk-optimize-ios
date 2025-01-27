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

@objc(AEPConfigManager)
class ConfigManager: NSObject {
    @objc static let shared = ConfigManager()

    private enum ProcessState {
        case idle
        case fetching
        case fetched
    }

    private(set) var optimizeTimeout: TimeInterval = OptimizeConstants.DEFAULT_TIMEOUT
    private var processState: ProcessState = .idle
    private let queue = DispatchQueue(label: "com.adobe.configmanager.queue", attributes: .concurrent)

    override private init() {
        super.init()
    }

    /// Fetches the timeout configuration and updates the cached value.
    ///
    /// - Parameter completion: A closure invoked with the retrieved timeout value as a `TimeInterval`.
    func fetchTimeoutConfiguration(completion: ((TimeInterval) -> Void)? = nil) {
        queue.sync {
            guard processState == .idle else {
                completion?(optimizeTimeout)
                return
            }
        }

        queue.async(flags: .barrier) {
            self.processState = .fetching
        }

        let event = Event(name: "Get Timeout Request",
                          type: EventType.optimize,
                          source: EventSource.requestConfiguration,
                          data: nil)

        MobileCore.dispatch(event: event) { [weak self] responseEvent in
            guard let self = self else { return }

            self.queue.async(flags: .barrier) {
                guard let responseEvent = responseEvent,
                      let timeout = responseEvent.data?[OptimizeConstants.EventDataKeys.TIMEOUT] as? TimeInterval
                else {
                    self.processState = .idle
                    Log.warning(label: OptimizeConstants.LOG_TAG, "Timeout not found in the response event. Using default timeout.")
                    return
                }
                self.optimizeTimeout = timeout
                self.processState = .fetched
                Log.debug(label: OptimizeConstants.LOG_TAG, "Timeout value cached: \(timeout)")

                DispatchQueue.main.async {
                    completion?(self.optimizeTimeout)
                }
            }
        }
    }
}
