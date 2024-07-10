# iOS 5.0 SDK 集成指南
> **Note**
> 如果你是从 5.x 以下版本升级上来的用户，请根据 [迁移指南](https://developer.tuya.com/cn/docs/app-development/migration_guide?id=Kci3zqm3wlcut) 进行升级。
> 
> 若之前已经集成过旧版本 SDK，更新至 5.0 SDK 后，请删除项目中的旧版 `t_s.bmp` 安全图片文件，并从 [IoT 平台](https://iot.tuya.com/oem/sdkList) 上获取新的 5.0 版本 App 密钥

iOS 5.0 SDK 为每个 App 提供了唯一的安全 SDK，对比旧版本的集成方式，**无需额外下载安全图片**并且集成方式也更为便捷

本文介绍如何使用 `CocoaPods` 为你的项目集成 5.0 SDK：

## 1. 重要文件信息
解压 `ios_core_sdk.tar.gz` 后，您将得到以下两个重要文件信息：

- `Build`：存放您的 **App 专属安全 SDK**，它和 App 密钥信息一样重要，请妥善保管，**谨防资源泄漏或对外公开**
- `ThingSmartCryption.podspec`：用于在引用、集成使用 5.0 SDK

建议这两个文件与 `podfile` 保持同级存放，便于后续引用操作

## 2. 声明、使用 SDK

在 `podfile` 中声明如下信息:

```
    # 从 iot.tuya.com 构建和获取 ThingSmartCryption
    #  购买正式版后，需重新在 IoT 平台构建 SDK 并重新集成
    # ./ 代表将 `ios_core_sdk.tar.gz` 解压之后所在目录与 `podfile` 同级
    # 若自定义存放目录，可以修改 `path` 为自定义目录层级
    
    pod 'ThingSmartCryption', :path => './'
```

如果您从 IoT 平台下载了 `podfile` 文件，其中已为您声明好您选择的功能 SDK。您可以在 `podfile` 文件中快速获取其他功能 SDK 的引用声明。

## 3. 集成 SDK
执行 `$ pod update` 命令，将会自动集成下载的 SDK 到 iOS 工程项目中


## 4. 填写应用配置信息
| **参数** | **说明** |  **来源**|
| ---- | ---- | ---- | 
| appKey | App 唯一凭证信息 | IoT SDK 详情页 - 获取密钥| 
| secretKey | App 密钥 key |  IoT SDK 详情页 - 获取密钥 | 
| bundleId | iOS App 应用包名 |  IoT SDK 详情页 - iOS 应用包名 | 

- 打开项目设置，`Target > General`，修改 `Bundle Identifier` 为 [涂鸦 IoT 平台](https://iot.tuya.com/oem/sdkList) 对应的 iOS 包名。

- 在初始化代码中填写 `AppKey` 和 `AppSecret`
    - Objc:
        ```objc
        [[ThingSmartSDK sharedInstance] startWithAppKey:<#your_app_key#> secretKey:<#your_secret_key#>];
         ```

    - Swift:
        ```swift
         ThingSmartSDK.sharedInstance()?.start(withAppKey: <#your_app_key#>, secretKey: <#your_secret_key#>)
        ```


> **Note**
> 在集成 SDK 时，请确保 `BundleId`、`AppKey` 和 `AppSecret` 信息与 IoT 平台上的信息一致。如果有任何一个信息不匹配，将导致 SDK 无法使用


# 注意事项
**开发版 SDK 仅供开发使用，请勿直接商用；如需上架商用，请前往平台购买正式版**

**购买正式版 SDK 后**
1. 需在 IoT 平台上重新构建和下载正式版 SDK
2. 在项目中重新集成正式版 SDK

> 更多信息请访问 [《涂鸦开发服务协议》](https://www.tuya.com/vas/contract?file=oceanus%2Ffile%2Fed50a9ee-8780-578f-87ca-7123195afa45.md)