//
//  ViewController.m
//  ThingSmartVisual
//
//  Created by MokZF on 2024/12/31.
//

#import "ThingCameraLitePreviewViewController.h"
#import "ThingMqttManager.h"
#import <CoreLocation/CoreLocation.h>
#import <ThingSmartCameraKitLite/ThingSmartCameraDevice.h>
#import <ThingCameraSDK/ThingCamera.h>
#import <ThingSmartMediaUIKit/ThingSmartMediaVideoView.h>
#import <ThingSmartCameraKitLite/ThingCameraUtil.h>
#import "ThingCameraLiteCloudViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ViewController.h"
#import <ThingSmartCameraKitLite/ThingSmartCameraTypeProtocol.h>

@interface ThingCameraLitePreviewViewController ()<CLLocationManagerDelegate,ThingCameraP2PConnectDataSource,ThingCameraMqttProtocol,ThingSmartCameraDeviceDataSource,ThingSmartCameraVirsualDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) ThingMqttManager *mqttManager;

@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong) UIButton *previewButton;
@property (nonatomic, strong) UIButton *stopPreviewButton;
@property (nonatomic, strong) UIButton *disConnectButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) ThingSmartMediaVideoView *videoView;

@property (nonatomic, assign) BOOL firstPix;
@property (nonatomic, strong) id<ThingSmartCameraTypeProtocol> device;

@property (nonatomic, copy) NSString *token;

@end

@implementation ThingCameraLitePreviewViewController

- (instancetype)initCameraLitePreviewControllerWithToken:(NSString *)token {
    self = [super init];
    if (self) {
        _token = token;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)dealloc {
    [self.mqttManager disconnect];
    [self.device disconnect];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self subViewInit];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // 检查当前授权状态，如果没有决定权限，发起请求
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];  // 请求"在使用时"的权限
    }

    
    ThingSmartCameraDevice *device = [[ThingSmartCameraDevice alloc] createCameraWithProductKey:testProductKey deviceSecret:testDeviceSecret deviceName:testDeviceName token:self.token];
    device.delegate = self;
    device.dataSource = self;
    self.device = device;
}


- (void)subViewInit {
    self.title = @"Preview";
    self.view.backgroundColor = [UIColor grayColor];
    CGFloat sw = self.view.frame.size.width;
    
    if (!self.resultLabel) {
        self.resultLabel = [UILabel new];
        [self.resultLabel setText:@"MQTT未连接"];
        [self.resultLabel setTextColor:[UIColor whiteColor]];
        self.resultLabel.backgroundColor = [UIColor redColor];
        self.resultLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.resultLabel];
    }
    
    if (!self.previewButton) {
        self.previewButton = [UIButton new];
        [self.previewButton setTitle:@"发起预览" forState:UIControlStateNormal];
        [self.previewButton addTarget:self action:@selector(_mqttConnectAction) forControlEvents:UIControlEventTouchUpInside];
        [self.previewButton setBackgroundColor:[UIColor redColor]];
        [self.previewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.previewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.previewButton];
    }
    
    if (!self.stopPreviewButton) {
        self.stopPreviewButton = [UIButton new];
        [self.stopPreviewButton setTitle:@"停止预览" forState:UIControlStateNormal];
        [self.stopPreviewButton addTarget:self action:@selector(_stopPreviewAction) forControlEvents:UIControlEventTouchUpInside];
        [self.stopPreviewButton setBackgroundColor:[UIColor redColor]];
        [self.stopPreviewButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.stopPreviewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.stopPreviewButton];
    }
    
    if (!self.disConnectButton) {
        self.disConnectButton = [UIButton new];
        [self.disConnectButton setTitle:@"断开P2P连接" forState:UIControlStateNormal];
        [self.disConnectButton addTarget:self action:@selector(_dicconnectAction) forControlEvents:UIControlEventTouchUpInside];
        [self.disConnectButton setBackgroundColor:[UIColor redColor]];
        [self.disConnectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.disConnectButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.disConnectButton];
    }
    
    if (!self.muteButton) {
        self.muteButton = [UIButton new];
        [self.muteButton setTitle:@"开启声音" forState:UIControlStateNormal];
        [self.muteButton addTarget:self action:@selector(_closeMuteAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.muteButton setBackgroundColor:[UIColor redColor]];
        [self.muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.muteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.muteButton];
    }

    
    CGFloat width = CGRectGetWidth(self.view.frame)/2 - 70;
    
    self.previewButton.frame = CGRectMake(20, 100, width, 60);
    self.stopPreviewButton.frame = CGRectMake(20, CGRectGetMaxY(self.previewButton.frame) + 20, width, 60);
    self.disConnectButton.frame = CGRectMake(20, CGRectGetMaxY(self.stopPreviewButton.frame) + 20, width, 60);
    self.resultLabel.frame = CGRectMake(20, CGRectGetMaxY(self.disConnectButton.frame) + 20, width, 60);
    
    self.muteButton.frame = CGRectMake(CGRectGetMaxX(self.previewButton.frame) + 40, 100, width, 60);
    
    if (!self.videoView) {
        CGFloat viewWidth = CGRectGetWidth(self.view.frame);
        self.videoView = [[ThingSmartMediaVideoView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.resultLabel.frame) + 20, viewWidth, viewWidth*9/16)];
        
        [self.view addSubview:self.videoView];
        self.videoView.userInteractionEnabled = YES;
    }
}

- (void)_mqttConnectAction {
    if (!_mqttManager) {
        ThingMqttManager *manager = [ThingMqttManager sharedInstance];
        manager.mqttManagerDataSource = self;
        manager.mqttManagerDelegate = self;
        _mqttManager = manager;
    }else {
        [_mqttManager disconnect];
    }
    [SVProgressHUD showWithStatus:@"MQTT连接中"];
    [_mqttManager connectMqtt];
}

- (void)_closeMuteAction:(UIButton *)sender {
    [sender removeTarget:self action:@selector(_closeMuteAction:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(_openMute:) forControlEvents:UIControlEventTouchUpInside];
    [sender setTitle:@"关闭声音" forState:UIControlStateNormal];
    [self.device updateMute:NO];
}

- (void)_openMute:(UIButton *)sender {
    [sender removeTarget:self action:@selector(_openMute:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(_closeMuteAction:) forControlEvents:UIControlEventTouchUpInside];
    [sender setTitle:@"开启声音" forState:UIControlStateNormal];
    [self.device updateMute:YES];
}

- (void)updateButtonEnable {
//    self.createCameraButton.enabled = YES;
}

- (void)_createCameraAction {
    if ([self.mqttManager mqttConnectState] != MQTTSessionManagerStateConnected) {
        return;
    }
    [SVProgressHUD showWithStatus:@"构建加密通道"];
    [self.device connect];
}

- (void)_startPreviewAction {
    [self.device startPreview];
}

- (void)_stopPreviewAction {
    [self.device stopPreview];
    [SVProgressHUD showSuccessWithStatus:@"视频流已停止播放"];
}

- (void)_dicconnectAction {
    [self.device disconnect];
}

// 权限申请结果回调方法
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"已获得在使用时的网络权限");
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"用户拒绝了网络权限");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"权限受限");
            break;
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"还未决定权限");
            break;
        default:
            break;
    }
}


#pragma mark -ThingCameraP2PConnectDataSource

- (NSString *)productKey {
    return mqttProductKey;
}

- (NSString *)deviceName {
    return mqttDevcieName;
}

- (NSString *)deviceSecret {
    return mqttDeviceSecret;
}

- (NSString *)mqttTopic {
    //订阅设备的topic
    return testDeviceTopicIn;
}

#pragma mark -ThingCameraMqttProtocol
- (void)thing_handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"【IPC log】handleMessage:%@",string);
    [self.device didReceiveMqttMessage:string];
}

- (void)thing_sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    NSString *text = @"MQTT";
    NSString *subText = @"";
    UIColor *color = [UIColor redColor];
    if (newState == MQTTSessionManagerStateConnecting) {
        subText = @"连接中...";
    }
    
    if (newState == MQTTSessionManagerStateConnected) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"MQTT连接成功"];
        [self _createCameraAction];
        subText = @"已连接";
        color = UIColor.greenColor;
    }
    
    if (newState == MQTTSessionManagerStateClosing) {
        subText = @"断开中...";
    }
    
    if (newState == MQTTSessionManagerStateClosed) {
        subText = @"已断开";
    }
    self.resultLabel.text = [NSString stringWithFormat:@"%@%@",text,subText];
    self.resultLabel.backgroundColor = color;
}

- (void)thing_sessionManager:(MQTTSessionManager *)sessionManager didDeliverMessage:(UInt16)msgID {
    
}

#pragma mark - ThingSmartCameraDeviceDataSource,ThingSmartCameraVirsualDelegate

- (void)shouldSendMqttMessage:(NSDictionary *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"=====%@",message);
        [self.mqttManager sendData:[[ThingCameraUtil thing_jsonStringFromDictionary:message] dataUsingEncoding:NSUTF8StringEncoding]];
    });
}


#pragma mark - ThingSmartCameraVirsualDelegate

- (void)camera:(id<ThingSmartCameraTypeProtocol>)cameraDevice didVideoFrameRecvedWithSampleBuffer:(CMSampleBufferRef)sampleBuffer videoFrameInfo:(ThingSmartVideoFrameInfo)videoFrameInfo {
    if (!self.firstPix) {
        self.firstPix = YES;
        [SVProgressHUD dismiss];
        [self.videoView startPlay];
    }
    CVPixelBufferRef pixcelBuffer = (CVPixelBufferRef)sampleBuffer;
    
    CVPixelBufferRetain(pixcelBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.videoView displayPixelBuffer:pixcelBuffer featureRect:CGRectMake(0, 0, videoFrameInfo.nWidth, videoFrameInfo.nHeight)];
        CVPixelBufferRelease(pixcelBuffer);
    });
}

- (void)cameraDidConnected:(id<ThingSmartCameraTypeProtocol>)camera {
    [SVProgressHUD showWithStatus:@"获取视频流"];
    [self _startPreviewAction];
}

- (void)cameraDisconnected:(id<ThingSmartCameraTypeProtocol>)camera specificErrorCode:(NSInteger)errorCode {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"P2P已断开连接，code:%d",errorCode]];
}

@end
