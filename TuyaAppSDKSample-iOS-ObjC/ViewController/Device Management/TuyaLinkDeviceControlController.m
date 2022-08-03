//
//  TuyaLinkDeviceControlController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLinkDeviceControlController.h"
#import "DeviceDetailTableViewController.h"
#import "SVProgressHUD.h"
#import "DeviceControlCellHelper.h"
#import "NotificationName.h"

@interface TuyaLinkDeviceControlController ()<TuyaSmartDeviceDelegate>

@end

@implementation TuyaLinkDeviceControlController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.device.deviceModel.name;
    self.device.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceHasRemoved:) name:SVProgressHUDDidDisappearNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self detectDeviceAvailability];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceHasRemoved:) name:SVProgressHUDDidDisappearNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show-device-detail"]) {
        ((DeviceDetailTableViewController *)segue.destinationViewController).device = self.device;
    }
}

- (void)publishMessage:(NSDictionary *) dps {
    [self.device publishDps:dps success:^{
            
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)detectDeviceAvailability {
    bool isOnline = self.device.deviceModel.isOnline;
    if (!isOnline) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceOffline object:nil];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"The device is offline. The control panel is unavailable.", @"")];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceOnline object:nil];
        [SVProgressHUD dismiss];
    }
}

- (void)deviceHasRemoved:(NSNotification *)notification {
    NSString *key = notification.userInfo[SVProgressHUDStatusUserInfoKey];
    if ([key containsString:@"removed"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
