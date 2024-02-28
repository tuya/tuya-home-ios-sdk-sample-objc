//
//  TuyaLockDeviceTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceTableViewController.h"
#import "TuyaLockDeviceUnlockOrLockViewController.h"
#import "TuyaLockDevicePasswordViewController.h"
#import "TuyaLockDeviceRecordViewController.h"
#import "TuyaLockDeviceSettingViewController.h"
#import "TuyaLockDeviceUnlockModeViewController.h"
#import "TuyaLockDeviceListViewController.h"
#import "TuyaZigbeeLockViewController.h"
#import "TuyaWiFiLockViewController.h"
#import "Alert.h"

@interface TuyaLockDeviceTableViewController ()<ThingSmartHomeDelegate,UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) ThingSmartHome *home;
@property (strong, nonatomic) NSMutableArray *devicelist;///门锁设备列表
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSString* subRecordId;
@property (strong, nonatomic) NSString* recordId;

@end

@implementation TuyaLockDeviceTableViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"门锁列表";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.devicelist = [[NSMutableArray alloc] initWithCapacity:10];
    
    if ([Home getCurrentHome]) {
        self.home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        self.home.delegate = self;
        [self selectLockDevice:self.home.deviceList];
        [self updateHomeDetail];
        
        [self.home getHomeMemberListWithSuccess:^(NSArray<ThingSmartHomeMemberModel *> *memberList) {
            self.memberList = [NSMutableArray arrayWithArray:memberList];
        } failure:^(NSError *error) {
            NSLog(@"");
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"kNotificationDeviceOnlineUpdate" object:nil];
}

- (void)updateHomeDetail {
    [self.home getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
        [self selectLockDevice:self.home.deviceList];
    } failure:^(NSError *error) {
        
    }];
}

- (void)selectLockDevice:(NSArray <ThingSmartDeviceModel *> *)deviceList{
    [self.devicelist removeAllObjects];
    
    for (ThingSmartDeviceModel *model in deviceList) {
        if ([model.categoryCode containsString:@"ms"]){
            [self.devicelist addObject:model];
        }
    }
}

- (void)refreshData{
    [self.tableView reloadData];
}

#pragma mark -TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devicelist.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    ThingSmartDeviceModel *model = self.devicelist[indexPath.row];
    NSString *isOnline = model.isOnline ? @"(在线)" : @"(离线)";
    cell.textLabel.text = [model.name stringByAppendingString:isOnline];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartDeviceModel *model = [self.devicelist objectAtIndex:indexPath.row];
    if ([model.categoryCode isEqualToString:@"jtmspro_2b_2"]
        || [model.categoryCode isEqualToString:@"ble_ms"]){
        TuyaLockDeviceListViewController *vc = [[TuyaLockDeviceListViewController alloc] init];
        vc.devId = model.devId;
        vc.memberList = self.memberList;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([model.categoryCode isEqualToString:@"jtmspro_4z_1"] ||
             [model.categoryCode isEqualToString:@"zig_ms"]){
        TuyaZigbeeLockViewController *vc = [[TuyaZigbeeLockViewController alloc] init];
        vc.devId = model.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([model.categoryCode isEqualToString:@"wf_jtmsbh"] 
             ||[model.categoryCode isEqualToString:@"wf_jtmspro"]
             ||[model.categoryCode isEqualToString:@"wf_ms"]){
        TuyaWiFiLockViewController *vc = [[TuyaWiFiLockViewController alloc] init];
        vc.devId = model.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        [Alert showBasicAlertOnVC:self withTitle:@"Demo只支持BLE、WiFi、ZigBee门锁" message:@""];
    }
}

@end
