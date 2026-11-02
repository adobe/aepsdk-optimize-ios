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

@testable import AEPCore

class MockExtension: NSObject, Extension {
    let name = "com.adobe.test.mockExtension"
    let friendlyName = "Mock Extension"
    static let extensionVersion = "1.0.0"
    let metadata: [String: String]? = nil
    let runtime: ExtensionRuntime

    required init(runtime: ExtensionRuntime) {
        self.runtime = runtime
    }

    // Tests set and reset these hooks on the main thread while the EventHub queue reads them, so the storage is guarded by a lock. That makes the nonisolated(unsafe) opt out for Swift 6 actually safe.
    private static let hooksLock = NSLock()
    nonisolated(unsafe) private static var _registrationClosure: (() -> Void)?
    nonisolated(unsafe) private static var _unregistrationClosure: (() -> Void)?
    nonisolated(unsafe) private static var _eventReceivedClosure: ((Event) -> Void)?

    static var registrationClosure: (() -> Void)? {
        get { hooksLock.lock(); defer { hooksLock.unlock() }; return _registrationClosure }
        set { hooksLock.lock(); defer { hooksLock.unlock() }; _registrationClosure = newValue }
    }

    static var unregistrationClosure: (() -> Void)? {
        get { hooksLock.lock(); defer { hooksLock.unlock() }; return _unregistrationClosure }
        set { hooksLock.lock(); defer { hooksLock.unlock() }; _unregistrationClosure = newValue }
    }

    static var eventReceivedClosure: ((Event) -> Void)? {
        get { hooksLock.lock(); defer { hooksLock.unlock() }; return _eventReceivedClosure }
        set { hooksLock.lock(); defer { hooksLock.unlock() }; _eventReceivedClosure = newValue }
    }

    static func reset() {
        registrationClosure = nil
        unregistrationClosure = nil
        eventReceivedClosure = nil
    }

    func onRegistered() {
        registerListener(type: EventType.wildcard, source: EventSource.wildcard) { event in
            if let closure = type(of: self).eventReceivedClosure {
                closure(event)
            }
        }

        if let closure = type(of: self).registrationClosure {
            closure()
        }
    }

    func onUnregistered() {
        if let closure = type(of: self).unregistrationClosure {
            closure()
        }
    }

    func readyForEvent(_: Event) -> Bool {
        return true
    }
}
