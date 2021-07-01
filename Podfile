# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

workspace 'AEPOptimize'
project 'AEPOptimize.xcodeproj'

target 'AEPOptimize' do
  # Pods for AEPOptimize
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

  target 'AEPOptimizeDemoSwiftUI'
  target 'AEPOptimizeDemoObjC'
end

