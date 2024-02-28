//
//  TuyaLockDeviceUnlockModePasswordViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModePasswordViewController.h"
#import "TuyaLockDeviceUnlockModePasswordView.h"
#import "Alert.h"

@interface TuyaLockDeviceUnlockModePasswordViewController ()

@property (nonatomic, strong) TuyaLockDeviceUnlockModePasswordView *pwdView;
@property (nonatomic, strong) NSDictionary *dataSource;

@end

@implementation TuyaLockDeviceUnlockModePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pwdView = [[TuyaLockDeviceUnlockModePasswordView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.pwdView];
    
    if (self.isEdit){
        self.title = @"修改密码";
        [self reloadData];
    }
    else{
        self.title = @"添加密码";
    }
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

- (void)reloadData{
    WEAKSELF_ThingSDK
    [self.bleDevice getProUnlockOpModeDetailWithDevId:self.bleDevice.deviceModel.devId
                                                        opModeId:self.model.opmodeId
                                                         success:^(id result) {
        weakSelf_ThingSDK.model = [ThingSmartBLELockOpmodeModel yy_modelWithJSON:result];
        [weakSelf_ThingSDK.pwdView reloadData:weakSelf_ThingSDK.model];
        weakSelf_ThingSDK.dataSource = result;
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取详情失败" message:error.localizedDescription];
    }];
}

- (void)saveAction{
    if (self.pwdView.nameTextField.text.length == 0){
        [Alert showBasicAlertOnVC:self withTitle:@"请输入密码名称" message:@""];
        return;
    }
        
    WEAKSELF_ThingSDK
    if (self.isEdit){
        if (![self.pwdView.nameTextField.text isEqualToString:self.model.unlockName] && self.pwdView.password.length == 0){
            if ([self.bleDevice.deviceModel.categoryCode isEqualToString:@"jtmspro_2b_2"]){
                [self.bleDevice updateProMemberOpmodeWithDevId:self.bleDevice.deviceModel.devId
                                                      opModeId:self.model.opmodeId
                                                    unlockName:self.pwdView.nameTextField.text
                                                 needHijacking:NO
                                                       appSend:NO
                                                       success:^(id result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改信息失败" message:error.localizedDescription];
                }];
            }
            else{
                [self.bleDevice updateMemberOpmodeWithMemberId:self.memberId
                                                      opmodeId:self.model.opmodeId
                                                    unlockName:self.pwdView.nameTextField.text
                                                       success:^(BOOL result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改信息失败" message:error.localizedDescription];
                }];
            }
        }
        
        if (self.pwdView.swBtn.isOn != self.model.unlockAttr){
            //添加劫持
            if (self.pwdView.swBtn.isOn){
                [self.bleDevice addHijackingConfigWithDevId:self.bleDevice.deviceModel.devId
                                                       dpId:self.model.opmode
                                                    dpValue:[self.dataSource[@"unlockId"] stringValue]
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
                                                       dpValue:[self.dataSource[@"unlockId"] stringValue]
                                                       success:^(id result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改信息失败" message:error.localizedDescription];
                }];
            }
        }
        
        if (self.pwdView.password.length > 0){
            if (self.pwdView.password.length == 0 || self.pwdView.password.length > 10 || self.pwdView.password.length < 6){
                [Alert showBasicAlertOnVC:self withTitle:@"输入密码有错" message:@""];
                return;
            }

            //Pro门锁
            if ([self.bleDevice.deviceModel.categoryCode isEqualToString:@"jtmspro_2b_2"]){
                [self.bleDevice modifyProUnlockOpModeForMemberWithMemberId:self.memberId
                                                                  opmodeId:self.model.opmodeId
                                                                   isAdmin:[self.dataSource[@"admin"] intValue]
                                                                firmwareId:[self.model.opmodeValue intValue]
                                                              unlockDpCode:@"unlock_password"
                                                              unlockOpType:ThingUnlockOpTypePassword
                                                                unlockName:self.pwdView.nameTextField.text
                                                             effectiveDate:nil
                                                               invalidDate:nil
                                                                     times:0
                                                                dataLength:(int)self.pwdView.password.length
                                                               dataContent:self.pwdView.password timeout:5
                                                             needHijacking:self.pwdView.swBtn.isOn
                                                                   appSend:NO
                                                                   success:^(BOOL result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改密码失败" message:error.localizedDescription];
                }];
            }
            else{
                [self.bleDevice modifyUnlockOpmodeForMemberWithMemberId:self.memberId
                                                               opmodeId:self.model.opmodeId
                                                                isAdmin:[self.dataSource[@"admin"] intValue]
                                                             firmwareId:[self.model.opmodeValue intValue]
                                                           unlockDpCode:@"unlock_password"
                                                           unlockOpType:ThingUnlockOpTypePassword
                                                             unlockName:self.pwdView.nameTextField.text
                                                          effectiveDate:nil
                                                            invalidDate:nil
                                                                  times:0
                                                             dataLength:(int)self.pwdView.password.length
                                                            dataContent:self.pwdView.password
                                                                timeout:5
                                                          needHijacking:self.pwdView.swBtn.isOn
                                                                success:^(BOOL result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改密码失败" message:error.localizedDescription];
                }];
            }
        }
    }else{
        //Pro门锁
        if ([self.bleDevice.deviceModel.categoryCode isEqualToString:@"jtmspro_2b_2"]){
            [self.bleDevice addProUnlockOpModeForMemberWithMemberId:self.memberId
                                                            isAdmin:NO
                                                       unlockDpCode:@"unlock_password"
                                                       unlockOpType:ThingUnlockOpTypePassword
                                                         unlockName:self.pwdView.nameTextField.text
                                                      effectiveDate:nil
                                                        invalidDate:nil
                                                              times:0
                                                         dataLength:(int)self.pwdView.password.length
                                                        dataContent:self.pwdView.password
                                                            timeout:5
                                                      needHijacking:self.pwdView.swBtn.isOn
                                                            appSend:NO
                                                            success:^(id result) {
                [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加密码失败" message:error.localizedDescription];
            }];
        }
        else{
            [self.bleDevice addPasswordForMemberWithMemberId:self.memberId
                                                    password:self.pwdView.password
                                                  unlockName:self.pwdView.nameTextField.text
                                               needHijacking:self.pwdView.swBtn.isOn
                                                     success:^(NSString *result) {
                [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加密码失败" message:error.localizedDescription];
            }];
        }
    }
}

@end
