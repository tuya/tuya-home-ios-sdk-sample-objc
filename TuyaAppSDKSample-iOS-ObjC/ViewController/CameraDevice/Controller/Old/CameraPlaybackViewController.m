//
//  CameraPlaybackViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraPlaybackViewController.h"
#import "CameraPermissionUtil.h"
#import "CameraCalendarView.h"
#import "CameraTimeLineModel.h"
#import <YYModel/YYModel.h>
#import <TuyaSmartCameraM/TuyaSmartCameraM.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraVideoView.h"
#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>
#import "CameraViewConstants.h"
#import "UIView+CameraAdditions.h"

#define VideoViewWidth [UIScreen mainScreen].bounds.size.width
#define VideoViewHeight ([UIScreen mainScreen].bounds.size.width / 16 * 9)

typedef NSArray<NSNumber *> TYNumberArray;
typedef NSArray<NSDictionary *> TYDictArray;

@interface CameraPlaybackViewController ()<TuyaSmartCameraDelegate, CameraCalendarViewDelegate, CameraCalendarViewDataSource, TuyaTimelineViewDelegate>

@property (nonatomic, strong) NSString *devId;

@property (nonatomic, strong) UIView *videoContainer;

@property (nonatomic, strong) CameraCalendarView *calendarView;

@property (nonatomic, strong) UIButton *soundButton;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, strong) UIButton *photoButton;

@property (nonatomic, strong) UIButton *recordButton;

@property (nonatomic, strong) UIButton *pauseButton;

@property (nonatomic, strong) UIView *controlBar;

@property (nonatomic, strong) TuyaTimelineView *timeLineView;

@property (nonatomic, strong) TYCameraTimeLabel *timeLineLabel;

@property (nonatomic, strong) CameraVideoView *videoView;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *playbackDays;

@property (nonatomic, strong) TuyaSmartPlaybackDate *currentDate;

@property (nonatomic, strong) NSArray *timeLineModels;

@property (nonatomic, assign) NSInteger playTime;

@property (nonatomic, strong) TuyaSmartDevice *device;

@property (nonatomic, strong) id<TuyaSmartCameraType> cameraType;

@property (nonatomic, assign, getter=isConnecting)      BOOL connecting;

@property (nonatomic, assign, getter=isConnected)       BOOL connected;

@property (nonatomic, assign, getter=isPlaybacking)     BOOL playbacking;

@property (nonatomic, assign, getter=isMuted)           BOOL muted;

@property (nonatomic, assign, getter=isRecording)       BOOL recording;

@property (nonatomic, assign, getter=isPlaybackPuased)  BOOL playbackPaused;

@property (nonatomic, strong) NSMutableDictionary<NSString *, TYNumberArray *> *cameraPlaybackDays;

@property (nonatomic, strong) NSString *lastPlaybackDayQueryMonth;

@property (nonatomic, copy) TYSuccessList getPlaybackDaysComplete;

@property (nonatomic, copy) TYSuccessList getRecordTimeSlicesComplete;

@property (nonatomic, assign) BOOL needsReconnect;

@end

@implementation CameraPlaybackViewController

- (void)dealloc {
    [self disConnect];
    [self.cameraType destory];
}

- (instancetype)initWithDeviceId:(NSString *)devId {
    if (self = [super initWithNibName:nil bundle:nil]) {
        _needsReconnect = YES;
        _devId = devId;
        _device = [TuyaSmartDevice deviceWithDeviceId:devId];
        _cameraType = [TuyaSmartCameraFactory cameraWithP2PType:@(_device.deviceModel.p2pType) deviceId:_device.deviceModel.devId delegate:self];
        _muted = YES;
        _videoView = [[CameraVideoView alloc] initWithFrame:CGRectZero];
        _videoView.renderView = _cameraType.videoView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xd8d8d8);
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *rightTitle = NSLocalizedStringFromTable(@"ipc_panel_button_calendar", @"IPCLocalizable", @"");
    [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(dateAction) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(0, 0, 30, 44);
    [rightBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    
    [self.view addSubview:self.videoContainer];
    [self.view addSubview:self.indicatorView];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.retryButton];
    [self.view addSubview:self.timeLineView];
    [self.view addSubview:self.soundButton];
    [self.view addSubview:self.calendarView];
    [self.view addSubview:self.controlBar];
    [self.view addSubview:self.timeLineLabel];
    
    [self.retryButton addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchUpInside];
    [self.soundButton addTarget:self action:@selector(soundAction) forControlEvents:UIControlEventTouchUpInside];
    [self.photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self action:@selector(pauseAction) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (NSString *)titleForCenterItem {
    return self.device.deviceModel.name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
    [self retryAction];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    [self stopPlayback];
}

- (void)willEnterForeground {
    [self retryAction];
}

- (void)didEnterBackground {
    self.connected = NO;
    [self stopPlayback];
}

#pragma mark - Action

- (void)enableAllControl:(BOOL)enabled {
    self.photoButton.enabled = enabled;
    self.pauseButton.enabled = enabled;
    self.recordButton.enabled = enabled;
}

- (void)dateAction {
    [self.view bringSubviewToFront:self.calendarView];
    [self.calendarView show:[NSDate new]];
    TuyaSmartPlaybackDate *playbackDate = [TuyaSmartPlaybackDate new];
    __weak typeof(self) weakSelf = self;
    [self playbackDaysInYear:playbackDate.year month:playbackDate.month complete:^(TYNumberArray *result) {
        weakSelf.playbackDays = result.mutableCopy;
        [weakSelf.calendarView reloadData];
    }];
}

- (void)retryAction {
    [self enableAllControl:NO];
    [self connectCamera];
    [self showLoadingWithTitle:NSLocalizedStringFromTable(@"loading", @"IPCLocalizable", @"")];
    self.retryButton.hidden = YES;
}

- (void)soundAction {
    [self enableMute:!self.isMuted];
}

- (void)recordAction {
    [self checkPhotoPermision:^(BOOL result) {
        if (result) {
            if (self.isRecording) {
                [self stopRecord];
            }else {
                [self startRecord];
            }
        }
    }];
}

- (void)checkPhotoPermision:(void(^)(BOOL result))complete {
    if ([CameraPermissionUtil isPhotoLibraryNotDetermined]) {
        [CameraPermissionUtil requestPhotoPermission:complete];
    }else if ([CameraPermissionUtil isPhotoLibraryDenied]) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"Photo library permission denied", @"IPCLocalizable", @"") complete:nil];
        !complete?:complete(NO);
    }else {
        !complete?:complete(YES);
    }
}

- (void)pauseAction {
    if (self.isPlaybackPuased) {
        [self.cameraType resumePlayback];
    } else if (self.isPlaybacking) {
        [self stopRecord];
        [self.cameraType pausePlayback];
    }
}

- (void)photoAction {
    [self checkPhotoPermision:^(BOOL result) {
        if (result) {
            [self.cameraType snapShoot];
        }
    }];
}

#pragma mark - Operation

- (void)connectCamera {
    if (self.isConnected || self.isConnecting) {
        return;
    }
    _connecting = YES;
    [self.cameraType connectWithMode:TuyaSmartCameraConnectAuto];
}

- (void)disConnect {
    [self stopPlayback];
    [self.cameraType disConnect];
    self.connected = NO;
    self.connecting = NO;
}

- (void)startPlayback {
    [self.videoView tuya_clear];
    [self.videoContainer addSubview:self.videoView];
    self.videoView.frame = self.videoContainer.bounds;
    [self getRecordAndPlay:[TuyaSmartPlaybackDate new]];
}

- (void)stopPlayback {
    if (self.isRecording) {
        [self.cameraType stopRecord];
    }
    [self.cameraType stopPlayback];
}

- (void)startRecord {
    if (self.isRecording) {
        return;
    }
    if (self.playbacking) {
        [self.cameraType startRecord];
        _recording = YES;
    }
}

- (void)stopRecord {
    if (self.isRecording) {
        [self.cameraType stopRecord];
    }
}

- (void)enableMute:(BOOL)isMute {
    [self.cameraType enableMute:isMute forPlayMode:TuyaSmartCameraPlayModePlayback];
}

#pragma mark - Loading && Alert

- (void)showLoadingWithTitle:(NSString *)title {
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
    self.stateLabel.hidden = NO;
    self.stateLabel.text = title;
}

- (void)stopLoadingWithText:(NSString *)text {
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
    if (text.length > 0) {
        self.stateLabel.text = text;
    }else {
        self.stateLabel.hidden = YES;
    }
}

- (void)showAlertWithMessage:(NSString *)msg complete:(void(^)(void))complete {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ipc_settings_ok", @"IPCLocalizable", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !complete?:complete();
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TuyaTimelineViewDelegate

- (void)timelineViewDidScroll:(TuyaTimelineView *)timeLineView time:(NSTimeInterval)timeInterval isDragging:(BOOL)isDragging {
    self.timeLineLabel.hidden = NO;
    self.timeLineLabel.timeStr = [NSDate tysdk_timeStringWithTimeInterval:timeInterval timeZone:[NSTimeZone localTimeZone]];
}

- (void)timelineView:(TuyaTimelineView *)timeLineView didEndScrollingAtTime:(NSTimeInterval)timeInterval inSource:(id<TuyaTimelineViewSource>)source {
    self.timeLineLabel.hidden = YES;
    if (source) {
        [self playbackWithTime:timeInterval timeLineModel:source];
    }
}

#pragma mark - CameraCalendarViewDataSource

- (BOOL)calendarView:(CameraCalendarView *)calendarView hasVideoOnYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    if (!self.playbackDays) {
        return NO;
    }
    return [self.playbackDays containsObject:@(day)];
}

#pragma mark - CameraCalendarViewDelegate

- (void)calendarView:(CameraCalendarView *)calendarView didSelectYear:(NSInteger)year month:(NSInteger)month {
    self.playbackDays = nil;
    [self showLoadingWithTitle:@""];
    [self playbackDaysInYear:year month:month complete:^(TYNumberArray *result) {
        [self stopLoadingWithText:@""];
        self.playbackDays = [result mutableCopy];
        [calendarView reloadData];
    }];
}

- (void)calendarView:(CameraCalendarView *)calendarView didSelectYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day date:(NSDate *)date {
    [calendarView hide];
    [self getRecordAndPlay:[TuyaSmartPlaybackDate playbackDateWithDate:date]];
}

#pragma mark - Private

- (void)getRecordAndPlay:(TuyaSmartPlaybackDate *)playbackDate {
    self.title = [NSString stringWithFormat:@"%@-%@-%@", @(playbackDate.year), @(playbackDate.month), @(playbackDate.day)];
    self.currentDate = playbackDate;
    __weak typeof(self) weakSelf = self;
    [self showLoadingWithTitle:@""];
    [self requestTimeSliceWithPlaybackDate:playbackDate complete:^(TYDictArray *result) {
        if (result.count > 0) {
            weakSelf.timeLineModels = [NSArray yy_modelArrayWithClass:[CameraTimeLineModel class] json:result];
            weakSelf.timeLineView.sourceModels = weakSelf.timeLineModels;
            [weakSelf.timeLineView setCurrentTime:0 animated:YES];
        }else {
            [weakSelf stopLoadingWithText:NSLocalizedStringFromTable(@"ipc_playback_no_records_today", @"IPCLocalizable", @"")];
        }
    }];
}

- (void)requestTimeSliceWithPlaybackDate:(TuyaSmartPlaybackDate *)date complete:(void(^)(TYDictArray *result))complete {
    NSString *monthKey = [NSString stringWithFormat:@"%@-%@", @(date.year), @(date.month)];
    TYNumberArray *days = [self.cameraPlaybackDays objectForKey:monthKey];
    
    if (![days containsObject:@(date.day)] && ![TuyaSmartPlaybackDate isToday:date]) {
        !complete?:complete(@[]);
    }else {
        self.getRecordTimeSlicesComplete = complete;
        [self.cameraType queryRecordTimeSliceWithYear:date.year month:date.month day:date.day];
    }
}

- (void)playbackWithTime:(NSInteger)playTime timeLineModel:(CameraTimeLineModel *)model {
    playTime = [model containsPlayTime:playTime] ? playTime : model.startTime;
    [self showLoadingWithTitle:@""];
    [self.cameraType startPlayback:playTime startTime:model.startTime stopTime:model.stopTime];
    _playbacking = YES;
    [self enableMute:self.isMuted];
}

- (void)playbackDaysInYear:(NSInteger)year month:(NSInteger)month complete:(void (^)(TYNumberArray *))complete {
    NSString *monthKey = [NSString stringWithFormat:@"%@-%@", @(year), @(month)];
    TYNumberArray *days = [self.cameraPlaybackDays objectForKey:monthKey];
    if (days) {
        !complete?:complete(days);
    }else {
        self.getPlaybackDaysComplete = complete;
        [self.cameraType queryRecordDaysWithYear:year month:month];
        self.lastPlaybackDayQueryMonth = [NSString stringWithFormat:@"%@-%@", @(year), @(month)];
    }
}

- (void)audioAttributesMap:(NSDictionary *)attributes {
    __block BOOL supportSound = NO;
    __block BOOL supportTalk = NO;
    BOOL couldChangeAudioMode = NO;
    if (!attributes) { return; }
    NSArray *hardwareCapability = [attributes objectForKey:@"hardwareCapability"];
    NSArray *callMode = [attributes objectForKey:@"callMode"];
    if (!hardwareCapability || hardwareCapability.count == 0) {
        return;
    }
    [hardwareCapability enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj integerValue] == 1) {
            supportSound = YES;
        }
        if ([obj integerValue] == 2) {
            supportTalk = YES;
        }
    }];
    
    if (!callMode || callMode.count == 0) {
        return;
    }
    
    if (callMode.count >= 2) {
        couldChangeAudioMode = YES;
    }else {
        couldChangeAudioMode = NO;
    }
    
    NSLog(@"isSupportInstantTalkback:%@", @(couldChangeAudioMode));
    NSLog(@"isSupportTalk:%@", @(supportTalk));
    NSLog(@"isSupportSound:%@", @(supportSound));
}

#pragma mark - TuyaSmartCameraDelegate

- (void)cameraDidConnected:(id<TuyaSmartCameraType>)camera {
    _connecting = NO;
    _connected = YES;
    [self.cameraType enterPlayback];
    NSDictionary *config = [TuyaSmartP2pConfigService getCachedConfigWithDeviceModel:self.device.deviceModel];
    [self audioAttributesMap:[config objectForKey:@"audioAttributes"]];
    [self startPlayback];
}

//- (void)cameraDisconnected:(id<TuyaSmartCameraType>)camera {
//    _connecting = NO;
//    _connected = NO;
//    [self enableAllControl:NO];
//    self.retryButton.hidden = NO;
//}

- (void)cameraDisconnected:(id<TuyaSmartCameraType>)camera specificErrorCode:(NSInteger)errorCode {
    _connecting = NO;
    _connected = NO;
    if ((errorCode == -3 || errorCode == -105) && self.needsReconnect) {
        self.needsReconnect = NO;
        NSLog(@"[reconnect]");
        [self retryAction];
        return;
    }
    [self enableAllControl:NO];
    self.retryButton.hidden = NO;
}

- (void)cameraDidBeginPreview:(id<TuyaSmartCameraType>)camera {
    [self.cameraType getHD];
}

- (void)cameraDidBeginPlayback:(id<TuyaSmartCameraType>)camera {
    _playbackPaused = NO;
    [self enableAllControl:YES];
    [self stopLoadingWithText:@""];
}

- (void)cameraDidPausePlayback:(id<TuyaSmartCameraType>)camera {
    _playbackPaused = YES;
    UIImage *image = [[UIImage imageNamed:@"ty_camera_tool_play_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.pauseButton setImage:image forState:UIControlStateNormal];
    self.recordButton.enabled = NO;
}

- (void)cameraDidResumePlayback:(id<TuyaSmartCameraType>)camera {
    _playbackPaused = NO;
    [self enableAllControl:YES];
    [self stopLoadingWithText:nil];
    UIImage *image = [[UIImage imageNamed:@"ty_camera_tool_pause_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.pauseButton setImage:image forState:UIControlStateNormal];
}

- (void)cameraDidStopPlayback:(id<TuyaSmartCameraType>)camera {
    _playbacking = NO;
    _playbackPaused = NO;
}

- (void)cameraPlaybackDidFinished:(id<TuyaSmartCameraType>)camera {
    _playbacking = NO;
    _playbackPaused = NO;
    [self enableAllControl:NO];
    [self stopLoadingWithText:NSLocalizedStringFromTable(@"ipc_video_end", @"IPCLocalizable", @"")];
}

- (void)cameraSnapShootSuccess:(id<TuyaSmartCameraType>)camera {
    [self showAlertWithMessage:NSLocalizedStringFromTable(@"ipc_multi_view_photo_saved", @"IPCLocalizable", @"") complete:nil];
}

- (void)cameraDidStartRecord:(id<TuyaSmartCameraType>)camera {
    self.recordButton.tintColor = [UIColor blueColor];
}

- (void)cameraDidStopRecord:(id<TuyaSmartCameraType>)camera {
    _recording = NO;
    self.recordButton.tintColor = [UIColor blackColor];
    [self showAlertWithMessage:NSLocalizedStringFromTable(@"ipc_multi_view_video_saved", @"IPCLocalizable", @"") complete:nil];
}

- (void)camera:(id<TuyaSmartCameraType>)camera didReceiveRecordDayQueryData:(NSArray<NSNumber *> *)days {
    if (self.lastPlaybackDayQueryMonth.length > 0) {
        [self.cameraPlaybackDays setObject:days forKey:self.lastPlaybackDayQueryMonth];
        self.lastPlaybackDayQueryMonth = nil;
        if (self.getPlaybackDaysComplete) {
            self.getPlaybackDaysComplete(days);
            self.getPlaybackDaysComplete = nil;
        }
    }
}

- (void)camera:(id<TuyaSmartCameraType>)camera didReceiveTimeSliceQueryData:(NSArray<NSDictionary *> *)timeSlices {
    if (self.getRecordTimeSlicesComplete) {
        self.getRecordTimeSlicesComplete([timeSlices copy]);
        self.getRecordTimeSlicesComplete = nil;
    }
}

- (void)camera:(id<TuyaSmartCameraType>)camera didReceiveMuteState:(BOOL)isMute playMode:(TuyaSmartCameraPlayMode)playMode {
    if (playMode == TuyaSmartCameraPlayModePlayback) {
        self.muted = isMute;
    }
    
    NSString *imageName = @"ty_camera_soundOn_icon";
    if (isMute) {
        imageName = @"ty_camera_soundOff_icon";
    }
    [self.soundButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}

- (void)camera:(id<TuyaSmartCameraType>)camera didOccurredErrorAtStep:(TYCameraErrorCode)errStepCode specificErrorCode:(NSInteger)errorCode {
    if (errStepCode == TY_ERROR_CONNECT_FAILED || errStepCode == TY_ERROR_CONNECT_DISCONNECT) {
        _connecting = NO;
        _connected = NO;
        [self stopLoadingWithText:@""];
        self.retryButton.hidden = NO;
        [self enableAllControl:NO];
    }
    else if (errStepCode == TY_ERROR_START_PREVIEW_FAILED) {
        [self stopLoadingWithText:@""];
        self.retryButton.hidden = NO;
    }
    else if (errStepCode == TY_ERROR_START_PLAYBACK_FAILED) {
        _playbacking = NO;
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"ipc_errmsg_record_play_failed", @"IPCLocalizable", @"") complete:nil];
    }
    else if (errStepCode == TY_ERROR_PAUSE_PLAYBACK_FAILED) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"") complete:nil];
    }
    else if (errStepCode == TY_ERROR_RESUME_PLAYBACK_FAILED) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"") complete:nil];
    }
    else if (errStepCode == TY_ERROR_SNAPSHOOT_FAILED) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"") complete:nil];
    }
    else if (errStepCode == TY_ERROR_RECORD_FAILED) {
        _recording = NO;
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"record failed", @"IPCLocalizable", @"") complete:nil];
    }
}

- (void)camera:(id<TuyaSmartCameraType>)camera ty_didReceiveVideoFrame:(CMSampleBufferRef)sampleBuffer frameInfo:(TuyaSmartVideoFrameInfo)frameInfo {
    if (self.playTime != frameInfo.nTimeStamp) {
        self.playTime = frameInfo.nTimeStamp;
        if (!self.timeLineView.isDecelerating && !self.timeLineView.isDragging) {
            [self.timeLineView setCurrentTime:self.playTime];
        }
    }
}

#pragma mark - Accessor

- (UIView *)videoContainer {
    if (!_videoContainer) {
        _videoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, VideoViewWidth, VideoViewHeight)];
        _videoContainer.backgroundColor = [UIColor blackColor];
    }
    return _videoContainer;
}

- (UIButton *)soundButton {
    if (!_soundButton) {
        _soundButton = [[UIButton alloc] initWithFrame:CGRectMake(8, APP_TOP_BAR_HEIGHT + VideoViewHeight - 50, 44, 44)];
        [_soundButton setImage:[UIImage imageNamed:@"ty_camera_soundOff_icon"] forState:UIControlStateNormal];
    }
    return _soundButton;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        CGPoint center = self.videoContainer.center;
        center.y -= 20;
        _indicatorView.center = center;
        _indicatorView.hidden = YES;
    }
    return _indicatorView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.indicatorView.frame) + 8, VideoViewWidth, 20)];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.textColor = [UIColor whiteColor];
        _stateLabel.hidden = YES;
    }
    return _stateLabel;
}

- (UIButton *)retryButton {
    if (!_retryButton) {
        _retryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VideoViewWidth, 40)];
        _retryButton.center = self.videoContainer.center;
        [_retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_retryButton setTitle:NSLocalizedStringFromTable(@"connect failed, click retry", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        _retryButton.hidden = YES;
    }
    return _retryButton;
}

- (CameraCalendarView *)calendarView {
    if (!_calendarView) {
        _calendarView = [[CameraCalendarView alloc] initWithFrame:CGRectZero];
        _calendarView.dataSource = self;
        _calendarView.delegate = self;
    }
    return _calendarView;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        UIImage *image = [[UIImage imageNamed:@"ty_camera_photo_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_photoButton setImage:image forState:UIControlStateNormal];
        [_photoButton setTintColor:[UIColor blackColor]];
    }
    return _photoButton;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        UIImage *image = [[UIImage imageNamed:@"ty_camera_rec_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_recordButton setImage:image forState:UIControlStateNormal];
        [_recordButton setTintColor:[UIColor blackColor]];
    }
    return _recordButton;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [[UIButton alloc] init];
        UIImage *image = [[UIImage imageNamed:@"ty_camera_tool_pause_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_pauseButton setImage:image forState:UIControlStateNormal];
        [_pauseButton setTintColor:[UIColor blackColor]];
    }
    return _pauseButton;
}

- (UIView *)controlBar {
    if (!_controlBar) {
        CGFloat top = [UIScreen mainScreen].bounds.size.height - 50;
        _controlBar = [[UIView alloc] initWithFrame:CGRectMake(0, top, VideoViewWidth, 50)];
        [_controlBar addSubview:self.photoButton];
        [_controlBar addSubview:self.pauseButton];
        [_controlBar addSubview:self.recordButton];
        CGFloat width = VideoViewWidth / 3;
        [_controlBar.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            obj.frame = CGRectMake(width * idx, 0, width, 50);
        }];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, VideoViewWidth, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_controlBar addSubview:line];
        _controlBar.backgroundColor = [UIColor whiteColor];
    }
    return _controlBar;
}

- (TuyaTimelineView *)timeLineView {
    if (!_timeLineView) {
        _timeLineView = [[TuyaTimelineView alloc] initWithFrame:CGRectMake(0, self.videoContainer.bottom, [UIScreen mainScreen].bounds.size.width, 150)];
        _timeLineView.timeHeaderHeight = 24;
        _timeLineView.showShortMark = YES;
        _timeLineView.spacePerUnit = 90;
        _timeLineView.timeTextTop = 6;
        _timeLineView.delegate = self;
        _timeLineView.backgroundColor = HEXCOLOR(0xf5f5f5);
        _timeLineView.backgroundGradientColors = @[];
        _timeLineView.contentGradientColors = @[(__bridge id)HEXCOLORA(0x4f67ee, 0.62).CGColor, (__bridge id)HEXCOLORA(0x4d67ff, 0.09).CGColor];
        _timeLineView.contentGradientLocations = @[@(0.0), @(1.0)];
        _timeLineView.timeStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:9], NSForegroundColorAttributeName : HEXCOLOR(0x999999)};
        _timeLineView.tickMarkColor = HEXCOLORA(0x000000, 0.1);
        _timeLineView.timeZone = [NSTimeZone localTimeZone];
    }
    return _timeLineView;
}

- (TYCameraTimeLabel *)timeLineLabel {
    if (!_timeLineLabel) {
        _timeLineLabel = [[TYCameraTimeLabel alloc] initWithFrame:CGRectMake((self.timeLineView.width - 74) / 2, self.timeLineView.top, 74, 22)];
        _timeLineLabel.position = 2;
        _timeLineLabel.hidden = YES;
        _timeLineLabel.ty_backgroundColor = [UIColor blackColor];
        _timeLineLabel.textColor = [UIColor whiteColor];
    }
    return _timeLineLabel;
}

- (NSMutableDictionary<NSString *,TYNumberArray *> *)cameraPlaybackDays {
    if (!_cameraPlaybackDays) {
        _cameraPlaybackDays = [NSMutableDictionary new];
    }
    return _cameraPlaybackDays;
}

@end
