source 'https://cdn.cocoapods.org/'
#source 'https://github.com/tuya/TuyaPublicSpecs.git'
#source 'https://github.com/tuya/tuya-pod-specs.git'

source 'https://registry.code.tuya-inc.top/tuyaIOS/TYSpecsThird.git' # 三方库源
source 'https://registry.code.tuya-inc.top/tuyaIOS/TYSpecs.git'   # 私有库

target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'
  pod 'Masonry'
  pod 'BlocksKit'
  
  pod 'ThingSmartLockKit', '5.0.1'
  
  pod 'ThingCameraSDK','4.4.0'
  pod 'ThingOpenSSLSDK','111.28.0-rc.1'
  pod 'ThingSmartActivatorKit','4.2.0-develop.4'
  pod 'ThingSmartBLEMeshKit','4.4.6'
  
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`

  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
