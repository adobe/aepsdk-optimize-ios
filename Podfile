# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPOptimize'
project 'AEPOptimize.xcodeproj'

pod 'SwiftLint', '0.52.0'

# ==================
# SHARED POD GROUPS
# ==================
def lib_main
    pod 'AEPCore'
    pod 'AEPServices'
    pod 'AEPRulesEngine'
end

def lib_dev
    pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
    pod 'AEPServices', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
    pod 'AEPRulesEngine', :git => 'https://github.com/adobe/aepsdk-rulesengine-ios.git', :branch => 'dev-v5.0.0'
end

def app_main
  lib_main  
  pod 'AEPLifecycle'
  pod 'AEPSignal'
  pod 'AEPIdentity'
  pod 'AEPEdge'
  pod 'AEPEdgeConsent'
  pod 'AEPEdgeIdentity'
end

def app_dev
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPServices', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPRulesEngine', :git => 'https://github.com/adobe/aepsdk-rulesengine-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPLifecycle', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPSignal', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPIdentity', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPEdge', :git => 'https://github.com/adobe/aepsdk-edge-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPEdgeConsent', :git => 'https://github.com/adobe/aepsdk-edgeconsent-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPEdgeIdentity', :git => 'https://github.com/adobe/aepsdk-edgeidentity-ios.git', :branch => 'dev-v5.0.0'
end

# Local-checkout variant for validating the Edge iOS batching port against this machine's
# aepsdk-edge-ios working copy, without publishing anything. Not for CI/release use.
def app_local
  lib_main
  pod 'AEPLifecycle'
  pod 'AEPSignal'
  pod 'AEPIdentity'
  pod 'AEPEdge', :path => '/Users/sagar/Adobe/aepsdk-edge-ios'
  pod 'AEPEdgeConsent'
  pod 'AEPEdgeIdentity'
end

# ==================
# TARGET DEFINITIONS
# ==================
target 'AEPOptimize' do
  # Pods for AEPOptimize
  lib_main
end

target 'UnitTests' do
  lib_main
end

target 'FunctionalTests' do
  lib_main
end

target 'IntegrationTests' do
  app_local
end

target 'AEPOptimizeDemoAppExtension' do
  app_local
end

target 'AEPOptimizeDemoSwiftUI' do
  app_local
  pod 'AEPAssurance'
end

target 'AEPOptimizeDemoObjC' do
  app_local
  pod 'AEPAssurance'
end
