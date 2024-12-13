//
//  DemoSplitVideoUtil.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoUtil.h"

@implementation DemoSplitVideoUtil

@end

inline UIColor * DemoHexColor(uint32_t hex) {
    return [UIColor demo_colorWithHex:hex];
}

inline UIColor * DemoHexAlphaColor(uint32_t hex, CGFloat alpha) {
    return [UIColor demo_colorWithHex:hex alpha:alpha];
}

@implementation UIColor (DemoColorExpand)

+ (UIColor *)demo_colorWithHex:(uint32_t)hex {
    CGFloat preAlpha = ((float)((hex & 0xFF000000) >> 24))/255.0f;
    CGFloat alpha = preAlpha > 0 ? preAlpha : 1;
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:alpha];
}

+ (UIColor *)demo_colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0 alpha:alpha];
}


@end
