/*
 Copyright 2024 Adobe. All rights reserved.
 This file is licensed to you under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License. You may obtain a copy
 of the License at http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed under
 the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
 OF ANY KIND, either express or implied. See the License for the specific language
 governing permissions and limitations under the License.
 */
import AEPCore
import AEPServices
import Foundation

@objc
public extension Optimize {
    /// This API dispatches an event for the Edge extension to send an Experience Event to the Edge network with the display interaction data for list of offers passed.
    ///
    /// - Parameter offers: An array of offer.
    @objc(displayed:)
    static func displayed(for offers: [Offer]) {
        guard !offers.isEmpty else { return }

        // Get unique propositions from offers
        let uniquePropositions = Set(offers.compactMap { $0.proposition })

        // For each unique proposition, create a new proposition with only the relevant offers
        let filteredPropositions = uniquePropositions.compactMap { proposition -> OptimizeProposition? in
            // Filter offers to only include those from the original input
            let relevantOffers = proposition.offers.filter { offer in
                offers.contains { $0.id == offer.id }
            }

            // Dictionary representation of the proposition with clean offer data
            let propositionData: [String: Any] = [
                "id": proposition.id,
                "scope": proposition.scope,
                "scopeDetails": proposition.scopeDetails,
                "items": relevantOffers.map { offer in
                    [
                        "id": offer.id,
                        "schema": offer.schema,
                        "data": [
                            "id": offer.id,
                            "type": offer.type.rawValue,
                            "content": offer.content,
                            "language": offer.language,
                            "characteristics": offer.characteristics
                        ]
                    ]
                }
            ]

            return OptimizeProposition.initFromData(propositionData)
        }

        guard !filteredPropositions.isEmpty else { return }

        // Generate XDM data and track
        if let xdmData = OptimizeTrackingUtils.generateInteractionXdm(
            for: filteredPropositions,
            for: OptimizeConstants.JsonValues.EE_EVENT_TYPE_PROPOSITION_DISPLAY
        ) {
            OptimizeTrackingUtils.trackWithData(xdmData)
        }
    }
}
