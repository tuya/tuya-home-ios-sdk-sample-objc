//
//  TuyaZigbeeDeviceRecordFilterView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaZigbeeDeviceRecordFilterViewDelegate <NSObject>

- (void)alarmFilter;
- (void)recordFilter;

@end

@interface TuyaZigbeeDeviceRecordFilterView : UIView

@property (nonatomic, weak) id<TuyaZigbeeDeviceRecordFilterViewDelegate> delegate;

@property (nonatomic, strong) UIButton *alarmBtn;
@property (nonatomic, strong) UIButton *recordBtn;

@end

NS_ASSUME_NONNULL_END
