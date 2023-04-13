//
//  CameraCruiseView.h
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraCruiseView : UIView
@property (nonatomic, copy) NSString *deviceId;

- (void)refreshView;

@end

NS_ASSUME_NONNULL_END
