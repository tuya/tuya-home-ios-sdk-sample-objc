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

@end

@implementation TuyaLockDeviceUnlockModeGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //密码
    if (self.unlockModeType == 1){
        self.title = @"添加密码";
        
    }
    else{
        self.guideView = [[TuyaLockDeviceUnlockModeGuideView alloc] initWithFrame:self.view.bounds];
        self.guideView.delegate = self;
        [self.view addSubview:self.guideView];
        
        if (self.unlockModeType == 0){
            self.title = @"添加指纹";
            [self.guideView reloadTitle:@"如何采集指纹" tipsStr:@"首先，根据提示找到门锁指纹传感器。再使用同一根手指完整触摸多次指纹识别区，并覆盖在识别区5s以上"];
        }
        else if (self.unlockModeType == 2){
            self.title = @"添加门卡";
            [self.guideView reloadTitle:@"如何采集门卡" tipsStr:@"首先，将需要激活的门卡在27s内，找到图示感应区域，直至绿灯闪烁2次，听到长鸣后，即激活成功；如果看到红灯闪烁，则激活失败，需要重试"];
        }

    }
}

#pragma mark - TuyaLockDeviceUnlockModeGuideViewDelegate

- (void)startToEntry{
    if (![self.bleDevice isBLEConnected]){
        [Alert showBasicAlertOnVC:self withTitle:@"蓝牙连接中" message:@""];
        [self.bleDevice autoConnect];
    }else{
        [self gotoEntryVC];
    }
}

- (void)gotoEntryVC{
    TuyaLockDeviceUnlockModeEntryViewController *vc = [[TuyaLockDeviceUnlockModeEntryViewController alloc] init];
    vc.bleDevice = self.bleDevice;
    vc.unlockModeType = self.unlockModeType;
    vc.userType = self.userType;
    vc.lockUserId = self.lockUserId;
    [self.navigationController pushViewController:vc animated:YES];
    
    WEAKSELF_ThingSDK
    if (self.unlockModeType == 0){
        [self.bleDevice addFingerPrintForMemberWithMemberId:self.memberId
                                                 unlockName:@"指纹测试"
                                              needHijacking:NO
                                                    success:^(NSString *result) {
            [weakSelf_ThingSDK gotoUnlockModeListVC];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加指纹失败" message:error.localizedDescription];
        }];
    }
    else if (self.unlockModeType == 1){
        
    }
    else if (self.unlockModeType == 2){
        [self.bleDevice addCardForMemberWithMemberId:self.memberId
                                          unlockName:@"卡片测试"
                                       needHijacking:NO
                                             success:^(NSString *result) {
            [weakSelf_ThingSDK gotoUnlockModeListVC];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"添加卡片失败" message:error.localizedDescription];
        }];
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

@end
