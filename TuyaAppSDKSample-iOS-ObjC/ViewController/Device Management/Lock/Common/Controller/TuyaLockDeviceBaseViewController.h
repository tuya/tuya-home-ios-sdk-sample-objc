//
//  TuyaLockDeviceBaseViewController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartLockKit/ThingSmartBLELockDevice.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLockDeviceBaseViewController : UIViewController

@property (nonatomic, copy) NSString *devId;
@property (strong, nonatomic) ThingSmartBLELockDevice *bleDevice;
@property (strong, nonatomic) NSMutableArray *memberList;

@end

NS_ASSUME_NONNULL_END
