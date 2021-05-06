Pod::Spec.new do |s|
  s.name             = "AEPEdgePersonalization"
  s.version          = "1.0.0"
  s.summary          = "Experience Platform Personalization extension for Adobe Experience Platform Mobile SDK. Written and maintained by Adobe."
  s.description      = <<-DESC
                        The Experience Platform Personalization extension provides APIs to enable real-time personalization workflows in Adobe Experience Platform SDKs using the Edge decisioning services. 
                        DESC
  s.homepage         = "https://github.com/adobe/aepsdk-edgepersonalization-ios"
  s.license          = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author           = "Adobe Experience Platform SDK Team"
  s.source           = { :git => "https://github.com/adobe/aepsdk-edgepersonalization-ios.git", :tag => s.version.to_s }
  s.swift_version = '5.1'
  s.ios.deployment_target = '10.0'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }

  s.source_files          = 'Sources/**/*.swift'
  s.dependency 'AEPCore', '>= 3.1.1'
end
