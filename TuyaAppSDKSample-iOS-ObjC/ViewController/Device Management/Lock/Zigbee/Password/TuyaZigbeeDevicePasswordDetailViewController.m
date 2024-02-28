//
//  TuyaZigbeeDevicePasswordDetailViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaZigbeeDevicePasswordDetailViewController.h"
#import "TuyaZigbeeDeviceOncePasswordView.h"
#import "TuyaLockDeviceCycleView.h"
#import "Alert.h"

@interface TuyaZigbeeDevicePasswordDetailViewController ()<TuyaZigbeeDeviceOncePasswordViewDelegate>

@property (nonatomic, strong) TuyaZigbeeDeviceOncePasswordView *oncePwd;
@property (nonatomic, strong) TuyaLockDeviceCycleView *cycleView;
@property (nonatomic, strong) TuyaLockDevicePwdInfoView *pwdInfoView;
@property (nonatomic, strong) UIButton *saveBtn;//保存按钮

@end

@implementation TuyaZigbeeDevicePasswordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.pwdType == PasswordType_ZigbeeTempOne){
        self.oncePwd = [[TuyaZigbeeDeviceOncePasswordView alloc] initWithFrame:self.view.bounds];
        self.oncePwd.delegate = self;
        [self.view addSubview:self.oncePwd];
    }
    
    if (self.pwdType == PasswordType_ZigbeeTempCycle){
        self.pwdInfoView = [[TuyaLockDevicePwdInfoView alloc] initWithFrame:CGRectMake(0, 120, self.view.bounds.size.width, 40 * 4)];
        self.cycleView = [[TuyaLockDeviceCycleView alloc] initWithFrame:CGRectMake(0, 120 + 40 * 4 + 20, self.view.bounds.size.width, 40 * 7)];
        self.cycleView.isZigbee = YES;
        
        self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, self.view.bounds.size.height - 100, 100, 50)];
        self.saveBtn.backgroundColor = [UIColor redColor];
        [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [self.saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.pwdInfoView];
        [self.view addSubview:self.cycleView];
        [self.view addSubview:self.saveBtn];
        
        if (self.actionType == PasswordActionType_Modify){
            [self.pwdInfoView reloadPwdName:[self.pwdDic[@"name"] stringValue]
                                   pwdValue:@"密码无法修改"
                              effectiveTime:[self.pwdDic[@"effectiveTime"] integerValue]/1000
                                invalidTime:[self.pwdDic[@"invalidTime"] integerValue]/1000];
            
            [self.cycleView reloadData:self.pwdDic];
        }
    }
}

- (void)showAlertOcVC:(NSString *)title message:(NSString *)message{
    [Alert showBasicAlertOnVC:self withTitle:title message:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigbeeDevicePasswordListRefresh" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveBtnClicked{
    WEAKSELF_ThingSDK
    if (self.pwdType == PasswordType_ZigbeeTempCycle){
        if (self.actionType == PasswordActionType_Add){
            ThingSmartBLELockScheduleList *listModel = [self.cycleView getScheduleListModel];
            [self.zigbeeDevice addTemporaryPasswordWithDevId:self.devId
                                                        name:[self.pwdInfoView getPwdName]
                                               effectiveTime:[self.pwdInfoView getEffectiveTime]*1000
                                                 invalidTime:[self.pwdInfoView getInvalidTime]*1000
                                                    password:[self.pwdInfoView getPwdValue]
                                                    schedule:listModel.scheduleList.yy_modelToJSONString
                                                     oneTime:0
                                                     success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"创建密码成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建密码失败" message:error.localizedDescription];
            }];
        }
        
        if (self.actionType == PasswordActionType_Modify){
            ThingSmartBLELockScheduleList *listModel = [self.cycleView getScheduleListModel];
            [self.zigbeeDevice modifyTemporaryPasswordWithDevId:self.devId
                                                          pwdId:[self.pwdDic[@"id"] integerValue] name:[self.pwdInfoView getPwdName]
                                                  effectiveTime:[self.pwdInfoView
                                                                 getEffectiveTime]*1000
                                                    invalidTime:[self.pwdInfoView getInvalidTime]*1000
                                                       schedule:listModel.scheduleList.yy_modelToJSONString
                                                        oneTime:[self.pwdDic[@"oneTime"] intValue]
                                                        success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"更新密码成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"更新密码失败" message:error.localizedDescription];
            }];
        }
    }
}

#pragma mark - TuyaZigbeeDeviceOncePasswordViewDelegate

- (void)createOncePwd:(NSString *)name{
    if (self.pwdType == PasswordType_ZigbeeTempOne){
        WEAKSELF_ThingSDK
        [self.zigbeeDevice addTemporaryPasswordWithDevId:self.devId
                                                    name:name
                                           effectiveTime:0
                                             invalidTime:0
                                                password:@""
                                                schedule:@""
                                                 oneTime:1
                                                 success:^(id result) {
            [weakSelf_ThingSDK showAlertOcVC:@"创建密码成功" message:@""];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建密码失败" message:error.localizedDescription];
        }];
    }
}

@end
