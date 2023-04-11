//
//  QRCodeScanerViewController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

#import "QRCodeScanerViewController.h"
#import <SGQRCode/SGQRCode.h>

@interface QRCodeScanerViewController ()<SGScanCodeDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    SGScanCode *scanCode;
}
@property (nonatomic, strong) SGScanView *scanView;
@end

@implementation QRCodeScanerViewController

- (void)dealloc {
    [self stop];
}

- (void)start {
    [scanCode startRunning];
    [self.scanView startScanning];
}

- (void)stop {
    [scanCode stopRunning];
    [self.scanView stopScanning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    
    [self configureNav];
    
    [self configureUI];
    
    [self configureQRCode];
}

- (void)configureUI {
    [self.view addSubview:self.scanView];
}

- (void)configureQRCode {
    scanCode = [SGScanCode scanCode];
    scanCode.preview = self.view;
    scanCode.delegate = self;
    [scanCode startRunning];
}

- (void)scanCode:(SGScanCode *)scanCode result:(NSString *)result {
    [self stop];
    
    if (self.scanCallback) {
        self.scanCallback(result);
    }
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)configureNav {
    self.navigationItem.title = @"Scan QRCode";
}

- (SGScanView *)scanView {
    if (!_scanView) {
        SGScanViewConfigure *configure = [[SGScanViewConfigure alloc] init];
        configure.isShowBorder = YES;
        configure.borderColor = [UIColor clearColor];
        configure.cornerColor = [UIColor whiteColor];
        configure.cornerWidth = 3;
        configure.cornerLength = 15;
        configure.isFromTop = YES;
        configure.scanline = @"SGQRCode.bundle/scan_scanline_qq";
        configure.color = [UIColor clearColor];
        
        CGFloat x = 0;
        CGFloat y = 0;
        CGFloat w = self.view.frame.size.width;
        CGFloat h = self.view.frame.size.height;
        _scanView = [[SGScanView alloc] initWithFrame:CGRectMake(x, y, w, h) configure:configure];
        [_scanView startScanning];
        _scanView.scanFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }
    return _scanView;
}

@end
