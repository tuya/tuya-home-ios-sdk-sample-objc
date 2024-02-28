//
//  TuyaLockDevicePasswordDetailViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDevicePasswordDetailViewController.h"
#import "TuyaLockDeviceCycleView.h"
#import "Alert.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDevicePasswordDetailViewController ()<TuyaLockDeviceOffinePwdViewDelegate>

@property (nonatomic, strong) TuyaLockDeviceCycleView *cycleView;//周期view
@property (nonatomic, strong) TuyaLockDevicePwdInfoView *pwdInfoView;//密码信息view
@property (nonatomic, strong) TuyaLockDeviceOffinePwdView *offlinePwdView;//离线密码view
@property (nonatomic, strong) UIButton *saveBtn;//保存按钮

@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示
@property (strong, nonatomic) UIButton *clearResultBtn;//结果清除按钮

@end


@implementation TuyaLockDevicePasswordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)setupViews{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(kResultLabelMargin, [UIScreen mainScreen].bounds.size.height - kResultLabelHeight, [UIScreen mainScreen].bounds.size.width - 2*kResultLabelMargin, kResultLabelHeight)];
    self.resultLabel.backgroundColor = [UIColor whiteColor];
    self.resultLabel.textColor = [UIColor blueColor];
    self.resultLabel.font = [UIFont systemFontOfSize:20];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.hidden = YES;
    self.resultLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.resultLabel];
    
    self.clearResultBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.resultLabel.frame.size.width - 100,0,100, 40)];
    self.clearResultBtn.backgroundColor = [UIColor redColor];
    [self.clearResultBtn setTitle:@"清除结果" forState:UIControlStateNormal];
    [self.clearResultBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.clearResultBtn addTarget:self action:@selector(clearResultBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.resultLabel addSubview:self.clearResultBtn];
    
    self.pwdInfoView = [[TuyaLockDevicePwdInfoView alloc] initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, viewHeight * 4)];
    [self.view addSubview:self.pwdInfoView];
    
    self.cycleView = [[TuyaLockDeviceCycleView alloc] initWithFrame:CGRectMake(0, 150 + viewHeight * 4 + 20, self.view.bounds.size.width, viewHeight * 7)];
    [self.view addSubview:self.cycleView];
    
    self.offlinePwdView = [[TuyaLockDeviceOffinePwdView alloc] initWithFrame:CGRectMake(0, 200, self.view.bounds.size.width, 400)];
    self.offlinePwdView.delegate = self;
    [self.offlinePwdView reloadView:self.pwdType];
    [self.view addSubview:self.offlinePwdView];
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, self.view.bounds.size.height - 100, 100, 50)];
    self.saveBtn.backgroundColor = [UIColor redColor];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.saveBtn];
    
    if (self.pwdType == PasswordType_OldOnlineOnce
        || self.pwdType == PasswordType_OldOnlineCycle
        || self.pwdType == PasswordType_ProOnlineCycle){
        self.offlinePwdView.hidden = YES;
        if (self.pwdType == PasswordType_OldOnlineOnce){
            self.cycleView.hidden = YES;
        }
    }
    else{
        self.pwdInfoView.hidden = YES;
        self.cycleView.hidden = YES;
        self.saveBtn.hidden = YES;
    }

    if (self.actionType == PasswordActionType_Modify){
        if (self.pwdType == PasswordType_OldOnlineOnce
            || self.pwdType == PasswordType_OldOnlineCycle
            || self.pwdType == PasswordType_ProOnlineCycle){
            self.cycleView.hidden = NO;
        }else{
            self.cycleView.hidden = YES;
        }
        
        [self.pwdInfoView reloadPwdName:[self.pwdDic[@"name"] stringValue]
                               pwdValue:@"密码无法修改"
                          effectiveTime:[self.pwdDic[@"effectiveTime"] integerValue]
                            invalidTime:[self.pwdDic[@"invalidTime"] integerValue]];
        
        [self.cycleView reloadData:self.pwdDic];
    }
}

#pragma mark - TuyaLockDeviceOffinePwdViewDelegate

- (void)addOfflinePasswordActionWithEffectiveTime:(NSInteger)effectiveTime invalidTime:(NSInteger)invalidTime{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"输入密码名称"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        NSString *pwdName = alert.textFields.firstObject.text;
        if (pwdName.length > 0){
            [self addOfflinePasswordWithName:pwdName effectiveTime:effectiveTime invalidTime:invalidTime];
        }else{
            [Alert showBasicAlertOnVC:self withTitle:@"请输入密码名称" message:@""];
        }
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"密码名称";
    }];
        
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addOfflinePasswordWithName:(NSString *)name effectiveTime:(NSInteger)effectiveTime invalidTime:(NSInteger)invalidTime{
    WEAKSELF_ThingSDK
    if (self.pwdType == PasswordType_OldOfflineOnce){
        [self.bleDevice getOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                            pwdType:@"1"
                                           gmtStart:0
                                         gmtExpired:0
                                            pwdName:name
                                            success:^(id result) {
            [weakSelf_ThingSDK showPwdInfo:result];
//            [self showResultLabel:[NSString stringWithFormat:@"value is %@", (NSDictionary *)result]];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
        }];
    }
    else if (self.pwdType == PasswordType_OldOfflineTimes){
        [self.bleDevice getOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                            pwdType:@"0"
                                           gmtStart:effectiveTime
                                         gmtExpired:invalidTime
                                            pwdName:name
                                            success:^(id result) {
//            [self showResultLabel:[NSString stringWithFormat:@"value is %@", (NSDictionary *)result]];
            [weakSelf_ThingSDK showPwdInfo:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
        }];
    }
    else if (self.pwdType == PasswordType_OldOfflineEmptyAll){
        [self.bleDevice getOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                            pwdType:@"9"
                                           gmtStart:0
                                         gmtExpired:0
                                            pwdName:name
                                            success:^(id result) {
//            [self showResultLabel:[NSString stringWithFormat:@"value is %@", (NSDictionary *)result]];
            [weakSelf_ThingSDK showPwdInfo:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
        }];
    }
    else if (self.pwdType == PasswordType_ProOfflineOnce){
        [self.bleDevice getProOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                               pwdType:@"1"
                                              gmtStart:0
                                            gmtExpired:0
                                               pwdName:name
                                               success:^(id result) {
            [weakSelf_ThingSDK showPwdInfo:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
        }];
    }
    else if (self.pwdType == PasswordType_ProOfflineTimes){
        [self.bleDevice getProOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                               pwdType:@"0"
                                              gmtStart:effectiveTime
                                            gmtExpired:invalidTime
                                               pwdName:name
                                               success:^(id result) {
            [weakSelf_ThingSDK showPwdInfo:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
        }];
    }
    else if (self.pwdType == PasswordType_ProOfflineEmptyAll){
        [self.bleDevice getProOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                               pwdType:@"9"
                                              gmtStart:0
                                            gmtExpired:0
                                               pwdName:name
                                               success:^(id result) {
            [weakSelf_ThingSDK showPwdInfo:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
        }];
    }
}

- (void)showPwdInfo:(id)result{
    if (result && [result isKindOfClass:[NSDictionary class]]){
        NSDictionary *dicValue = (NSDictionary *)result;
        [self.offlinePwdView showPwdInfo:dicValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDevicePasswordListRefresh" object:nil];
    }
}

- (void)modifyPwdName:(NSString *)pwdName{
    
}
    
#pragma mark - action

- (void)saveBtnClicked:(UIButton *)btn{
    if (![self.bleDevice isBLEConnected]){
        [Alert showBasicAlertOnVC:self withTitle:@"蓝牙已断开" message:@""];
        return;
    }
    
    NSString *password = [self.pwdInfoView getPwdValue];
    if (password.length > 10 || password.length < 5){
        [Alert showBasicAlertOnVC:self withTitle:@"密码长度错误" message:@"请输入6-10位密码"];
        return;
    }
    
    WEAKSELF_ThingSDK
    if (self.actionType == PasswordActionType_Add){
        if (self.pwdType == PasswordType_OldOnlineOnce){
            ThingSmartBLELockScheduleList *listModel = [[ThingSmartBLELockScheduleList alloc] init];
            [self.bleDevice getCustomOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                         name:[self.pwdInfoView getPwdName]
                                                effectiveTime:[self.pwdInfoView getEffectiveTime]
                                                  invalidTime:[self.pwdInfoView getInvalidTime]
                                                     password:password
                                                     schedule:listModel
                                                    availTime:1
                                                           sn:0
                                                      success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"创建成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
            }];
        }
        else if (self.pwdType == PasswordType_OldOnlineCycle){
            ThingSmartBLELockScheduleList *listModel = [self.cycleView getScheduleListModel];
            [self.bleDevice getCustomOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                         name:[self.pwdInfoView getPwdName]
                                                effectiveTime:[self.pwdInfoView getEffectiveTime]
                                                  invalidTime:[self.pwdInfoView getInvalidTime]
                                                     password:password
                                                     schedule:listModel
                                                    availTime:0
                                                           sn:0
                                                      success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"创建成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
            }];
        }
        else if (self.pwdType == PasswordType_ProOnlineCycle){
            ThingSmartBLELockScheduleList *listModel = [self.cycleView getScheduleListModel];
            [self.bleDevice getProCustomOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                           name:[self.pwdInfoView getPwdName]
                                                       password:password
                                                  effectiveTime:[self.pwdInfoView getEffectiveTime]
                                                    invalidTime:[self.pwdInfoView getInvalidTime]
                                                      availTime:0
                                                             sn:0
                                                       schedule:listModel
                                                        success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"创建成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建失败" message:error.localizedDescription];
            }];
        }
    }
    else if (self.actionType == PasswordActionType_Modify){
        if (self.pwdType == PasswordType_OldOnlineOnce){
            ThingSmartBLELockScheduleList *listModel = [self.cycleView getScheduleListModel];
            [self.bleDevice updateOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                     name:[self.pwdInfoView getPwdName]
                                                 password:@""
                                                    pwdId:[self.pwdDic[@"id"] integerValue]
                                            effectiveTime:[self.pwdInfoView getEffectiveTime]
                                              invalidTime:[self.pwdInfoView getInvalidTime]
                                                 schedule:listModel
                                                       sn:[self.pwdDic[@"sn"] integerValue]
                                                availTime:1
                                                  success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"修改成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改失败" message:error.localizedDescription];
            }];
        }
        else if (self.pwdType == PasswordType_OldOnlineCycle){
            ThingSmartBLELockScheduleList *listModel = [self.cycleView getScheduleListModel];
            [self.bleDevice updateOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                     name:@""
                                                 password:@""
                                                    pwdId:[self.pwdDic[@"id"] integerValue]
                                            effectiveTime:[self.pwdInfoView getEffectiveTime]
                                              invalidTime:[self.pwdInfoView getInvalidTime]
                                                 schedule:listModel
                                                       sn:[self.pwdDic[@"sn"] integerValue]
                                                availTime:0
                                                  success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"修改成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改失败" message:error.localizedDescription];
            }];
        }
        if (self.pwdType == PasswordType_ProOnlineCycle){
            ThingSmartBLELockScheduleList *listModel = [self.cycleView getScheduleListModel];
            [self.bleDevice updateProOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                        name:[self.pwdInfoView getPwdName]
                                                    password:@""
                                             unlockBindingId:[self.pwdDic[@"unlockBindingId"] integerValue]
                                               effectiveTime:[self.pwdInfoView getEffectiveTime]
                                                 invalidTime:[self.pwdInfoView getInvalidTime]
                                                       phase:2
                                                    schedule:listModel
                                                          sn:1
                                                     success:^(id result) {
                [weakSelf_ThingSDK showAlertOcVC:@"修改成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"修改失败" message:error.localizedDescription];
            }];
        }
    }
}

- (void)showAlertOcVC:(NSString *)title message:(NSString *)message{
    [Alert showBasicAlertOnVC:self withTitle:title message:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDevicePasswordListRefresh" object:nil];
}

- (void)showResultLabel:(NSString *)text{
    self.resultLabel.text = text;
    self.resultLabel.hidden = NO;
}

- (void)clearResultBtnClicked:(UIButton *)btn{
    self.resultLabel.hidden = YES;
}

@end
