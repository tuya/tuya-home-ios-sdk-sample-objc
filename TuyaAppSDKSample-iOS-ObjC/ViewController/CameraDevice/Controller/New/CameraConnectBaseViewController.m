//
//  CameraConnectBaseViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraConnectBaseViewController.h"

#import "CameraDeviceManager.h"

@interface CameraConnectBaseViewController () <TuyaSmartCameraDelegate>

@end

@implementation CameraConnectBaseViewController

- (instancetype)initWithDeviceId:(NSString *)devId {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _devId = devId;
        _cameraDevice = [CameraDeviceManager.sharedManager getCameraDeviceWithDevId:devId];
        [_cameraDevice addDelegate:self];
        
        _videoView = [[CameraVideoView alloc] initWithFrame:CGRectZero];
        _videoView.renderView = _cameraDevice.videoView;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionDidInterruptNotification:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.cameraDevice bindVideoRenderView];
    self.videoView.renderView = self.cameraDevice.videoView;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cameraDevice unbindVideoRenderView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)disconnect {
    [self.cameraDevice disconnect];
}

#pragma mark - Notification

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification {
    [self disconnect];
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    
}

- (void)audioSessionDidInterruptNotification:(NSNotification *)notification {
    NSInteger type = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self applicationDidEnterBackgroundNotification:nil];
    } else if (type == AVAudioSessionInterruptionTypeEnded) {
        [self applicationWillEnterForegroundNotification:nil];
    }
}

#pragma mark - TuyaSmartCameraDelegate


@end
