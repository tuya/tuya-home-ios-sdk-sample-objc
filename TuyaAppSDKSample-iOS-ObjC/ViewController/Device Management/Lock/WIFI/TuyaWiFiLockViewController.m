//
//  TuyaWiFiLockViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiLockViewController.h"
#import "TuyaWiFiDeviceUnlockViewController.h"
#import "TuyaWiFiDevicePasswordListViewController.h"
#import "TuyaWiFiDeviceRecordListViewController.h"
#import "TuyaLockDeviceSettingViewController.h"
#import "TuyaWiFiMemberListViewController.h"
#import "TuyaWiFiMemberManagementViewController.h"

@interface TuyaWiFiLockViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;

@end

@implementation TuyaWiFiLockViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.wifiDevice = [ThingSmartLockDevice deviceWithDeviceId:self.devId];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.title = [NSString stringWithFormat:@"%@(%@)",self.wifiDevice.deviceModel.name,(self.wifiDevice.deviceModel.isOnline ? @"在线":@"离线")];
    ///Init data
    self.datalist = @[
        @"开关锁",
        @"密码列表",
        @"门锁记录",
        @"成员管理",
        @"设置",
    ];
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
            TuyaWiFiDeviceUnlockViewController *vc = [[TuyaWiFiDeviceUnlockViewController alloc] init];
            vc.devId = self.devId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            TuyaWiFiDevicePasswordListViewController *vc = [[TuyaWiFiDevicePasswordListViewController alloc] init];
            vc.devId = self.devId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            TuyaWiFiDeviceRecordListViewController *vc = [[TuyaWiFiDeviceRecordListViewController alloc] init];
            vc.devId = self.devId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            TuyaWiFiMemberManagementViewController *vc = [[TuyaWiFiMemberManagementViewController alloc] init];
            vc.devId = self.devId;
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
