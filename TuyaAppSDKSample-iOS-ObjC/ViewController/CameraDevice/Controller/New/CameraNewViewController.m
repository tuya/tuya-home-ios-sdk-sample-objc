//
//  CameraNewViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraNewViewController.h"
#import "CameraControlNewView.h"
#import "CameraPlaybackNewViewController.h"
#import "CameraSettingViewController.h"
#import "CameraCloudNewViewController.h"
#import "CameraMessageViewController.h"
#import "CameraPermissionUtil.h"
#import <TuyaSmartCameraM/TuyaSmartCameraM.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraVideoView.h"
#import "CameraBottomSwitchView.h"
#import "CameraPTZControlView.h"
#import "CameraCollectionPointListView.h"
#import "CameraCruiseView.h"
#import "CameraViewConstants.h"
#import "UIView+CameraAdditions.h"

#import "CameraDeviceManager.h"
#import "CameraLoadingButton.h"

#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>

#import <TuyaCloudStorageDebugger/TuyaCloudStorageDebugger.h>

#define VideoViewWidth [UIScreen mainScreen].bounds.size.width
#define VideoViewHeight ([UIScreen mainScreen].bounds.size.width / 16 * 9)
#define BottomSwitchViewHeight 44.0

#define kControlTalk        @"talk"
#define kControlRecord      @"record"
#define kControlPhoto       @"photo"
#define kControlPlayback    @"playback"
#define kControlCloud       @"Cloud"
#define kControlMessage     @"message"
#define kControlCloudDebug       @"CloudDebug"

@interface CameraNewViewController ()<CameraBottomSwitchViewDelegate, TuyaSmartCameraDelegate, CameraControlNewViewDelegate, TuyaSmartCameraDPObserver, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *videoContainer;

@property (nonatomic, strong) CameraBottomSwitchView *bottomSwitchView;

@property (nonatomic, strong) UIScrollView *bodyScrollView;

@property (nonatomic, strong) CameraPTZControlView *ptzControlView;

@property (nonatomic, strong) CameraCollectionPointListView *cpView;

@property (nonatomic, strong) CameraCruiseView *cruiseView;

@property (nonatomic, strong) CameraControlNewView *controlView;

@property (nonatomic, strong) CameraLoadingButton *soundButton;

@property (nonatomic, strong) CameraLoadingButton *hdButton;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, assign) BOOL needsReconnect;

@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation CameraNewViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self stopPreview];
    [self.cameraDevice removeDelegate:self];
}

- (instancetype)initWithDeviceId:(NSString *)devId {
    if (self = [super initWithDeviceId:devId]) {
        _needsReconnect = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"tp_top_bar_more"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(settingAction) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    [rightBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    
    self.title = self.cameraDevice.deviceModel.name;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.videoContainer];
    [self.view addSubview:self.indicatorView];
    [self.view addSubview:self.stateLabel];
    [self.view addSubview:self.retryButton];
    [self.view addSubview:self.bottomSwitchView];
    [self.view addSubview:self.bodyScrollView];
    [self.bodyScrollView addSubview:self.controlView];
    [self.bodyScrollView addSubview:self.ptzControlView];
    [self.bodyScrollView addSubview:self.cpView];
    [self.bodyScrollView addSubview:self.cruiseView];
    [self.bodyScrollView layoutIfNeeded];
    
    [self.view addSubview:self.soundButton];
    [self.view addSubview:self.hdButton];
    
    // Tips: Speak、Record、Take Photo、Sound、HD, these buttons can be available after received video data.
    // Playback、Cloud Storage、Message, these buttons can be available after camera is connected.
    [self.retryButton addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchUpInside];
    [self.soundButton addTarget:self action:@selector(soundActionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.hdButton addTarget:self action:@selector(hdActionClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self retryAction];
    if (self.cameraDevice.cameraModel.connectState == CameraDeviceConnected) {
        [self startPreview];
    }
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

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self stopPreview];
    [super applicationDidEnterBackgroundNotification:notification];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    [self retryAction];
    [super applicationWillEnterForegroundNotification:notification];
}

#pragma mark - Action

- (void)settingAction {
    CameraSettingViewController *settingVC = [CameraSettingViewController new];
    settingVC.devId = self.devId;
    settingVC.dpManager = self.cameraDevice.dpManager;
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)retryAction {
    if (!self.cameraDevice.deviceModel.isOnline) {
        self.stateLabel.hidden = NO;
        self.stateLabel.text = NSLocalizedStringFromTable(@"title_device_offline", @"IPCLocalizable", @"");
        return;
    }
    [self connectCamera];
    [self showLoadingWithTitle:NSLocalizedStringFromTable(@"loading", @"IPCLocalizable", @"")];
    self.retryButton.hidden = YES;
}

- (void)soundActionClicked:(CameraLoadingButton *)sender {
    [sender startLoadingWithEnabled:NO];
    
    [self enableMute:!self.cameraDevice.cameraModel.mutedForPreview];
}

- (void)hdActionClicked:(CameraLoadingButton *)sender {
    [sender startLoadingWithEnabled:NO];
    
    TuyaSmartCameraDefinition definition = !self.cameraDevice.cameraModel.isHD ? TuyaSmartCameraDefinitionHigh : TuyaSmartCameraDefinitionStandard;
    [self.cameraDevice setDefinition:definition];
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
    if (self.cameraDevice.cameraModel.isTalking) {
        [self.cameraDevice stopTalk];
        [self.controlView deselectedControl:kControlTalk];
    }else {
        [self.cameraDevice startTalk];
    }
}

- (void)recordAction {
    [self checkPhotoPermision:^(BOOL result) {
        if (result) {
            if (self.cameraDevice.cameraModel.isRecording) {
                [self.cameraDevice stopRecord];
            }else {
                [self.cameraDevice startRecord];
            }
        }
    }];
}

- (void)photoAction {
    [self checkPhotoPermision:^(BOOL result) {
        if (result) {
            [self.cameraDevice snapshoot];
        }
    }];
}

- (void)checkPhotoPermision:(void(^)(BOOL result))complete {
    if ([CameraPermissionUtil isPhotoLibraryNotDetermined]) {
        [CameraPermissionUtil requestPhotoPermission:complete];
    }else if ([CameraPermissionUtil isPhotoLibraryDenied]) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"Photo library permission denied", @"IPCLocalizable", @"")];
        !complete?:complete(NO);
    }else {
        !complete?:complete(YES);
    }
}

#pragma mark - Operation

- (void)connectCamera {
    [self.controlView disableAllControl];
    [self.cameraDevice connectWithPlayMode:TuyaSmartCameraPlayModePreview];
}

- (void)startPreview {
    [self.videoContainer addSubview:self.videoView];
    self.videoView.frame = self.videoContainer.bounds;
    
    [self stopPlayback];
    [self.cameraDevice startPreview];
    [self enableMute:self.cameraDevice.cameraModel.mutedForPreview];
}

- (void)stopPreview {
    [self.cameraDevice stopPreview];
}


- (void)enableMute:(BOOL)isMute {
    [self.cameraDevice enableMute:isMute forPlayMode:TuyaSmartCameraPlayModePreview];
}

- (void)stopPlayback {
    [self.cameraDevice stopPlayback];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = (scrollView.contentOffset.x / scrollView.frame.size.width);
    if (page == self.currentPage) {
        return;
    }
    if (page == 2) {
        [self.cpView refreshView];
    } else if (page == 3) {
        [self.cruiseView refreshView];
    }
    [self.bottomSwitchView selecteItem:page];
    self.currentPage = page;
}

#pragma mark - CameraControlNewViewDelegate

- (void)controlView:(CameraControlNewView *)controlView didSelectedControl:(NSString *)identifier {
    if ([identifier isEqualToString:kControlTalk]) {
        [self talkAction];
        return;
    }
    if ([identifier isEqualToString:kControlPlayback]) {
        CameraPlaybackNewViewController *vc = [[CameraPlaybackNewViewController alloc] initWithDeviceId:self.devId];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if ([identifier isEqualToString:kControlCloud]) {
        CameraCloudNewViewController *vc = [CameraCloudNewViewController new];
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if ([identifier isEqualToString:kControlMessage]) {
        CameraMessageViewController *vc = [CameraMessageViewController new];
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if ([identifier isEqualToString:kControlCloudDebug]) {
        [[TuyaCloudStorageDebugger sharedInstance] startWithDeviceSpaceId:[Home getCurrentHome].homeId navigationController:self.navigationController];
    }
    BOOL needPhotoPermission = [identifier isEqualToString:kControlPhoto] || [identifier isEqualToString:kControlRecord];
    if (needPhotoPermission) {
        if ([CameraPermissionUtil isPhotoLibraryNotDetermined]) {
            [CameraPermissionUtil requestPhotoPermission:^(BOOL result) {
                if (result) {
                    if ([identifier isEqualToString:kControlRecord]) {
                        [self recordAction];
                    } else if ([identifier isEqualToString:kControlPhoto]) {
                        [self photoAction];
                    }
                }
            }];
        }else if ([CameraPermissionUtil isPhotoLibraryDenied]) {
            [self showAlertWithMessage:NSLocalizedStringFromTable(@"Photo library permission denied", @"IPCLocalizable", @"")];
        }else {
            if ([identifier isEqualToString:kControlRecord]) {
                [self recordAction];
            } else if ([identifier isEqualToString:kControlPhoto]) {
                [self photoAction];
            }
        }
    }
}

#pragma mark - TuyaSmartCameraDelegate

- (void)cameraDidConnected:(id<TuyaSmartCameraType>)camera {
    [self startPreview];
}

- (void)cameraDisconnected:(id<TuyaSmartCameraType>)camera specificErrorCode:(NSInteger)errorCode {
    if ((errorCode == -3 || errorCode == -105) && self.needsReconnect) {
        self.needsReconnect = NO;
        NSLog(@"[reconnect]");
        [self retryAction];
        return;
    }
    [self.hdButton stopLoadingWithEnabled:YES];
    [self.soundButton stopLoadingWithEnabled:YES];
    
    [self.controlView disableAllControl];
    self.retryButton.hidden = NO;
}

- (void)cameraDidBeginPreview:(id<TuyaSmartCameraType>)camera {
    [self.cameraDevice getHD];
    [self.controlView enableAllControl];
    [self stopLoading];
}

- (void)cameraDidStopPreview:(id<TuyaSmartCameraType>)camera {
    
}

- (void)cameraDidBeginTalk:(id<TuyaSmartCameraType>)camera {
    [self.controlView selectedControl:kControlTalk];
}

- (void)cameraDidStopTalk:(id<TuyaSmartCameraType>)camera {
    
}

- (void)cameraSnapShootSuccess:(id<TuyaSmartCameraType>)camera {
    [self showSuccessTip:NSLocalizedStringFromTable(@"ipc_multi_view_photo_saved", @"IPCLocalizable", @"")];
}

- (void)cameraDidStartRecord:(id<TuyaSmartCameraType>)camera {
    [self.controlView selectedControl:kControlRecord];
}

- (void)cameraDidStopRecord:(id<TuyaSmartCameraType>)camera {
    [self.controlView deselectedControl:kControlRecord];
    [self showSuccessTip:NSLocalizedStringFromTable(@"ipc_multi_view_video_saved", @"IPCLocalizable", @"")];
}

- (void)camera:(id<TuyaSmartCameraType>)camera definitionChanged:(TuyaSmartCameraDefinition)definition{
    [self.hdButton stopLoadingWithEnabled:YES];
    self.hdButton.selected = self.cameraDevice.cameraModel.isHD;
}

- (void)camera:(id<TuyaSmartCameraType>)camera didReceiveMuteState:(BOOL)isMute playMode:(TuyaSmartCameraPlayMode)playMode {
    [self.soundButton stopLoadingWithEnabled:YES];
    self.soundButton.selected = !isMute;
}

- (void)camera:(id<TuyaSmartCameraType>)camera resolutionDidChangeWidth:(NSInteger)width height:(NSInteger)height {
    [self.cameraDevice getDefinition];
}

- (void)camera:(id<TuyaSmartCameraType>)camera didOccurredErrorAtStep:(TYCameraErrorCode)errStepCode specificErrorCode:(NSInteger)errorCode {
    if (errStepCode == TY_ERROR_CONNECT_FAILED || errStepCode == TY_ERROR_CONNECT_DISCONNECT) {
        [self stopLoading];
        self.retryButton.hidden = NO;
        [self.controlView disableAllControl];
    }
    else if (errStepCode == TY_ERROR_START_PREVIEW_FAILED) {
        [self stopLoading];
        self.retryButton.hidden = NO;
    } else if (errStepCode == TY_ERROR_START_TALK_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"ipc_errmsg_mic_failed", @"IPCLocalizable", @"")];
    } else if (errStepCode == TY_ERROR_SNAPSHOOT_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"")];
    } else if (errStepCode == TY_ERROR_RECORD_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"record failed", @"IPCLocalizable", @"")];
    } else if (errStepCode == TY_ERROR_ENABLE_HD_FAILED) {
        [self.hdButton stopLoadingWithEnabled:YES];
    } else if (errStepCode == TY_ERROR_ENABLE_MUTE_FAILED) {
        [self.soundButton stopLoadingWithEnabled:YES];
    }
}

#pragma mark - CameraBottomSwitchViewDelegate
- (void)didClickBottomButton:(CameraBottomSwitchView *)switchView buttonType:(CameraBottomButtonType)buttonType {
    NSInteger page = (NSInteger)buttonType;
    self.currentPage = page;
    CGPoint offset = CGPointMake([UIScreen mainScreen].bounds.size.width * page, 0);
    [self.bodyScrollView setContentOffset:offset animated:YES];
    if (page==2) {
        [self.cpView refreshView];
    } else if (page == 3) {
        [self.cruiseView refreshView];
    }
}

#pragma mark - Private

#pragma mark - Accessor

- (UIView *)videoContainer {
    if (!_videoContainer) {
        _videoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, VideoViewWidth, VideoViewHeight)];
        _videoContainer.backgroundColor = [UIColor blackColor];
    }
    return _videoContainer;
}

- (NSArray *)controlDatas {
    NSMutableArray *featureDatas = [NSMutableArray array];
    NSArray *basicFeatureDatas = @[@{
        @"image": @"ty_camera_mic_icon",
        @"title": NSLocalizedStringFromTable(@"ipc_panel_button_speak", @"IPCLocalizable", @""),
        @"identifier": kControlTalk
        },
    @{
        @"image": @"ty_camera_rec_icon",
        @"title": NSLocalizedStringFromTable(@"ipc_panel_button_record", @"IPCLocalizable", @""),
        @"identifier": kControlRecord
        },
    @{
        @"image": @"ty_camera_photo_icon",
        @"title": NSLocalizedStringFromTable(@"ipc_panel_button_screenshot", @"IPCLocalizable", @""),
        @"identifier": kControlPhoto
        },
    @{
        @"image": @"ty_camera_playback_icon",
        @"title": NSLocalizedStringFromTable(@"pps_flashback", @"IPCLocalizable", @""),
        @"identifier": kControlPlayback
        }
    ];
    [featureDatas addObjectsFromArray:basicFeatureDatas];
    [featureDatas addObject:@{
        @"image": @"ty_camera_cloud_icon",
        @"title": NSLocalizedStringFromTable(@"ipc_panel_button_cstorage", @"IPCLocalizable", @""),
        @"identifier": kControlCloud
    }];
    [featureDatas addObject:@{
        @"image": @"ty_camera_message",
        @"title": NSLocalizedStringFromTable(@"ipc_panel_button_message", @"IPCLocalizable", @""),
        @"identifier": kControlMessage
    }];
    return featureDatas.copy;
}

- (CameraBottomSwitchView *)bottomSwitchView {
    if (!_bottomSwitchView) {
        CGFloat width = UIScreen.mainScreen.bounds.size.width;
        CGFloat height = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        _bottomSwitchView = [[CameraBottomSwitchView alloc] initWithFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height-height, width, height)];
        _bottomSwitchView.delegate = self;
    }
    return _bottomSwitchView;
}

- (UIScrollView *)bodyScrollView {
    if (!_bodyScrollView) {
        CGFloat top = VideoViewHeight + APP_TOP_BAR_HEIGHT;
        CGFloat width = UIScreen.mainScreen.bounds.size.width;
        CGFloat bottomSwitchViewHeight = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        CGFloat height = UIScreen.mainScreen.bounds.size.height - top - bottomSwitchViewHeight;
        _bodyScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, top, width, height)];
        _bodyScrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width*4, height);
        _bodyScrollView.pagingEnabled = YES;
        _bodyScrollView.delegate = self;
        _bodyScrollView.showsVerticalScrollIndicator = NO;
        _bodyScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _bodyScrollView;
}

- (CameraControlNewView *)controlView {
    if (!_controlView) {
        CGFloat top = VideoViewHeight + APP_TOP_BAR_HEIGHT;
        CGFloat bottomSwitchViewHeight = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        CGFloat height = UIScreen.mainScreen.bounds.size.height - top - bottomSwitchViewHeight;
        _controlView = [[CameraControlNewView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, height)];
        _controlView.sourceData = [self controlDatas];
        _controlView.delegate = self;
    }
    return _controlView;
}

- (CameraPTZControlView *)ptzControlView {
    if (!_ptzControlView) {
        CGFloat top = VideoViewHeight + APP_TOP_BAR_HEIGHT;
        CGFloat bottomSwitchViewHeight = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        CGFloat height = UIScreen.mainScreen.bounds.size.height - top - bottomSwitchViewHeight;
        _ptzControlView = [[CameraPTZControlView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width, 0, UIScreen.mainScreen.bounds.size.width, height)];
        _ptzControlView.deviceId = self.devId;
        _ptzControlView.fatherVc = self;
    }
    return _ptzControlView;
}

- (CameraCollectionPointListView *)cpView {
    if (!_cpView) {
        CGFloat top = VideoViewHeight + APP_TOP_BAR_HEIGHT;
        CGFloat bottomSwitchViewHeight = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        CGFloat height = UIScreen.mainScreen.bounds.size.height - top - bottomSwitchViewHeight;
        _cpView = [[CameraCollectionPointListView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width * 2, 0, UIScreen.mainScreen.bounds.size.width, height)];
        _cpView.deviceId = self.devId;
    }
    return _cpView;
}

- (CameraCruiseView *)cruiseView {
    if (!_cruiseView) {
        CGFloat top = VideoViewHeight + APP_TOP_BAR_HEIGHT;
        CGFloat bottomSwitchViewHeight = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        CGFloat height = UIScreen.mainScreen.bounds.size.height - top - bottomSwitchViewHeight;
        _cruiseView = [[CameraCruiseView alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width * 3, 0, UIScreen.mainScreen.bounds.size.width, height)];
        _cruiseView.deviceId = self.devId;
    }
    return _cruiseView;
}

- (CameraLoadingButton *)soundButton {
    if (!_soundButton) {
        _soundButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _soundButton.frame = CGRectMake(8, APP_TOP_BAR_HEIGHT + VideoViewHeight - 50, 44, 44);
        [_soundButton setImage:[UIImage imageNamed:@"ty_camera_soundOff_icon"] forState:UIControlStateNormal];
        [_soundButton setImage:[UIImage imageNamed:@"ty_camera_soundOn_icon"] forState:UIControlStateSelected];
    }
    return _soundButton;
}

- (UIButton *)hdButton {
    if (!_hdButton) {
        _hdButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _hdButton.frame = CGRectMake(60, APP_TOP_BAR_HEIGHT + VideoViewHeight - 50, 44, 44);
        [_hdButton setImage:[UIImage imageNamed:@"ty_camera_control_sd_normal"] forState:UIControlStateNormal];
        [_hdButton setImage:[UIImage imageNamed:@"ty_camera_control_hd_normal"] forState:UIControlStateSelected];
    }
    return _hdButton;
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

@end
