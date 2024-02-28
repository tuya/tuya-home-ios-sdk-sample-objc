//
//  TuyaLockDeviceRecordFilterView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceRecordFilterViewDelegate <NSObject>

- (void)timeFilter;
- (void)typeFilter;
- (void)memberFilter;

@end

@interface TuyaLockDeviceRecordFilterView : UIView

@property (nonatomic, weak) id<TuyaLockDeviceRecordFilterViewDelegate> delegate;

@property (nonatomic, strong) UIButton *timeBtn;
@property (nonatomic, strong) UIButton *typeBtn;
@property (nonatomic, strong) UIButton *memberBtn;

@end

NS_ASSUME_NONNULL_END
