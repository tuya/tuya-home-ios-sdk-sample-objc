//
//  TuyaLockDeviceFingerEntryView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceUnlockModeEntryErrorViewDelegate <NSObject>

- (void)retryAction;

@end

@interface TuyaLockDeviceUnlockModeEntryView : UIView

@property (nonatomic, assign) int total;
@property (nonatomic, assign) int step;

- (void)reloadStep:(int)step total:(int)total;

@end

@interface TuyaLockDeviceUnlockModeEntryErrorView : UIView

@property (nonatomic,weak) id<TuyaLockDeviceUnlockModeEntryErrorViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
