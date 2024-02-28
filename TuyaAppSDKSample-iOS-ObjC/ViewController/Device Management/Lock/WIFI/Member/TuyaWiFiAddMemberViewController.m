//
//  TuyaWiFiAddMemberViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiAddMemberViewController.h"
#import "TuyaWiFiAddMemberView.h"
#import "Alert.h"

@interface TuyaWiFiAddMemberViewController ()<TuyaWiFiAddMemberViewDelegate>

@property (nonatomic, strong) TuyaWiFiAddMemberView *addMemberView;

@end

@implementation TuyaWiFiAddMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addMemberView = [[TuyaWiFiAddMemberView alloc] initWithFrame:self.view.bounds];
    self.addMemberView.delegate = self;
    self.addMemberView.isEdit = self.isEdit;
    [self.view addSubview:self.addMemberView];
    
    if (self.isEdit){
        self.title = @"编辑家庭成员";
        [self.addMemberView reloadModel:self.dataSource];
    }else{
        self.title = @"添加家庭成员";
    }
}

#pragma mark - TuyaLockDeviceAddMemberViewDelegate

- (void)updateMemberAction:(ThingSmartLockMemberModel *)model{
    WEAKSELF_ThingSDK
    [self.wifiDevice updateLockNormalUserWithUserId:model.userId
                                           userName:model.userName
                                        avatarImage:nil
                                    unlockRelations:model.unlockRelations
                                            success:^(BOOL result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceMemberListRefresh" object:nil];
        [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"更新家庭成员失败" message:error.localizedDescription];
    }];
}

- (void)addMemberAction:(ThingSmartLockMemberModel *)model{
    WEAKSELF_ThingSDK
    [self.wifiDevice addLockNormalUserWithUserName:model.userName
                                       avatarImage:nil
                                   unlockRelations:nil
                                           success:^(NSString *result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceMemberListRefresh" object:nil];
        [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建面板成员失败" message:error.localizedDescription];
    }];
}

- (void)warningAlert{
    [Alert showBasicAlertOnVC:self withTitle:@"提示" message:@"请输入正确内容"];
}

@end

