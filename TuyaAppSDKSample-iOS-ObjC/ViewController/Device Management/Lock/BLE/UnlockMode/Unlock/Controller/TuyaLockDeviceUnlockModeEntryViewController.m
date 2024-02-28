//
//  TuyaLockDeviceFingerEntryViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeEntryViewController.h"
#import "TuyaLockDeviceUnlockModeEntryView.h"
#import "Alert.h"

@interface TuyaLockDeviceUnlockModeEntryViewController ()<TuyaLockDeviceUnlockModeEntryErrorViewDelegate,ThingSmartBLELockDeviceDelegate,ThingSmartZigbeeLockDeviceDelegate>

@property (nonatomic, strong) TuyaLockDeviceUnlockModeEntryView *entryView;
@property (nonatomic, strong) TuyaLockDeviceUnlockModeEntryErrorView *errorView;

@end

@implementation TuyaLockDeviceUnlockModeEntryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    self.entryView = [[TuyaLockDeviceUnlockModeEntryView alloc] initWithFrame:self.view.bounds];
    
    self.errorView = [[TuyaLockDeviceUnlockModeEntryErrorView alloc] initWithFrame:self.view.bounds];
    self.errorView.delegate = self;
    self.errorView.hidden = YES;
    [self.view addSubview:self.errorView];
    [self.view addSubview:self.entryView];
    
    [self performSelector:@selector(handleTimeout) withObject:nil afterDelay:30];
    
    if ([self isBLEDevice]){
        self.bleDevice.delegate = self;
    }
    
    if ([self isZigbeeDevice]){
        self.zigbeeDevice.delegate = self;
    }
}

- (void)backAction{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"取消"
                                                                   message:@"确定要取消吗？"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        BOOL isAdmin = (self.userType == 10 || self.userType == 50) ? YES : NO;
        WEAKSELF_ThingSDK
        if ([self isBLEDevice] && self.unlockModeType == ThingUnlockOpTypeFinger){
            if ([self isBLEDevice]){
                [self.bleDevice cancelUnlockOpmodeForFingerWithAdmin:isAdmin
                                                          lockUserId:self.lockUserId
                                                             success:^(BOOL result) {
                    [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"取消录入指纹失败" message:error.localizedDescription];
                    [weakSelf_ThingSDK performSelector:@selector(popVC) withObject:nil afterDelay:2];
                }];
            }
        }
        
        if ([self isZigbeeDevice]){
            [self.zigbeeDevice cancelUnlockOpmodeWithAdmin:isAdmin
                                                lockUserId:self.lockUserId
                                              unlockOpType:self.unlockModeType
                                                   success:^(BOOL result) {
                [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
            }
                                                            failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"取消录入指纹失败" message:error.localizedDescription];
                [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)handleTimeout{
    self.entryView.hidden = YES;
    self.errorView.hidden = NO;
    [self cancelTimeout];
}

- (void)cancelTimeout {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeout) object:nil];
}

- (void)popVC{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TuyaLockDeviceUnlockModeEntryErrorViewDelegate

- (void)retryAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - ThingSmartDeviceDelegate

- (void)device:(ThingSmartDevice *)device dpsUpdate:(NSDictionary *)dps{
    NSString *dpValue, *statusString, *countString;
    if ([self isBLEDevice]){
        dpValue = [dps objectForKey:@"1"];
        if (dpValue.length == 0 || (dpValue.length != 14)) {
            return ;
        }
        
        statusString = [dpValue substringWithRange:NSMakeRange(2, 2)];
        countString = [dpValue substringWithRange:NSMakeRange(10, 2)];
    }
    
    if ([self isZigbeeDevice]){
        dpValue = [dps objectForKey:@"54"];
        if (dpValue.length == 0 || (dpValue.length != 18)) {
            return ;
        }
        
        statusString = [dpValue substringWithRange:NSMakeRange(2, 2)];
        countString = [dpValue substringWithRange:NSMakeRange(14, 2)];
    }
    
    //录入开始
    if ([statusString isEqualToString:@"00"]) {
        //指纹总次数
        int total = [countString intValue];
        [self.entryView reloadStep:0 total:total];
    }
    //录入进行
    else if ([statusString isEqualToString:@"fc"]) {
        //当前次数
        int index = [countString intValue];
        [self.entryView reloadStep:index total:0];
    }
    //录入失败
    else if ([statusString isEqualToString:@"fd"]) {
        NSLog(@"Zigbee Device 录入失败");
    }
    //取消录入
    else if ([statusString isEqualToString:@"fe"]) {
        NSLog(@"Zigbee Device 取消录入");
    }
}

@end
