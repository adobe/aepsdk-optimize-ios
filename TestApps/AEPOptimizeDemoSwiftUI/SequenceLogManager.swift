/*
Copyright 2026 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/

import Foundation

/// On-screen log sink for the "Run Seq (6 calls)" batching test button, mirroring the Android
/// test app's `LogManager` used for the same measurement harness. Entries are also printed to the
/// console (tagged "SEQCALL") so they show up in `xcrun simctl spawn booted log stream` output too.
class SequenceLogManager: ObservableObject {
    private let maxLogCount = 50

    @Published private(set) var logs: [String] = []

    /// Adds `message` to the on-screen log and prints it to the console. Safe to call from any thread.
    func addLog(_ message: String) {
        print("SEQCALL \(message)")
        DispatchQueue.main.async {
            if self.logs.count >= self.maxLogCount {
                self.logs.removeFirst()
            }
            self.logs.append(message)
        }
    }

    func clear() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
}
