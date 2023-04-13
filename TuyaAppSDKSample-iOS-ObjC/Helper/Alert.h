//
//  Alert.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Alert : NSObject

+ (void)showBasicAlertOnVC:(UIViewController *)vc withTitle:(NSString *)title message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
