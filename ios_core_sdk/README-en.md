# iOS 5.0 SDK User Guide
> **Note**
> If you are upgrading from a version below 5.x, please refer to the，请根据 [Migration Guide](https://developer.tuya.com/en/docs/app-development/migration_guide?id=Kci3zqm3wlcut) for upgrading.
> 
> f you have integrated the old SDK before but have now updated to the 5.0 SDK, please delete the old `t_s.bmp` security image file in your project and obtain a new App key for the 5.0 version from [the IoT platform](https://iot.tuya.com/oem/sdkList).

The iOS 5.0 SDK provides a unique security SDK for each App. Compared with the integration method of the old version, there is no need to download additional security images and the integration method is also more convenient.

This article explains how to integrate the 5.0 SDK into your project using `CocoaPods`:

## 1. Important file information
After unpacking the `ios_core_sdk.tar.gz` file, you will get the following two important file information:

- `Build`：Stores your App's dedicated security SDK, which is as important as the App key information. Please keep it properly to prevent resource leaks or public disclosure.
- `ThingSmartCryption.podspec`：Used for reference and integration of the 5.0 SDK.

It is recommended that these two files be stored at the same level as the `podfile` for easy reference and operation in the future.

## 2. Use SDK

Declare the following information in the `podfile`:

```
    # Build and obtain ThingSmartCryption from iot.tuya.com
    # After purchasing the official version, you need to re-build the SDK on the IoT platform and re-integrate it.
    # The `./` here represents the directory where `ios_core_sdk.tar.gz` is uncompressed and is at the same level as the `podfile`.
    # If you have a custom directory, you can modify the `path` to the custom directory level.

    pod 'ThingSmartCryption', :path => './'
```

If you have downloaded the `podfile` from the IoT platform, the SDK you choose will be declared for you in the `podfile`. You can quickly obtain the reference declaration of other feature SDKs in the podfile.


## 3. Integrate SDK
Execute `$ pod update` and the downloaded SDK will be automatically integrated into the iOS project.


## 4. Project settings
| **Parameter** | **Description** |  |
| ---- | ---- | ---- | 
| appKey | AppKey | IoT SDK Detail - Get Key| 
| secretKey | AppSecret |  IoT SDK Detail - Get Key | 
| bundleId | iOS App bundle id |  IoT SDK Detail - iOS App bundle id | 

- Open the project settings, click **Target** > **General**, and then modify **Bundle Identifier** to the iOS Bundle ID set on the Tuya IoT Platform

- Use `ThingSmartSDK` to initialize the SDK.
    - Objc:
        ```objc
        [[ThingSmartSDK sharedInstance] startWithAppKey:<#your_app_key#> secretKey:<#your_secret_key#>];
         ```

    - Swift:
        ```swift
         ThingSmartSDK.sharedInstance()?.start(withAppKey: <#your_app_key#>, secretKey: <#your_secret_key#>)
        ```


> **Note**
> In the Preparation topic, get the `AppKey`, `AppSecret` and `BundleId` for iOS. Make sure that the `BundleId`, `AppKey` and `AppSecret`, are consistent with those used on the Tuya IoT Platform. Any mismatch will cause the SDK development or demo app to be failed.


# Notes
**Development version SDK is for testing purposes only, not for commercial use. To use in commercial scenarios, please purchase the formal version SDK on the platform.**

**After purchasing the formal version SDK:**
1. You need to rebuild and download the formal version SDK on the IoT platform.
2. Reintegrate the formal version SDK into your project.
