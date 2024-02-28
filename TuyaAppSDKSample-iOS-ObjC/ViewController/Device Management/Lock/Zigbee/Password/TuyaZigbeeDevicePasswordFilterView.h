//
//  TuyaZigbeeDevicePasswordFilterView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaZigbeeDevicePasswordFilterViewDelegate <NSObject>

- (void)validFilter;
- (void)invalidFilter;

@end

@interface TuyaZigbeeDevicePasswordFilterView : UIView

@property (nonatomic, weak) id<TuyaZigbeeDevicePasswordFilterViewDelegate> delegate;

@property (nonatomic, strong) UIButton *validBtn;
@property (nonatomic, strong) UIButton *invalidBtn;

@end

NS_ASSUME_NONNULL_END
