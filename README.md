# Maintenance Discontinuation Notice

This Demo project is no longer maintained as of version 5.8. Please use the [Swift version Demo]((https://github.com/tuya/tuya-home-ios-sdk-sample-swift)
) https://github.com/tuya/tuya-home-ios-sdk-sample-swift instead.


---

# Tuya iOS Smart Life App SDK Sample for Objective-C

This sample demonstrates the use of Tuya iOS Smart Life App SDK to build an IoT app from scratch. Tuya iOS Smart Life App SDK is divided into several function groups to give developers a clear insight into the implementation for different features, including the user registration process, home management for different users, device network configuration, and controls. For device network configuration, the EZ mode and AP mode are implemented. This allows developers to pair devices over Wi-Fi and control the devices over LAN and MQTT. For device control, a common panel is used to send and receive any type of data points.

![Tuya Smart app](https://github.com/tuya/tuya-home-ios-sdk-sample-objc/raw/main/screenshot.png)

## Self-developed Smart Life App Service
Self-Developed Smart Life App is one of Tuya’s IoT app development solutions. This solution provides the services that enable connections between the app and the cloud. It also supports a full range of services and capabilities that customers can use to independently develop mobile apps. The Smart Life App SDK used in this sample is included in the Self-developed Smart Life App Service.

Self-Developed Smart Life App is classified into the **Development** and **Official** editions:

- **Self-Developed App Development**: provided for a free trial. It supports up to 1 million cloud API calls per month and up to 100 registered end users in total.

- **Self-Developed App Official**: provided for commercial use and costs $5,000/year (¥33,500/year) for the initial subscription and $2,000/year (¥13,500/year) for subsequent annual renewal. It is supplied with the Custom Domain Name service and up to 100 million cloud API calls per month.

For more information, please check the [Pricing](https://developer.tuya.com/en/docs/app-development/app-sdk-price?id=Kbu0tcr2cbx3o).

## Prerequisites

- Xcode 12.0 and later
- iOS 12 and later

## Use the sample

1. The Tuya iOS Smart Life App SDK is distributed through [CocoaPods](http://cocoapods.org/) and other dependencies in this sample. Make sure that you have installed CocoaPods. If not, run the following command to install CocoaPods first:

```bash
sudo gem install cocoapods
pod setup
```

2. Clone or download this sample, change the directory to the one that includes **Podfile**, and then run the following command:

```bash
pod install
```

3. This sample requires you to have a pair of keys from [Tuya IoT Platform](https://developer.tuya.com/), and register a developer account if you don't have one. For more details, please check this tutorial: [Preparation](https://developer.tuya.com/en/docs/app-development/preparation?id=Ka69nt983bhh5)
4. Open the `TuyaAppSDKSample-iOS-ObjC.xcworkspace` pod generated for you.
5. Fill in the AppKey and AppSecret in the **AppKey.h** file.

```objective-c
#define APP_KEY @"<#AppKey#>"
#define APP_SECRET_KEY @"<#SecretKey#>"
```
**Note**: The bundle ID, AppKey and AppSecret must be the same as your app on the [Tuya IoT Platform](https://iot.tuya.com). Otherwise, the sample cannot request the API.

For more details, please check this tutorial [Fast Integration with Smart Life App SDK for iOS](https://developer.tuya.com/en/docs/app-development/integrate-sdk?id=Ka5d52ewngdoi).

## 5.x migration guide

> The test was conducted on Ruby version 2.7.2p137.

The Ruby script `/Tools/translator/translator.rb` can translate the code in your project that contains Tuya identifiers API to Thing identifiers API. For more information on migrating to version 5.x, please refer to the [migration guide](https://developer.tuya.com/en/docs/app-development/migration_guide?id=Kci3zqm3wlcut). To run the script, use the following command:

```ruby
sudo ruby translator.rb [you project path]
```

## References
For more information about Tuya iOS HomeSDK, see [App SDK](https://developer.tuya.com/en/docs/app-development).
