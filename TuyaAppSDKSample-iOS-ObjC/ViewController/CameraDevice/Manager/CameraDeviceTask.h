//
//  CameraDeviceTask.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CameraDeviceTaskEvent) {
    CameraDeviceTaskStartPreview,
    CameraDeviceTaskStopPreview
};

@interface CameraDeviceTask : NSObject


@property (nonatomic, assign, getter=isRunning) BOOL running;

@property (nonatomic, assign) CameraDeviceTaskEvent taskEvent;

@end

NS_ASSUME_NONNULL_END
