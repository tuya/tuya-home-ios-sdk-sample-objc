//
//  Home.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Home : NSObject
+ (TuyaSmartHomeModel *)getCurrentHome;
+ (void)setCurrentHome:(nullable TuyaSmartHomeModel *)homeModel;
@end

NS_ASSUME_NONNULL_END
