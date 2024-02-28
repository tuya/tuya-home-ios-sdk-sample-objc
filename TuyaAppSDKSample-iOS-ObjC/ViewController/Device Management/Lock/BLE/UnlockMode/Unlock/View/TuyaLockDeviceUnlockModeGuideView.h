//
//  TuyaLockDeviceFingerGuideView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceUnlockModeGuideViewDelegate <NSObject>

- (void)startToEntry;

@end

@interface TuyaLockDeviceUnlockModeGuideView : UIView

@property (nonatomic, weak) id<TuyaLockDeviceUnlockModeGuideViewDelegate> delegate;

- (void)reloadTitle:(NSString *)title tipsStr:(NSString *)tipsStr;

@end

NS_ASSUME_NONNULL_END
