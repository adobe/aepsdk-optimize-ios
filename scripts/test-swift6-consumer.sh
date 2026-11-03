#!/bin/bash

set -e # Any subsequent(*) commands which fail will cause the shell script to exit immediately

# Builds a minimal Swift 6 consumer of AEPOptimize to continuously protect the
# @Sendable / @preconcurrency public completion-handler contract.
#
# The consumer calls Optimize.updatePropositions, Optimize.getPropositions and
# Optimize.onPropositionsUpdate with *plain* closures from @MainActor code. Because
# the public completions are declared @Sendable, the compiler must accept these calls
# from a main-actor context without inferring main-actor isolation on the closure
# (the inference that causes the libdispatch "expected on main queue" crash at runtime).
# Because DecisionScope and OptimizeProposition are Sendable, the results can be
# handed to the main actor directly. If either annotation were dropped, this Swift 6
# build would fail.

PROJECT_NAME=Swift6Consumer

# Clean up.
rm -rf $PROJECT_NAME

mkdir -p $PROJECT_NAME && cd $PROJECT_NAME

# Create the package.
swift package init

# Create the Package.swift. The consumer target is compiled in Swift 6 language
# mode; dependencies keep their own declared language modes.
echo "// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription
let package = Package(
    name: \"Swift6Consumer\",
    defaultLocalization: \"en-US\",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: \"Swift6Consumer\",
            targets: [\"Swift6Consumer\"]
        )
    ],
    dependencies: [
        .package(name: \"AEPOptimize\", path: \"../\")
    ],
    targets: [
        .target(
            name: \"Swift6Consumer\",
            dependencies: [
                .product(name: \"AEPOptimize\", package: \"AEPOptimize\"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ])
    ]
)
" >Package.swift

# Replace the generated source with a @MainActor consumer that exercises the
# public completion-handler APIs with plain (non-@Sendable-annotated) closures.
rm -rf Sources/Swift6Consumer
mkdir -p Sources/Swift6Consumer
echo "import AEPOptimize
import Foundation

@MainActor
final class Swift6Consumer {
    var propositions: [DecisionScope: OptimizeProposition]?
    var lastError: Error?
    var updateCount = 0

    func exercise() {
        let scopes = [DecisionScope(name: \"mbox\")]

        // Plain closure from @MainActor code: compiles only because the public
        // completion is @Sendable (success and error paths).
        Optimize.updatePropositions(for: scopes, withXdm: nil, andData: nil) { propositions, error in
            Task { @MainActor in
                self.propositions = propositions
                self.lastError = error
            }
        }

        // Timeout overload, handing the Sendable result to the main queue.
        Optimize.updatePropositions(for: scopes, withXdm: nil, andData: nil, timeout: 5) { propositions, _ in
            DispatchQueue.main.async {
                self.propositions = propositions
            }
        }

        Optimize.getPropositions(for: scopes) { propositions, error in
            Task { @MainActor in
                self.propositions = propositions
                self.lastError = error
            }
        }

        Optimize.getPropositions(for: scopes, timeout: 5) { propositions, error in
            Task { @MainActor in
                self.propositions = propositions
                self.lastError = error
            }
        }

        // Permanent listener from @MainActor code.
        Optimize.onPropositionsUpdate { propositions in
            let count = propositions.count
            Task { @MainActor in
                self.updateCount = count
            }
        }
    }
}
" >Sources/Swift6Consumer/Swift6Consumer.swift

swift package update
swift package resolve

# This is necessary to avoid internal PIF error
swift package dump-pif > /dev/null
(xcodebuild clean -scheme Swift6Consumer -destination 'generic/platform=iOS' > /dev/null) || :

# Build for generic iOS device in Swift 6 language mode
echo '############# Build Swift 6 consumer for generic iOS device ###############'
xcodebuild build -scheme Swift6Consumer -destination 'generic/platform=iOS'

# Clean up.
cd ../
rm -rf $PROJECT_NAME
