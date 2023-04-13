//
//  TuyaLockDeviceListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceListViewController.h"
#import "TuyaLockDeviceUnlockOrLockViewController.h"
#import "TuyaLockDevicePasswordViewController.h"
#import "TuyaLockDeviceRecordViewController.h"
#import "TuyaLockDeviceSettingViewController.h"
#import "TuyaLockDeviceMemberManagementViewController.h"
#import "TuyaLockDeviceUnlockModeViewController.h"
#import "Alert.h"

@interface TuyaLockDeviceListViewController ()<ThingSmartHomeDelegate,UITableViewDelegate,UITableViewDataSource,ThingSmartBLELockDeviceDelegate>

@property (strong, nonatomic) ThingSmartHome *home;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;///tableview数据源
@property (strong, nonatomic) NSArray<ThingSmartBLELockMemberModel *> *memberList;

@end

@implementation TuyaLockDeviceListViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bleDevice = [ThingSmartBLELockDevice deviceWithDeviceId:self.devId];
    self.bleDevice.delegate = self;
    self.title = [NSString stringWithFormat:@"%@(%@)",self.bleDevice.deviceModel.name,([self.bleDevice isBLEConnected] ? @"在线":@"离线")];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    ///Init data
    self.datalist = @[
        @"开关锁",
        @"临时密码",
        @"成员管理",
        @"门锁记录",
        @"解锁方式",
        @"设置",
        @"连接蓝牙",
        //        @"客户问题处理"
    ];
    
    [self.bleDevice getMemberListWithSuccess:^(NSArray<ThingSmartBLELockMemberModel *> * _Nonnull members) {
        self.memberList = members;
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"面板成员列表查询失败" message:@""];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"kNotificationDeviceOnlineUpdate" object:nil];
    
}

- (void)refreshData{
    self.title = [NSString stringWithFormat:@"%@(%@)",self.bleDevice.deviceModel.name,([self.bleDevice isBLEConnected] ? @"在线":@"离线")];
    
    //蓝牙链接成功，需要下发T0数据，否则无法开锁
    [self.bleDevice publishSyncBatchDataSuccess:^{
        NSLog(@"T0数据下发成功");
    } failure:^(NSError *error) {
        NSLog(@"T0数据下发失败");
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
            TuyaLockDeviceUnlockOrLockViewController *vc = [[TuyaLockDeviceUnlockOrLockViewController alloc] init];
            vc.devId = self.devId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            TuyaLockDevicePasswordViewController *vc = [[TuyaLockDevicePasswordViewController alloc] init];
            vc.devId = self.devId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            TuyaLockDeviceMemberManagementViewController *vc = [[TuyaLockDeviceMemberManagementViewController alloc] init];
            vc.bleDevice = self.bleDevice;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            TuyaLockDeviceRecordViewController *vc = [[TuyaLockDeviceRecordViewController alloc] init];
            vc.bleDevice = self.bleDevice;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            TuyaLockDeviceUnlockModeViewController *vc = [[TuyaLockDeviceUnlockModeViewController alloc] init];
            vc.bleDevice = self.bleDevice;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 5:
        {
            TuyaLockDeviceSettingViewController *vc = [[TuyaLockDeviceSettingViewController alloc] init];
            vc.bleDevice = self.bleDevice;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 6:
        {
            if (![self.bleDevice isBLEConnected]){
                [self.bleDevice autoConnect];
            }else{
                [Alert showBasicAlertOnVC:self withTitle:@"蓝牙已连接" message:@""];
            }
        }
            break;
        default:
            break;
    }
}

@end
