//
//  TuyaLockDeviceRemoteSettingView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceRemoteSettingViewDelegate <NSObject>

- (void)remoteSwitchAction:(BOOL)value;

- (void)voiceSwitchAction:(BOOL)value;

- (void)permissionAction;

@end

@interface TuyaLockDeviceRemoteSettingView : UIView

@property (nonatomic, assign) BOOL isZigbee;
@property (nonatomic, strong) UILabel *permissionTitle;
@property (nonatomic, strong) UILabel *permissionValue;

@property (nonatomic, weak) id<TuyaLockDeviceRemoteSettingViewDelegate> delegate;

- (void)setRemoteHidden:(BOOL)hidden;
- (void)setVoiceHidden:(BOOL)hidden;

- (void)setRemoteValue:(BOOL)value;

- (void)setVoiceValue:(BOOL)value;

@end

NS_ASSUME_NONNULL_END
