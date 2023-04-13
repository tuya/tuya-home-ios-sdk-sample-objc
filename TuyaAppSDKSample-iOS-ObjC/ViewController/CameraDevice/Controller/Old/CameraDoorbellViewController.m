//
//  CameraDoorbellViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraDoorbellViewController.h"
#import "CameraPermissionUtil.h"
#import <TuyaSmartCameraM/TuyaSmartCameraM.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraVideoView.h"
#import "CameraDoorbellManager.h"
#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>
#import "CameraViewConstants.h"
#import "UIView+CameraAdditions.h"


#define VideoViewWidth [UIScreen mainScreen].bounds.size.width
#define VideoViewHeight ([UIScreen mainScreen].bounds.size.width / 16 * 9)

#define kControlTalk        @"talk"

@interface CameraDoorbellViewController ()<TuyaSmartCameraDelegate, TuyaSmartCameraDPObserver>

@property (nonatomic, strong) NSString *devId;

@property (nonatomic, strong) UIView *videoContainer;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, strong) UIButton *hangupButton;

@property (nonatomic, strong) UIButton *hangupTextButton;

@property (nonatomic, strong) TuyaSmartDevice *device;

@property (nonatomic, strong) id<TuyaSmartCameraType> cameraType;

@property (nonatomic, strong) CameraVideoView *videoView;

@property (nonatomic, assign, getter=isConnecting)      BOOL connecting;

@property (nonatomic, assign, getter=isConnected)       BOOL connected;

@property (nonatomic, assign, getter=isPreviewing)      BOOL previewing;

@property (nonatomic, assign) BOOL needsReconnect;

@end

@implementation CameraDoorbellViewController

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
        _videoView = [[CameraVideoView alloc] initWithFrame:CGRectZero];
        _videoView.renderView = _cameraType.videoView;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
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
    [self disConnect];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
}

- (void)willEnterForeground {
    [self retryAction];
}

- (void)didEnterBackground {
    [self stopPreview];
    [self disConnect];
}

#pragma mark - Action

- (void)retryAction {
    if (!self.device.deviceModel.isOnline) {
        self.stateLabel.hidden = NO;
        self.stateLabel.text = NSLocalizedStringFromTable(@"title_device_offline", @"IPCLocalizable", @"");
        return;
    }
    if ([self isDoorbell]) {
        [self.device awakeDeviceWithSuccess:nil failure:nil];
    }
    [self connectCamera];
    [self showLoadingWithTitle:NSLocalizedStringFromTable(@"loading", @"IPCLocalizable", @"")];
    self.retryButton.hidden = YES;
}

- (void)talkAction {
    if ([CameraPermissionUtil microNotDetermined]) {
        [CameraPermissionUtil requestAccessForMicro:^(BOOL result) {
            if (result) {
                [self _talkAction];
            }
        }];
    }else if ([CameraPermissionUtil microDenied]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromTable(@"Micro permission denied", @"IPCLocalizable", @"") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ipc_settings_ok", @"IPCLocalizable", @"") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        [self _talkAction];
    }
}

- (void)_talkAction {
    [self.cameraType startTalk];
}

#pragma mark - Operation

- (BOOL)isDoorbell {
    return self.device.deviceModel.isLowPowerDevice;
}

- (void)connectCamera {
    if (self.isConnected || self.isConnecting) {
        return;
    }
    _connecting = YES;
    [self.cameraType connectWithMode:TuyaSmartCameraConnectAuto];
}

- (void)startPreview {
    [self.videoContainer addSubview:self.videoView];
    self.videoView.frame = self.videoContainer.bounds;
    [self.cameraType startPreview];
    _previewing = YES;
}

- (void)stopPreview {
    [self.cameraType stopPreview];
}

- (void)disConnect {
    [self stopPreview];
    [self.cameraType disConnect];
    self.connected = NO;
    self.connecting = NO;
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

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ty_alert_confirm", @"IPCLocalizable", @"") style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)showAlertWithMessage:(NSString *)msg complete:(void(^)(void))complete {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ipc_settings_ok", @"IPCLocalizable", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !complete?:complete();
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TuyaSmartCameraDelegate

- (void)cameraDidConnected:(id<TuyaSmartCameraType>)camera {
    [self.cameraType enterPlayback];
    _connecting = NO;
    _connected = YES;
    NSDictionary *config = [TuyaSmartP2pConfigService getCachedConfigWithDeviceModel:self.device.deviceModel];
    [self audioAttributesMap:[config objectForKey:@"audioAttributes"]];
    [self startPreview];
}

//- (void)cameraDisconnected:(id<TuyaSmartCameraType>)camera {
//    _connecting = NO;
//    _connected = NO;
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
    self.retryButton.hidden = NO;
}

- (void)cameraDidBeginPreview:(id<TuyaSmartCameraType>)camera {
    [self.cameraType getHD];
    [self stopLoading];
    
    [self.cameraType enableMute:NO forPlayMode:TuyaSmartCameraPlayModePreview];
    [self talkAction];
}

- (void)cameraDidStopPreview:(id<TuyaSmartCameraType>)camera {
    _previewing = NO;
}

- (void)camera:(id<TuyaSmartCameraType>)camera didOccurredErrorAtStep:(TYCameraErrorCode)errStepCode specificErrorCode:(NSInteger)errorCode {
    if (errStepCode == TY_ERROR_CONNECT_FAILED || errStepCode == TY_ERROR_CONNECT_DISCONNECT) {
        _connecting = NO;
        _connected = NO;
        [self stopLoading];
        self.retryButton.hidden = NO;
    }
    else if (errStepCode == TY_ERROR_START_PREVIEW_FAILED) {
        _previewing = NO;
        [self stopLoading];
        self.retryButton.hidden = NO;
    }
    else if (errStepCode == TY_ERROR_START_TALK_FAILED) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"ipc_errmsg_mic_failed", @"IPCLocalizable", @"")];
    }
}

#pragma mark - Private

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
