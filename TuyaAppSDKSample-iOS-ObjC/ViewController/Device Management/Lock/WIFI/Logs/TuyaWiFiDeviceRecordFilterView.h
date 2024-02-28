//
//  TuyaWiFiDeviceRecordFilterView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaWiFiDeviceRecordFilterViewDelegate <NSObject>

- (void)alarmFilter;
- (void)recordFilter;
- (void)hijackFilter;

@end

@interface TuyaWiFiDeviceRecordFilterView : UIView

@property (nonatomic, weak) id<TuyaWiFiDeviceRecordFilterViewDelegate> delegate;

@property (nonatomic, strong) UIButton *alarmBtn;
@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIButton *hijackBtn;

@end

NS_ASSUME_NONNULL_END
