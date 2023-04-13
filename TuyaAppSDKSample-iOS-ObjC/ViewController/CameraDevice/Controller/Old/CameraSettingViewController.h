//
//  CameraSettingViewController.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>

@interface CameraSettingViewController : UIViewController

@property (nonatomic, strong) NSString *devId;

@property (nonatomic, strong) TuyaSmartCameraDPManager *dpManager;

@end
