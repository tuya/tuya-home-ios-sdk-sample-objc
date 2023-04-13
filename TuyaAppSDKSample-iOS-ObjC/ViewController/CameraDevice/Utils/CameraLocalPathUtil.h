//
//  CameraLocalPathUtil.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraLocalPathUtil : NSObject

/**
 生成一个随机本地地址
 */
+ (NSString *)generateRandomLocalPath;

@end

NS_ASSUME_NONNULL_END
