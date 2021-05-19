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
    
import AEPAssurance
import AEPEdgePersonalization

import SwiftUI

struct SettingsView: View {
    @State private var appId = ""
    @State private var assuranceSessionURL = ""
   
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack {
            HeaderView(text: "Settings")
            Form {
                Section(header: Text("Launch Environment File ID")) {
                    TextField("Enter your appId", text: $appId)
                }
                Section(header: Text("AEP Assurance Start URL")) {
                    TextField("Enter Assurance start URL", text: $assuranceSessionURL)
                        .onChange(of: assuranceSessionURL) {
                            if let url = URL(string: $0) {
                                AEPAssurance.startSession(url)
                            }
                        }
                }
                Section(header: Text("Personalization - ODE")) {
                    TextField("Enter Encoded Decision Scope (Text)", text: $appSettings.textEncodedDecisionScope)
                    TextField("Enter Encoded Decision Scope (Image)", text: $appSettings.imageEncodedDecisionScope)
                    TextField("Enter Encoded Decision Scope (Html)", text: $appSettings.htmlEncodedDecisionScope)
                    TextField("Enter Encoded Decision Scope (Json)", text: $appSettings.jsonEncodedDecisionScope)
                    TextField("Enter Target Mbox", text: $appSettings.targetMbox)
                }
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Personalization.extensionVersion)
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppSettings())
    }
}
