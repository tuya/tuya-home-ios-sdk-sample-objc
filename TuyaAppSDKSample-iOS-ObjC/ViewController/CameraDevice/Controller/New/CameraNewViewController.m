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
#import <ThingSmartCameraM/ThingSmartCameraM.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraVideoView.h"
#import "CameraBottomSwitchView.h"
#import "CameraPTZControlView.h"
#import "CameraCollectionPointListView.h"
#import "CameraCruiseView.h"
#import "CameraViewConstants.h"
#import "UIView+CameraAdditions.h"
#import "UIButton+Extensions.h"
#import "UIViewController+InterfaceOrientations.h"

#import "CameraDeviceManager.h"
#import "CameraLoadingButton.h"

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>

#import <YYModel/YYModel.h>

#import "CameraControlButtonItem.h"

#import "DemoSplitVideoViewManager.h"

#import "DemoCallManager.h"
#if __has_include(<ThingCloudStorageDebugger/ThingCloudStorageDebugger.h>)
#import <ThingCloudStorageDebugger/ThingCloudStorageDebugger.h>
#define kControlCloudDebugEnable 1
#else
#define kControlCloudDebugEnable 0
#endif

#define VideoViewWidth (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))
#define VideoViewHeight (VideoViewWidth / 16 * 9)

#define FullScreenVideoViewWidth (MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height))
#define FullScreenVideoViewHeight ((FullScreenVideoViewWidth) / 16 * 9)

#define BottomSwitchViewHeight 44.0

#define kControlTalk        @"talk"
#define kControlVideoTalk   @"videoTalk"
#define kControlRecord      @"record"
#define kControlPhoto       @"photo"
#define kControlPlayback    @"playback"
#define kControlCloud       @"Cloud"
#define kControlMessage     @"message"
#define kControlCloudDebug       @"CloudDebug"

@interface CameraNewViewController ()<CameraBottomSwitchViewDelegate, ThingSmartCameraDelegate, CameraControlNewViewDelegate, ThingSmartCameraDPObserver, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *videoContainer;

@property (nonatomic, strong) CameraBottomSwitchView *bottomSwitchView;

@property (nonatomic, strong) UIScrollView *bodyScrollView;

@property (nonatomic, strong) CameraPTZControlView *ptzControlView;

@property (nonatomic, strong) CameraCollectionPointListView *cpView;

@property (nonatomic, strong) CameraCruiseView *cruiseView;

@property (nonatomic, strong) CameraControlNewView *controlView;

@property (nonatomic, strong) CameraLoadingButton *soundButton;

@property (nonatomic, strong) CameraLoadingButton *hdButton;

@property (nonatomic, strong) CameraLoadingButton *toolbarFoldingButton;
@property (nonatomic, strong) CameraLoadingButton *fullScreenButton;
@property (nonatomic, strong) CameraLoadingButton *backPageButton;

@property (nonatomic, strong) UIView *operationToolbar;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIButton *retryButton;

@property (nonatomic, assign) BOOL needsReconnect;

@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) DemoSplitVideoViewManager *splitVideoViewManager;
@property (nonatomic, strong) CameraSplitVideoContainerView *splitVideoView;

@property (nonatomic, assign, getter=isFullScreen) BOOL fullScreen;

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
        [self setCameraDeviceOutLineFeatures];
        _splitVideoViewManager = [[DemoSplitVideoViewManager alloc] initWithCameraDevice:self.cameraDevice];
        _splitVideoView = _splitVideoViewManager.splitVideoView;
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
    if (self.splitVideoView) {
        [self.videoContainer addSubview:self.splitVideoView];
        self.splitVideoView.frame = self.videoContainer.bounds;
    } else {
        [self.videoContainer addSubview:self.videoView];
        self.videoView.frame = self.videoContainer.bounds;
    }
    [self.view addSubview:self.operationToolbar];
    [self.operationToolbar addSubview:self.soundButton];
    [self.operationToolbar addSubview:self.hdButton];
    [self.operationToolbar addSubview:self.toolbarFoldingButton];
    [self.operationToolbar addSubview:self.fullScreenButton];

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
    
    [self.view addSubview:self.backPageButton];
    
    // Tips: Speak、Record、Take Photo、Sound、HD, these buttons can be available after received video data.
    // Playback、Cloud Storage、Message, these buttons can be available after camera is connected.
    [self.retryButton addTarget:self action:@selector(retryAction) forControlEvents:UIControlEventTouchUpInside];
    [self.soundButton addTarget:self action:@selector(soundActionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.hdButton addTarget:self action:@selector(hdActionClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarFoldingButton addTarget:self action:@selector(toolbarFoldingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.fullScreenButton addTarget:self action:@selector(fullScreenButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.backPageButton addTarget:self action:@selector(backPageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    [self refreshControlViewDatas];
    
    [self reloadAllSubviewsLayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.fullScreen = NO;
    [self demo_rotateWindowIfNeed];
    self.navigationController.navigationBar.hidden = self.fullScreen;
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self retryAction];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopPreview];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.isFullScreen) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    if (tp_topMostViewController() == self) {
        [self stopPreview];
        [super applicationDidEnterBackgroundNotification:notification];
    }
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    if (tp_topMostViewController() == self) {
        [self retryAction];
        [super applicationWillEnterForegroundNotification:notification];
    }
}

- (void)reloadAllSubviewsLayout {
    self.toolbarFoldingButton.hidden = self.fullScreen;
    self.bodyScrollView.hidden = self.fullScreen;
    self.navigationController.navigationBar.hidden = self.fullScreen;
    self.operationToolbar.hidden = self.fullScreen;

    self.backPageButton.hidden = !self.fullScreen;
    if (self.fullScreen) {
        self.backPageButton.frame = CGRectMake(IsIphoneX ? 24 : 12, 10, 44, 44);
        CGFloat videoContainerHeight = FullScreenVideoViewHeight;
        self.videoContainer.frame = CGRectMake(0, 0, FullScreenVideoViewWidth, videoContainerHeight);
        if (self.splitVideoView) {
            self.splitVideoView.frame = self.videoContainer.bounds;
        } else {
            self.videoView.frame = self.videoContainer.bounds;
        }
        CGFloat videoContainerBottom = self.videoContainer.bottom;
        CGFloat videoContainerWidth = self.videoContainer.width;

        CGPoint indicatorViewCenter = self.videoContainer.center;
        indicatorViewCenter.y -= 20;
        self.indicatorView.center = indicatorViewCenter;
                
        self.stateLabel.frame = CGRectMake(0, self.indicatorView.bottom + 8, videoContainerWidth, 20);

        self.retryButton.frame = CGRectMake(0, 0, videoContainerWidth, 40);
        self.retryButton.center = self.videoContainer.center;
               
        self.operationToolbar.frame = CGRectMake(0, videoContainerBottom - 50, videoContainerWidth, 50);
    } else {
        CGFloat videoContainerHeight = VideoViewHeight;
        if (YES == self.toolbarFoldingButton.selected) {
            videoContainerHeight *= 2;
        }
        self.videoContainer.frame = CGRectMake(0, (IsIphoneX ? 88 : 64), VideoViewWidth, videoContainerHeight);
        if (self.splitVideoView) {
            self.splitVideoView.frame = self.videoContainer.bounds;
        } else {
            self.videoView.frame = self.videoContainer.bounds;
        }
        CGFloat videoContainerBottom = self.videoContainer.bottom;
        CGFloat videoContainerWidth = self.videoContainer.width;

        CGPoint indicatorViewCenter = self.videoContainer.center;
        indicatorViewCenter.y -= 20;
        self.indicatorView.center = indicatorViewCenter;
                
        self.stateLabel.frame = CGRectMake(0, self.indicatorView.bottom + 8, videoContainerWidth, 20);

        self.retryButton.frame = CGRectMake(0, 0, videoContainerWidth, 40);
        self.retryButton.center = self.videoContainer.center;
               
        
        self.operationToolbar.frame = CGRectMake(0, videoContainerBottom - 50, videoContainerWidth, 50);

        CGFloat bottomSwitchViewHeight = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        CGFloat bodyScrollViewHeight = FullScreenVideoViewWidth - videoContainerBottom - bottomSwitchViewHeight;
        self.bodyScrollView.frame = CGRectMake(0, videoContainerBottom, videoContainerWidth, bodyScrollViewHeight);
        self.bodyScrollView.contentSize = CGSizeMake(videoContainerWidth * 4, bodyScrollViewHeight);
        self.controlView.frame = self.bodyScrollView.bounds;
        self.ptzControlView.frame = CGRectMake(videoContainerWidth, 0, videoContainerWidth, bodyScrollViewHeight);
        self.cpView.frame = CGRectMake(videoContainerWidth * 2, 0, videoContainerWidth, bodyScrollViewHeight);
        self.cruiseView.frame = CGRectMake(videoContainerWidth * 3, 0, videoContainerWidth, bodyScrollViewHeight);
    }
    if (self.splitVideoView) {
        [self.splitVideoView setLandscape:self.fullScreen];
    }
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
        [self enableAllOperationButtons:NO];
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

- (void)soundActionClicked:(CameraLoadingButton *)sender {
    [sender startLoadingWithEnabled:NO];
    
    [self enableMute:!self.cameraDevice.cameraModel.mutedForPreview];
}

- (void)hdActionClicked:(CameraLoadingButton *)sender {
    [sender startLoadingWithEnabled:NO];
    
    ThingSmartCameraDefinition definition = !self.cameraDevice.cameraModel.isHD ? ThingSmartCameraDefinitionHigh : ThingSmartCameraDefinitionStandard;
    [self.cameraDevice setDefinition:definition];
}

- (void)toolbarFoldingButtonClicked:(CameraLoadingButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.splitVideoView) {
        [self.splitVideoView setToolbarFolding:sender.selected];
    }
    self.controlView.isSmallSize = sender.selected;
    [UIView animateWithDuration:0.25 animations:^{
        [self reloadAllSubviewsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (void)fullScreenButtonClicked:(CameraLoadingButton *)sender {
    self.fullScreen = !self.isFullScreen;
    [self demo_rotateWindowIfNeed];
    
    [self reloadAllSubviewsLayout];
}

- (void)backPageButtonClicked:(CameraLoadingButton *)sender {
    [self fullScreenButtonClicked:nil];
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
    [self enableAllOperationButtons:NO];
    [self.cameraDevice connectWithPlayMode:ThingSmartCameraPlayModePreview];
}

- (void)startPreview {
    [self stopPlayback];
    [self.cameraDevice startPreview];
    [self enableMute:self.cameraDevice.cameraModel.mutedForPreview];
}

- (void)stopPreview {
    [self.cameraDevice stopPreview];
}


- (void)enableMute:(BOOL)isMute {
    [self.cameraDevice enableMute:isMute forPlayMode:ThingSmartCameraPlayModePreview];
}

- (void)stopPlayback {
    [self.cameraDevice stopPlayback];
}

- (void)startVideoCall {
    if ([DemoCallManager.sharedInstance canStartCall]) {
        __weak typeof(self) weak_self = self;
        NSDictionary *extraMap = @{@"bizType" : @"screen_ipc",
                                   @"category" : @"sp_dpsxj",
                                   @"channelType" : @2};
        [DemoCallManager.sharedInstance startCallWithTargetId:self.devId timeout:60 extra:extraMap success:^{
            
        } failure:^(NSError * _Nullable error) {
            if (error.localizedDescription) {
                [weak_self showErrorTip:error.localizedDescription];
            }
        }];
    } else {

    }
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
    if ([identifier isEqualToString:kControlVideoTalk]) {
        [self startVideoCall];
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
#if __has_include(<ThingCloudStorageDebugger/ThingCloudStorageDebugger.h>)
        [[ThingCloudStorageDebugger sharedInstance] startWithDeviceSpaceId:[Home getCurrentHome].homeId navigationController:self.navigationController];
#endif
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
    [self.hdButton stopLoadingWithEnabled:YES];
    [self.soundButton stopLoadingWithEnabled:YES];
    
    [self enableAllOperationButtons:NO];
    self.retryButton.hidden = NO;
}

- (void)cameraDidBeginPreview:(id<ThingSmartCameraType>)camera {
    [self.cameraDevice getHD];
    [self enableAllOperationButtons:YES];
    [self stopLoading];
    if (self.splitVideoView) {
        [self.splitVideoView setShowLocalizer:YES];
    }
}

- (void)cameraDidStopPreview:(id<ThingSmartCameraType>)camera {
    
}

- (void)cameraDidBeginTalk:(id<ThingSmartCameraType>)camera {
    [self.controlView selectedControl:kControlTalk];
}

- (void)cameraDidStopTalk:(id<ThingSmartCameraType>)camera {
    
}

- (void)cameraSnapShootSuccess:(id<ThingSmartCameraType>)camera {
    [self showSuccessTip:NSLocalizedStringFromTable(@"ipc_multi_view_photo_saved", @"IPCLocalizable", @"")];
}

- (void)cameraDidStartRecord:(id<ThingSmartCameraType>)camera {
    [self.controlView selectedControl:kControlRecord];
}

- (void)cameraDidStopRecord:(id<ThingSmartCameraType>)camera {
    [self.controlView deselectedControl:kControlRecord];
    [self showSuccessTip:NSLocalizedStringFromTable(@"ipc_multi_view_video_saved", @"IPCLocalizable", @"")];
}

- (void)camera:(id<ThingSmartCameraType>)camera definitionChanged:(ThingSmartCameraDefinition)definition{
    [self.hdButton stopLoadingWithEnabled:YES];
    self.hdButton.selected = self.cameraDevice.cameraModel.isHD;
}

- (void)camera:(id<ThingSmartCameraType>)camera didReceiveMuteState:(BOOL)isMute playMode:(ThingSmartCameraPlayMode)playMode {
    [self.soundButton stopLoadingWithEnabled:YES];
    self.soundButton.selected = !isMute;
}

- (void)camera:(id<ThingSmartCameraType>)camera resolutionDidChangeWidth:(NSInteger)width height:(NSInteger)height {
    [self.cameraDevice getDefinition];
}

- (void)camera:(id<ThingSmartCameraType>)camera didOccurredErrorAtStep:(ThingCameraErrorCode)errStepCode specificErrorCode:(NSInteger)errorCode {
    if (errStepCode == Thing_ERROR_CONNECT_FAILED || errStepCode == Thing_ERROR_CONNECT_DISCONNECT) {
        [self stopLoading];
        self.retryButton.hidden = NO;
        [self enableAllOperationButtons:NO];
    }
    else if (errStepCode == Thing_ERROR_START_PREVIEW_FAILED) {
        [self stopLoading];
        self.retryButton.hidden = NO;
    } else if (errStepCode == Thing_ERROR_START_TALK_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"ipc_errmsg_mic_failed", @"IPCLocalizable", @"")];
    } else if (errStepCode == Thing_ERROR_SNAPSHOOT_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"")];
    } else if (errStepCode == Thing_ERROR_RECORD_FAILED) {
        [self showErrorTip:NSLocalizedStringFromTable(@"record failed", @"IPCLocalizable", @"")];
    } else if (errStepCode == Thing_ERROR_ENABLE_HD_FAILED) {
        [self.hdButton stopLoadingWithEnabled:YES];
    } else if (errStepCode == Thing_ERROR_ENABLE_MUTE_FAILED) {
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

- (void)setCameraDeviceOutLineFeatures {
    [self.cameraDevice setOutOffBoundsEnable:YES];
    CameraDeviceOutlineProperty *outlineProperty = [[CameraDeviceOutlineProperty alloc] init];
    outlineProperty.type = 1;
    outlineProperty.index = 0;
    outlineProperty.rgb = @(0x4200c8);
    outlineProperty.shape = CameraDeviceOutlineShapeStyleFull;
    outlineProperty.brushWidth = CameraDeviceOutlineWidthWide;

    CameraDeviceOutlineFlashFps *flashFps = [[CameraDeviceOutlineFlashFps alloc] init];
    flashFps.drawKeepFrames = CameraDeviceOutlineFlashFast;
    flashFps.stopKeepFrames = CameraDeviceOutlineFlashFast;
    outlineProperty.flashFps = flashFps;
    [self.cameraDevice setOutOffBoundsFeatures:@[outlineProperty]];
}

- (void)refreshControlViewDatas {
    __weak typeof(self) weak_self = self;
    [DemoCallManager.sharedInstance fetchDeviceCallAbilityByDevId:self.devId completion:^(BOOL result, NSError * _Nullable error) {
        if (result == YES) {
            NSMutableArray<NSDictionary *> *featureDatas = [NSMutableArray arrayWithArray:[weak_self controlDatas]];
            for (NSArray *subFeatureDatas in featureDatas) {
                for (CameraControlButtonItem *buttonItem in subFeatureDatas) {
                    if ([buttonItem.identifier isEqualToString:kControlVideoTalk]) {
                        buttonItem.hidden = NO;
                        break;
                    }
                }
            }
            weak_self.controlView.buttonItems = featureDatas.copy;
        }
    }];
}

- (void)enableAllOperationButtons:(BOOL)enabled {
    if (enabled) {
        [self.controlView enableAllControl];
    } else {
        [self.controlView disableAllControl];
    }
    [self enableToolbarButtons:enabled];
}

- (void)enableToolbarButtons:(BOOL)enabled {
    [self.operationToolbar.subviews setValue:@(enabled) forKeyPath:@"enabled"];
}

#pragma mark - Accessor

- (UIView *)videoContainer {
    if (!_videoContainer) {
        _videoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, VideoViewWidth, VideoViewHeight)];
        _videoContainer.backgroundColor = [UIColor blackColor];
    }
    return _videoContainer;
}

- (NSArray *)controlDatas {
    NSArray *localFeatureDatas = [self localConfigToolbarItems];
    if (!localFeatureDatas) {
        return nil;
    }
    NSMutableArray *featureDatas = [NSMutableArray arrayWithArray:localFeatureDatas];
    if ([ThingSmartCloudManager isSupportCloudStorage:self.devId] ) {
        for (NSArray *subFeatureDatas in featureDatas) {
            for (CameraControlButtonItem *buttonItem in subFeatureDatas) {
                if ([buttonItem.identifier isEqualToString:kControlCloud]) {
                    buttonItem.hidden = NO;
                }
                if ([buttonItem.identifier isEqualToString:kControlCloudDebug]) {
                    buttonItem.hidden = kControlCloudDebugEnable ? NO : YES;
                }
            }
        }
    } else {
        [self showTip:NSLocalizedStringFromTable(@"Cloud Stroage is unsupported", @"IPCLocalizable", @"")];
    }
    return featureDatas.copy;
}

- (NSArray *)localConfigToolbarItems {
    NSString *configFilePath = [NSBundle.mainBundle pathForResource:@"ipc_preview_toolbar_items" ofType:@"json"];
    NSError *error = nil;
    NSString *jsonString = [NSString stringWithContentsOfFile:configFilePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding: NSUTF8StringEncoding];
    if (jsonData) {
        NSArray *parentArray = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
        NSMutableArray *tempLocalConfigItems = NSMutableArray.array;
        for (NSArray *sonArray in parentArray) {
            NSArray *buttonItems = [NSArray yy_modelArrayWithClass:CameraControlButtonItem.class json:sonArray];
            [tempLocalConfigItems addObject:buttonItems];
        }
        if (tempLocalConfigItems.count) {
            return tempLocalConfigItems.copy;
        }
    }
    return nil;
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
        if (@available(iOS 11.0, *)) {
            _bodyScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _bodyScrollView;
}

- (CameraControlNewView *)controlView {
    if (!_controlView) {
        CGFloat top = VideoViewHeight + APP_TOP_BAR_HEIGHT;
        CGFloat bottomSwitchViewHeight = IsIphoneX ? IphoneXSafeBottomMargin + BottomSwitchViewHeight : BottomSwitchViewHeight;
        CGFloat height = UIScreen.mainScreen.bounds.size.height - top - bottomSwitchViewHeight;
        _controlView = [[CameraControlNewView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, height)];
        _controlView.buttonItems = [self controlDatas];
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

- (UIView *)operationToolbar {
    if (!_operationToolbar) {
        _operationToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, self.videoContainer.bottom - 50, self.videoContainer.width, 50)];
        _operationToolbar.backgroundColor = UIColor.clearColor;
    }
    return _operationToolbar;
}

- (CameraLoadingButton *)soundButton {
    if (!_soundButton) {
        _soundButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _soundButton.frame = CGRectMake(8, 3, 44, 44);
        [_soundButton setImage:[UIImage imageNamed:@"ty_camera_soundOff_icon"] forState:UIControlStateNormal];
        [_soundButton setImage:[UIImage imageNamed:@"ty_camera_soundOn_icon"] forState:UIControlStateSelected];
    }
    return _soundButton;
}

- (CameraLoadingButton *)hdButton {
    if (!_hdButton) {
        _hdButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _hdButton.frame = CGRectMake(60, 3, 44, 44);
        [_hdButton setImage:[UIImage imageNamed:@"ty_camera_control_sd_normal"] forState:UIControlStateNormal];
        [_hdButton setImage:[UIImage imageNamed:@"ty_camera_control_hd_normal"] forState:UIControlStateSelected];
    }
    return _hdButton;
}

- (CameraLoadingButton *)toolbarFoldingButton {
    if (!_toolbarFoldingButton) {
        _toolbarFoldingButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _toolbarFoldingButton.frame = CGRectMake(self.videoContainer.width - 44 - 8, 3, 44, 44);
        [_toolbarFoldingButton demo_setBackgroundColor:[UIColor.blackColor colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        [_toolbarFoldingButton setImage:[UIImage imageNamed:@"demo_camera_toolbar_fold"] forState:UIControlStateNormal];
        [_toolbarFoldingButton setImage:[UIImage imageNamed:@"demo_camera_toolbar_unfold"] forState:UIControlStateSelected];
        _toolbarFoldingButton.layer.cornerRadius = 6;
        _toolbarFoldingButton.clipsToBounds = YES;
    }
    return _toolbarFoldingButton;
}

- (CameraLoadingButton *)fullScreenButton {
    if (!_fullScreenButton) {
        _fullScreenButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _fullScreenButton.frame = CGRectMake(self.toolbarFoldingButton.left - 44 - 8, self.toolbarFoldingButton.top, 44, 44);
        [_fullScreenButton demo_setBackgroundColor:[UIColor.blackColor colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        [_fullScreenButton setImage:[UIImage imageNamed:@"demo_camera_control_fullscreen"] forState:UIControlStateNormal];
        _fullScreenButton.layer.cornerRadius = 6;
        _fullScreenButton.clipsToBounds = YES;
    }
    return _fullScreenButton;
}

- (CameraLoadingButton *)backPageButton {
    if (!_backPageButton) {
        _backPageButton = [CameraLoadingButton buttonWithType:UIButtonTypeCustom];
        _backPageButton.frame = CGRectMake(IsIphoneX ? 24 : 12, 10, 44, 44);
        [_backPageButton demo_setBackgroundColor:[UIColor.blackColor colorWithAlphaComponent:0.3] forState:UIControlStateNormal];
        [_backPageButton setImage:[UIImage imageNamed:@"demo_camera_page_back"] forState:UIControlStateNormal];
        _backPageButton.layer.cornerRadius = 22;
        _backPageButton.clipsToBounds = YES;
        _backPageButton.hidden = YES;
    }
    return _backPageButton;
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
