//
//  CameraDevice.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <TuyaSmartDeviceCoreKit/TuyaSmartDeviceCoreKit.h>
#import <TuyaSmartCameraBase/TuyaSmartCameraBase.h>
#import <TuyaSmartCameraKit/TuyaSmartPlaybackDate.h>

#import "CameraDeviceModel.h"
#import "CameraTimeLineModel.h"

NS_ASSUME_NONNULL_BEGIN


@class TuyaSmartCameraDPManager;
@interface CameraDevice : TuyaSmartDevice

@property (nonatomic, strong, readonly) TuyaSmartCameraDPManager *dpManager;

@property (nonatomic, strong, readonly) UIView<TuyaSmartVideoViewType> *videoView;

@property (nonatomic, strong, readonly) CameraDeviceModel *cameraModel;

- (instancetype)initWithDeviceId:(NSString *)devId;

- (void)addDelegate:(id<TuyaSmartCameraDelegate>)delegate;
- (void)removeDelegate:(id<TuyaSmartCameraDelegate>)delegate;

- (void)bindVideoRenderView;
- (void)unbindVideoRenderView;

- (void)connect;
- (void)connectWithPlayMode:(TuyaSmartCameraPlayMode)playMode;
- (void)disconnect;

- (void)destory;

- (void)startPreview;
- (void)stopPreview;

- (void)queryRecordDaysWithYear:(NSUInteger)year month:(NSUInteger)month;
- (void)queryRecordTimeSlicesWithPlaybackDate:(TuyaSmartPlaybackDate *)playbackDate;
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

- (void)enableMute:(BOOL)mute forPlayMode:(TuyaSmartCameraPlayMode)playMode;

- (void)getHD;
- (void)getDefinition;
- (void)setDefinition:(TuyaSmartCameraDefinition)definition;

- (void)startTalk;
- (void)stopTalk;

- (void)startRecord;
- (void)stopRecord;

- (UIImage *)snapshoot;

@end

NS_ASSUME_NONNULL_END
