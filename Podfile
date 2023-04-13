source 'https://cdn.cocoapods.org/'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'Masonry'
  
  pod 'SGQRCode', '~> 4.1.0'

  pod 'TuyaSmartHomeKit'
  pod 'TuyaSmartCameraKit'
  pod 'TuyaCameraUIKit'
  pod 'TuyaCloudStorageDebugger'
  
#  pod 'TuyaCameraAutomation'
  
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`
end
