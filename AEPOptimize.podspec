Pod::Spec.new do |s|
  s.name             = "AEPOptimize"
  s.version          = "5.5.0"
  s.summary          = "Experience Platform Optimize extension for Adobe Experience Platform Mobile SDK. Written and maintained by Adobe."
  s.description      = <<-DESC
                        The Experience Platform Optimize extension provides APIs to enable real-time personalization workflows in the Adobe Experience Platform SDKs using Adobe Target or Adobe Journey Optimizer Offer Decisioning. 
                        DESC
  s.homepage         = "https://github.com/adobe/aepsdk-optimize-ios"
  s.platforms        = { :ios => "12.0", :tvos => "12.0" }
  s.license          = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author           = "Adobe Experience Platform SDK Team"
  s.source           = { :git => "https://github.com/adobe/aepsdk-optimize-ios.git", :tag => s.version.to_s }
  s.swift_version = '5.1'
  s.ios.deployment_target = '12.0'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.source_files          = 'Sources/**/*.swift'
  s.dependency 'AEPCore', '>= 5.4.0', '< 6.0.0'
  s.dependency 'AEPEdge', '>= 5.0.0', '< 6.0.0'
end
