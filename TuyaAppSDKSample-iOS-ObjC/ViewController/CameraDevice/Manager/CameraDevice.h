//
//  CameraDevice.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <ThingSmartDeviceCoreKit/ThingSmartDeviceCoreKit.h>
#import <ThingSmartCameraBase/ThingSmartCameraBase.h>
#import <ThingSmartCameraKit/ThingSmartPlaybackDate.h>

#import "CameraDeviceModel.h"
#import "CameraTimeLineModel.h"
#import "CameraDeviceOutlineProperty.h"

NS_ASSUME_NONNULL_BEGIN


@class ThingSmartCameraDPManager;
@interface CameraDevice : ThingSmartDevice

@property (nonatomic, strong, readonly) ThingSmartCameraDPManager *dpManager;

@property (nonatomic, strong, readonly) UIView<ThingSmartVideoViewType> *videoView;

@property (nonatomic, strong, readonly) CameraDeviceModel *cameraModel;

@property (nonatomic, strong, readonly) id<ThingSmartCameraType> camera;

@property (nonatomic, assign, readonly) BOOL isSupportedVideoSplitting;

- (instancetype)initWithDeviceId:(NSString *)devId;

- (void)addDelegate:(id<ThingSmartCameraDelegate>)delegate;
- (void)removeDelegate:(id<ThingSmartCameraDelegate>)delegate;

- (void)bindVideoRenderView;
- (void)unbindVideoRenderView;

- (void)bindLocalVideoView:(UIView<ThingSmartVideoViewType> *)videoView;
- (void)unbindLocalVideoView:(UIView<ThingSmartVideoViewType> *)videoView;

- (void)connect;
- (void)connectWithPlayMode:(ThingSmartCameraPlayMode)playMode;
- (void)disconnect;

- (void)destory;

- (void)startPreview;
- (void)stopPreview;

- (void)enterCallState;
- (void)leaveCallState;

- (void)queryRecordDaysWithYear:(NSUInteger)year month:(NSUInteger)month;
- (void)queryRecordTimeSlicesWithPlaybackDate:(ThingSmartPlaybackDate *)playbackDate;
- (void)startPlaybackWithPlayTime:(NSInteger)playTime timeLineModel:(CameraTimeLineModel *)timeLineModel;
- (void)startPlayback:(NSInteger)playTime startTime:(NSInteger)startTime stopTime:(NSInteger)stopTime;
- (void)pausePlayback;
- (void)resumePlayback;
- (void)stopPlayback;
- (NSArray<NSNumber *> *)getSupportPlaySpeedList;
- (BOOL)isSupportPlaybackDelete;
- (int)deletePlayBackDataWithDay:(NSString *)day onResponse:(void (^)(int errCode))callback onFinish:(void (^)(int errCode))finishedCallBack;
- (BOOL)isSupportPlaybackDownload;
- (int)downloadPlayBackVideoWithRange:(NSRange)timeRange filePath:(NSString *)filePath success:(void(^)(NSString *filePath))success progress:(void(^)(NSUInteger progress))progress failure:(void(^)(NSError *error))failure;
- (int)stopPlayBackDownloadWithResponse:(void (^)(int errCode))callback;

- (void)enableMute:(BOOL)mute forPlayMode:(ThingSmartCameraPlayMode)playMode;

- (void)getHD;
- (void)getDefinition;
- (void)setDefinition:(ThingSmartCameraDefinition)definition;

- (void)startTalk;
- (void)stopTalk;

/**
 start video talk
 */
- (int)startVideoTalk;

/**
 stop video talk
 */
-(int)stopVideoTalk;

/**
    pause send video talk
 */
- (int)pauseVideoTalk;

/**
    resume send video talk
 */
- (int)resumeVideoTalk;

/**
 open local video capture
 */
-(int)startLocalVideoCapture;

/**
 stop the local video capture.
 */
-(int)stopLocalVideoCapture;

/**
 switch local camera position
 */
-(int)switchLocalCameraPosition;

/**
 start audio record
 */
-(int)startAudioRecord;

/**
 start audio record
 */
-(int)stopAudioRecord;


- (void)startRecord;
- (void)stopRecord;

- (UIImage *)snapshoot;

//set ipc_object_outline switch, set before startPreview
- (void)setObjectOutlineEnable:(BOOL)enable;

//set out_off_bounds switch, set before startPreview
- (void)setOutOffBoundsEnable:(BOOL)enable;

//set ipc_object_outline feature, set before startPreview
- (void)setObjectOutlineFeature:(CameraDeviceOutlineProperty *)feature;

//set out_off_bounds features, set before startPreview
- (void)setOutOffBoundsFeatures:(NSArray<CameraDeviceOutlineProperty *> *)features;

@end

NS_ASSUME_NONNULL_END
