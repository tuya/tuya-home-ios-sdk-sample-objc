//
//  TuyaLockDeviceAddMemberViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceAddMemberViewController.h"
#import "TuyaLockDeviceAddMemberView.h"
#import "Alert.h"

@interface TuyaLockDeviceAddMemberViewController ()<TuyaLockDeviceAddMemberViewDelegate>

@property (nonatomic, strong) TuyaLockDeviceAddMemberView *addMemberView;

@end

@implementation TuyaLockDeviceAddMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addMemberView = [[TuyaLockDeviceAddMemberView alloc] initWithFrame:self.view.bounds];
    self.addMemberView.delegate = self;
    self.addMemberView.isEdit = self.isEdit;
    [self.view addSubview:self.addMemberView];
    
    if (self.isEdit){
        self.title = @"编辑家庭成员";
        [self.addMemberView reloadData:self.dataSource];
    }else{
        self.title = @"添加家庭成员";
    }
}

#pragma mark - TuyaLockDeviceAddMemberViewDelegate

- (void)updateMemberAction:(ThingSmartHomeMemberRequestModel *)model{
    WEAKSELF_ThingSDK
    if ([self isBLEDevice]){
        [self.bleDevice updateProLockMemberInfoWithRequestModel:model success:^{
            NSLog(@"更新家庭成员成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceMemberListRefresh" object:nil];
            [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"更新家庭成员失败" message:error.localizedDescription];
        }];
    }
    else if ([self isZigbeeDevice]){
        [self.zigbeeDevice updateMemberWithRequestModel:model success:^{
            NSLog(@"更新家庭成员成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDeviceMemberListRefresh" object:nil];
            [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"更新家庭成员失败" message:error.localizedDescription];
        }];
    }
}

- (void)addMemberAction:(ThingSmartHomeAddMemberRequestModel *)model{
    WEAKSELF_ThingSDK
    long long homeId = [Home getCurrentHome].homeId;
    if([self isBLEDevice]){
        [self.bleDevice createProLockMemberWithHomeId:homeId
                                         requestModel:model
                                              success:^(NSDictionary *dict) {
            NSLog(@"创建家庭成员成功");
            [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建家庭成员失败" message:error.localizedDescription];
        }];
    }
    else if ([self isZigbeeDevice]){
        [self.zigbeeDevice addMemberWithHomeId:homeId requestModel:model success:^(NSDictionary *dict) {
            NSLog(@"创建家庭成员成功");
            [weakSelf_ThingSDK.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"创建家庭成员失败" message:error.localizedDescription];
        }];
    }
}

- (void)selectRoleType{
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"选择角色" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *modifyAction = [UIAlertAction actionWithTitle:@"管理员" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.addMemberView reloadRoleType:@"管理员"];
    }];

    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"普通成员" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.addMemberView reloadRoleType:@"普通成员"];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];

    [alertViewController addAction:modifyAction];
    [alertViewController addAction:deleteAction];
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}

- (void)warningAlert{
    [Alert showBasicAlertOnVC:self withTitle:@"提示" message:@"请输入正确内容"];
}

@end
