//
//  UIImage+DemoQRCode.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (DemoQRCode)

/**
 [^zh]将文本内容渲染为二维码[$zh]
 [^en]Create QRCode image with str[$]
 */
+ (UIImage *)demo_qrCodeWithString:(NSString *)str width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
