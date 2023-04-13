//
//  CameraPermissionUtil.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraPermissionUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@implementation CameraPermissionUtil

#pragma mark - Photo Permission

+ (BOOL)isPhotoLibraryDenied {
    if(PHAuthorizationStatusRestricted == [PHPhotoLibrary authorizationStatus] || PHAuthorizationStatusDenied == [PHPhotoLibrary authorizationStatus]){
        return YES;
    }
    return NO;
}

+ (BOOL)isPhotoLibraryNotDetermined {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined)
        return YES;
    return NO;
}

+ (void)requestPhotoPermission:(TYSuccessBOOL)result {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(PHAuthorizationStatusAuthorized == status){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) result(YES);
            });
        }
    }];
}

#pragma mark - Micro Permission

// Microphone is unauthorized
+ (BOOL)microNotDetermined {
    NSString *mediaType = AVMediaTypeAudio;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusNotDetermined) {
        return YES;
    }
    return NO;
}

// Microphone permission denied
+ (BOOL)microDenied {
    __block BOOL microDenied = NO;
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            // No microphone permission
            microDenied = YES;
        } else {
            microDenied = NO;
        }
    }];
    return microDenied;
}

// Request microphone permission
+ (void)requestAccessForMicro:(TYSuccessBOOL)result {
    NSString *mediaType = AVMediaTypeAudio;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) result(granted);
        });
    }];
}

@end
