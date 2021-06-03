# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPOptimize'
project 'AEPOptimize.xcodeproj'

target 'AEPOptimize' do
  # Pods for AEPOptimize
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.1.4'
end

target 'UnitTests' do
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.1.4'
end

target 'FunctionalTests' do
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.1.4'
end

abstract_target 'shared' do
  pod 'AEPCore', :git => 'https://github.com/adobe/aepsdk-core-ios.git', :branch => 'dev-v3.1.4'
  pod 'AEPLifecycle'
  pod 'AEPIdentity'
  pod 'AEPSignal'
  pod 'AEPEdge'
  pod 'AEPEdgeConsent'
  pod 'AEPEdgeIdentity'
  pod 'AEPAssurance'
  pod 'ACPCore', :git => 'https://github.com/adobe/aepsdk-compatibility-ios.git', :branch => 'main'
  
  target 'AEPOptimizeDemoSwiftUI'
  target 'AEPOptimizeDemoObjC'
end

