//
//  DemoSplitVideoUtil.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoUtil : NSObject

@end

UIKIT_EXTERN UIColor * DemoHexColor(uint32_t hex);
UIKIT_EXTERN UIColor * DemoHexAlphaColor(uint32_t hex, CGFloat alpha);

@interface UIColor (DemoColorExpand)

+ (UIColor *)demo_colorWithHex:(uint32_t)hex;
+ (UIColor *)demo_colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
