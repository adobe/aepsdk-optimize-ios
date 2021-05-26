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
    
import AEPOptimize
import SwiftUI

struct HomeView: View {
    @StateObject var appSettings = AppSettings()
    @StateObject var propositionItems = PropositionItems()
    
    @State private var viewDidLoad = false
    
    init() {
        UITabBar.appearance().barTintColor = UIColor.white
    }
    
    var body: some View {
        TabView {
            OffersView(propositionItems: propositionItems)
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
                Optimize.onPropositionsUpdate { propositions in
                    guard let propositions = propositions else {
                        return
                    }
                    DispatchQueue.main.async {
                        if let textProposition = propositions[DecisionScope(name: self.appSettings.textEncodedDecisionScope)] {
                            self.propositionItems.textOffers = textProposition.offers.map {
                                $0.content
                            }
                        }
                        if let imageProposition = propositions[DecisionScope(name: self.appSettings.imageEncodedDecisionScope)] {
                            self.propositionItems.imageOffers = imageProposition.offers.map {
                                $0.content
                            }
                        }
                        if let htmlProposition = propositions[DecisionScope(name: self.appSettings.htmlEncodedDecisionScope)] {
                            self.propositionItems.htmlOffers = htmlProposition.offers.map {
                                $0.content
                            }
                        }
                        if let jsonProposition = propositions[DecisionScope(name: self.appSettings.jsonEncodedDecisionScope)] {
                            self.propositionItems.jsonOffers = jsonProposition.offers.map {
                                $0.content
                            }
                        }
                        if let targetProposition = propositions[DecisionScope(name: self.appSettings.targetMbox)] {
                            self.propositionItems.targetOffers = targetProposition.offers.map {
                                $0.content
                            }
                        }
                    }
                }
            }
        }
        .environmentObject(appSettings)
    }
}

class AppSettings: ObservableObject {
    @Published var textEncodedDecisionScope = ""
    @Published var imageEncodedDecisionScope = ""
    @Published var htmlEncodedDecisionScope = ""
    @Published var jsonEncodedDecisionScope = ""
    @Published var targetMbox = ""
}

class PropositionItems: ObservableObject {
    @Published var textOffers: [String] = []
    @Published var imageOffers: [String] = []
    @Published var htmlOffers: [String] = []
    @Published var jsonOffers: [String] = []
    @Published var targetOffers: [String] = []
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppSettings())
    }
}
