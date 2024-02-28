//
//  TuyaLockDeviceMemberUpdateTimeViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceMemberUpdateTimeViewController.h"
#import "TuyaLockDeviceMemberUpdateTimeView.h"
#import "Alert.h"
#import "TuyaLockDeviceMemberManagementViewController.h"

@interface TuyaLockDeviceMemberUpdateTimeViewController ()<TuyaLockDeviceMemberUpdateTimeViewDelegate>

@property (nonatomic, strong) TuyaLockDeviceMemberUpdateTimeView *timeView;

@end

@implementation TuyaLockDeviceMemberUpdateTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"编辑时效";
    self.timeView = [[TuyaLockDeviceMemberUpdateTimeView alloc] initWithFrame:self.view.bounds];
    self.timeView.delegate = self;
    [self.view addSubview:self.timeView];
    
    [self.timeView reloadData:self.dataSource];
}

#pragma mark - TuyaLockDeviceMemberUpdateTimeViewDelegate

- (void)saveMemberTimeInfo{
    WEAKSELF_ThingSDK
    int userType = [self.dataSource[@"userType"] intValue];
    BOOL isAdmin = (userType == 10 || userType == 50) ? YES : NO;
    [self.bleDevice updateProLockMemberTimeWithDevId:self.bleDevice.deviceModel.devId
                                            memberId:[self.dataSource[@"userId"] stringValue]
                                       offlineUnlock:NO
                                             isAdmin:isAdmin
                                       effectiveDate:[self.timeView getEffectiveData]
                                         invalidDate:[self.timeView getInvalidData]
                                            schedule:[self.timeView getScheduleInfo]
                                             success:^(id result) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"更新成功" message:@""];
        [weakSelf_ThingSDK performSelector:@selector(popVC) withObject:nil afterDelay:2];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"更新成员时效失败" message:error.localizedDescription];
    }];
}

- (void)popVC{
    NSArray *vcs = self.navigationController.viewControllers;
    for (UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[TuyaLockDeviceMemberManagementViewController class]]){
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

@end
