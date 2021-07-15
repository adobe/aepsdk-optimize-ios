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
    private let LAUNCH_ENVIRONMENT_FILE_ID = ""
    private let OVERRIDE_DATASET_ID = ""
    
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        MobileCore.setLogLevel(.trace)

        MobileCore.registerExtensions([AEPEdgeIdentity.Identity.self, AEPIdentity.Identity.self, Lifecycle.self, Signal.self, Edge.self, Optimize.self, Assurance.self]) {
            MobileCore.configureWith(appId: self.LAUNCH_ENVIRONMENT_FILE_ID)
            
            // Update Configuration with override dataset identifier
            MobileCore.updateConfigurationWith(configDict: ["optimize.datasetId": self.OVERRIDE_DATASET_ID])
        }
        return true
    }
}

@main
struct AEPOptimizeDemoSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            HomeView()
                .onOpenURL{ url in
                    Assurance.startSession(url: url)
                }
        }
    }
}
