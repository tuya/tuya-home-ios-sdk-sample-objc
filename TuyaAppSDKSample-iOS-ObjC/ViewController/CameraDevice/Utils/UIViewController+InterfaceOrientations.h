//
//  UIViewController+InterfaceOrientations.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (InterfaceOrientations)

- (void)demo_rotateWindowIfNeed;


- (UIInterfaceOrientation)demo_preferredOrientationForWindowRotation;

@end

NS_ASSUME_NONNULL_END
