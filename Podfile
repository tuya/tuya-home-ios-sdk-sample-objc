source 'https://cdn.cocoapods.org/'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'

  pod 'ThingSmartHomeKit', '>= 4.0.0'
 pod 'ThingFoundationKit'
 
  #扫地机
  pod 'ThingSmartSweeperKit','5.0.0'
  #pod 'TuyaSmartSweeperKit', :path => '../../Bundle/sweeper/TuyaSmartSweeperKit/TuyaSmartSweeperKit.podspec'
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`

  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
