//
//  CameraBaseViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraBaseViewController : UIViewController

- (void)showTip:(NSString *)tip;
- (void)showSuccessTip:(NSString *)tip;
- (void)showErrorTip:(NSString *)tip;
- (void)showProgress:(float)progress tip:(NSString *)tip;
- (void)dismissTip;

- (void)showAlertWithMessage:(NSString *)msg complete:(nullable void(^)(void))complete;
- (void)showAlertWithMessage:(NSString *)msg cancelHandler:(void(^)(void))cancelHandler confirmHandler:(void(^)(void))confirmHandler;
- (void)showAlertWithMessage:(NSString *)msg;

@end

NS_ASSUME_NONNULL_END
