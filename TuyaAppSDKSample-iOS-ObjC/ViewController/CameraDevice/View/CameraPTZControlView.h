//
//  CameraPTZControlView.h
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraPTZControlView : UIView
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, weak) UIViewController *fatherVc;
@end

NS_ASSUME_NONNULL_END
