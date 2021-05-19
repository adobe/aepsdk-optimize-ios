# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPEdgePersonalization'
project 'AEPEdgePersonalization.xcodeproj'

target 'AEPEdgePersonalization' do
  # Pods for AEPEdgePersonalization
  pod 'AEPCore'
end

target 'UnitTests' do
  pod 'AEPCore'
end

target 'FunctionalTests' do
  pod 'AEPCore'
end

abstract_target 'shared' do
  pod 'AEPCore'
  pod 'AEPLifecycle'
  pod 'AEPIdentity'
  pod 'AEPSignal'
  pod 'AEPEdge'
  pod 'AEPEdgeConsent'
  pod 'AEPEdgeIdentity'
  pod 'AEPAssurance'
  pod 'ACPCore', :git => 'https://github.com/adobe/aepsdk-compatibility-ios.git', :branch => 'main'
  
  target 'AEPEdgePersonalizationDemoSwiftUI'
  target 'AEPEdgePersonalizationDemoObjC'
end

