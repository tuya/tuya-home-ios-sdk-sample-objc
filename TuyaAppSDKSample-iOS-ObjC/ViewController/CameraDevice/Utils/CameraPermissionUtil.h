//
//  CameraPermissionUtil.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>
#import <TuyaSmartBaseKit/TuyaSmartBaseKit.h>

@interface CameraPermissionUtil : NSObject

+ (BOOL)isPhotoLibraryDenied;
+ (BOOL)isPhotoLibraryNotDetermined;
+ (void)requestPhotoPermission:(TYSuccessBOOL)result;

+ (BOOL)microNotDetermined;
+ (BOOL)microDenied;
+ (void)requestAccessForMicro:(TYSuccessBOOL)result;

@end
