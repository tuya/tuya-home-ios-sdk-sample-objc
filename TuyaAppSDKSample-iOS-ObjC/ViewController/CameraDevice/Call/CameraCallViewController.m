//
//  CameraCallViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraCallViewController.h"
#import "CameraPermissionUtil.h"
#import <ThingSmartCameraM/ThingSmartCameraM.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraVideoView.h"
#import "CameraViewConstants.h"
#import "UIView+CameraAdditions.h"
#import "UIButton+Extensions.h"

#import "CameraLoadingButton.h"

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import <ThingSmartMediaUIKit/ThingSmartMediaVideoView.h>

#import <YYModel/YYModel.h>

#import <Masonry/Masonry.h>

#import <ThingSmartCallChannelKit/ThingSmartCallChannelKit.h>
#import "CameraDeviceManager.h"

#import "CameraDemoDeviceFetcher.h"

@interface CameraCallViewController ()<ThingSmartCameraDelegate>

@property (nonatomic, strong) id <ThingSmartCallProtocol> call;

@property (nonatomic, strong) UIView *videoContainer;

@property (nonatomic, strong) CameraLoadingButton *hangupButton;

@property (nonatomic, strong) CameraLoadingButton *acceptButton;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong, readonly) UIView <ThingSmartVideoViewType> *localVideoView;

@property (nonatomic, assign) BOOL heavyTasksExecuted;
@property (nonatomic, assign) BOOL hasCallResponded;

@property (nonatomic, assign) SystemSoundID warningSound;
@property (nonatomic, weak) NSTimer *ringSoundTimer;

@end

@implementation CameraCallViewController

@synthesize actionExecuter,callKit;

#pragma mark - ThingSmartCallInterface


- (instancetype)initWithCall:(id<ThingSmartCallProtocol>)call {
    self = [self initWithDeviceId:call.targetId];
    if (self) {
        _call = call;
    }
    return self;
}


- (void)setupCompleted:(void (^)(NSError *error))completed {
    NSString *devId = self.call.targetId;
    __weak typeof(self) weak_self = self;
    if (NO == self.call.outgoing) {
        [CameraDemoDeviceFetcher fetchDeviceWithDevId:devId completion:^(ThingSmartDeviceModel * _Nullable deviceModel, NSError * _Nullable error) {
            CameraDevice *cameraDevice = [CameraDeviceManager.sharedManager getCameraDeviceWithDevId:devId];
            if (deviceModel == nil || cameraDevice == nil) {
                !completed ?: completed([NSError nonexistentDeviceError]);
            } else {
                !completed ?: completed(nil);
                [weak_self callConfigInit];
            }
        }];
    } else {
        !completed ?: completed(nil);
        [self callConfigInit];
    }
}


- (void)callPeerDidRespond {
    _hasCallResponded = YES;
    
    [self remakeOperationButtonsLayout];
    
    [self executeHeavyTasksIfNeeded];
}

/// 通知界面通话结束
/// - Parameter error: 错误
- (void)callEndWithError:(nullable NSError *)error {
    //接听了，断流，断视频，断声音
    if (self.cameraDevice) {
        [self cameraDeviceMuted:YES];
        
        [self turnLocalCameraOn:NO];

        [self stopAudioTalk];
        [self stopVideoTalk];

        
        [self stopPreview];
    }

    if (error) {
        NSString *errorTips = error.localizedDescription;
        if (!errorTips) {
            errorTips = NSLocalizedStringFromTable(@"call_call_finish", @"IPCLocalizable", @"");
        }
        [self showTip:errorTips];
    }
}

- (void)executeHeavyTasksCompleted:(void (^)(NSError * error))completed {
    _heavyTasksExecuted = YES;
    [self executeHeavyTasksIfNeeded];
}


- (void)dealloc {
    NSLog(@"%s", __func__);
    [self stopSoundRinging];
    [self stopPreview];
    [self callConfigDeinit];
}

- (instancetype)initWithDeviceId:(NSString *)devId {
    if (self = [super initWithDeviceId:devId]) {
        CGFloat localVideoViewWidth = 100;
        CGFloat localVideoViewHeight = localVideoViewWidth / 9 * 16;
        _localVideoView = [[ThingSmartMediaVideoView alloc] initWithFrame:CGRectMake(0, 0, localVideoViewWidth, localVideoViewHeight)];
        NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"demo_ring" ofType:@"caf"];
        [self confirgurateSoundFile:soundFilePath];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.cameraDevice.deviceModel.name;
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    CGFloat localVideoViewWidth = 100;
    CGFloat localVideoViewHeight = localVideoViewWidth / 9 * 16;
    [self.view addSubview:self.localVideoView];
    [self.localVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.size.mas_equalTo(CGSizeMake(localVideoViewWidth, localVideoViewHeight));
    }];
    
    
    CGFloat videoWidth = self.view.width;
    CGFloat videoHeight = videoWidth / 16 * 9;
    [self.view addSubview:self.videoContainer];
    [self.videoContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.localVideoView.mas_bottom).offset(40);
        make.leading.trailing.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(videoWidth, videoHeight));
    }];
    
    [self.videoContainer addSubview:self.videoView];
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.videoContainer);
    }];
    
    [self.view addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.videoContainer.mas_centerX);
        make.centerY.equalTo(self.videoContainer.mas_centerY).offset(-20);
    }];
    
    [self.view addSubview:self.hangupButton];
    [self.view addSubview:self.acceptButton];

    [self remakeOperationButtonsLayout];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (NO == self.call.outgoing) {
        [self startSoundRinging];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopSoundRinging];
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    if (tp_topMostViewController() == self) {
        [self hangupActionClicked:nil];
        [super applicationDidEnterBackgroundNotification:notification];
    }
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    if (tp_topMostViewController() == self) {
        [super applicationWillEnterForegroundNotification:notification];
    }
}

#pragma mark - Action

- (void)hangupActionClicked:(CameraLoadingButton *)sender {
    [self stopSoundRinging];
    [sender startLoadingWithEnabled:NO];
    if (self.call.outgoing) {
        if (NO == self.call.answered) {
            [self.actionExecuter interface:self onCancel:self.call];
        } else {
            [self.actionExecuter interface:self onHangUp:self.call];
        }
    } else {
        if (NO == self.call.accepted) {
            [self.actionExecuter interface:self onReject:self.call];
        } else {
            [self.actionExecuter interface:self onHangUp:self.call];
        }
    }
    [sender stopLoadingWithEnabled:YES];
}

- (void)acceptActionClicked:(CameraLoadingButton *)sender {
    [self stopSoundRinging];
    [sender startLoadingWithEnabled:NO];
    [self.actionExecuter interface:self onAccept:self.call];
    [sender stopLoadingWithEnabled:YES];
    [self remakeOperationButtonsLayout];
}

- (void)checkCameraPermision:(void(^)(BOOL result))complete {
    if ([CameraPermissionUtil cameraNotDetermined]) {
        [CameraPermissionUtil requestAccessForCamera:complete];
    }else if ([CameraPermissionUtil cameraDenied]) {
        !complete?:complete(NO);
    }else {
        !complete?:complete(YES);
    }
}

- (void)checkMicrophonePermision:(void(^)(BOOL result))complete  {
    if ([CameraPermissionUtil microNotDetermined]) {
        [CameraPermissionUtil requestAccessForMicro:complete];
    }else if ([CameraPermissionUtil microDenied]) {
        !complete?:complete(NO);
    }else {
        !complete?:complete(YES);
    }
}

#pragma mark - Operation


- (void)stopPreview {
    [self.cameraDevice stopPreview];
}

- (BOOL)executeHeavyTasksIfNeeded {
    if (NO == [self connected]) {
        return NO;
    }
    if (NO == self.heavyTasksExecuted) {
        return NO;
    }
    if (NO == self.hasCallResponded) {
        return NO;
    }

    [self cameraDeviceMuted:NO];
    
    [self executeVideoTalkIfNeeded];

    [self executeAudioTalkIfNeeded];
    return YES;
}


- (void)cameraDeviceMuted:(BOOL)muted {
    [self.cameraDevice enableMute:NO forPlayMode:ThingSmartCameraPlayModePreview];
}

- (void)executeConnectIfNeeded {
    if (self.cameraDevice.cameraModel.connectState == CameraDeviceConnected) {
        [self connectCompleted];
    }else if (self.cameraDevice.cameraModel.connectState == CameraDeviceConnecting) {

    }else{
        [self.cameraDevice connectWithPlayMode:ThingSmartCameraPlayModePreview];
    }
}

- (BOOL)executePreviewIfNeeded {
    if (self.call.end) {
        NSLog(@"[TwoWayCall] %s call had stopped",__func__);
        return NO;
    }
    
    if (![self connectExecuted]) {
        NSLog(@"[TwoWayCall] %s P2P connect is required",__func__);
        return NO;
    }
    if (self.previewed) {
        [self previewCompleted];
    }
    [self.cameraDevice startPreview];
    
    return YES;
}

- (void)connectCompleted {
    if ([self.actionExecuter respondsToSelector:@selector(interface:onConnected:)]) {
        [self.actionExecuter interface:self onConnected:self.call];
    }
    [self turnLocalCameraOn:YES];

    [self executePreviewIfNeeded];
}

- (void)previewCompleted {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshOpreationButtonsEnabled];
    });
}

- (void)executeVideoTalkIfNeeded {
    if (self.call.end) {
        NSLog(@"[TwoWayCall] %s call had stopped",__func__);
        return;
    }
    
    if (!self.hasCallResponded) {
        NSLog(@"[TwoWayCall] %s call has not accepted",__func__);
        return;
    }
    
    if (![self connected]) {
        NSLog(@"[TwoWayCall] %s P2P connect is required",__func__);
        return;
    }
    
    
    if ([self videoTalkExecuted]) {
        NSLog(@"[TwoWayCall] %s has started video talk",__func__);
        return;
    }

    [self.cameraDevice startVideoTalk];
}

- (void)stopVideoTalk {
    [self.cameraDevice stopVideoTalk];
}

- (void)executeAudioTalkIfNeeded {
    if (self.call.end) {
        NSLog(@"[TwoWayCall] %s call had stopped",__func__);
        return;
    }
    
    if (!self.hasCallResponded) {
        NSLog(@"[TwoWayCall] %s call has not accepted",__func__);
        return;
    }
    
    if (![self connected]) {
        NSLog(@"[TwoWayCall] %s P2P connect is required",__func__);
        return;
    }

    
    if ([self audioTalkExecuted]) {
        NSLog(@"[TwoWayCall] %s has started audio talk",__func__);
        return;
    }
    __weak typeof(self) weak_self = self;
    [self checkMicrophonePermision:^(BOOL result) {
        if (result) {
            [weak_self.cameraDevice startTalk];
        } else {
            [weak_self showErrorTip:NSLocalizedStringFromTable(@"Micro permission denied", @"IPCLocalizable", @"")];
        }
    }];
}

- (void)stopAudioTalk {
    [self.cameraDevice stopTalk];
}

- (void)turnLocalCameraOn:(BOOL)isOn {
    __weak typeof(self) weakSelf = self;
    [self checkCameraPermision:^(BOOL result) {
        if (result) {
            if (isOn) {
                [weakSelf executeVideoTalkIfNeeded];
                NSLog(@"[test]-%s",__func__);
                [weakSelf.cameraDevice startLocalVideoCapture];
            } else {
                [weakSelf.cameraDevice stopLocalVideoCapture];
            }
        } else {
            [weakSelf showErrorTip:NSLocalizedStringFromTable(@"Camera permission denied", @"IPCLocalizable", @"")];
        }
    }];
}

- (void)callConfigInit {
    [self.cameraDevice bindLocalVideoView:self.localVideoView];
    [self.cameraDevice enterCallState];
    [self executeConnectIfNeeded];
}

- (void)callConfigDeinit {
    [self.cameraDevice unbindLocalVideoView:self.localVideoView];
    [self.cameraDevice leaveCallState];
    [self.cameraDevice removeDelegate:self];
}

#pragma mark - Loading && Alert

- (void)showLoadingWithTitle:(NSString *)title {
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
}

- (void)stopLoading {
    [self.indicatorView stopAnimating];
    self.indicatorView.hidden = YES;
}

#pragma mark - ThingSmartCameraDelegate

- (void)cameraDidConnected:(id<ThingSmartCameraType>)camera {
    [self connectCompleted];
}

- (void)cameraDisconnected:(id<ThingSmartCameraType>)camera specificErrorCode:(NSInteger)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshOpreationButtonsEnabled];
        [self hangupActionClicked:nil];
    });
}

- (void)cameraDidBeginPreview:(id<ThingSmartCameraType>)camera {
    [self.cameraDevice getHD];
    [self stopLoading];
    [self previewCompleted];
}

- (void)cameraDidStopPreview:(id<ThingSmartCameraType>)camera {
    
}

- (void)cameraDidBeginTalk:(id<ThingSmartCameraType>)camera {
    
}

- (void)cameraDidStopTalk:(id<ThingSmartCameraType>)camera {
    
}

- (void)cameraSnapShootSuccess:(id<ThingSmartCameraType>)camera {
    [self showSuccessTip:NSLocalizedStringFromTable(@"ipc_multi_view_photo_saved", @"IPCLocalizable", @"")];
}


- (void)camera:(id<ThingSmartCameraType>)camera resolutionDidChangeWidth:(NSInteger)width height:(NSInteger)height {
    [self.cameraDevice getDefinition];
}

- (void)camera:(id<ThingSmartCameraType>)camera didOccurredErrorAtStep:(ThingCameraErrorCode)errStepCode specificErrorCode:(NSInteger)errorCode {
    if (errStepCode == Thing_ERROR_CONNECT_FAILED || errStepCode == Thing_ERROR_CONNECT_DISCONNECT) {
        [self stopLoading];
    }
    else if (errStepCode == Thing_ERROR_START_PREVIEW_FAILED) {
        [self stopLoading];
    } else if (errStepCode == Thing_ERROR_START_TALK_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"ipc_errmsg_mic_failed", @"IPCLocalizable", @"")];
    } else if (errStepCode == Thing_ERROR_SNAPSHOOT_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"")];
    } else if (errStepCode == Thing_ERROR_RECORD_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"record failed", @"IPCLocalizable", @"")];
    }
}

#pragma mark - Accessor

- (UIView *)videoContainer {
    if (!_videoContainer) {
        _videoContainer = [[UIView alloc] initWithFrame:CGRectZero];
        _videoContainer.backgroundColor = [UIColor blackColor];
    }
    return _videoContainer;
}

- (CameraLoadingButton *)hangupButton {
    if (!_hangupButton) {
        _hangupButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _hangupButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_hangupButton addTarget:self action:@selector(hangupActionClicked:) forControlEvents:UIControlEventTouchUpInside];
        _hangupButton.backgroundColor = UIColor.redColor;
        _hangupButton.layer.cornerRadius = 35;
        _hangupButton.layer.masksToBounds = YES;
    }
    return _hangupButton;
}

- (CameraLoadingButton *)acceptButton {
    if (!_acceptButton) {
        _acceptButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        [_acceptButton setTitle:NSLocalizedStringFromTable(@"Answer", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        _acceptButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_acceptButton addTarget:self action:@selector(acceptActionClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_acceptButton demo_setBackgroundColor:UIColor.greenColor forState:UIControlStateNormal];
        [_acceptButton demo_setBackgroundColor:UIColor.grayColor forState:UIControlStateDisabled];

        _acceptButton.enabled = NO;
        _acceptButton.layer.cornerRadius = 35;
        _acceptButton.layer.masksToBounds = YES;
    }
    return _acceptButton;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.hidden = YES;
    }
    return _indicatorView;
}

- (void)refreshOpreationButtonsEnabled {
    BOOL enabled = [self previewed];
    self.acceptButton.enabled = enabled;
}

- (void)remakeOperationButtonsLayout {
    CGSize operationButtonSize = CGSizeMake(70, 70);
    if (self.call.outgoing) {
        //call out
        self.acceptButton.hidden = YES;
        if (NO == self.call.answered) {
            [self.hangupButton setTitle:NSLocalizedStringFromTable(@"Cancel", @"IPCLocalizable", @"") forState:UIControlStateNormal];
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.videoContainer.mas_bottom).offset(70);
                make.centerX.equalTo(self.view.mas_centerX);
                make.size.mas_equalTo(operationButtonSize);
            }];
        } else {
            [self.hangupButton setTitle:NSLocalizedStringFromTable(@"Hangup", @"IPCLocalizable", @"") forState:UIControlStateNormal];
            [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.videoContainer.mas_bottom).offset(70);
                make.centerX.equalTo(self.view.mas_centerX);
                make.size.mas_equalTo(operationButtonSize);
            }];
        }
    } else {
        if (NO == self.call.accepted) {
            self.acceptButton.hidden = NO;
            [self.hangupButton setTitle:NSLocalizedStringFromTable(@"Refuse", @"IPCLocalizable", @"") forState:UIControlStateNormal];
            [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.videoContainer.mas_bottom).offset(70);
                make.left.equalTo(self.view).offset(50);
                make.size.mas_equalTo(operationButtonSize);
            }];
            [self.acceptButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.hangupButton);
                make.right.equalTo(self.view).offset(-50);
                make.size.mas_equalTo(operationButtonSize);
            }];
        } else {
            self.acceptButton.hidden = YES;
            [self.hangupButton setTitle:NSLocalizedStringFromTable(@"Hangup", @"IPCLocalizable", @"") forState:UIControlStateNormal];
            [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.videoContainer.mas_bottom).offset(70);
                make.centerX.equalTo(self.view.mas_centerX);
                make.size.mas_equalTo(operationButtonSize);
            }];
        }
    }
}

#pragma mark - sound

- (BOOL)confirgurateSoundFile:(NSString *)filePath {
    if (filePath.length == 0) {
        self.warningSound = 0;
        return NO;
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    self.warningSound = soundID;
    return YES;
}

- (void)startSoundRinging {
    if ([self.actionExecuter respondsToSelector:@selector(interface:onRing:)]) {
        [self.actionExecuter interface:self onRing:self.call];
    }
    if (self.warningSound <= 0) {
        return;
    }
    
    if (self.warningSound > 0) {
        AudioServicesPlayAlertSound(self.warningSound);
    }
    self.ringSoundTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(ringSoundTimerAction:) userInfo:nil repeats:YES];
}

- (void)stopSoundRinging {
    if (self.warningSound > 0) {
        AudioServicesDisposeSystemSoundID(self.warningSound);
        self.warningSound = 0;
    }
    if (self.ringSoundTimer) {
        [self.ringSoundTimer invalidate];
        self.ringSoundTimer = nil;
    }
}

- (void)ringSoundTimerAction:(NSTimer *)timer {
    if (self.warningSound > 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}


#pragma mark - state

- (BOOL)previewExecuted {
    BOOL flag = (self.cameraDevice.cameraModel.previewState == CameraDevicePreviewLoading || self.cameraDevice.cameraModel.previewState == CameraDevicePreviewing);
    return flag;
}

- (BOOL)previewed {
    BOOL flag = self.cameraDevice.cameraModel.previewState == CameraDevicePreviewing;
    return flag;
}

- (BOOL)connectExecuted {
    BOOL flag = (self.cameraDevice.cameraModel.connectState == CameraDeviceConnecting || self.cameraDevice.cameraModel.connectState == CameraDeviceConnected);
    return flag;
}

- (BOOL)connected {
    BOOL flag = self.cameraDevice.cameraModel.connectState == CameraDeviceConnected;
    return flag;
}

- (BOOL)videoTalkExecuted {
    BOOL flag = (self.cameraDevice.cameraModel.videoTalkState == CameraDeviceTaskStateExecuting || self.cameraDevice.cameraModel.videoTalkState == CameraDeviceTaskStateCompleted);
    return flag;
}

- (BOOL)audioTalkExecuted {
    BOOL flag = (self.cameraDevice.cameraModel.talkLoading || self.cameraDevice.cameraModel.talking);
    return flag;
}

@end
