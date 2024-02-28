//
//  TuyaLockDeviceSetRemoteVoicePasswordViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceSetRemoteVoicePasswordViewController.h"
#import "TuyaLockDeviceSetRemoteVoicePasswordView.h"
#import "Alert.h"

@interface TuyaLockDeviceSetRemoteVoicePasswordViewController ()<TuyaLockDeviceSetRemoteVoicePasswordViewDelegate>

@property (nonatomic, strong) TuyaLockDeviceSetRemoteVoicePasswordView *voicePasswordView;

@end

@implementation TuyaLockDeviceSetRemoteVoicePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.voicePasswordView = [[TuyaLockDeviceSetRemoteVoicePasswordView alloc] initWithFrame:self.view.bounds];
    self.voicePasswordView.delegate = self;
    [self.view addSubview:self.voicePasswordView];
}

- (void)popToVC{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TuyaLockDeviceSetRemoteVoicePasswordViewDelegate

- (void)confirmAction:(NSString *)pwd{
    WEAKSELF_ThingSDK
    if ([self isBLEDevice]){
        [self.bleDevice setRemoteVoiceUnlockWithDevId:self.bleDevice.deviceModel.devId
                                                 open:YES
                                                  pwd:pwd
                                              success:^(id result) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"设置成功" message:@""];
            [weakSelf_ThingSDK performSelector:@selector(popToVC) withObject:nil afterDelay:2];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程语音密码设置失败" message:error.localizedDescription];
        }];
    }
    
    if ([self isZigbeeDevice]){
        [self.zigbeeDevice setRemoteVoiceUnlockWithDevId:self.devId open:YES pwd:pwd success:^(id result) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"设置成功" message:@""];
            [weakSelf_ThingSDK performSelector:@selector(popToVC) withObject:nil afterDelay:2];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程语音密码设置失败" message:error.localizedDescription];
        }];
    }
}

- (void)errorPwd{
    [Alert showBasicAlertOnVC:self withTitle:@"请输入正确的密码" message:@""];
}

@end
