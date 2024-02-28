//
//  TuyaZigbeeDeviceRecordListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaZigbeeDeviceRecordListViewController.h"
#import <ThingSmartLockKit/ThingSmartZigbeeLockDevice.h>
#import "TuyaZigbeeDeviceRecordFilterView.h"
#import "Alert.h"
#import "TuyaZigbeeDeviceRecordListCell.h"

@interface TuyaZigbeeDeviceRecordListViewController ()
<UITableViewDelegate,UITableViewDataSource,TuyaZigbeeDeviceRecordFilterViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) TuyaZigbeeDeviceRecordFilterView *filterView;
@property (strong, nonatomic) NSDictionary *currentDic;

@end

@implementation TuyaZigbeeDeviceRecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.zigbeeDevice = [[ThingSmartZigbeeLockDevice alloc] initWithDeviceId:self.devId];
    
    self.title = @"记录列表";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[TuyaZigbeeDeviceRecordListCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    self.tableView.tableHeaderView = self.filterView;
    
    [self alarmFilter];
}

#pragma mark - TuyaZigbeeDeviceRecordFilterViewDelegate

- (void)alarmFilter{
    WEAKSELF_ThingSDK
    [self.zigbeeDevice getAlarmRecordListWithDevId:self.devId
                                             dpIds:@[@"hijack",@"alarm_lock",@"doorbell"]
                                            offset:0
                                             limit:50
                                           success:^(id result) {
        weakSelf_ThingSDK.datalist = (NSArray *)result[@"datas"];
        [weakSelf_ThingSDK.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
    }];
}

- (void)recordFilter{
    WEAKSELF_ThingSDK
    NSArray *dpIds = @[@"unlock_fingerprint", @"unlock_password", @"unlock_dynamic", @"unlock_temporary",@"unlock_card",@"unlock_face",@"unlock_key",@"unlock_remote",@"open_inside",@"hijack"];
    [self.zigbeeDevice getUnlockRecordListWithDevId:self.devId
                                              dpIds:dpIds
                                          startTime:0
                                            endTime:0
                                             offset:0
                                              limit:50
                                            success:^(id result) {
        weakSelf_ThingSDK.datalist = (NSArray *)result[@"datas"];
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
    NSDictionary *dic = self.datalist[indexPath.row];
    TuyaZigbeeDeviceRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"dpId:%@ , dpValue:%@",dic[@"dpId"],dic[@"dpValue"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (([dic[@"dpId"] intValue] == 1
        || [dic[@"dpId"] intValue] == 2
        || [dic[@"dpId"] intValue] == 5) && [dic[@"userName"] stringValue].length == 0){
        [cell makeBtnShow];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.datalist[indexPath.row];
    if (([dic[@"dpId"] intValue] == 1
        || [dic[@"dpId"] intValue] == 2
        || [dic[@"dpId"] intValue] == 5) && [dic[@"userName"] stringValue].length == 0){
        self.currentDic = dic;
        [self bindMember];
    }else{
        self.currentDic = nil;
    }
}

- (void)bindMember{
    WEAKSELF_ThingSDK
    [self.zigbeeDevice getMemberListWithDevId:self.devId success:^(id result) {
        [weakSelf_ThingSDK memberAlert:(NSArray *)result];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取成员列表失败" message:error.localizedDescription];
    }];
}

- (void)memberAlert:(NSArray *)memberList{
    WEAKSELF_ThingSDK
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"选择关联的成员" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSDictionary *dic in memberList) {
        NSString *name = [dic[@"nickName"] stringValue];
        UIAlertAction *nameAction = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSString *unlockIds = [NSString stringWithFormat:@"%@-%@",[self.currentDic[@"dpId"] stringValue],[self.currentDic[@"dpValue"] stringValue]];
            [self.zigbeeDevice bindUnlockOpModeWithDevId:self.devId userId:[dic[@"userId"] stringValue] unlockIds:@[unlockIds].thingsdk_JSONString success:^(id result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"绑定成功" message:@""];
                //刷新
                [weakSelf_ThingSDK recordFilter];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"绑定失败" message:error.localizedDescription];
            }];
        }];
        [alertViewController addAction:nameAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}

#pragma mark - property

- (TuyaZigbeeDeviceRecordFilterView *)filterView{
    if (!_filterView){
        _filterView = [[TuyaZigbeeDeviceRecordFilterView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 30)];
        _filterView.delegate = self;
    }
    
    return _filterView;
}

@end
