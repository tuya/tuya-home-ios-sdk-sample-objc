//
//  APModeTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "APModeTableViewController.h"


@interface APModeTableViewController () <ThingSmartActivatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ssidTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) bool isSuccess;
@end

@implementation APModeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestToken];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopConfigWifi];
}

- (IBAction)searchTapped:(UIBarButtonItem *)sender {
    [self startConfiguration];
}

- (void)requestToken {
    long long homeId = [Home getCurrentHome].homeId;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Requesting for Token", @"")];
    [[ThingSmartActivator sharedInstance] getTokenWithHomeId:homeId success:^(NSString *result) {
        if (result && result.length > 0) {
            self.token = result;
        }
        [SVProgressHUD dismiss];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)startConfiguration {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    NSString *ssid = self.ssidTextField.text;
    NSString *password = self.passwordTextField.text;
    [ThingSmartActivator sharedInstance].delegate = self;
    [[ThingSmartActivator sharedInstance] startConfigWiFi:ThingActivatorModeAP ssid:ssid password:password token:self.token timeout:100];
}

- (void)stopConfigWifi {
    if (!self.isSuccess) {
        [SVProgressHUD dismiss];
    }
    [ThingSmartActivator sharedInstance].delegate = nil;
    [[ThingSmartActivator sharedInstance] stopConfigWiFi];
}

- (void)activator:(ThingSmartActivator *)activator didReceiveDevice:(ThingSmartDeviceModel *)deviceModel error:(NSError *)error {
    if (deviceModel && error == nil) {
        NSString *name = deviceModel.name?deviceModel.name:NSLocalizedString(@"Unknown Name", @"Unknown name device.");
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@" ,NSLocalizedString(@"Successfully Added", @"") ,name]];
        self.isSuccess = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

// Only the Security Level Device Need this.
- (void)activator:(ThingSmartActivator *)activator didPassWIFIToSecurityLevelDeviceWithUUID:(NSString *)uuid {
    [SVProgressHUD dismiss];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"SecurityLevelDevice" message:@"continue pair? (Please check you phone connected the same Wi-Fi as you Inputed)" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil]];
    [vc addAction:[UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[ThingSmartActivator sharedInstance] continueConfigSecurityLevelDevice];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    }]];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
