//
//  EZModeTableViewController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "EZModeTableViewController.h"

@interface EZModeTableViewController () <ThingSmartActivatorDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ssidTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) NSString *token;
@property (assign, nonatomic) bool isSuccess;
@end

@implementation EZModeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopConfigWifi];
}

- (IBAction)searchTapped:(id)sender {
    [self startConfiguration];
}

- (void)stopConfigWifi {
    if (!self.isSuccess) {
        [SVProgressHUD dismiss];
    }
    [ThingSmartActivator sharedInstance].delegate = nil;
    [[ThingSmartActivator sharedInstance] stopConfigWiFi];
}

- (void)startConfiguration {
    long long homeId = [Home getCurrentHome].homeId;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Requesting for Token", @"")];
    [[ThingSmartActivator sharedInstance] getTokenWithHomeId:homeId success:^(NSString *result) {
        if (result && result.length > 0) {
            self.token = result;
        }
        [self startConfiguration:self.token];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)startConfiguration:(NSString *)token {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    NSString *ssid = self.ssidTextField.text;
    NSString *password = self.passwordTextField.text;
    [ThingSmartActivator sharedInstance].delegate = self;
    [[ThingSmartActivator sharedInstance] startConfigWiFi:ThingActivatorModeEZ ssid:ssid password:password token:self.token timeout:100];
}

-(void)activator:(ThingSmartActivator *)activator didReceiveDevice:(ThingSmartDeviceModel *)deviceModel error:(NSError *)error {
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
@end
