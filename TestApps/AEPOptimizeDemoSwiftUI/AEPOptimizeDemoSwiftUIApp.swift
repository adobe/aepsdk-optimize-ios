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
    
import AEPCore
import AEPIdentity
import AEPLifecycle
import AEPSignal

import AEPAssurance

import AEPEdge
import AEPEdgeConsent
import AEPEdgeIdentity

import AEPOptimize
import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    // Same Launch/Data Collection property used by aepsdk-optimize-android's test app
    // (MainApplication.kt's LAUNCH_ENVIRONMENT_FILE_ID) for apples-to-apples batching validation.
    private let ENVIRONMENT_FILE_ID = "3149c49c3910/0f12baf27522/launch-c219c0fa9543"
    private let OVERRIDE_DATASET_ID = ""

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        MobileCore.setLogLevel(.trace)

        MobileCore.registerExtensions([AEPEdgeIdentity.Identity.self, AEPIdentity.Identity.self, Lifecycle.self, Signal.self, Edge.self, Optimize.self, Assurance.self]) {
            MobileCore.configureWith(appId: self.ENVIRONMENT_FILE_ID)

            // Update Configuration with override dataset identifier, only if one was actually provided
            // (an empty override would otherwise clobber the real Launch-configured optimize.datasetId).
            if !self.OVERRIDE_DATASET_ID.isEmpty {
                MobileCore.updateConfigurationWith(configDict: ["optimize.datasetId": self.OVERRIDE_DATASET_ID])
            }
        }
        return true
    }

    
    @main
    struct AEPOptimizeDemoSwiftUIApp: App {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        @Environment(\.scenePhase) private var scenePhase
        
        var body: some Scene {
            WindowGroup {
                HomeView()
                    .onOpenURL{ url in
                        Assurance.startSession(url: url)
                    }
            }
            .onChange(of: scenePhase) { phase in
                switch phase {
                case .background:
                    print("Scene phase changed to background.")
                    MobileCore.lifecyclePause()
                case .active:
                    print("Scene phase changed to active.")
                    MobileCore.lifecycleStart(additionalContextData: nil)
                case .inactive:
                    print("Scene phase changed to inactive.")
                @unknown default:
                    print("Unknown scene phase.")
                }
            }
        }
    }
}
