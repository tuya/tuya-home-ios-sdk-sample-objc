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
@property (nonatomic, copy) NSString *currentPermission;

@property (nonatomic, assign) ThingRemotePermissionType currentRemotePermissionType;
@property (nonatomic, strong) ThingSmartZigbeeLockRemotePermissionModel *permissionModel;

@end

@implementation TuyaLockDeviceRemoteSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.remoteSettingView = [[TuyaLockDeviceRemoteSettingView alloc] initWithFrame:self.view.bounds];
    self.remoteSettingView.isZigbee = [self isZigbeeDevice];
    self.remoteSettingView.delegate = self;
    [self.view addSubview:self.remoteSettingView];
    
    [self fetchData];
}

- (void)fetchData{
    WEAKSELF_ThingSDK
    if ([self isBLEDevice]){
        if ([self getDpIdWithDpCode:@"remote_no_dp_key"].length > 0){
            [self.bleDevice fetchRemoteUnlockTypeWithDevId:self.devId
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
            [self.bleDevice fetchRemoteVoiceUnlockWithDevId:self.devId
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
    
    if ([self isZigbeeDevice]){
        if ([self getDpIdWithDpCode:@"remote_no_dp_key"].length > 0 || [self getDpIdWithDpCode:@"remote_unlock"].length > 0){
            [self.zigbeeDevice fetchRemoteUnlockTypeWithDevId:self.devId
                                                   success:^(id result) {
                [weakSelf_ThingSDK.remoteSettingView setRemoteHidden:NO];
                BOOL value = [result[@"isRemoteOpen"] boolValue];
                [weakSelf_ThingSDK.remoteSettingView setRemoteValue:value];
            } failure:^(NSError *error) {
                [weakSelf_ThingSDK.remoteSettingView setRemoteHidden:YES];
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取远程解锁开关失败" message:error.localizedDescription];
            }];
        }
        else{
            [self.remoteSettingView setRemoteHidden:YES];
            [Alert showBasicAlertOnVC:self withTitle:@"设备不支持dpCode:remote_no_dp_key和remote_unlock" message:@""];
        }
        
        if ([self getDpIdWithDpCode:@"unlock_voice_remote"].length > 0){
            [self.zigbeeDevice fetchRemoteVoiceUnlockWithDevId:self.devId
                                                    success:^(id result) {
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
        
        if ([self getDpIdWithDpCode:@"remote_no_pd_setkey"].length > 0
            || [self getDpIdWithDpCode:@"remote_unlock"].length > 0){
            WEAKSELF_ThingSDK
            [self.zigbeeDevice getRemoteUnlockPermissionValueWithDevId:self.devId success:^(ThingSmartZigbeeLockRemotePermissionModel * _Nonnull model) {
                weakSelf_ThingSDK.permissionModel = model;
                
                if ([model.way isEqualToString:@"remote_no_dp_key"]
                    && [model.user isEqualToString:@"admin"]){
                    weakSelf_ThingSDK.currentPermission = @"免密-管理员>";
                }
                
                if ([model.way isEqualToString:@"remote_no_dp_key"]
                    && [model.user isEqualToString:@"all"]){
                    weakSelf_ThingSDK.currentPermission = @"免密-所有人>";
                }
                
                if ([model.way isEqualToString:@"remote_unlock"]
                    && [model.user isEqualToString:@"admin"]){
                    weakSelf_ThingSDK.currentPermission = @"含密-管理员>";
                }
                
                if ([model.way isEqualToString:@"remote_unlock"]
                    && [model.user isEqualToString:@"all"]){
                    weakSelf_ThingSDK.currentPermission = @"含密-所有人>";
                }
                
                weakSelf_ThingSDK.remoteSettingView.permissionValue.text = weakSelf_ThingSDK.currentPermission;
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:self withTitle:@"权限设置接口报错" message:error.localizedDescription];
            }];
        }
        else{
            [self.remoteSettingView setRemoteHidden:YES];
            [Alert showBasicAlertOnVC:self withTitle:@"设备不支持dpCode:remote_no_pd_setkey和remote_unlock" message:@""];
        }
    }
}

- (void)permissionRequest{
    if ([self isZigbeeDevice]){
        WEAKSELF_ThingSDK
        [self.zigbeeDevice setRemoteUnlockPermissionValueWithDevId:self.devId remotePermissionType:self.currentRemotePermissionType success:^(id result) {
            weakSelf_ThingSDK.remoteSettingView.permissionValue.text = weakSelf_ThingSDK.currentPermission;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"设置免密失败" message:error.localizedDescription];
        }];
    }
}

#pragma mark - TuyaLockDeviceRemoteSettingViewDelegate

- (void)remoteSwitchAction:(BOOL)value{
    WEAKSELF_ThingSDK
    if ([self isBLEDevice]){
        NSString *dataStr = @"{\"UNLOCK_PHONE_REMOTE\":\"true\"}";
        if (!value){
            dataStr = @"{\"UNLOCK_PHONE_REMOTE\":\"false\"}";
        }
        [self.bleDevice setRemoteUnlockTypeWithDevId:self.devId
                                             propKvs:dataStr
                                             success:^(id result) {
            
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程解锁设置失败" message:error.localizedDescription];
        }];
    }
    
    if ([self isZigbeeDevice]){
        [self.zigbeeDevice setRemoteUnlockTypeWithDevId:self.devId
                                             open:value
                                             success:^(id result) {
            
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程解锁设置失败" message:error.localizedDescription];
        }];
    }
}

- (void)voiceSwitchAction:(BOOL)value{
    if (value){
        TuyaLockDeviceSetRemoteVoicePasswordViewController *vc = [[TuyaLockDeviceSetRemoteVoicePasswordViewController alloc] init];
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)permissionAction{
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"选择远程开门权限" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *mmManagerAction = [UIAlertAction actionWithTitle:@"免密-管理员" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.currentPermission = @"免密-管理员>";
        self.currentRemotePermissionType = ThingRemotePermissionType_NonePwd_Admin;
        [self permissionRequest];
    }];

    UIAlertAction *mmAllAction = [UIAlertAction actionWithTitle:@"免密-所有人" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.currentPermission = @"免密-所有人>";
        self.currentRemotePermissionType = ThingRemotePermissionType_NonePwd_All;
        [self permissionRequest];
    }];
    
    UIAlertAction *hmManagerAllAction = [UIAlertAction actionWithTitle:@"含密-管理员" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.currentPermission = @"含密-管理员>";
        self.currentRemotePermissionType = ThingRemotePermissionType_Pwd_Admin;
        [self permissionRequest];
    }];
    
    UIAlertAction *hmAllAction = [UIAlertAction actionWithTitle:@"含密-所有人" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.currentPermission = @"含密-所有人>";
        self.currentRemotePermissionType = ThingRemotePermissionType_Pwd_All;
        [self permissionRequest];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];

    [alertViewController addAction:mmManagerAction];
    [alertViewController addAction:mmAllAction];
    [alertViewController addAction:hmManagerAllAction];
    [alertViewController addAction:hmAllAction];
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}

@end
