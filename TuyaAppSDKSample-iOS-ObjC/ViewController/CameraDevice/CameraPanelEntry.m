//
//  CameraPanelEntry.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraPanelEntry.h"

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import "CameraNewViewController.h"

#import "UIView+CameraAdditions.h"

#import "CameraDeviceManager.h"

@implementation CameraPanelEntry

+ (BOOL)openCameraPanelWithDeviceModel:(ThingSmartDeviceModel *)deviceModel {
    if (deviceModel.isIPCDevice) {
        CameraDevice *cameraDevice = [CameraDeviceManager.sharedManager getCameraDeviceWithDevId:deviceModel.devId];
        UIViewController *panelPage = [[CameraNewViewController alloc] initWithDeviceId:deviceModel.devId];
        [tp_topMostViewController().navigationController pushViewController:panelPage animated:YES];
        return YES;
    }
    return NO;
}

@end
