//
//  TuyaLockDeviceUnlockModeModifyViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeModifyViewController.h"
#import "TuyaLockDeviceUnlockModeModifyView.h"
#import "Alert.h"

@interface TuyaLockDeviceUnlockModeModifyViewController ()

@property (nonatomic, strong) TuyaLockDeviceUnlockModeModifyView *modifyView;
@property (nonatomic, copy)   NSString *dpValue;

@end

@implementation TuyaLockDeviceUnlockModeModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modifyView = [[TuyaLockDeviceUnlockModeModifyView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.modifyView];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    WEAKSELF_ThingSDK
    if ([self isBLEDevice]){
        [self.bleDevice getProUnlockOpModeDetailWithDevId:self.bleDevice.deviceModel.devId
                                                            opModeId:self.model.opmodeId
                                                             success:^(id result) {
            weakSelf_ThingSDK.dpValue = [result[@"unlockId"] stringValue];
            weakSelf_ThingSDK.model = [ThingSmartBLELockOpmodeModel yy_modelWithJSON:result];
            [weakSelf_ThingSDK.modifyView reloadData:weakSelf_ThingSDK.model];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取详情失败" message:error.localizedDescription];
        }];
    }
    
    if ([self isZigbeeDevice]){
        [weakSelf_ThingSDK.modifyView reloadZigbeeData:self.zigbeeModel];
    }
}

- (void)saveAction{
    if (self.modifyView.nameTextField.text.length == 0){
        [Alert showBasicAlertOnVC:self withTitle:@"请输入名称" message:@""];
        return;
    }
    
    WEAKSELF_ThingSDK
    if (![self.modifyView.nameTextField.text isEqualToString:self.model.unlockName]){
        if ([self isBLEDevice]){
            [self.bleDevice updateMemberOpmodeWithMemberId:self.memberId
                                                  opmodeId:self.model.opmodeId
                                                unlockName:self.modifyView.nameTextField.text
                                                   success:^(BOOL result) {
                [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改信息失败" message:error.localizedDescription];
            }];
        }
        
        if ([self isZigbeeDevice]){
            [self.zigbeeDevice modifyUnlockOpmodeForMemberWithDevId:self.devId
                                                           opmodeId:self.zigbeeModel.opmodeId
                                                         unlockName:self.modifyView.nameTextField.text
                                                            success:^(id result) {
                [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改信息失败" message:error.localizedDescription];
            }];
        }
    }
    
    if (self.modifyView.swBtn.isOn != self.model.unlockAttr){
        //添加劫持
        if (self.modifyView.swBtn.isOn){
            if ([self isBLEDevice]){
                [self.bleDevice addHijackingConfigWithDevId:self.bleDevice.deviceModel.devId
                                                       dpId:self.model.opmode
                                                    dpValue:self.dpValue
                                                    success:^(BOOL result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改信息失败" message:error.localizedDescription];
                }];
            }
            
            if ([self isZigbeeDevice]){
                [self.zigbeeDevice addHijackingConfigWithDevId:self.devId 
                                                          dpId:self.zigbeeModel.opmode
                                                      unlockId:self.zigbeeModel.unlockId
                                                       success:^(BOOL result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"设置劫持失败" message:error.localizedDescription];
                }];
            }
        }
        //移除劫持
        else{
            if ([self isBLEDevice]){
                [self.bleDevice removeHijackingConfigWithDevId:self.bleDevice.deviceModel.devId
                                                          dpId:self.model.opmode
                                                       dpValue:self.dpValue
                                                       success:^(id result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"设置劫持失败" message:error.localizedDescription];
                }];
            }
            
            if ([self isZigbeeDevice]){
                [self.zigbeeDevice removeHijackingConfigWithDevId:self.devId 
                                                             dpId:self.zigbeeModel.opmode
                                                         unlockId:self.zigbeeModel.unlockId
                                                          success:^(id result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"设置劫持失败" message:error.localizedDescription];
                }];
            }
        }
    }
}

@end
