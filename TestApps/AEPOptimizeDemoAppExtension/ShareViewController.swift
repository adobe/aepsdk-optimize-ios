/*
Copyright 2022 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/
    

import UIKit
import Social
import AEPCore
import AEPIdentity
import AEPLifecycle
import AEPEdge
import AEPEdgeConsent
import AEPEdgeIdentity

import AEPOptimize

///
/// This Share Extension is set up to handle sharing Images from the camera roll.
/// To test, simply run the AEPOptimizeDemoAppExtension app extension and select the Photos app on device or simulator.
/// Then attempt to share a photo and select the AEPOptimizeDemoAppSwiftUI from the share menu
/// This shareViewController will then be presented and can be handled appropriately.
/// 
class ShareViewController: SLComposeServiceViewController {

    private let LAUNCH_ENVIRONMENT_FILE_ID = ""
    private let OVERRIDE_DATASET_ID = ""

    override func presentationAnimationDidFinish() {
        super.presentationAnimationDidFinish()
        MobileCore.setLogLevel(.trace)

        MobileCore.registerExtensions([AEPEdgeIdentity.Identity.self, AEPIdentity.Identity.self, Lifecycle.self, Edge.self, Optimize.self]) {
            MobileCore.configureWith(appId: self.LAUNCH_ENVIRONMENT_FILE_ID)

            // Update Configuration with override dataset identifier
            MobileCore.updateConfigurationWith(configDict: ["optimize.datasetId": self.OVERRIDE_DATASET_ID])
        }
    }
    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
