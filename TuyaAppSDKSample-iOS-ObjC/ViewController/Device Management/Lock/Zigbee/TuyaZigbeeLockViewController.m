//
//  TuyaZigbeeLockViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaZigbeeLockViewController.h"
#import <ThingSmartLockKit/ThingSmartZigbeeLockDevice.h>
#import "TuyaZigbeeDeviceUnlockViewController.h"
#import "TuyaZigbeeDevicePasswordListViewController.h"
#import "TuyaZigbeeDeviceRecordListViewController.h"
#import "TuyaLockDeviceMemberManagementViewController.h"
#import "TuyaLockDeviceSettingViewController.h"
#import "Alert.h"

@interface TuyaZigbeeLockViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;

@end

@implementation TuyaZigbeeLockViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.zigbeeDevice = [ThingSmartZigbeeLockDevice deviceWithDeviceId:self.devId];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.title = [NSString stringWithFormat:@"%@(%@)",self.zigbeeDevice.deviceModel.name,(self.zigbeeDevice.deviceModel.isOnline ? @"在线":@"离线")];
    ///Init data
    self.datalist = @[
        @"开关锁",
        @"密码列表",
        @"门锁记录",
        @"成员管理",
        @"设置",
    ];
    
    WEAKSELF_ThingSDK
    [self.zigbeeDevice getMemberListWithDevId:self.devId success:^(id result) {
        weakSelf_ThingSDK.memberList = (NSArray *)result;
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
    }];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datalist.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = self.datalist[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            TuyaZigbeeDeviceUnlockViewController *vc = [[TuyaZigbeeDeviceUnlockViewController alloc] init];
            vc.devId = self.devId;
            vc.memberList = self.memberList;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            TuyaZigbeeDevicePasswordListViewController *vc = [[TuyaZigbeeDevicePasswordListViewController alloc] init];
            vc.devId = self.devId;
            vc.memberList = self.memberList;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            TuyaZigbeeDeviceRecordListViewController *vc = [[TuyaZigbeeDeviceRecordListViewController alloc] init];
            vc.devId = self.devId;
            vc.memberList = self.memberList;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            TuyaLockDeviceMemberManagementViewController *vc = [[TuyaLockDeviceMemberManagementViewController alloc] init];
            vc.devId = self.devId;
            vc.memberList = self.memberList;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            TuyaLockDeviceSettingViewController *vc = [[TuyaLockDeviceSettingViewController alloc] init];
            vc.devId = self.devId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}



@end
