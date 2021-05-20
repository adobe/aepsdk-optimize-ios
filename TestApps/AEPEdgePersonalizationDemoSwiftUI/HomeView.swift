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
    
import AEPEdgePersonalization
import SwiftUI

struct HomeView: View {
    @StateObject var odeSettings = OdeSettings()
    @StateObject var targetSettings = TargetSettings()
    @StateObject var propositions = Propositions()
    
    @State private var viewDidLoad = false
    
    init() {
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            OffersView(propositions: propositions)
                .tabItem {
                    Label("Offers", systemImage: "list.bullet.below.rectangle")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            if viewDidLoad == false {
                viewDidLoad = true
                Personalization.onPropositionsUpdate { propositionsDict in
                    guard let propositionsDict = propositionsDict else {
                        return
                    }
                    DispatchQueue.main.async {
                        if let textProposition = propositionsDict[DecisionScope(name: self.odeSettings.textEncodedDecisionScope)] {
                            self.propositions.textProposition = textProposition
                        }
                        if let imageProposition = propositionsDict[DecisionScope(name: self.odeSettings.imageEncodedDecisionScope)] {
                            self.propositions.imageProposition = imageProposition
                        }
                        if let htmlProposition = propositionsDict[DecisionScope(name: self.odeSettings.htmlEncodedDecisionScope)] {
                            self.propositions.htmlProposition = htmlProposition
                        }
                        if let jsonProposition = propositionsDict[DecisionScope(name: self.odeSettings.jsonEncodedDecisionScope)] {
                            self.propositions.jsonProposition = jsonProposition
                        }
                        if let targetProposition = propositionsDict[DecisionScope(name: self.targetSettings.targetMbox)] {
                            self.propositions.targetProposition = targetProposition
                        }
                    }
                }
            }
        }
        .environmentObject(odeSettings)
        .environmentObject(targetSettings)
    }
}

class OdeSettings: ObservableObject {
    @Published var textEncodedDecisionScope = ""
    @Published var imageEncodedDecisionScope = ""
    @Published var htmlEncodedDecisionScope = ""
    @Published var jsonEncodedDecisionScope = ""
    
}

class TargetSettings: ObservableObject {
    @Published var targetMbox: String
    @Published var mboxParameters: [String: String]
    @Published var profileParameters: [String: String]
    @Published var order: TargetOrder
    @Published var product: TargetProduct
    
    init() {
        targetMbox = ""
        mboxParameters = [:]
        profileParameters = [:]
        order = TargetOrder(orderId: "", orderTotal: "", purchasedProductIds: "")
        product = TargetProduct(productId: "", categoryId: "")
    }
}

class Propositions: ObservableObject {
    @Published var textProposition: Proposition?
    @Published var imageProposition: Proposition?
    @Published var htmlProposition: Proposition?
    @Published var jsonProposition: Proposition?
    @Published var targetProposition: Proposition?
    
    init() {
        textProposition = nil
        imageProposition = nil
        htmlProposition = nil
        jsonProposition = nil
        targetProposition = nil
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(OdeSettings())
            .environmentObject(TargetSettings())
    }
}
