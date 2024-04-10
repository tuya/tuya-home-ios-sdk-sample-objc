//
//  CameraPermissionUtil.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>

@interface CameraPermissionUtil : NSObject

+ (BOOL)isPhotoLibraryDenied;
+ (BOOL)isPhotoLibraryNotDetermined;
+ (void)requestPhotoPermission:(ThingSuccessBOOL)result;

+ (BOOL)microNotDetermined;
+ (BOOL)microDenied;
+ (void)requestAccessForMicro:(ThingSuccessBOOL)result;

// Camera is unauthorized
+ (BOOL)cameraNotDetermined;
// Camera permission denied
+ (BOOL)cameraDenied;
// Request Camera permission
+ (void)requestAccessForCamera:(ThingSuccessBOOL)result;

@end
