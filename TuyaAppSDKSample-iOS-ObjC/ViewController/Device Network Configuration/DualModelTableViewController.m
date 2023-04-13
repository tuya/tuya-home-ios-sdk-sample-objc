//
//  DualModelTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DualModelTableViewController.h"

@interface DualModelTableViewController ()<ThingSmartBLEManagerDelegate, ThingSmartBLEWifiActivatorDelegate>

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
    
    ThingSmartBLEManager.sharedInstance.delegate = nil;
    [ThingSmartBLEManager.sharedInstance stopListening:YES];

    ThingSmartBLEWifiActivator.sharedInstance.bleWifiDelegate = nil;
    [ThingSmartBLEWifiActivator.sharedInstance stopDiscover];
}

- (IBAction)searchClicked:(id)sender {
    ThingSmartBLEManager.sharedInstance.delegate = self;
    [ThingSmartBLEManager.sharedInstance startListening:YES];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Searching", @"")];
}

- (void)didDiscoveryDeviceWithDeviceInfo:(ThingBLEAdvModel *)deviceInfo{
    if (deviceInfo.bleType == ThingSmartBLETypeUnknow ||
        deviceInfo.bleType == ThingSmartBLETypeBLE ||
        deviceInfo.bleType == ThingSmartBLETypeBLEPlus ||
        deviceInfo.bleType == ThingSmartBLETypeBLESecurity ||
        deviceInfo.bleType == ThingSmartBLETypeBLEZigbee ||
        deviceInfo.bleType == ThingSmartBLETypeBLEBeacon) {
        NSLog(@"Please use BLE Mode to pair: %@", deviceInfo.uuid);
        return;
    }
    
    long long homeId = [Home getCurrentHome].homeId;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Sending Data to the Device", @"")];
    ThingSmartBLEWifiActivator.sharedInstance.bleWifiDelegate = self;
    [ThingSmartBLEWifiActivator.sharedInstance startConfigBLEWifiDeviceWithUUID:deviceInfo.uuid homeId:homeId productId:deviceInfo.productId ssid:_txtFSSID.text ?: @"" password:_txtFPS.text ?: @"" timeout:100 success:^{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to configuration", "")];
    }];
}

- (void)bleWifiActivator:(ThingSmartBLEWifiActivator *)activator didReceiveBLEWifiConfigDevice:(nullable ThingSmartDeviceModel *)deviceModel error:(nullable NSError *)error {
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
