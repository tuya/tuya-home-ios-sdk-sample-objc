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

@end
