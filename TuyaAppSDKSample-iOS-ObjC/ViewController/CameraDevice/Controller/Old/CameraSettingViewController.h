//
//  CameraSettingViewController.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <ThingSmartCameraKit/ThingSmartCameraKit.h>

@interface CameraSettingViewController : UIViewController

@property (nonatomic, strong) NSString *devId;

@property (nonatomic, strong) ThingSmartCameraDPManager *dpManager;

@end
