//
//  CameraDoorbellManager.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraDoorbellManager : NSObject

+ (instancetype)sharedInstance;

- (void)addDoorbellObserver;

- (void)removeDoorbellObserver;

- (void)hangupDoorBellCall;

- (void)setDoorbellRingTimeoutInterval:(NSInteger)timeoutInterval ofDevId:(NSString *)devId;

@end

NS_ASSUME_NONNULL_END
