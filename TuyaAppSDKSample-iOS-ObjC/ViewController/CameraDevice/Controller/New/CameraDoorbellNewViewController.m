//
//  CameraDoorbellNewViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraDoorbellNewViewController.h"
#import "CameraPermissionUtil.h"
#import <ThingSmartCameraM/ThingSmartCameraM.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraVideoView.h"
#import "CameraDoorbellManager.h"
#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import "CameraViewConstants.h"
#import "UIView+CameraAdditions.h"

#import "CameraDeviceManager.h"


#define VideoViewWidth [UIScreen mainScreen].bounds.size.width
#define VideoViewHeight ([UIScreen mainScreen].bounds.size.width / 16 * 9)

#define kControlTalk        @"talk"

@interface CameraDoorbellNewViewController ()<ThingSmartCameraDelegate, ThingSmartCameraDPObserver>

@property (nonatomic, strong) UIView *videoContainer;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, strong) UIButton *hangupButton;

@property (nonatomic, strong) UIButton *hangupTextButton;

@property (nonatomic, assign) BOOL needsReconnect;

@end

@implementation CameraDoorbellNewViewController

- (void)dealloc {
    [self stopPreview];
    [self.cameraDevice removeDelegate:self];
    [self.cameraDevice leaveCallState];
}

- (instancetype)initWithDeviceId:(NSString *)devId {
    self = [super initWithDeviceId:devId];
    if (self) {
        _needsReconnect = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoContainer];
    [self.view addSubview:self.indicatorView];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.retryButton];
    [self.view addSubview:self.hangupButton];
    [self.view addSubview:self.hangupTextButton];
    
    [self.retryButton addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cameraDevice enterCallState];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self retryAction];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopPreview];
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    [self retryAction];
    [super applicationWillEnterForegroundNotification:notification];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self stopPreview];
    [super applicationDidEnterBackgroundNotification:notification];
}

#pragma mark - Action

- (void)retryAction {
    if (!self.cameraDevice.deviceModel.isOnline) {
        self.stateLabel.hidden = NO;
        self.stateLabel.text = NSLocalizedStringFromTable(@"title_device_offline", @"IPCLocalizable", @"");
        return;
    }
    if (self.cameraDevice.cameraModel.connectState == CameraDeviceConnecting || self.cameraDevice.cameraModel.connectState == CameraDeviceConnected) {
        [self startPreview];
    } else {
        [self connectCamera];
    }
    if (self.cameraDevice.cameraModel.previewState != CameraDevicePreviewing) {
        [self showLoadingWithTitle:NSLocalizedStringFromTable(@"loading", @"IPCLocalizable", @"")];
        self.retryButton.hidden = YES;
    }
}

- (void)talkAction {
    if ([CameraPermissionUtil microNotDetermined]) {
        [CameraPermissionUtil requestAccessForMicro:^(BOOL result) {
            if (result) {
                [self _talkAction];
            }
        }];
    }else if ([CameraPermissionUtil microDenied]) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"Micro permission denied", @"IPCLocalizable", @"")];
    }else {
        [self _talkAction];
    }
}

- (void)_talkAction {
    [self.cameraDevice startTalk];
}

#pragma mark - Operation

- (void)connectCamera {
    [self.cameraDevice connectWithPlayMode:ThingSmartCameraPlayModePreview];
}

- (void)startPreview {
    [self.videoContainer addSubview:self.videoView];
    self.videoView.frame = self.videoContainer.bounds;
    [self.cameraDevice startPreview];
}

- (void)stopPreview {
    [self.cameraDevice stopPreview];
}

#pragma mark - Loading && Alert

- (void)showLoadingWithTitle:(NSString *)title {
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
    self.stateLabel.hidden = NO;
    self.stateLabel.text = title;
}

- (void)stopLoading {
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
    self.stateLabel.hidden = YES;
}

#pragma mark - ThingSmartCameraDelegate

- (void)cameraDidConnected:(id<ThingSmartCameraType>)camera {
    [self startPreview];
}

- (void)cameraDisconnected:(id<ThingSmartCameraType>)camera specificErrorCode:(NSInteger)errorCode {
    if ((errorCode == -3 || errorCode == -105) && self.needsReconnect) {
        self.needsReconnect = NO;
        NSLog(@"[reconnect]");
        [self retryAction];
        return;
    }
    self.retryButton.hidden = NO;
}

- (void)cameraDidBeginPreview:(id<ThingSmartCameraType>)camera {
    [self.cameraDevice getHD];
    [self stopLoading];
    
    [self.cameraDevice enableMute:NO forPlayMode:ThingSmartCameraPlayModePreview];
    [self talkAction];
}

- (void)cameraDidStopPreview:(id<ThingSmartCameraType>)camera {
    
}

- (void)camera:(id<ThingSmartCameraType>)camera didOccurredErrorAtStep:(ThingCameraErrorCode)errStepCode specificErrorCode:(NSInteger)errorCode {
    if (errStepCode == Thing_ERROR_CONNECT_FAILED || errStepCode == Thing_ERROR_CONNECT_DISCONNECT) {
        [self stopLoading];
        self.retryButton.hidden = NO;
    } else if (errStepCode == Thing_ERROR_START_PLAYBACK_FAILED || errStepCode == Thing_ERROR_QUERY_RECORD_DAY_FAILED || errStepCode == Thing_ERROR_QUERY_EVENTLIST_SIFT_FAILED || errStepCode == Thing_ERROR_QUERY_TIMESLICE_FAILED) {
        [self stopLoading];
        self.retryButton.hidden = NO;
    } else if (errStepCode == Thing_ERROR_START_TALK_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"ipc_errmsg_mic_failed", @"IPCLocalizable", @"")];
    }
}

#pragma mark - Private

#pragma mark - Accessor

- (UIView *)videoContainer {
    if (!_videoContainer) {
        _videoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VideoViewWidth, VideoViewHeight)];
        _videoContainer.center = self.view.center;
        _videoContainer.backgroundColor = [UIColor blackColor];
    }
    return _videoContainer;
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

- (UIButton *)hangupButton {
    if (!_hangupButton) {
        _hangupButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        _hangupButton.centerX = self.videoContainer.centerX;
        _hangupButton.top = self.videoContainer.bottom + 50;
        [_hangupButton setImage:[UIImage imageNamed:@"ty_camera_hangup"] forState:UIControlStateNormal];
        [_hangupButton addTarget:self action:@selector(hangupBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupButton;
}

- (UIButton *)hangupTextButton {
    if (!_hangupTextButton) {
        _hangupTextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
        _hangupTextButton.centerX = self.hangupButton.centerX;
        _hangupTextButton.top = self.hangupButton.bottom + 5;
        [_hangupTextButton setTitle:NSLocalizedStringFromTable(@"Hangup", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        [_hangupTextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _hangupTextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_hangupTextButton addTarget:self action:@selector(hangupBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hangupTextButton;
}

- (void)hangupBtnClick {
    [[CameraDoorbellManager sharedInstance] hangupDoorBellCall];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
