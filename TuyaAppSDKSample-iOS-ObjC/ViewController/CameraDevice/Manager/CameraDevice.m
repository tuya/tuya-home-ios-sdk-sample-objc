//
//  CameraDevice.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraDevice.h"

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import <ThingSmartCameraM/ThingSmartCameraM.h>

#import <YYModel/YYModel.h>

#import "CameraDeviceTask.h"

@interface NSDictionary (ConvertedJsonString)

@end

@implementation NSDictionary (ConvertedJsonString)

- (NSString *)convertedJsonString {
    if (![NSJSONSerialization isValidJSONObject:self]) {
        return nil;
    }
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = nil;
    if (!jsonData) {
        return nil;
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr.copy;
}



@end

@interface CameraDevice ()<ThingSmartCameraDelegate> {
    dispatch_semaphore_t _deviceTasksLock;
    BOOL _isOnCallState;
}

@property (nonatomic, strong) id<ThingSmartCameraType> camera;

@property (nonatomic, strong, readwrite) ThingSmartCameraDPManager *dpManager;

@property (nonatomic, strong) NSHashTable<id<ThingSmartCameraDelegate>> *innerDelegates;

@property (nonatomic, assign) BOOL lastMuted;

@property (nonatomic, strong) CameraDeviceOutlineProperty *innerObjectOutlineFeature;
@property (nonatomic, copy) NSArray<CameraDeviceOutlineProperty *> *innerOutOffBoundsFeatures;

@property (nonatomic, assign) BOOL innerObjectOutlineEnabled;
@property (nonatomic, assign) BOOL innerOutOffBoundsEnabled;

@property (nonatomic, strong) NSMutableArray<CameraDeviceTask *> *deviceTasks;
@property (nonatomic, strong) CameraDeviceTask *runningTask;

@end

@implementation CameraDevice

- (instancetype)initWithDeviceId:(NSString *)devId {
    self = [super initWithDeviceId:devId];
    if (self) {
        _deviceTasksLock = dispatch_semaphore_create(1);
        _deviceTasks = NSMutableArray.array;
        
        _camera = [ThingSmartCameraFactory cameraWithP2PType:@(self.deviceModel.p2pType) deviceId:self.deviceModel.devId delegate:self];
        NSLog(@"[test]-%s",__func__);
        _cameraModel = [[CameraDeviceModel alloc] init];
        _innerDelegates = [NSHashTable weakObjectsHashTable];
        
        ThingSmartCameraAbility *cameraAbility = [ThingSmartCameraAbility cameraAbilityWithDeviceModel:self.deviceModel];
        [_cameraModel resetCameraAbility:cameraAbility];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self clearAllTasks];
    [self.camera destory];
    [self.camera disConnect];
}

- (UIView<ThingSmartVideoViewType> *)videoView {
    return _camera.videoView;
}

- (ThingSmartCameraDPManager *)dpManager {
    if (!_dpManager) {
        _dpManager = [[ThingSmartCameraDPManager alloc] initWithDeviceId:self.deviceModel.devId];
    }
    return _dpManager;
}

- (void)addDelegate:(id<ThingSmartCameraDelegate>)delegate {
    [self.innerDelegates addObject:delegate];
}

- (void)removeDelegate:(id<ThingSmartCameraDelegate>)delegate {
    [self.innerDelegates removeObject:delegate];
}

- (void)bindVideoRenderView {
    [self.camera.videoView thing_clear];
    [self.camera registerVideoRenderView:nil];
}


- (void)unbindVideoRenderView {
    [self.camera uninstallVideoRenderView:nil];
}

- (void)bindLocalVideoView:(UIView<ThingSmartVideoViewType> *)videoView {
    [self.camera bindLocalVideoView:videoView];
}

- (void)unbindLocalVideoView:(UIView<ThingSmartVideoViewType> *)videoView {
    [self.camera unbindLocalVideoView:videoView];
}

- (void)connect {
    [self connectWithPlayMode:ThingSmartCameraPlayModePlayback];
}

- (void)connectWithPlayMode:(ThingSmartCameraPlayMode)playMode {
    if (self.cameraModel.connectState == CameraDeviceConnecting || self.cameraModel.connectState == CameraDeviceConnected) {
        return;
    }
    if (playMode == ThingSmartCameraPlayModePreview) {
        if (self.deviceModel.isLowPowerDevice) {
            [self awakeDeviceWithSuccess:nil failure:nil];
        }
    }
    self.cameraModel.connectState = CameraDeviceConnecting;
    [self.camera connectWithMode:ThingSmartCameraConnectAuto];
}

- (void)disconnect {
    [self stopPreview];
    [self stopPlayback];
    [self.camera disConnect];
    self.cameraModel.connectState = CameraDeviceDisconnected;
    self.cameraModel.previewState = CameraDevicePreviewNone;
    self.cameraModel.videoTalkState = CameraDeviceTaskStateNone;
    self.cameraModel.videoTalkPaused = NO;
    self.cameraModel.muteLoading = NO;
}

- (void)destory {
    [self.camera destory];
}


- (void)startPreview {
    if (self.cameraModel.previewState == CameraDevicePreviewLoading || self.cameraModel.previewState == CameraDevicePreviewing) {
        return;
    }
    self.cameraModel.previewState = CameraDevicePreviewLoading;
    [self.camera startPreview];
    self.lastMuted = self.cameraModel.mutedForPreview;
    
    [self setOutLineEnable];
    [self setSmartRectFeatures];
}

- (void)stopPreview {
    if (_isOnCallState == YES) {
        return;
    }
    [self stopTalk];
    [self stopRecord];
    
    [self.camera stopPreview];
    self.cameraModel.previewState = CameraDevicePreviewNone;
}


- (void)enterCallState {
    _isOnCallState = YES;
}

- (void)leaveCallState {
    _isOnCallState = NO;
}

- (void)queryRecordDaysWithYear:(NSUInteger)year month:(NSUInteger)month {
    [self.camera queryRecordDaysWithYear:year month:month];
}

- (void)queryRecordTimeSlicesWithPlaybackDate:(ThingSmartPlaybackDate *)playbackDate {
    if (self.cameraModel.isSupportNewRecordEvent) {
        [self.camera newQueryRecordTimeSliceWithYear:playbackDate.year month:playbackDate.month day:playbackDate.day];
    } else {
        [self.camera queryRecordTimeSliceWithYear:playbackDate.year month:playbackDate.month day:playbackDate.day];
    }
}

- (void)startPlaybackWithPlayTime:(NSInteger)playTime timeLineModel:(CameraTimeLineModel *)timeLineModel {
    playTime = [timeLineModel containsPlayTime:playTime] ? playTime : timeLineModel.startTime;
    [self startPlayback:playTime startTime:timeLineModel.startTime stopTime:timeLineModel.stopTime];
}


- (void)startPlayback:(NSInteger)playTime startTime:(NSInteger)startTime stopTime:(NSInteger)stopTime {
    [self.camera startPlayback:playTime startTime:startTime stopTime:stopTime];
    self.lastMuted = self.cameraModel.mutedForPlayback;
}

- (void)pausePlayback {
    if (self.cameraModel.playbackPaused) {
        return;
    }
    [self.camera pausePlayback];
}

- (void)resumePlayback {
    if (self.cameraModel.playbackPaused) {
        [self.camera resumePlayback];
    }
}
 
- (void)stopPlayback {
    if (self.cameraModel.playbackState == CameraDevicePlaybackLoading || self.cameraModel.playbackState == CameraDevicePlaybacking) {
        [self stopRecord];
        [self.camera stopPlayback];
    }
}

- (NSArray<NSNumber *> *)getSupportPlaySpeedList {
    return [self.camera getSupportPlaySpeedList];
}

- (BOOL)isSupportPlaybackDelete {
    return [self.camera isSupportPlaybackDelete];;
}

- (int)deletePlayBackDataWithDay:(NSString *)day onResponse:(void (^)(int errCode))callback onFinish:(void (^)(int errCode))finishedCallBack {
    return [self.camera deletePlayBackDataWithDay:day onResponse:callback onFinish:finishedCallBack];
}

- (BOOL)isSupportPlaybackDownload {
    return [self.camera isSupportPlaybackDownload];;
}

- (int)downloadPlayBackVideoWithRange:(NSRange)timeRange filePath:(NSString *)filePath success:(void(^)(NSString *filePath))success progress:(void(^)(NSUInteger progress))progress failure:(void(^)(NSError *error))failure {
    if (self.cameraModel.isDownloading) {
        return -1;
    }
    __weak typeof(self) weakSelf = self;
    int result = [self.camera downloadPlayBackVideoWithRange:timeRange filePath:filePath success:^(NSString *filePath) {
        weakSelf.cameraModel.downloading = NO;
    } progress:progress failure:^(NSError *error) {
        weakSelf.cameraModel.downloading = NO;
    }];
    self.cameraModel.downloading = (result == 0);
    return result;
}

- (int)stopPlayBackDownloadWithResponse:(void (^)(int errCode))callback {
    self.cameraModel.downloading = NO;
    return [self.camera stopPlayBackDownloadWithResponse:callback];;
}

- (void)enableMute:(BOOL)mute forPlayMode:(ThingSmartCameraPlayMode)playMode {
    if (playMode == ThingSmartCameraPlayModePreview) {
        self.cameraModel.mutedForPreview = mute;
    } else if (playMode == ThingSmartCameraPlayModePlayback) {
        self.cameraModel.mutedForPlayback = mute;
    }
    self.cameraModel.muteLoading = YES;
    [self.camera enableMute:mute forPlayMode:playMode];
    self.lastMuted = mute;
}

- (void)getHD {
    [self.camera getHD];
}

- (void)getDefinition {
    [self.camera getDefinition];
}

- (void)setDefinition:(ThingSmartCameraDefinition)definition {
    [self.camera setDefinition:definition];
    
    [self setOutLineEnable];
    [self setSmartRectFeatures];
}

- (void)startTalk {
    if (self.cameraModel.talking || self.cameraModel.talkLoading) {
        return;
    }
    self.cameraModel.talkLoading = YES;
    [self.camera startTalk];
}
- (void)stopTalk {
    if (self.cameraModel.talking || self.cameraModel.talkLoading) {
        self.cameraModel.talkLoading = NO;
        self.cameraModel.talking = NO;
        [self.camera stopTalk];
    }
}

- (int)startVideoTalk {
    if (self.cameraModel.videoTalkState == CameraDeviceTaskStateExecuting || self.cameraModel.videoTalkState == CameraDeviceTaskStateCompleted || (self.cameraModel.connectState != CameraDeviceConnected)) {
        return -1;
    }
    self.cameraModel.videoTalkState = CameraDeviceTaskStateExecuting;
    return [self.camera startVideoTalk];
}

/**
    stop video talk
 */
-(int)stopVideoTalk {
    if (self.cameraModel.videoTalkState == CameraDeviceTaskStateExecuting || self.cameraModel.videoTalkState == CameraDeviceTaskStateCompleted) {
        return [self.camera stopVideoTalk];
    }
    return -1;
}

/**
    pause send video talk
 */
- (int)pauseVideoTalk {
    if ((self.cameraModel.connectState == CameraDeviceConnected) && self.cameraModel.videoTalkState == CameraDeviceTaskStateCompleted && !self.cameraModel.videoTalkPaused) {
        [self.camera pauseVideoTalk];
    }
    return -1;
}

/**
    resume send video talk
 */
- (int)resumeVideoTalk {
    if ((self.cameraModel.connectState == CameraDeviceConnected) && self.cameraModel.videoTalkState == CameraDeviceTaskStateCompleted && self.cameraModel.videoTalkPaused) {
        [self.camera resumeVideoTalk];
    }
    return -1;
}


-(int)startLocalVideoCapture {
    if (self.cameraModel.videoCaptureState == CameraDeviceTaskStateExecuting || self.cameraModel.videoCaptureState == CameraDeviceTaskStateCompleted) {
        return 0;
    }
    self.cameraModel.videoCaptureState = CameraDeviceTaskStateExecuting;
    int retCode = [self.camera startLocalVideoCaptureWithVideoInfo:nil];
    self.cameraModel.videoCaptureState = CameraDeviceTaskStateCompleted;
    if (retCode < 0) {
        self.cameraModel.videoCaptureState = CameraDeviceTaskStateFailed;
    }
    return retCode;
}

/**
    switch camera
 */
-(int)switchLocalCameraPosition {
    if (self.cameraModel.videoCaptureState == CameraDeviceTaskStateExecuting || self.cameraModel.videoCaptureState == CameraDeviceTaskStateCompleted) {
        int retCode = [self.camera switchLocalCameraPosition];
        return retCode;
    }
    return -1;
}

/**
    close the video capture.
 */
-(int)stopLocalVideoCapture  {
    int retCode = [self.camera stopLocalVideoCapture];
    self.cameraModel.videoCaptureState = CameraDeviceTaskStateNone;
    return retCode;
}

/**
 start audio record
 */
-(int)startAudioRecord {
    return [self.camera startAudioRecordWithAudioInfo:nil];
}

/**
 start audio record
 */
-(int)stopAudioRecord {
    return [self.camera stopAudioRecord];
}


- (void)startRecord {
    if (self.cameraModel.isRecording) {
        return;
    }
    self.cameraModel.recordLoading = YES;
    [self.camera startRecord];
}

- (void)stopRecord {
    if (!self.cameraModel.isRecording) {
        return;
    }
    self.cameraModel.recording = NO;
    self.cameraModel.recordLoading = NO;
    [self.camera stopRecord];
}

- (UIImage *)snapshoot {
    return [self.camera snapShoot];
}


- (void)setOutLineEnable {
    if (self.innerObjectOutlineEnabled || self.innerOutOffBoundsEnabled) {
        [self.camera setOutLineEnable:YES];
        return;
    }
    [self.camera setOutLineEnable:NO];
}

//set ipc_object_outline switch, set before startPreview
- (void)setObjectOutlineEnable:(BOOL)enable {
    self.innerObjectOutlineEnabled = enable;
}

//set out_off_bounds switch, set before startPreview
- (void)setOutOffBoundsEnable:(BOOL)enable {
    self.innerOutOffBoundsEnabled = enable;
}

//set ipc_object_outline feature
- (void)setObjectOutlineFeature:(CameraDeviceOutlineProperty *)feature {
    self.innerObjectOutlineFeature = feature;
}

//set out_off_bounds features
- (void)setOutOffBoundsFeatures:(NSArray<CameraDeviceOutlineProperty *> *)features {
    self.innerOutOffBoundsFeatures = features;
}

- (int)setSmartRectFeatures {
     
    NSMutableArray *allFrameFeatures = NSMutableArray.array;
    //智能画框/ipc_object_outline
    if (self.innerObjectOutlineFeature) {
        [allFrameFeatures addObject:self.innerObjectOutlineFeature];
    }
    //越线框/out_off_bounds
    NSArray *outOffBoundsFeatures = self.innerOutOffBoundsFeatures;
    if (outOffBoundsFeatures) {
        [allFrameFeatures addObjectsFromArray:outOffBoundsFeatures];
    }
    //{"SmartRectFeature":[{"index":0,"brushWidth":0,"type":1,"shape":0,"flashFps":{"drawKeepFrames":0,"stopKeepFrames":0}}]}
    NSDictionary *resultFeatureMap = @{@"SmartRectFeature" : [allFrameFeatures yy_modelToJSONObject]};
    NSString *featuresJson = [resultFeatureMap convertedJsonString];
    return [self.camera setSmartRectFeatures:featuresJson];
}

#pragma mark - ThingSmartCameraDelegate

/**
 [^en]
 the p2p channel did connected.
 [$en]

 [^zh]
 p2p 通道已连接
 [$zh]

 @param camera camera
 */
- (void)cameraDidConnected:(id<ThingSmartCameraType>)camera {
    [self.camera enterPlayback];
    
    self.cameraModel.connectState = CameraDeviceConnected;
        
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidConnected:)]) {
            [obj cameraDidConnected:camera];
        }
    }];
}



/**
 [^en]
 the new p2p channel did disconnected.
 [$en]

 [^zh]
 新p2p 通道已断开
 [$zh]

 @param camera camera
 @param errorCode [^en]errorCode reference ThingCameraSDK.framework/TYDefines[$en] [^zh]具体参考ThingCameraSDK.framework/TYDefines[$zh]
 */
- (void)cameraDisconnected:(id<ThingSmartCameraType>)camera specificErrorCode:(NSInteger)errorCode {
    self.cameraModel.connectState = CameraDeviceDisconnected;
    if (errorCode == -23 || errorCode == -104 || errorCode == -113) {
        self.cameraModel.connectState = CameraDeviceConnectBusy;
    }
    self.cameraModel.previewState = CameraDevicePreviewNone;
    self.cameraModel.playbackState = CameraDevicePlaybackNone;
    self.cameraModel.videoTalkState = CameraDeviceTaskStateNone;
    self.cameraModel.videoTalkPaused = NO;
    self.cameraModel.playbackPaused = NO;
    self.cameraModel.downloading = NO;

    self.cameraModel.talking = self.cameraModel.talkLoading = NO;

    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDisconnected:specificErrorCode:)]) {
            [obj cameraDisconnected:camera specificErrorCode:errorCode];
        }
    }];
}

/**
 [^en]
 the playback channel did connected.
 [$en]

 [^zh]
 回放通道已经连接
 [$zh]

 @param camera camera
 */
- (void)cameraDidConnectPlaybackChannel:(id<ThingSmartCameraType>)camera {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidConnectPlaybackChannel:)]) {
            [obj cameraDidConnectPlaybackChannel:camera];
        }
    }];
}

/**
 [^en]
 the camera did began play live video.
 [$en]

 [^zh]
 摄像头已经开始播放实时视频
 [$zh]

 @param camera camera
 */
- (void)cameraDidBeginPreview:(id<ThingSmartCameraType>)camera {
    self.cameraModel.previewState = CameraDevicePreviewing;

    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidBeginPreview:)]) {
            [obj cameraDidBeginPreview:camera];
        }
    }];
}

/**
 [^en]
 the camera did stop live video.
 [$en]

 [^zh]
 摄像头实时视频已停止
 [$zh]

 @param camera camera
 */
- (void)cameraDidStopPreview:(id<ThingSmartCameraType>)camera {
    self.cameraModel.previewState = CameraDevicePreviewNone;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidStopPreview:)]) {
            [obj cameraDidStopPreview:camera];
        }
    }];
}

/**
 [^en]
 the camera did began playback record video in the SD card.
 [$en]

 [^zh]
 摄像头SD卡视频回放已开始
 [$zh]

 @param camera camera
 */
- (void)cameraDidBeginPlayback:(id<ThingSmartCameraType>)camera {
    self.cameraModel.playbackState = CameraDevicePlaybacking;
    self.cameraModel.playbackPaused = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidBeginPlayback:)]) {
            [obj cameraDidBeginPlayback:camera];
        }
    }];
}

/**
 [^en]
 the camera did pause playback record video in the SD card.
 [$en]

 [^zh]
 摄像头SD卡视频回放已暂停
 [$zh]

 @param camera camera
 */
- (void)cameraDidPausePlayback:(id<ThingSmartCameraType>)camera {
    self.cameraModel.playbackPaused = YES;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidPausePlayback:)]) {
            [obj cameraDidPausePlayback:camera];
        }
    }];
}

/**
 [^en]
 the camera did resume playback record video in the SD card.
 [$en]

 [^zh]
 摄像头SD卡视频回放已恢复播放
 [$zh]

 @param camera camera
 */
- (void)cameraDidResumePlayback:(id<ThingSmartCameraType>)camera {
    self.cameraModel.playbackPaused = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidResumePlayback:)]) {
            [obj cameraDidResumePlayback:camera];
        }
    }];
}

/**
 [^en]
 the camera did stop playback record video in the SD card.
 [$en]

 [^zh]
 摄像头SD卡视频回放已中止
 [$zh]

 @param camera camera
 */
- (void)cameraDidStopPlayback:(id<ThingSmartCameraType>)camera {
    self.cameraModel.playbackState = CameraDevicePlaybackNone;
    self.cameraModel.playbackPaused = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidStopPlayback:)]) {
            [obj cameraDidStopPlayback:camera];
        }
    }];
}

/**
 [^en]
 the record video in the SD card playback finished.
 [$en]

 [^zh]
 摄像头SD卡视频回放已结束
 [$zh]

 @param camera camera
 */
- (void)cameraPlaybackDidFinished:(id<ThingSmartCameraType>)camera {
    self.cameraModel.playbackState = CameraDevicePlaybackNone;
    self.cameraModel.playbackPaused = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraPlaybackDidFinished:)]) {
            [obj cameraPlaybackDidFinished:camera];
        }
    }];
}

/**
 [^en]
 the record video in the SD card playback finished
 [$en]

 [^zh]
 摄像头SD卡视频回放结束时状态
 [$zh]

 @param camera camera
 @param status finished status
 */
- (void)camera:(id<ThingSmartCameraType>)camera playbackDidFinishedWithStatus:(NSInteger)status {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:playbackDidFinishedWithStatus:)]) {
            [obj camera:camera playbackDidFinishedWithStatus:status];
        }
    }];
}

- (void)camera:(id<ThingSmartCameraType>)camera playbackTimeSlice:(NSDictionary *)timeSlice didFinishedWithStatus:(NSInteger)status {
    self.cameraModel.playbackState = CameraDevicePlaybackNone;
    // 自动播放下一段时，可能重复收到播放结束的回调，如果已经开始加载下一段，将 playbackloading 设置为 NO 会导致状态错误
    // self.cameraModel.playbackLoading = NO;
    self.cameraModel.playbackPaused = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:playbackTimeSlice:didFinishedWithStatus:)]) {
            [obj camera:camera playbackTimeSlice:timeSlice didFinishedWithStatus:status];
        }
    }];
}

/**
 [^en]
 receive first video frame
 this method will call when every 'startPreview/startPlayback/resumePlayback' sucess.
 [$en]
 收到的第一帧视频
 此方法将会在每一次 'startPreview/startPlayback/resumePlayback' 成功时被调用
 [^zh]

 [$zh]
 @param camera camera
 @param image  [^en]fisrt frame image[$en] [^zh]第一帧图片[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera didReceiveFirstFrame:(UIImage *)image {
    if (self.cameraModel.previewState == CameraDevicePreviewLoading) {
        self.cameraModel.previewState = CameraDevicePreviewing;
    } else if (self.cameraModel.playbackState == CameraDevicePlaybackLoading){
        self.cameraModel.playbackState = CameraDevicePlaybacking;
    }
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:didReceiveFirstFrame:)]) {
            [obj camera:camera didReceiveFirstFrame:image];
        }
    }];
}

/**
 [^en]
 begin talk to the device. will call when 'startTalk' success.
 [$en]

 [^zh]
 开始与设备进行对讲，方法会在 'startTalk' 成时被调用
 [$zh]

 @param camera camera
 */
- (void)cameraDidBeginTalk:(id<ThingSmartCameraType>)camera {
    self.cameraModel.talking = YES;
    self.cameraModel.talkLoading = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidBeginTalk:)]) {
            [obj cameraDidBeginTalk:camera];
        }
    }];
}

/**
 [^en]
 talk to the device did stop. will call when 'stopTalk' success.
 [$en]

 [^zh]
 与设备对讲已经结束，方法会在 'stopTalk' 成功时被调用
 [$zh]

 @param camera camera
 */
- (void)cameraDidStopTalk:(id<ThingSmartCameraType>)camera {
    self.cameraModel.talkLoading = NO;
    self.cameraModel.talking = NO;
    
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidStopTalk:)]) {
            [obj cameraDidStopTalk:camera];
        }
    }];
}

/**
 [^en]
 the video screenshot has saved in the photo album.
 [$en]

 [^zh]
 视频截图已成功保存到相册
 [$zh]

 @param camera camera
 */
- (void)cameraSnapShootSuccess:(id<ThingSmartCameraType>)camera {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraSnapShootSuccess:)]) {
            [obj cameraSnapShootSuccess:camera];
        }
    }];
}

/**
 [^en]
 video recording did start success.
 [$en]

 [^zh]
 视频录制已成功开始
 [$zh]

 @param camera camera
 */
- (void)cameraDidStartRecord:(id<ThingSmartCameraType>)camera {
    self.cameraModel.recording = YES;
    self.cameraModel.recordLoading = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidStartRecord:)]) {
            [obj cameraDidStartRecord:camera];
        }
    }];
}

/**
 [^en]
 video recording did stop sucess, and the video has saved in photo album success.
 [$en]

 [^zh]
 视频录制已经成功停止，视频已成功保存到相册
 [$zh]

 @param camera camera
 */
- (void)cameraDidStopRecord:(id<ThingSmartCameraType>)camera {
    self.cameraModel.recording = NO;
    self.cameraModel.recordLoading = NO;
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cameraDidStopRecord:)]) {
            [obj cameraDidStopRecord:camera];
        }
    }];
}

/**
 [^en]
 did receive definition state. will call when 'getHD' success or the definition has changed.
 [$en]

 [^zh]
 收到视频清晰度状态，方法会在 'getHD' 成功 或者清晰度改变的时候被调用
 [$zh]

 @param camera camera
 @param definition [^en]definition[$en] [^zh]清晰度[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera definitionChanged:(ThingSmartCameraDefinition)definition {
    self.cameraModel.HD = definition >= ThingSmartCameraDefinitionHigh;
    
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:definitionChanged:)]) {
            [obj camera:camera definitionChanged:definition];
        }
    }];
}

/**
 [^en]
 called when query data of the playback event list sift success.
 [$en]

 [^zh]
 方法会在请求回放事件筛选列表成功后调用
 [$zh]

 @param camera camera
 @param titles [^en]the array of title，ex: [@(Message left), @"Call"]; [$en] [^zh]标题的数组， ex: [@"有人留言", @"有人呼叫";[$zh]
 @param eventIds [^en]the array of eventIds，ex: [@(1), @"2"]; [$en] [^zh]事件id的数组， ex: [@(1), @(2)];[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera didReceiveEventListSiftData:(NSArray<NSString *> *)titles eventIds:(NSArray<NSNumber *> *)eventIds {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:didReceiveEventListSiftData:eventIds:)]) {
            [obj camera:camera didReceiveEventListSiftData:titles eventIds:eventIds];
        }
    }];
}

/**
 [^en]
 called when query date of the playback record success.
 [$en]

 [^zh]
 方法会在按日期查询回放视频数据成功后被调用
 [$zh]

 @param camera camera
 @param days [^en]the array of days，ex: [@(1), @(2), @(5), @(6), @(31)]; express in this month, 1，2，5，6，31  has video record.[$en] [^zh]日期的数组， ex: [@(1), @(2), @(5), @(6), @(31)]; 代表这个月中的 1，2，5，6，31 号有视频录制数据[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera didReceiveRecordDayQueryData:(NSArray<NSNumber *> *)days {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:didReceiveRecordDayQueryData:)]) {
            [obj camera:camera didReceiveRecordDayQueryData:days];
        }
    }];
}

/**
 [^en]
 called when query video record slice of one day success.
 [$en]

 [^zh]
 方法将会在查询一天内视频回放片段数据成功后被调用
 [$zh]

 @param camera camera
 
 @param timeSlices [^en]the array of playback video record information. the element is a NSDictionary, content like this:
 kThingSmartPlaybackPeriodStartDate  ： startTime(NSDate)
 kThingSmartPlaybackPeriodStopDate   ： stopTime(NSDate)
 kThingSmartPlaybackPeriodStartTime  ： startTime(NSNumer, unix timestamp)
 kThingSmartPlaybackPeriodStopTime   ： stopTime(NSNumer, unix timestamp)[$en] [^zh]回放视频数据信息数组，数组内元素为NSDictionary类型，如下:
 kThingSmartPlaybackPeriodStartDate  ： startTime(NSDate)
 kThingSmartPlaybackPeriodStopDate   ： stopTime(NSDate)
 kThingSmartPlaybackPeriodStartTime  ： startTime(NSNumer, unix timestamp)
 kThingSmartPlaybackPeriodStopTime   ： stopTime(NSNumer, unix timestamp)[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera didReceiveTimeSliceQueryData:(NSArray<NSDictionary *> *)timeSlices {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:didReceiveTimeSliceQueryData:)]) {
            [obj camera:camera didReceiveTimeSliceQueryData:timeSlices];
        }
    }];
}

/**
 [^en]
 did receive mute state. will call when 'enableMute:' success. default is YES.
 [$en]

 [^zh]
 收到静音状态，方法会在 'enableMute:' 成功之后被调用，默认为 YES
 [$zh]

 @param camera camera
 @param isMute [^en]is muted[$en] [^zh]是否为静音[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera didReceiveMuteState:(BOOL)isMute playMode:(ThingSmartCameraPlayMode)playMode {
    self.cameraModel.muteLoading = NO;
    if (playMode == ThingSmartCameraPlayModePreview) {
        self.cameraModel.mutedForPreview = isMute;
    }else if (playMode == ThingSmartCameraPlayModePlayback) {
        self.cameraModel.mutedForPlayback = isMute;
    }
    
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:didReceiveMuteState:playMode:)]) {
            [obj camera:camera didReceiveMuteState:isMute playMode:playMode];
        }
    }];
}

/**
 [^en]
 the control of camera has occurred an error with specific reason code
 [$en]
 
 [^zh]
 camera 控制出现了一个错误，附带错误码
 [$zh]
 @param camera camera
 @param errStepCode [^en]reference the ThingCameraErrorCode[$en] [^zh]具体参考 ThingCameraErrorCode [$zh]
 @param errorCode [^en]errorCode reference ThingCameraSDK.framework/TYDefines[$en] [^zh]具体参考ThingCameraSDK.framework/TYDefines[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera didOccurredErrorAtStep:(ThingCameraErrorCode)errStepCode specificErrorCode:(NSInteger)errorCode {
    if (errStepCode == Thing_ERROR_CONNECT_FAILED || errStepCode == Thing_ERROR_CONNECT_DISCONNECT) {
        if (errorCode == -23 || errorCode == -104 || errorCode == -113) {
            self.cameraModel.connectState = CameraDeviceConnectBusy;
        } else {
            self.cameraModel.connectState = CameraDeviceConnectFailed;
        }
    } else if (errStepCode == Thing_ERROR_START_PREVIEW_FAILED) {
        [self.camera stopPreview];
        self.cameraModel.previewState = CameraDevicePreviewFailed;
    } else if (errStepCode == Thing_ERROR_START_PLAYBACK_FAILED) {
        [self stopPlayback];
        self.cameraModel.playbackState = CameraDevicePlaybackFailed;
    } else if (errStepCode == Thing_ERROR_PAUSE_PLAYBACK_FAILED) {
        
    } else if (errStepCode == Thing_ERROR_RESUME_PLAYBACK_FAILED) {
      
    } else if (errStepCode == Thing_ERROR_START_TALK_FAILED) {
        self.cameraModel.talkLoading = NO;
        self.cameraModel.talking = NO;
    } else if (errStepCode == Thing_ERROR_SNAPSHOOT_FAILED) {
    
    } else if (errStepCode == Thing_ERROR_RECORD_FAILED) {
        self.cameraModel.recordLoading = NO;
        self.cameraModel.recording = NO;
    } else if (errStepCode == Thing_ERROR_ENABLE_MUTE_FAILED) {
        self.cameraModel.muteLoading = NO;
    } else if (errStepCode == Thing_ERROR_ENABLE_HD_FAILED) {

    }else if (errStepCode == Thing_ERROR_QUERY_TIMESLICE_FAILED) {
        self.cameraModel.playbackState = CameraDevicePlaybackFailed;
    }else if (errStepCode == Thing_ERROR_QUERY_RECORD_DAY_FAILED) {
        self.cameraModel.playbackState = CameraDevicePlaybackFailed;
    } else if (errStepCode == Thing_ERROR_QUERY_EVENTLIST_SIFT_FAILED) {
        self.cameraModel.playbackState = CameraDevicePlaybackFailed;
    }
//    } else if (errStepCode == Thing_ERROR_SET_PLAYBACK_SPEED_FAILED) {
//
//    }
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:didOccurredErrorAtStep:specificErrorCode:)]) {
            [obj camera:camera didOccurredErrorAtStep:errStepCode specificErrorCode:errorCode];
        }
    }];
}
/**
 [^en]
 the definition of the video did chagned
 [$en]

 [^zh]
 视频清晰度已经修改
 [$zh]
 @param camera camera
 @param width video width
 @param height video height
 */
- (void)camera:(id<ThingSmartCameraType>)camera resolutionDidChangeWidth:(NSInteger)width height:(NSInteger)height {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:resolutionDidChangeWidth:height:)]) {
            [obj camera:camera resolutionDidChangeWidth:width height:height];
        }
    }];
}

/**
 [^en]
 if 'isRecvFrame' is true, and p2pType is "1", the video data will not decode in the SDK, and could get the orginal video frame data through this method.
 [$en]

 [^zh]
 如果 'isRecvFrame' 是true，并且 'p2pType' 是 1， 视频数据将不会在SDK中解码，通过此方法可以获取到原始视频帧数据
 [$zh]
 @param camera      camera
 @param frameData   [^en]original video frame data[$en] [^zh]原始视频帧数据[$zh]
 @param size        [^en]video frame data size[$en] [^zh]视频帧数尺寸[$zh]
 @param frameInfo   [^en]frame header info[$en] [^zh]视频帧头信息[$zh]
 */

- (void)camera:(id<ThingSmartCameraType>)camera thing_didReceiveFrameData:(const char *)frameData dataSize:(unsigned int)size frameInfo:(ThingSmartVideoStreamInfo)frameInfo {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:thing_didReceiveFrameData:dataSize:frameInfo:)]) {
            [obj camera:camera thing_didReceiveFrameData:frameData dataSize:size frameInfo:frameInfo];
        }
    }];
}

/**
 [^en]
 if 'isRecvFrame' is true, and p2pType is greater than 2, could get the decoded YUV frame data through this method.
 [$en]

 [^zh]
 如果 'isRecvFrame' 为true，并且 'p2pType' 大于 2，可以通过此方法j获得解码后的 YUV 帧数据
 [$zh]
 @param camera          camera
 @param sampleBuffer    [^en]video frame YUV data[$en] [^zh]YUV 视频帧数据[$zh]
 @param frameInfo       [^en]frame header info[$en] [^zh]数据帧头信息[$zh]
 */
- (void)camera:(id<ThingSmartCameraType>)camera thing_didReceiveVideoFrame:(CMSampleBufferRef)sampleBuffer frameInfo:(ThingSmartVideoFrameInfo)frameInfo {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:thing_didReceiveVideoFrame:frameInfo:)]) {
            [obj camera:camera thing_didReceiveVideoFrame:sampleBuffer frameInfo:frameInfo];
        }
    }];
}

/**
 [^en]
 if p2pType is greater than 2, could get audio record data when talking through this method. if yout want change the audio data, must keep the audio data length same，and synchronize。
 [$en]

 [^zh]
 p2p2 以上的设备，如果 p2pType 大于 2， 此方法会返回录制的音频数据。如果你需要修改音频数据，务必不要改变音频数据的长度，并在修改操作需要在代理方法中同步进行。
 [$zh]
 @param camera           camera
 @param pcm              [^en]audio data[$en] [^zh]音频数据[$zh]
 @param length           [^en]date length[$en] [^zh]数据长度[$zh]
 @param sampleRate       [^en]audio sample rate[$en] [^zh]音频样本比率[$zh]
*/
- (void)camera:(id<ThingSmartCameraType>)camera thing_didRecieveAudioRecordDataWithPCM:(const unsigned char*)pcm length:(int)length sampleRate:(int)sampleRate {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:thing_didRecieveAudioRecordDataWithPCM:length:sampleRate:)]) {
            [obj camera:camera thing_didRecieveAudioRecordDataWithPCM:pcm length:length sampleRate:sampleRate];
        }
    }];
}

- (void)camera:(id<ThingSmartCameraType>)camera thing_didSpeedPlayWithSpeed:(ThingSmartCameraPlayBackSpeed)playBackSpeed {
    NSArray<id<ThingSmartCameraDelegate>> *delegates = self.innerDelegates.allObjects;
    [delegates enumerateObjectsUsingBlock:^(id<ThingSmartCameraDelegate>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(camera:thing_didSpeedPlayWithSpeed:)]) {
            [obj camera:camera thing_didSpeedPlayWithSpeed:playBackSpeed];
        }
    }];
}

- (void)cameraDidStartVideoTalk:(id<ThingSmartCameraType>)camera {
    self.cameraModel.videoTalkState = CameraDeviceTaskStateCompleted;
    self.cameraModel.videoTalkPaused = NO;
}

- (void)cameraDidStopVideoTalk:(id<ThingSmartCameraType>)camera {
    self.cameraModel.videoTalkState = CameraDeviceTaskStateNone;
    self.cameraModel.videoTalkPaused = NO;
}

- (void)cameraDidPauseVideoTalk:(id<ThingSmartCameraType>)camera {
    self.cameraModel.videoTalkPaused = YES;
}

- (void)cameraDidResumeVideoTalk:(id<ThingSmartCameraType>)camera {
    self.cameraModel.videoTalkPaused = NO;
}

- (void)camera:(id<ThingSmartCameraType>)camera didReceiveLocalVideoFirstFrame:(UIImage *)image localVideoInfo:(id<ThingSmartLocalVideoInfoType>)localVideoInfo {
    NSLog(@"%s-size(%.fx%.f)",__func__,localVideoInfo.width,localVideoInfo.height);
}

- (void)camera:(id<ThingSmartCameraType>)camera didReceiveLocalVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer localVideoInfo:(id<ThingSmartLocalVideoInfoType>)localVideoInfo {
}

#pragma mark - Util

- (void)enableMute:(BOOL)muted {
    BOOL isOnPreviewMode = self.cameraModel.isOnPreviewMode;
    if (isOnPreviewMode) {
        self.cameraModel.mutedForPreview = muted;
    } else {
        self.cameraModel.mutedForPlayback = muted;
    }
    ThingSmartCameraPlayMode playMode = isOnPreviewMode ? ThingSmartCameraPlayModePreview : ThingSmartCameraPlayModePlayback;
    [self.camera enableMute:muted forPlayMode:playMode];
}
  

#pragma mark - Task

- (void)appendTask:(CameraDeviceTask *)task {
    [self addTask:task];
    [self syncRunTask];
}

- (void)clearAllTasks {
    dispatch_semaphore_wait(_deviceTasksLock, DISPATCH_TIME_FOREVER);
    [self.deviceTasks removeAllObjects];
    self.runningTask = nil;
    dispatch_semaphore_signal(_deviceTasksLock);
}

- (void)addTask:(CameraDeviceTask *)task {
    dispatch_semaphore_wait(_deviceTasksLock, DISPATCH_TIME_FOREVER);
    [self.deviceTasks addObject:task];
    dispatch_semaphore_signal(_deviceTasksLock);
}

- (void)removeTask:(CameraDeviceTask *)task {
    dispatch_semaphore_wait(_deviceTasksLock, DISPATCH_TIME_FOREVER);
    [self.deviceTasks removeObject:task];
    dispatch_semaphore_signal(_deviceTasksLock);
}

- (CameraDeviceTask *)nextDeviceTask {
    CameraDeviceTask *deviceTask = nil;
    dispatch_semaphore_wait(_deviceTasksLock, DISPATCH_TIME_FOREVER);
    deviceTask = self.deviceTasks.firstObject;
    dispatch_semaphore_signal(_deviceTasksLock);
    return deviceTask;
}

- (void)syncRunTask {
    if (self.runningTask.isRunning) {
        return;
    }
    if (!self.runningTask) {
        self.runningTask = [self nextDeviceTask];
    }
    if (self.runningTask) {
        self.runningTask.running = YES;
        if (self.runningTask.taskEvent == CameraDeviceTaskStartPreview) {
            [self startPreview];
        } else if (self.runningTask.taskEvent == CameraDeviceTaskStopPreview) {
            [self stopPreview];
        }
    }
}

- (void)task:(CameraDeviceTaskEvent)taskEvent completeWithError:(NSError *)error {
    CameraDeviceTask *task = nil;
    if (self.runningTask.taskEvent == taskEvent) {
        task = self.runningTask;
        [self removeTask:task];
        self.runningTask = nil;
    }
    if (!task) {
        return;
    }
    task.running = NO;
    [self syncRunTask];
    
}

@end
