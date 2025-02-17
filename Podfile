source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'


platform :ios, '12.2'


target 'ThingSmartCameraLiteDemo' do
  
  # camera lite sdk
  pod 'ThingSmartCameraKitLite','1.0.4'
  
  # MQTTClient,you can user other versions
  pod 'MQTTClient', :git => 'https://registry.code.tuya-inc.top/iOSThirdParty/mqttclient.git',:branch => 'feature/batchSub-and-pubAck'
  
  # YUV player
  pod 'ThingSmartMediaUIKit'
  
  # HUD helper
  pod 'SVProgressHUD'
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "11.0"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"

      # replace to your teamid
      config.build_settings["DEVELOPMENT_TEAM"] = "your teamid"
    end
  end
end