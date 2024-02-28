//
//  TuyaWiFiDeviceRecordListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiDeviceRecordListViewController.h"
#import <ThingSmartLockKit/ThingSmartLockDevice.h>
#import "TuyaWiFiDeviceRecordFilterView.h"
#import "TuyaWiFiDeviceRecordListCell.h"
#import "Alert.h"

@interface TuyaWiFiDeviceRecordListViewController ()<UITableViewDelegate,UITableViewDataSource,TuyaWiFiDeviceRecordFilterViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<ThingSmartLockRecordModel *> *datalist;
@property (strong, nonatomic) TuyaWiFiDeviceRecordFilterView *filterView;

@end

@implementation TuyaWiFiDeviceRecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"记录列表";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[TuyaWiFiDeviceRecordListCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    self.tableView.tableHeaderView = self.filterView;
    
    [self alarmFilter];
}

#pragma mark - TuyaZigbeeDeviceRecordFilterViewDelegate

- (void)alarmFilter{
    WEAKSELF_ThingSDK
    [self.wifiDevice getLockRecordListWithDpCodes:@[@"hijack",@"alarm_lock",@"doorbell"]
                                           offset:0
                                            limit:50
                                          success:^(NSArray<ThingSmartLockRecordModel *> * _Nonnull lockRecordModels) {
        weakSelf_ThingSDK.datalist = lockRecordModels;
        [weakSelf_ThingSDK.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
    }];
}

- (void)recordFilter{
    WEAKSELF_ThingSDK
    [self.wifiDevice getUnlockRecordList:0 
                                   limit:50
                                 success:^(NSArray<ThingSmartLockRecordModel *> * _Nonnull lockRecordModels) {
        weakSelf_ThingSDK.datalist = lockRecordModels;
        [weakSelf_ThingSDK.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
    }];
}

- (void)hijackFilter{
    WEAKSELF_ThingSDK
    [self.wifiDevice getLockHijackRecordListWithDpCodes:@[@"hijack"]
                                                 offset:0
                                                  limit:50
                                                success:^(NSArray<ThingSmartLockRecordModel *> * _Nonnull lockRecordModels) {
        weakSelf_ThingSDK.datalist = lockRecordModels;
        [weakSelf_ThingSDK.tableView reloadData];
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
    ThingSmartLockRecordModel *model = self.datalist[indexPath.row];
    TuyaWiFiDeviceRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"dpData:%@",model.dpData];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - property

- (TuyaWiFiDeviceRecordFilterView *)filterView{
    if (!_filterView){
        _filterView = [[TuyaWiFiDeviceRecordFilterView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 30)];
        _filterView.delegate = self;
    }
    
    return _filterView;
}

@end
