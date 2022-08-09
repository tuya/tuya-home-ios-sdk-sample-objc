source 'https://cdn.cocoapods.org/'
source 'https://github.com/tuya/TuyaPublicSpecs.git'

target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'TuyaSmartHomeKit'
  pod 'SGQRCode', '~> 4.1.0'
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`
end
