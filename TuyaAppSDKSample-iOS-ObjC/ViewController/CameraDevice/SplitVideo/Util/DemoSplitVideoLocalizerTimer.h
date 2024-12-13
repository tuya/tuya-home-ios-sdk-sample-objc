//
//  DemoSplitVideoLocalizerTimer.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoLocalizerTimer : NSObject

/// if repeats, set 0.
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval times:(NSUInteger)times target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo;

///only execute once.
+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo;


@property (nullable, nonatomic, readonly) id userInfo;

- (void)fire;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
