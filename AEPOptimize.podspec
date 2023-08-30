Pod::Spec.new do |s|
  s.name             = "AEPOptimize"
  s.version          = "4.0.1"
  s.summary          = "Experience Platform Optimize extension for Adobe Experience Platform Mobile SDK. Written and maintained by Adobe."
  s.description      = <<-DESC
                        The Experience Platform Optimize extension provides APIs to enable real-time personalization workflows in the Adobe Experience Platform SDKs using Adobe Target or Adobe Journey Optimizer Offer Decisioning. 
                        DESC
  s.homepage         = "https://github.com/adobe/aepsdk-optimize-ios"
  s.license          = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author           = "Adobe Experience Platform SDK Team"
  s.source           = { :git => "https://github.com/adobe/aepsdk-optimize-ios.git", :tag => s.version.to_s }
  s.swift_version = '5.1'
  s.ios.deployment_target = '11.0'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.source_files          = 'Sources/**/*.swift'
  s.dependency 'AEPCore', '>= 4.0.0'
  s.dependency 'AEPEdge', '>= 4.0.0'
end
