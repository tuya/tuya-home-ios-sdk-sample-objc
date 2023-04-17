source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'

  pod 'ThingSmartHomeKit', '~> 5.0.0'
  pod 'ThingSmartCryption', :path => './'
end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # 消除文档警告
      config.build_settings['CLANG_WARN_DOCUMENTATION_COMMENTS'] = 'NO'
      # iOS 模拟器去除 arm64
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
