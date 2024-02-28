//
//  TuyaLockDeviceFingerResultViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeResultViewController.h"
#import "TuyaLockDeviceUnlockModeResultView.h"
#import "Alert.h"

@interface TuyaLockDeviceUnlockModeResultViewController ()

@property (nonatomic, strong) TuyaLockDeviceUnlockModeResultView *resultView;

@end

@implementation TuyaLockDeviceUnlockModeResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resultView = [[TuyaLockDeviceUnlockModeResultView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.resultView];
}

@end
