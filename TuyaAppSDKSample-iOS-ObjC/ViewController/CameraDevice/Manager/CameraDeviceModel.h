//
//  CameraDeviceModel.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import <TuyaSmartCameraKit/TuyaSmartCameraAbility.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CameraDeviceDisconnected = 0,
    CameraDeviceConnecting,
    CameraDeviceConnectFailed,
    CameraDeviceConnectBusy,
    CameraDeviceConnected
} CameraDeviceConnectState;

typedef enum : NSUInteger {
    CameraDevicePreviewNone = 0,
    CameraDevicePreviewLoading,
    CameraDevicePreviewing,
    CameraDevicePreviewFailed
} CameraDevicePreviewState;


typedef enum : NSUInteger {
    CameraDevicePlaybackNone = 0,
    CameraDevicePlaybackDayLoading,
    CameraDevicePlaybackTimeLineLoading,
    CameraDevicePlaybackLoading,
    CameraDevicePlaybacking,
    CameraDevicePlaybackFailed
} CameraDevicePlaybackState;


@interface CameraDeviceModel : NSObject

@property (nonatomic, assign) CameraDeviceConnectState connectState;
@property (nonatomic, assign) CameraDevicePreviewState previewState;
@property (nonatomic, assign) CameraDevicePlaybackState playbackState;
@property (nonatomic, assign, getter=isPlaybackPaused) BOOL playbackPaused;

@property (nonatomic, assign, readonly) BOOL isOnPreviewMode;

@property (nonatomic, assign, getter=isMuteLoading) BOOL muteLoading;

@property (nonatomic, assign) BOOL mutedForPreview;
@property (nonatomic, assign) BOOL mutedForPlayback;

@property (nonatomic, assign, getter=isTalkingLoading) BOOL talkLoading;
@property (nonatomic, assign, getter=isTalking) BOOL talking;


@property (nonatomic, assign, getter=isRecordLoading) BOOL recordLoading;
@property (nonatomic, assign, getter=isRecording) BOOL recording;

@property (nonatomic, assign, getter=isDownloading) BOOL downloading;

@property (nonatomic, assign, getter=isHD) BOOL HD;

@property (nonatomic, assign) BOOL isSupportNewRecordEvent;

/// device is support speaker
@property (nonatomic, assign, readonly) BOOL isSupportSpeaker;

/// device is support sound pickup
@property (nonatomic, assign, readonly) BOOL isSupportPickup;

/// default talkback mode, configured in Tuya backend.
@property (nonatomic, assign, readonly) TuyaSmartCameraTalkbackMode defaultTalkbackMode;

/// if device support both speaker and sound pickup, device support both one-way talk and two-way talk, so it could change the talkback mode.
@property (nonatomic, assign, readonly) BOOL couldChangeTalkbackMode;

/// default definition of live video, configured in Tuya backend.
@property (nonatomic, assign, readonly) TuyaSmartCameraDefinition defaultDefinition;

/// original config data
@property (nonatomic, copy, readonly) NSDictionary *configInfoData;

- (void)resetCameraAbility:(TuyaSmartCameraAbility *)cameraAbility;

@end

NS_ASSUME_NONNULL_END
