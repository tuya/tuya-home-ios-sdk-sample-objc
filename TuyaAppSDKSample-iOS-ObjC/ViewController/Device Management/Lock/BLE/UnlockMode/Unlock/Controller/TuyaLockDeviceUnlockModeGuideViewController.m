//
//  TuyaLockDeviceFingerGuideViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeGuideViewController.h"
#import "TuyaLockDeviceUnlockModeGuideView.h"
#import "Alert.h"
#import "TuyaLockDeviceUnlockModeEntryViewController.h"
#import "TuyaLockDeviceUnlockModeListViewController.h"

@interface TuyaLockDeviceUnlockModeGuideViewController ()<TuyaLockDeviceUnlockModeGuideViewDelegate>

@property (nonatomic, strong) TuyaLockDeviceUnlockModeGuideView *guideView;
@property (nonatomic, assign) BOOL tyabitmqxx;

@end

@implementation TuyaLockDeviceUnlockModeGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tyabitmqxx = YES;
    self.guideView = [[TuyaLockDeviceUnlockModeGuideView alloc] initWithFrame:self.view.bounds];
    self.guideView.delegate = self;
    [self.view addSubview:self.guideView];
    
    if (self.unlockModeType == ThingUnlockOpTypeFinger){
        self.title = @"添加指纹";
        [self.guideView reloadTitle:@"如何采集指纹" tipsStr:@"首先，根据提示找到门锁指纹传感器。再使用同一根手指完整触摸多次指纹识别区，并覆盖在识别区5s以上"];
    }
    else if (self.unlockModeType == ThingUnlockOpTypeCard){
        self.title = @"添加门卡";
        [self.guideView reloadTitle:@"如何采集门卡" tipsStr:@"首先，将需要激活的门卡在27s内，找到图示感应区域，直至绿灯闪烁2次，听到长鸣后，即激活成功；如果看到红灯闪烁，则激活失败，需要重试"];
    }
    else if (self.unlockModeType == ThingUnlockOpTypePassword){
        self.title = @"添加密码";
        [self.guideView reloadTitle:@"如何添加密码" tipsStr:@"根据提示在门锁上录入密码"];
    }
    
    WEAKSELF_ThingSDK
    if ([self isZigbeeDevice]){
        [self.zigbeeDevice getLockDeviceConfigWithProductId:self.zigbeeDevice.deviceModel.productId options:@"uiContent,cloudDp,powerCode" success:^(id result) {
            if (!result){
                weakSelf_ThingSDK.tyabitmqxx = NO;
            }
            else{
                NSDictionary *powerCode = result[@"powerCode"];
                if (powerCode[@"tyabitmqxx"]){
                    weakSelf_ThingSDK.tyabitmqxx = [powerCode[@"tyabitmqxx"] boolValue];
                }
            }
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加密码失败" message:error.localizedDescription];
        }];
    }
}

#pragma mark - TuyaLockDeviceUnlockModeGuideViewDelegate

- (void)startToEntry{
    if([self isBLEDevice]){
        if (![self.bleDevice isBLEConnected]){
            [Alert showBasicAlertOnVC:self withTitle:@"蓝牙连接中" message:@""];
            [[ThingSmartBLEManager sharedInstance] connectBLEWithUUID:self.bleDevice.deviceModel.uuid
                                                          productKey:self.bleDevice.deviceModel.productId success:^{
                [Alert showBasicAlertOnVC:self withTitle:@"连接成功" message:@""];
            } failure:^{
                [Alert showBasicAlertOnVC:self withTitle:@"连接失败" message:@""];
            }];
            return;
        }
        
        [self gotoEntryVC];
    }
    
    if ([self isZigbeeDevice]){
        [self gotoEntryVC];
    }
}

- (void)gotoEntryVC{
    WEAKSELF_ThingSDK
    if ([self isZigbeeDevice] && self.unlockModeType == ThingUnlockOpTypePassword){
        BOOL isAdmin = (self.userType == 10 || self.userType == 50) ? YES : NO;
        if (self.tyabitmqxx){
            [self.zigbeeDevice addUnlockOpmodeForMemberWithDevId:self.devId
                                                         isAdmin:isAdmin
                                                    unlockOpType:self.unlockModeType unlockDpCode:@"unlock_password"
                                                      lockUserId:self.lockUserId
                                                          userId:self.memberId
                                                      unlockName:@"zigbee密码测试-01"
                                                   needHijacking:NO
                                                         success:^(id result) {
                [weakSelf_ThingSDK gotoUnlockModeListVC];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加密码失败" message:error.localizedDescription];
            }];
        }
        else{
            [self enterPwd];
        }
        
        return;
    }
    
    TuyaLockDeviceUnlockModeEntryViewController *vc = [[TuyaLockDeviceUnlockModeEntryViewController alloc] init];
    vc.devId = self.devId;
    vc.unlockModeType = self.unlockModeType;
    vc.userType = self.userType;
    vc.lockUserId = self.lockUserId;
    [self.navigationController pushViewController:vc animated:YES];
    
    if (self.unlockModeType == ThingUnlockOpTypeFinger){
        if ([self isBLEDevice]){
            [self.bleDevice addFingerPrintForMemberWithMemberId:self.memberId
                                                     unlockName:@"指纹测试"
                                                  needHijacking:NO
                                                        success:^(NSString *result) {
                [weakSelf_ThingSDK gotoUnlockModeListVC];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加指纹失败" message:error.localizedDescription];
            }];
        }
        
        if ([self isZigbeeDevice]){
            BOOL isAdmin = (self.userType == 10 || self.userType == 50) ? YES : NO;
            [self.zigbeeDevice addUnlockOpmodeForMemberWithDevId:self.devId 
                                                         isAdmin:isAdmin
                                                    unlockOpType:self.unlockModeType unlockDpCode:@"unlock_fingerprint"
                                                      lockUserId:self.lockUserId
                                                          userId:self.memberId
                                                      unlockName:@"zigbee指纹测试"
                                                   needHijacking:NO
                                                         success:^(id result) {
                [weakSelf_ThingSDK gotoUnlockModeListVC];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加指纹失败" message:error.localizedDescription];
            }];
        }
    }
    else if (self.unlockModeType == ThingUnlockOpTypeCard){
        if ([self isBLEDevice]){
            [self.bleDevice addCardForMemberWithMemberId:self.memberId
                                              unlockName:@"卡片测试"
                                           needHijacking:NO
                                                 success:^(NSString *result) {
                [weakSelf_ThingSDK gotoUnlockModeListVC];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加卡片失败" message:error.localizedDescription];
            }];
        }
        
        if ([self isZigbeeDevice]){
            BOOL isAdmin = (self.userType == 10 || self.userType == 50) ? YES : NO;
            [self.zigbeeDevice addUnlockOpmodeForMemberWithDevId:self.devId
                                                         isAdmin:isAdmin
                                                    unlockOpType:self.unlockModeType unlockDpCode:@"unlock_card"
                                                      lockUserId:self.lockUserId
                                                          userId:self.memberId
                                                      unlockName:@"zigbee卡片测试"
                                                   needHijacking:NO
                                                         success:^(id result) {
                [weakSelf_ThingSDK gotoUnlockModeListVC];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加卡片失败" message:error.localizedDescription];
            }];
        }
    }
}

- (void)gotoUnlockModeListVC{
    NSArray *arrayVC = self.navigationController.viewControllers;
    for (UIViewController *vc in arrayVC) {
        if ([vc isKindOfClass:[TuyaLockDeviceUnlockModeListViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceUnlockModeListRefresh" object:nil];
}

- (void)enterPwd{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请输入密码"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        NSString *pwdString = alert.textFields.firstObject.text;
        if (pwdString.length > 0){
            WEAKSELF_ThingSDK
            BOOL isAdmin = (self.userType == 10 || self.userType == 50) ? YES : NO;
            [self.zigbeeDevice addPasswordOpmodeForMemberWithDevId:self.devId
                                                           isAdmin:isAdmin
                                                          password:pwdString
                                                        lockUserId:self.lockUserId
                                                            userId:self.memberId
                                                        unlockName:@"zigbee密码测试-08"
                                                     needHijacking:NO
                                                           success:^(id result) {
                [weakSelf_ThingSDK gotoUnlockModeListVC];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加密码失败" message:error.localizedDescription];
            }];
        }else{
            [Alert showBasicAlertOnVC:self withTitle:@"请输入密码" message:@""];
        }
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"密码内容";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];
        
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
