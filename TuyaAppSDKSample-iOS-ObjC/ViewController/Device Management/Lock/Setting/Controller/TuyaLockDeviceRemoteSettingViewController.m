//
//  TuyaLockDeviceRemoteSettingViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceRemoteSettingViewController.h"
#import "TuyaLockDeviceRemoteSettingView.h"
#import "TuyaLockDeviceSetRemoteVoicePasswordViewController.h"
#import "Alert.h"

@interface TuyaLockDeviceRemoteSettingViewController ()<TuyaLockDeviceRemoteSettingViewDelegate>

@property (nonatomic, strong) TuyaLockDeviceRemoteSettingView *remoteSettingView;

@end

@implementation TuyaLockDeviceRemoteSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.remoteSettingView = [[TuyaLockDeviceRemoteSettingView alloc] initWithFrame:self.view.bounds];
    self.remoteSettingView.delegate = self;
    [self.view addSubview:self.remoteSettingView];
    
    [self fetchData];
}

- (void)fetchData{
    WEAKSELF_ThingSDK
    if ([self getDpIdWithDpCode:@"remote_no_dp_key"].length > 0){
        [self.bleDevice fetchRemoteUnlockTypeWithDevId:self.bleDevice.deviceModel.devId
                                               success:^(id result) {
            [weakSelf_ThingSDK.remoteSettingView setRemoteHidden:NO];
            BOOL value = [result[@"UNLOCK_PHONE_REMOTE"] boolValue];
            [weakSelf_ThingSDK.remoteSettingView setRemoteValue:value];
        } failure:^(NSError *error) {
            [weakSelf_ThingSDK.remoteSettingView setRemoteHidden:YES];
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取远程解锁开关失败" message:error.localizedDescription];
        }];
    }
    else{
        [self.remoteSettingView setRemoteHidden:YES];
        [Alert showBasicAlertOnVC:self withTitle:@"设备不支持dpCode:remote_no_dp_key" message:@""];
    }
    
    if ([self getDpIdWithDpCode:@"unlock_voice_remote"].length > 0){
        [self.bleDevice fetchRemoteVoiceUnlockWithDevId:self.bleDevice.deviceModel.devId
                                                success:^(id result) {
            [weakSelf_ThingSDK.remoteSettingView setVoiceHidden:NO];
            [weakSelf_ThingSDK.remoteSettingView setVoiceValue:[result boolValue]];
        } failure:^(NSError *error) {
            [weakSelf_ThingSDK.remoteSettingView setVoiceHidden:YES];
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取远程语音解锁开关失败" message:error.localizedDescription];
        }];
    }
    else{
        [self.remoteSettingView setVoiceHidden:YES];
        [Alert showBasicAlertOnVC:self withTitle:@"设备不支持dpCode:unlock_voice_remote" message:@""];
    }
}

#pragma mark - TuyaLockDeviceRemoteSettingViewDelegate

- (void)remoteSwitchAction:(BOOL)value{
    WEAKSELF_ThingSDK
    NSString *dataStr = @"{\"UNLOCK_PHONE_REMOTE\":\"true\"}";
    if (!value){
        dataStr = @"{\"UNLOCK_PHONE_REMOTE\":\"false\"}";
    }
    [self.bleDevice setRemoteUnlockTypeWithDevId:self.bleDevice.deviceModel.devId
                                         propKvs:dataStr
                                         success:^(id result) {
        
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程解锁设置失败" message:error.localizedDescription];
    }];
}

- (void)voiceSwitchAction:(BOOL)value{
    if (value){
        TuyaLockDeviceSetRemoteVoicePasswordViewController *vc = [[TuyaLockDeviceSetRemoteVoicePasswordViewController alloc] init];
        vc.bleDevice = self.bleDevice;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -

- (NSString *)getDpIdWithDpCode:(NSString *)code {
    for (ThingSmartSchemaModel *schema in self.bleDevice.deviceModel.schemaArray) {
        if ([schema.code isEqualToString:code]) {
            return schema.dpId;
        }
    }
    
    return nil;
}


@end
