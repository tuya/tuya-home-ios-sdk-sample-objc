//
//  TuyaZigbeeDeviceOncePasswordView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaZigbeeDeviceOncePasswordViewDelegate <NSObject>

- (void)createOncePwd:(NSString *)name;

@end

@interface TuyaZigbeeDeviceOncePasswordView : UIView

@property (nonatomic,weak) id<TuyaZigbeeDeviceOncePasswordViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
