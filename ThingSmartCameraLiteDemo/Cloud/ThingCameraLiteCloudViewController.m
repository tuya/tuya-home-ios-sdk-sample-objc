//
//  ThingCameraLiteCloudViewController.m
//  ThingSmartVisual
//
//  Created by MokZF on 2025/1/14.
//

#import "ThingCameraLiteCloudViewController.h"
#import <ThingSmartCameraKitLite/ThingSmarCameraLiteCloudManager.h>
#import <ThingSmartMediaUIKit/ThingSmartMediaVideoView.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ViewController.h"
#import <ThingSmartCameraKitLite/ThingSmartCameraCloudDelegate.h>
#import <ThingSmartCameraKitLite/ThingSmartCameraTypeProtocol.h>

@interface ThingCameraLiteCloudViewController ()<ThingSmartCameraCloudDelegate>

@property (nonatomic, strong) ThingSmarCameraLiteCloudManager *cloudManager;
@property (nonatomic, strong) UIButton *cloudButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *stopPlayButton;
@property (nonatomic, strong) ThingSmartMediaVideoView *videoView;
@property (nonatomic, assign) BOOL firstPix;

@property (nonatomic, copy) NSString *token;

@end

@implementation ThingCameraLiteCloudViewController

- (instancetype)initCameraLiteCloudViewController:(NSString *)token {
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Cloud";
    self.view.backgroundColor = [UIColor grayColor];
    [self _viewInit];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cloudManager stopPlayCloudVideo];
    });
}

- (void)_viewInit {
    if (!self.cloudButton) {
        self.cloudButton = [UIButton new];
        [self.cloudButton setTitle:@"开始播放" forState:UIControlStateNormal];
        [self.cloudButton addTarget:self action:@selector(cloudAction) forControlEvents:UIControlEventTouchUpInside];
        [self.cloudButton setBackgroundColor:[UIColor redColor]];
        [self.cloudButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.cloudButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.cloudButton];
        CGFloat width = CGRectGetWidth(self.view.frame) - 220;
        self.cloudButton.frame = CGRectMake(20, 90, width, 60);

    }
    
    if (!self.muteButton) {
        self.muteButton = [UIButton new];
        [self.muteButton setTitle:@"关闭声音" forState:UIControlStateNormal];
        [self.muteButton addTarget:self action:@selector(mute:) forControlEvents:UIControlEventTouchUpInside];
        [self.muteButton setBackgroundColor:[UIColor redColor]];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.muteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.muteButton];
        CGFloat width = CGRectGetWidth(self.view.frame) - 220;
        self.muteButton.frame = CGRectMake(20, CGRectGetMaxY(self.cloudButton.frame)+20, width, 60);

    }
    
    if (!self.stopPlayButton) {
        self.stopPlayButton = [UIButton new];
        [self.stopPlayButton setTitle:@"暂停播放" forState:UIControlStateNormal];
        [self.stopPlayButton addTarget:self action:@selector(pausePlay:) forControlEvents:UIControlEventTouchUpInside];
        [self.stopPlayButton setBackgroundColor:[UIColor redColor]];
        [self.stopPlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.stopPlayButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.stopPlayButton];
        CGFloat width = CGRectGetWidth(self.view.frame) - 220;
        self.stopPlayButton.frame = CGRectMake(20, CGRectGetMaxY(self.muteButton.frame)+20, width, 60);

    }
    
    if (!self.videoView) {
        CGFloat sw = self.view.frame.size.width;
        self.videoView = [[ThingSmartMediaVideoView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.stopPlayButton.frame) + 40, sw, sw*9/16)];
        [self.view addSubview:self.videoView];
        self.videoView.userInteractionEnabled = YES;
    }

}

- (void)cloudAction {
    [self _loadData];
}

- (void)mute:(UIButton *)sender {
    [self.cloudManager updateMute:YES];
    [sender setTitle:@"开启声音" forState:UIControlStateNormal];
    [sender removeTarget:self action:@selector(mute:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(unMute:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)unMute:(UIButton *)sender {
    [self.cloudManager updateMute:NO];
    [sender setTitle:@"关闭声音" forState:UIControlStateNormal];
    [sender removeTarget:self action:@selector(unMute:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(mute:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)pausePlay:(UIButton *)sender {
    [self.cloudManager pausePlayCloudVideo];
    [sender setTitle:@"继续播放" forState:UIControlStateNormal];
    [sender removeTarget:self action:@selector(pausePlay:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(resumePlay:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)resumePlay:(UIButton *)sender {
    [self.cloudManager resumePlayCloudVideo];
    [sender setTitle:@"暂停播放" forState:UIControlStateNormal];
    [sender removeTarget:self action:@selector(resumePlay:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(pausePlay:) forControlEvents:UIControlEventTouchUpInside];

}

- (ThingSmarCameraLiteCloudManager *)cloudManager {
    if (!_cloudManager) {
        _cloudManager = [[ThingSmarCameraLiteCloudManager alloc] initWithDeviceId:testDeviceName productId:testProductKey token:self.token];
        _cloudManager.delegate = self;
    }
    return _cloudManager;
}

- (void)_loadData  {
    NSDate *currentDate = [NSDate date];
    
    [SVProgressHUD showWithStatus:@"数据加载中..."];
    ThingSmarCameraLiteCloudParamas *params = [[ThingSmarCameraLiteCloudParamas alloc] init];
    params.startTime = 1739116800;
    params.endTime = 1739177398;
    params.pageIndex = 1;
    params.pageSize = 20;
    [self.cloudManager loadCloudData:params success:^(NSString * _Nonnull jsonData) {
        if (jsonData) {
            params.metaData = jsonData;
            [self.cloudManager playCloudDatas:params responseHandler:^(const char * _Nonnull msg, int errCode) {
                if (errCode == 0) {
                    
                }
            } playFinishHandler:^(const char * _Nonnull msg, int errCode) {
                            
            }];
        }
    } fail:^(NSError * _Nonnull error) {
            
    }];
    [SVProgressHUD showWithStatus:@"正在获取视频流"];
}

#pragma mark - ThingSmartCameraCloudDelegate

- (void)cloudVideoPlayer:(ThingSmarCameraLiteCloudManager *)player didReceivedFrame:(CMSampleBufferRef)frameBuffer videoFrameInfo:(ThingSmartVideoFrameInfo)frameInfo {
    if (!self.firstPix) {
        self.firstPix = YES;
        [SVProgressHUD dismiss];
        [self.videoView startPlay];
        [player updateMute:NO];
    }
    
    CVPixelBufferRef pixcelBuffer = (CVPixelBufferRef)frameBuffer;
    CVPixelBufferRetain(pixcelBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoView displayPixelBuffer:pixcelBuffer featureRect:CGRectMake(0, 0, frameInfo.nWidth, frameInfo.nHeight)];
        CVPixelBufferRelease(pixcelBuffer);
    });

}


@end
