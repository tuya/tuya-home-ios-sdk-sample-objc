//
//  DualModelTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DualModelTableViewController.h"

@interface DualModelTableViewController ()<TuyaSmartBLEManagerDelegate, TuyaSmartBLEWifiActivatorDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtFSSID;
@property (weak, nonatomic) IBOutlet UITextField *txtFPS;

@property (nonatomic, assign) BOOL isSuccess;

@end

@implementation DualModelTableViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopScan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)stopScan{
    if (!self.isSuccess) {
        [SVProgressHUD dismiss];
    }
    
    TuyaSmartBLEManager.sharedInstance.delegate = nil;
    [TuyaSmartBLEManager.sharedInstance stopListening:YES];

    TuyaSmartBLEWifiActivator.sharedInstance.bleWifiDelegate = nil;
    [TuyaSmartBLEWifiActivator.sharedInstance stopDiscover];
}

- (IBAction)searchClicked:(id)sender {
    TuyaSmartBLEManager.sharedInstance.delegate = self;
    [TuyaSmartBLEManager.sharedInstance startListening:YES];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching", @"")];
}

- (void)didDiscoveryDeviceWithDeviceInfo:(TYBLEAdvModel *)deviceInfo{
    long long homeId = [Home getCurrentHome].homeId;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Sending Data to the Device", @"")];
    TuyaSmartBLEWifiActivator.sharedInstance.bleWifiDelegate = self;
    [TuyaSmartBLEWifiActivator.sharedInstance startConfigBLEWifiDeviceWithUUID:deviceInfo.uuid homeId:homeId productId:deviceInfo.productId ssid:_txtFSSID.text ?: @"" password:_txtFPS.text ?: @"" timeout:100 success:^{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to configuration", "")];
    }];
}

- (void)bleWifiActivator:(nonnull TuyaSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nonnull TuyaSmartDeviceModel *)deviceModel error:(nonnull NSError *)error {
    if (error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription ?: NSLocalizedString(@"Failed to configuration", "")];
        return;
    }
    self.isSuccess = YES;
    NSString *name = deviceModel.name ?: NSLocalizedString(@"Unknown Name", @"Unknown name device.");
    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@" ,NSLocalizedString(@"Successfully Added", @"") ,name]];
    [self.navigationController popViewControllerAnimated:YES];
}
    

@end
