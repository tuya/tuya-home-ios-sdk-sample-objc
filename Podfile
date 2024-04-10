source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

target 'TuyaAppSDKSample-iOS-ObjC' do
  pod 'SVProgressHUD'
  pod 'SGQRCode', '~> 4.1.0'
  pod 'Masonry'
  
  pod 'ThingSmartHomeKit', '~> 5.11.0'
  pod 'ThingSmartCameraKit', '~> 5.11.0'
  pod 'ThingCameraUIKit'
  # 从 iot.tuya.com 构建和获取 ThingSmartCryption
  #  购买正式版后，需重新在 IoT 平台构建 SDK 并重新集成
  # ./ 代表将 `ios_core_sdk.tar.gz` 解压之后所在目录与 `podfile` 同级
  # 若自定义存放目录，可以修改 `path` 为自定义目录层级
  pod 'ThingSmartCryption', :path => './'

  pod 'ThingSmartLogger'

#  pod 'ThingCameraAutomation'
pod 'ThingCloudStorageDebugger', '~> 5.0.0'

end

post_install do |installer|
  `cd TuyaAppSDKSample-iOS-ObjC; [[ -f AppKey.h ]] || cp AppKey.h.default AppKey.h;`
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
