//
//  TuyaLockDeviceSetRemoteVoicePasswordView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceSetRemoteVoicePasswordViewDelegate <NSObject>

- (void)errorPwd;

- (void)confirmAction:(NSString *)pwd;

@end

@interface TuyaLockDeviceSetRemoteVoicePasswordView : UIView

@property (nonatomic, weak) id<TuyaLockDeviceSetRemoteVoicePasswordViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
