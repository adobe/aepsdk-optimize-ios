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
import AEPEdgeIdentity
import AEPOptimize
import SwiftUI

import Foundation

struct OffersView: View {
    @EnvironmentObject var odeSettings: OdeSettings
    @EnvironmentObject var targetSettings: TargetSettings
    @ObservedObject var propositions: Propositions
    
    @State private var errorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            HeaderView(text: "Welcome to AEPOptimize Demo")
            List {
                Section(header: Text("Text Offers")) {
                    if let textProposition = propositions.textProposition,
                       !textProposition.offers.isEmpty {
                        ForEach(textProposition.offers, id: \.self) { offer in
                            TextOfferView(text: offer.content,
                                          displayAction: { offer.displayed() },
                                          tapAction: { offer.tapped() })
                        }
                    } else {
                        TextOfferView(text: "Placeholder Text")
                    }
                }

                Section(header: Text("Image Offers")) {
                    if let imageProposition = propositions.imageProposition,
                       !imageProposition.offers.isEmpty {
                        ForEach(imageProposition.offers, id: \.self) { offer in
                            ImageOfferView(url: offer.content,
                                           displayAction: { offer.displayed() },
                                           tapAction: { offer.tapped() })
                        }
                    } else {
                        ImageOfferView(url: "https://gblobscdn.gitbook.com/spaces%2F-Lf1Mc1caFdNCK_mBwhe%2Favatar-1585843848509.png?alt=media")
                    }
                }

                Section(header: Text("Html Offers")) {
                    if let htmlProposition = propositions.htmlProposition,
                       !htmlProposition.offers.isEmpty {
                        ForEach(htmlProposition.offers, id: \.self) { offer in
                            HtmlOfferView(htmlString: offer.content,
                                          displayAction: { offer.displayed() },
                                          tapAction: { offer.tapped() })
                        }
                    } else {
                        HtmlOfferView(htmlString:
                                        """
                                        <html><body><p style="color:green; font-size:50px;position: absolute;top: 50%;left: 50%;margin-right: -50%;transform: translate(-50%, -50%)">Placeholder Html</p></body></html>
                                        """)
                    }
                }
                
                Section(header: Text("Json Offers")) {
                    if let jsonProposition = propositions.jsonProposition,
                       !jsonProposition.offers.isEmpty {
                        ForEach(jsonProposition.offers, id: \.self) { offer in
                            TextOfferView(text: offer.content,
                                          displayAction: { offer.displayed() },
                                          tapAction: { offer.tapped() })
                        }
                    } else {
                        TextOfferView(text: """
                            { "placeholder": true }
                        """)
                    }
                }

                Section(header: Text("Target Offers")) {
                    if let targetProposition = propositions.targetProposition,
                       !targetProposition.offers.isEmpty {
                        ForEach(targetProposition.offers, id: \.self) { offer in
                            if offer.type == OfferType.html {
                                HtmlOfferView(htmlString: offer.content,
                                              displayAction: { offer.displayed() },
                                              tapAction: { offer.tapped() })
                            } else {
                                TextOfferView(text: offer.content,
                                              displayAction: { offer.displayed() },
                                              tapAction: { offer.tapped() })
                            }
                        }
                    } else {
                        TextOfferView(text: "Placeholder Target Text")
                    }
                }
            }
            Divider()
            HStack {
                CustomButtonView(buttonTitle: "Update Propositions") {
                    
                    let textDecisionScope = DecisionScope(name: odeSettings.textEncodedDecisionScope)
                    let imageDecisionScope = DecisionScope(name: odeSettings.imageEncodedDecisionScope)
                    let htmlDecisionScope = DecisionScope(name: odeSettings.htmlEncodedDecisionScope)
                    let jsonDecisionScope = DecisionScope(name: odeSettings.jsonEncodedDecisionScope)
                    let targetScope = DecisionScope(name: targetSettings.targetMbox)

                    // Send a custom Identity in IdentityMap as primary identifier to Edge network in personalization query request.
                    let identityMap = IdentityMap()
                    identityMap.add(item: IdentityItem(id: "1111",
                                                       authenticatedState: AuthenticatedState.authenticated,
                                                       primary: true),
                                    withNamespace: "userCRMID")
                    Identity.updateIdentities(with: identityMap)
                    
                    var data: [String: Any] = [:]
                    var targetParams: [String: String] = [:]
                    if !targetScope.name.isEmpty {
                        if !targetSettings.mboxParameters.isEmpty {
                            targetParams.merge(targetSettings.mboxParameters) { _, new in new }
                        }
                        
                        if !targetSettings.profileParameters.isEmpty {
                            targetParams.merge(targetSettings.profileParameters) { _, new in new }
                        }
                        
                        if targetSettings.order.isValid() {
                            targetParams["orderId"] = targetSettings.order.orderId
                            targetParams["orderTotal"] = targetSettings.order.orderTotal
                            targetParams["purchasedProductIds"] = targetSettings.order.purchasedProductIds
                        }
                        
                        if targetSettings.product.isValid() {
                            targetParams["productId"] = targetSettings.product.productId
                            targetParams["categoryId"] = targetSettings.product.categoryId
                        }
                        
                        if !targetParams.isEmpty {
                            data["__adobe"] = [
                                "target": targetParams
                            ]
                        }
                    }
                    data["dataKey"] = "5678"

                    Optimize.updatePropositions(for: [
                        textDecisionScope,
                        imageDecisionScope,
                        htmlDecisionScope,
                        jsonDecisionScope,
                        targetScope
                    ], withXdm: ["xdmKey": "1234"], andData: data) { data, error in
                        if let error = error as? AEPOptimizeError {
                            errorAlert = true
                            if let errorStatus = error.status {
                                errorMessage = (error.title ?? "Unexpected Error") + " : " + String(errorStatus)
                            }else{
                                errorMessage = error.title ?? "Unexpected Error"
                            }
                        }
                    }
                        
                }
                .alert(isPresented: $errorAlert) {
                    Alert(title: Text("Error: Update Propositions"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
                
                CustomButtonView(buttonTitle: "Get Propositions") {
                    
                    let textDecisionScope = DecisionScope(name: odeSettings.textEncodedDecisionScope)
                    let imageDecisionScope = DecisionScope(name: odeSettings.imageEncodedDecisionScope)
                    let htmlDecisionScope = DecisionScope(name: odeSettings.htmlEncodedDecisionScope)
                    let jsonDecisionScope = DecisionScope(name: odeSettings.jsonEncodedDecisionScope)
                    let targetScope = DecisionScope(name: targetSettings.targetMbox)
    
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
                                        propositions.textProposition = nil
                                        propositions.imageProposition = nil
                                        propositions.htmlProposition = nil
                                        propositions.jsonProposition = nil
                                        propositions.targetProposition = nil
                                        return
                                    }
                                    
                                    if let textProposition = propositionsDict[textDecisionScope] {
                                        propositions.textProposition = textProposition
                                    }

                                    if let imageProposition = propositionsDict[imageDecisionScope] {
                                        propositions.imageProposition = imageProposition
                                    }

                                    if let htmlProposition = propositionsDict[htmlDecisionScope] {
                                        propositions.htmlProposition = htmlProposition
                                    }
                                    
                                    if let jsonProposition = propositionsDict[jsonDecisionScope] {
                                        propositions.jsonProposition = jsonProposition
                                    }
                                    
                                    if let targetProposition = propositionsDict[targetScope] {
                                        propositions.targetProposition = targetProposition
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
        OffersView(propositions: Propositions())
    }
}

