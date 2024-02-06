# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPOptimize'
project 'AEPOptimize.xcodeproj'

pod 'SwiftLint', '0.52.0'

target 'AEPOptimize' do
  # Pods for AEPOptimize
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
end

target 'UnitTests' do
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
end

target 'FunctionalTests' do
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
end

target 'IntegrationTests' do
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPEdge'
  pod 'AEPIdentity'
end

def shared_app
  pod 'AEPSignal'
  pod 'AEPAssurance'
end

def shared_all
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v5.0.0'
  pod 'AEPLifecycle'
  pod 'AEPIdentity'
  pod 'AEPEdge'
  pod 'AEPEdgeConsent'
  pod 'AEPEdgeIdentity'
end

abstract_target 'shared' do
  shared_all
  target 'AEPOptimizeDemoAppExtension'
  target 'AEPOptimizeDemoSwiftUI' do
    shared_app
  end
  target 'AEPOptimizeDemoObjC' do
    shared_app
  end
end

