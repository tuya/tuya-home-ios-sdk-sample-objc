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

- (void)saveAction{
    if (self.modifyView.nameTextField.text.length == 0){
        [Alert showBasicAlertOnVC:self withTitle:@"请输入卡片名称" message:@""];
        return;
    }
    
    WEAKSELF_ThingSDK
    if (![self.modifyView.nameTextField.text isEqualToString:self.model.unlockName]){
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
    
    if (self.modifyView.swBtn.isOn != self.model.unlockAttr){
        //添加劫持
        if (self.modifyView.swBtn.isOn){
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
        //移除劫持
        else{
            [self.bleDevice removeHijackingConfigWithDevId:self.bleDevice.deviceModel.devId
                                                      dpId:self.model.opmode
                                                   dpValue:self.dpValue
                                                   success:^(id result) {
                [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改信息失败" message:error.localizedDescription];
            }];
        }
    }
}

@end
