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

NS_ASSUME_NONNULL_BEGIN


@class ThingSmartCameraDPManager;
@interface CameraDevice : ThingSmartDevice

@property (nonatomic, strong, readonly) ThingSmartCameraDPManager *dpManager;

@property (nonatomic, strong, readonly) UIView<ThingSmartVideoViewType> *videoView;

@property (nonatomic, strong, readonly) CameraDeviceModel *cameraModel;

- (instancetype)initWithDeviceId:(NSString *)devId;

- (void)addDelegate:(id<ThingSmartCameraDelegate>)delegate;
- (void)removeDelegate:(id<ThingSmartCameraDelegate>)delegate;

- (void)bindVideoRenderView;
- (void)unbindVideoRenderView;

- (void)connect;
- (void)connectWithPlayMode:(ThingSmartCameraPlayMode)playMode;
- (void)disconnect;

- (void)destory;

- (void)startPreview;
- (void)stopPreview;

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

- (void)startRecord;
- (void)stopRecord;

- (UIImage *)snapshoot;

@end

NS_ASSUME_NONNULL_END
