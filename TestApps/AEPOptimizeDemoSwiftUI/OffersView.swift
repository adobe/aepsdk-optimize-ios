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
    @StateObject private var sequenceLog = SequenceLogManager()

    @State private var errorAlert = false
    @State private var errorMessage = ""
    @State private var useBatchTracking = false

    var body: some View {
        VStack {
            HeaderView(text: "Welcome to AEPOptimize Demo")
            List {
                Section(header: Text("Tracking Methods")) {
                    Toggle("Use Batch Tracking", isOn: $useBatchTracking)
                        .padding(.vertical, 5)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(useBatchTracking ? "Batch Tracking" : "Individual Tracking")
                            .font(.headline)
                        Text(useBatchTracking ?
                            "All offers are tracked together using Optimize.displayed()" :
                            "Each offer is tracked individually using offer.displayed() when it appears on screen")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                }

                Section(header: Text("Batching Test (6-call sequence)")) {
                    HStack {
                        CustomButtonView(buttonTitle: "Run Seq (6 calls)") {
                            runPropositionsSequence()
                        }
                        CustomButtonView(buttonTitle: "Clear Log") {
                            sequenceLog.clear()
                        }
                    }
                    if sequenceLog.logs.isEmpty {
                        Text("No log entries yet. Tap \"Run Seq (6 calls)\" to fire the measurement sequence.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(sequenceLog.logs.enumerated()), id: \.offset) { _, entry in
                                    Text(entry)
                                        .font(.system(.caption, design: .monospaced))
                                }
                            }
                        }
                        .frame(height: 160)
                    }
                }

                Section(header: Text("Text Offers")) {
                    if let textProposition = propositions.textProposition,
                       !textProposition.offers.isEmpty {
                        ForEach(textProposition.offers, id: \.self) { offer in
                            TextOfferView(text: offer.content,
                                          displayAction: useBatchTracking ? nil : { offer.displayed() },
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
                                           displayAction: useBatchTracking ? nil : { offer.displayed() },
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
                                          displayAction: useBatchTracking ? nil : { offer.displayed() },
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
                                          displayAction: useBatchTracking ? nil : { offer.displayed() },
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
                                              displayAction: useBatchTracking ? nil : { offer.displayed() },
                                              tapAction: { offer.tapped() })
                            } else {
                                TextOfferView(text: offer.content,
                                              displayAction: useBatchTracking ? nil : { offer.displayed() },
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

                    // Use all decision scopes but track in batch when enabled
                    let decisionScopes = [textDecisionScope, imageDecisionScope, htmlDecisionScope, jsonDecisionScope, targetScope]

                    Optimize.updatePropositions(for: decisionScopes,
                                             withXdm: ["xdmKey": "1234"],
                                             andData: data,
                                             timeout: 10) { data, error in
                        if let error = error as? AEPOptimizeError {
                            errorAlert = true
                            if let errorStatus = error.status {
                                errorMessage = (error.title ?? "Unexpected Error") + " : " + String(errorStatus)
                            } else {
                                errorMessage = error.title ?? "Unexpected Error"
                            }
                        }
                        
                        if useBatchTracking {
                            var offersArray: [Offer] = []
                            for data in data ?? [:] {
                                offersArray.append(contentsOf: data.value.offers)
                            }
                            if !offersArray.isEmpty {
                                Optimize.displayed(for: offersArray)
                                let xdmData = Optimize.generateDisplayInteractionXdm(for: offersArray)
                                print( xdmData ?? "No XDM data found for list of Offers")
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

    // MARK: - Batching test: 6-call sequence

    /// Decision scope deliberately not configured in any datastream/sandbox — expected to fail/404,
    /// exercising the error path alongside the success path within the same batch.
    private static let invalidMboxScope = DecisionScope(name: "invalidMbox")

    /// Measurement harness mirroring `aepsdk-optimize-android`'s test app `updatePropositionsSequence()`:
    /// fires six DISTINCT `updatePropositions` calls — call1 alone, then a pause of 20ms, then calls
    /// 2-6 back-to-back with no further delay — exercising different scope combinations plus repeats:
    ///   call1 = [mbox]              call2 = [ode]
    ///   call3 = [mbox] (repeat)     call4 = [invalidMbox]
    ///   call5 = [mbox, ode, invalidMbox]   call6 = [same three] (repeat)
    ///
    /// Firing all 6 back-to-back would race the hit queue's background executor: the first batch
    /// cycle reads however many events happen to already be queued when it wakes up, which varies
    /// run to run. The single pause after call1 (comfortably longer than the in-process time to
    /// schedule/run a batch cycle) lets that first cycle reliably grab only call1. Calls 2-6 are then
    /// fired with no gap between them so they enqueue essentially simultaneously and land in one
    /// consistent batch once call1's request clears.
    private func runPropositionsSequence() {
        let mbox = DecisionScope(name: targetSettings.targetMbox)
        let ode = DecisionScope(name: odeSettings.textEncodedDecisionScope)
        let invalid = Self.invalidMboxScope

        sequenceLog.addLog("Sequence | firing 6 distinct updatePropositions calls")
        DispatchQueue.global(qos: .userInitiated).async {
            updatePropositionsForScopes(callTag: "call1_mbox", scopes: [mbox])
            Thread.sleep(forTimeInterval: 0.02)
            updatePropositionsForScopes(callTag: "call2_ode", scopes: [ode])
            updatePropositionsForScopes(callTag: "call3_mbox", scopes: [mbox])
            updatePropositionsForScopes(callTag: "call4_invalidMbox", scopes: [invalid])
            updatePropositionsForScopes(callTag: "call5_all", scopes: [mbox, ode, invalid])
            updatePropositionsForScopes(callTag: "call6_all", scopes: [mbox, ode, invalid])
        }
    }

    /// Issues a single `updatePropositions` call for `scopes`, timing call -> callback and logging
    /// the elapsed time tagged with `callTag` for measurement. Does not touch `propositions` state
    /// (so caching across the sequence is observable via subsequent "Get Propositions" calls).
    private func updatePropositionsForScopes(callTag: String, scopes: [DecisionScope]) {
        let startTime = Date()
        Optimize.updatePropositions(for: scopes,
                                     withXdm: ["xdmKey": "1234"],
                                     andData: ["dataKey": "5678"],
                                     timeout: 10) { data, error in
            let elapsedMs = Int(Date().timeIntervalSince(startTime) * 1000)
            if let error = error {
                let description = (error as? AEPOptimizeError)?.title ?? error.localizedDescription
                sequenceLog.addLog("\(callTag) | fail | \(elapsedMs) ms | \(description)")
            } else {
                sequenceLog.addLog("\(callTag) | success | \(elapsedMs) ms | \(data?.count ?? 0) propositions")
            }
        }
    }
}

struct OffersView_Previews: PreviewProvider {
    static var previews: some View {
        OffersView(propositions: Propositions())
    }
}

