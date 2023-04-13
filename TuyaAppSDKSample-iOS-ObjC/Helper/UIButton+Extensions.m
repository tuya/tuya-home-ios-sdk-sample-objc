//
//  UIButton+Extensions.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "UIButton+Extensions.h"

@implementation UIButton (Extensions)
- (void)roundCorner {
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = true;
}
@end

