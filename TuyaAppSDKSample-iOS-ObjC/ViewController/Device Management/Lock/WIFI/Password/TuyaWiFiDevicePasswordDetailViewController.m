//
//  TuyaWiFiDevicePasswordDetailViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiDevicePasswordDetailViewController.h"
#import "TuyaLockDeviceCycleView.h"
#import "Alert.h"

@interface TuyaWiFiDevicePasswordDetailViewController ()

@property (nonatomic, strong) TuyaLockDevicePwdInfoView *pwdInfoView;
@property (nonatomic, strong) UIButton *saveBtn;//保存按钮

@end

@implementation TuyaWiFiDevicePasswordDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.pwdInfoView = [[TuyaLockDevicePwdInfoView alloc] initWithFrame:CGRectMake(0, 120, self.view.bounds.size.width, 40 * 4)];
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-100)/2, self.view.bounds.size.height - 100, 100, 50)];
    self.saveBtn.backgroundColor = [UIColor redColor];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.pwdInfoView];
    [self.view addSubview:self.saveBtn];
}

- (void)showAlertOcVC:(NSString *)title message:(NSString *)message{
    [Alert showBasicAlertOnVC:self withTitle:title message:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WiFiDevicePasswordListRefresh" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveBtnClicked{
    WEAKSELF_ThingSDK
    [self.wifiDevice createLockTempPwd:[self.pwdInfoView getPwdValue]
                                  name:[self.pwdInfoView getPwdName]
                         effectiveDate:[self.pwdInfoView getEffectiveDate]
                           invalidDate:[self.pwdInfoView getInvalidDate]
                               success:^(BOOL result) {
        [weakSelf_ThingSDK showAlertOcVC:@"创建密码成功" message:@""];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建密码失败" message:error.localizedDescription];
    }];
}

@end
