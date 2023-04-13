//
//  QRCodeScanerViewController.h
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeScanerViewController : UIViewController
@property (nonatomic, copy) ThingSuccessString scanCallback;
@end

NS_ASSUME_NONNULL_END
