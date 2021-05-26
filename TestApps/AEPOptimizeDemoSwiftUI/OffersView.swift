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
import AEPCore
import AEPIdentity
import AEPOptimize
import SwiftUI

import Foundation

struct OffersView: View {
    @EnvironmentObject var appSettings: AppSettings
    @ObservedObject var propositionItems: PropositionItems
    
    @State private var errorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            HeaderView(text: "Welcome to AEPOptimize Demo")
            List {
                Section(header: Text("Text Offers")) {
                    if !propositionItems.textOffers.isEmpty {
                        ForEach(propositionItems.textOffers, id: \.self) {
                            TextOfferView(text: $0)
                        }
                    } else {
                        TextOfferView(text: "Placeholder Text")
                    }
                }

                Section(header: Text("Image Offers")) {
                    if !propositionItems.imageOffers.isEmpty {
                        ForEach(propositionItems.imageOffers, id: \.self) {
                            ImageOfferView(url: $0)
                        }
                    } else {
                        ImageOfferView(url: "https://gblobscdn.gitbook.com/spaces%2F-Lf1Mc1caFdNCK_mBwhe%2Favatar-1585843848509.png?alt=media")
                    }
                }

                Section(header: Text("Html Offers")) {
                    if !propositionItems.htmlOffers.isEmpty {
                        ForEach(propositionItems.htmlOffers, id: \.self) {
                            HtmlOfferView(htmlString: $0)
                        }
                    } else {
                        HtmlOfferView(htmlString:
                                        """
                                        <html><body><p style="color:green; font-size:50px;position: absolute;top: 50%;left: 50%;margin-right: -50%;transform: translate(-50%, -50%)">Placeholder Html</p></body></html>
                                        """)
                    }
                }
                
                Section(header: Text("Json Offers")) {
                    if !propositionItems.jsonOffers.isEmpty {
                        ForEach(propositionItems.jsonOffers, id: \.self) {
                            TextOfferView(text: $0)
                        }
                    } else {
                        TextOfferView(text: """
                            { "placeholder": true }
                        """)
                    }
                }
                // Fix after format fix is available in prod
                Section(header: Text("Target Offers")) {
                    if !propositionItems.targetOffers.isEmpty {
                        ForEach(propositionItems.targetOffers, id: \.self) {
                            TextOfferView(text: $0)
                        }
                    } else {
                        TextOfferView(text: "Placeholder Target Text")
                    }
                }
            }
            Divider()
            HStack {
                CustomButtonView(buttonTitle: "Update Propositions") {
                    
                    let textDecisionScope = DecisionScope(name: appSettings.textEncodedDecisionScope)
                    let imageDecisionScope = DecisionScope(name: appSettings.imageEncodedDecisionScope)
                    let htmlDecisionScope = DecisionScope(name: appSettings.htmlEncodedDecisionScope)
                    let jsonDecisionScope = DecisionScope(name: appSettings.jsonEncodedDecisionScope)
                    let targetScope = DecisionScope(name: appSettings.targetMbox)

                    let experienceData = ExperienceData(xdm: ["xdmKey": "1234"], data: ["dataKey": "5678"], datasetIdentifier: "1234-5678")
                    
                    Optimize.updatePropositions(for: [
                        textDecisionScope,
                        imageDecisionScope,
                        htmlDecisionScope,
                        jsonDecisionScope,
                        targetScope
                    ], with: experienceData)
                }
                
                CustomButtonView(buttonTitle: "Get Propositions") {
                    
                    let textDecisionScope = DecisionScope(name: appSettings.textEncodedDecisionScope)
                    let imageDecisionScope = DecisionScope(name: appSettings.imageEncodedDecisionScope)
                    let htmlDecisionScope = DecisionScope(name: appSettings.htmlEncodedDecisionScope)
                    let jsonDecisionScope = DecisionScope(name: appSettings.jsonEncodedDecisionScope)
                    let targetScope = DecisionScope(name: appSettings.targetMbox)
    
                    Optimize.getPropositions(for: [
                        textDecisionScope,
                        imageDecisionScope,
                        htmlDecisionScope,
                        jsonDecisionScope,
                        targetScope
                    ]) {
                            propositionsDict, error in
    
                            if let error = error {
                                errorAlert = true
                                errorMessage = error.localizedDescription
                            } else {
                                
                                guard let propositionsDict = propositionsDict else {
                                    return
                                }
                                
                                DispatchQueue.main.async {
                                    
                                    if propositionsDict.isEmpty {
                                        propositionItems.textOffers = []
                                        propositionItems.imageOffers = []
                                        propositionItems.htmlOffers = []
                                        propositionItems.jsonOffers = []
                                        propositionItems.targetOffers = []
                                        return
                                    }
                                    
                                    if let textProposition = propositionsDict[textDecisionScope] {
                                        propositionItems.textOffers = textProposition.offers.map {
                                            $0.content
                                        }
                                    }

                                    if let imageProposition = propositionsDict[imageDecisionScope] {
                                        propositionItems.imageOffers = imageProposition.offers.map {
                                            $0.content
                                        }
                                    }

                                    if let htmlProposition = propositionsDict[htmlDecisionScope] {
                                        propositionItems.htmlOffers = htmlProposition.offers.map {
                                            $0.content
                                        }
                                    }
                                    
                                    if let jsonProposition = propositionsDict[jsonDecisionScope] {
                                        propositionItems.jsonOffers = jsonProposition.offers.map {
                                            $0.content
                                        }
                                    }
                                    
                                    if let targetProposition = propositionsDict[targetScope] {
                                        propositionItems.targetOffers = targetProposition.offers.map {
                                            $0.content
                                        }
                                    }
                                }
                            }
                    }
                }
                .alert(isPresented: $errorAlert) {
                    Alert(title: Text("Error: Get Propositions"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                CustomButtonView(buttonTitle: "Clear Propositions") {
                    Optimize.clearCachedPropositions()
                }
            }
            .padding(15)
        }
    }
}

struct OffersView_Previews: PreviewProvider {
    static var previews: some View {
        OffersView(propositionItems: PropositionItems())
    }
}
