source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'

  pod 'ThingSmartHomeKit', '~> 5.0.0'
  pod 'ThingSmartCameraKit', '~> 5.6.0'
  pod 'ThingCameraUIKit', '~> 5.0.0'
  pod 'ThingCloudStorageDebugger', '~> 5.0.0'

#  pod 'ThingCameraAutomation'

end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`
end
