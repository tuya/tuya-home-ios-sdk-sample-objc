source 'https://cdn.cocoapods.org/'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'


target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'
  pod 'Masonry'
  pod 'BlocksKit'
  
  pod 'ThingSmartLockKit', '5.2.0'
  
  pod 'ThingCameraSDK','4.8.0'
  pod 'ThingOpenSSLSDK','1.1.1-t.0'
  pod 'ThingSmartActivatorKit','5.1.3'
  pod 'ThingSmartBLEMeshKit','5.3.0.1'
  
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`

  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
