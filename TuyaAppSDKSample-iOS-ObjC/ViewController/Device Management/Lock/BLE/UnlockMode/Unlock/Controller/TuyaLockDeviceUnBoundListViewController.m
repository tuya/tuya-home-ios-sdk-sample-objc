//
//  TuyaLockDeviceUnBoundListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnBoundListViewController.h"
#import "TuyaLockDeviceUnBoundListCell.h"
#import "Alert.h"

@interface TuyaLockDeviceUnBoundListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;

@end

@implementation TuyaLockDeviceUnBoundListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"未绑定的解锁方式列表";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[TuyaLockDeviceUnBoundListCell class] forCellReuseIdentifier:@"TuyaLockDeviceUnBoundListCell"];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"LockDeviceUnBoundListRefresh" object:nil];
}

- (void)reloadData{
    WEAKSELF_ThingSDK
    if([self isBLEDevice]){
        [self.bleDevice getProUnboundUnlockOpModeListWithDevId:self.bleDevice.deviceModel.devId
                                                       success:^(id result) {
            weakSelf_ThingSDK.datalist = (NSArray *)result;
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取成员未绑定的解锁方式列表失败" message:error.localizedDescription];
        }];
    }
    else if ([self isZigbeeDevice]){
        [self.zigbeeDevice getUnallocOpModeWithDevId:self.devId success:^(id result) {
            weakSelf_ThingSDK.datalist = (NSArray *)result;
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取成员未绑定的解锁方式列表失败" message:error.localizedDescription];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datalist.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TuyaLockDeviceUnBoundListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TuyaLockDeviceUnBoundListCell" forIndexPath:indexPath];
    NSDictionary *model = self.datalist[indexPath.row];
    [cell reloadData:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *model = self.datalist[indexPath.row];
    NSArray *unlockInfo = (NSArray *)model[@"unlockInfo"];
    NSDictionary *dicValue = unlockInfo.firstObject;
    NSString *unlockId = [dicValue[@"unlockId"] stringValue];
    
    NSDictionary *member = self.memberList.firstObject;
    NSString *userId = [member[@"userId"] stringValue];
    NSString *nickName = [member[@"nickName"] stringValue];
    
    WEAKSELF_ThingSDK
    //userId：被分配的成员userId  unlockIds：解锁方式id
    if ([self isBLEDevice]){
        [self.bleDevice allocProUnlockOpModeWithDevId:self.bleDevice.deviceModel.devId
                                               userId:userId
                                            unlockIds:@[unlockId].thingsdk_JSONString
                                              success:^(id result) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:[NSString stringWithFormat:@"开锁方式分配给：%@成功",nickName] message:@""];
            [weakSelf_ThingSDK reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"开锁方式分配到人失败" message:error.localizedDescription];
        }];
    }
    else if ([self isZigbeeDevice]){
        [self.zigbeeDevice allocUnlockOpModeWithDevId:self.devId userId:userId unlockIds:@[unlockId].thingsdk_JSONString success:^(id result) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:[NSString stringWithFormat:@"开锁方式分配给：%@成功",nickName] message:@""];
            [weakSelf_ThingSDK reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"开锁方式分配到人失败" message:error.localizedDescription];
        }];
    }
}

@end
