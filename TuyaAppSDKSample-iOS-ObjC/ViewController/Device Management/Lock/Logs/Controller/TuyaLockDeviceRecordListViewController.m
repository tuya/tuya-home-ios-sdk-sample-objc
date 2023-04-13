//
//  TuyaLockDeviceRecordListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceRecordListViewController.h"
#import "TuyaLockDeviceRecordListCell.h"
#import "TuyaLockDeviceRecordFilterView.h"
#import "Alert.h"

@interface TuyaLockDeviceRecordListViewController ()<UITableViewDelegate,UITableViewDataSource,TuyaLockDeviceRecordFilterViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) TuyaLockDeviceRecordFilterView *filterView;

@property (strong, nonatomic) NSArray<ThingSmartLockRecordModel *> *alermList;
@property (strong, nonatomic) NSArray<ThingSmartBLELockRecordModel *> *unlockRecordList;
@property (strong, nonatomic) NSArray *proDataList;

@property (copy, nonatomic)   NSString *logCategories;
@property (copy, nonatomic)   NSString *userIds;
@property (assign, nonatomic) NSInteger startTime;
@property (assign, nonatomic) NSInteger endTime;

@property (copy, nonatomic)   NSString *typeTime;
@property (copy, nonatomic)   NSString *typeName;
@property (copy, nonatomic)   NSString *memberName;

@end

@implementation TuyaLockDeviceRecordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.title = @"日志列表";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[TuyaLockDeviceRecordListCell class] forCellReuseIdentifier:@"TuyaLockDeviceRecordListCell"];
    
    if (self.logType == 3){
        self.filterView = [[TuyaLockDeviceRecordFilterView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 30)];
        self.filterView.delegate = self;
        self.tableView.tableHeaderView = self.filterView;
    }
    
    //操作日志：operation 开门记录：unlock_record 关门记录：close_record 告警记录：alarm_record
    self.userIds = @"";
    self.startTime = 0;
    self.endTime = 0;
    self.logCategories = @"operation,unlock_record,close_record,alarm_record";
    [self reloadData];
}

- (void)reloadData{
    //Demo 翻页逻辑暂不处理，一次性捞了50条
    WEAKSELF_ThingSDK
    if (self.logType == 1){
        [self.bleDevice getAlarmRecordListWithOffset:0
                                               limit:50
                                             success:^(NSArray<ThingSmartLockRecordModel *> * _Nonnull records) {
            weakSelf_ThingSDK.alermList = records;
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.logType == 2){
        [self.bleDevice getUnlockRecordListWithOffset:0
                                                limit:50
                                              success:^(NSArray<ThingSmartBLELockRecordModel *> * _Nonnull records) {
            weakSelf_ThingSDK.unlockRecordList = records;
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.logType == 3){
        [self.bleDevice getProUnlockRecordListWithDevId:self.bleDevice.deviceModel.devId
                                          logCategories:self.logCategories
                                                userIds:self.userIds
                                    onlyShowMediaRecord:NO
                                              startTime:self.startTime
                                                endTime:self.endTime
                                             lastRowKey:@""
                                                  limit:50
                                                success:^(id result) {
            weakSelf_ThingSDK.proDataList = result[@"records"];
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.logType == 1){
        return self.alermList.count;
    }
    else if (self.logType == 2){
        return self.unlockRecordList.count;
    }
    else if (self.logType == 3){
        return self.proDataList.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TuyaLockDeviceRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TuyaLockDeviceRecordListCell" forIndexPath:indexPath];
    
    NSString *titleStr = @"";
    NSTimeInterval time = 0;
    NSString *logType = @"";
    if (self.logType == 1){
        ThingSmartLockRecordModel *alermModel = self.alermList[indexPath.row];
        NSArray<NSDictionary *> *dpsArray = alermModel.dpsArray;
        NSDictionary *dicValue = dpsArray.firstObject;
        titleStr = [dicValue.allValues.firstObject stringValue];
        time = alermModel.time;
    }
    else if (self.logType == 2){
        ThingSmartBLELockRecordModel *unlockRecordModel = self.unlockRecordList[indexPath.row];
        titleStr = [NSString stringWithFormat:@"%@(dpId:%@)",unlockRecordModel.userName,unlockRecordModel.dpId];
        time = unlockRecordModel.time;
    }
    else if (self.logType == 3){
        NSDictionary *dicValue = self.proDataList[indexPath.row];
        titleStr = dicValue[@"userName"];
        time = [dicValue[@"time"] integerValue];
        logType = dicValue[@"logType"];
    }
    
    [cell reloadData:titleStr time:time logType:logType];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - TuyaLockDeviceRecordFilterViewDelegate

- (void)timeFilter{
    [self.navigationController presentViewController:[self timeAlert] animated:YES completion:nil];
}

- (void)typeFilter{
    [self.navigationController presentViewController:[self typeAlert] animated:YES completion:nil];
}

- (void)memberFilter{
    [self.navigationController presentViewController:[self memberAlert] animated:YES completion:nil];
}

#pragma mark - UIAlertAction

- (UIAlertController *)timeAlert{
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"时间" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"全部时间" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.startTime = 0;
        self.endTime = 0;
        [self reloadData];
        [self.filterView.timeBtn setTitle:@"时间" forState:UIControlStateNormal];
    }];
    UIAlertAction *weekAction = [UIAlertAction actionWithTitle:@"近3天" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970] - 3 * 24 * 3600;
        self.startTime = startTime * 1000;
        self.endTime = endTime * 1000;
        [self reloadData];
        [self.filterView.timeBtn setTitle:@"近3天" forState:UIControlStateNormal];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
    [alertViewController addAction:weekAction];
    [alertViewController addAction:allAction];
    [alertViewController addAction:cancelAction];
    
    return alertViewController;
}

- (UIAlertController *)typeAlert{
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"类型" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *allAction = [UIAlertAction actionWithTitle:@"全部记录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.logCategories = @"operation,unlock_record,close_record,alarm_record";
        [self reloadData];
        [self.filterView.typeBtn setTitle:@"类型" forState:UIControlStateNormal];
    }];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"开门记录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.logCategories = @"unlock_record";
        [self reloadData];
        [self.filterView.typeBtn setTitle:@"开门记录" forState:UIControlStateNormal];
    }];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"关门记录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.logCategories = @"close_record";
        [self reloadData];
        [self.filterView.typeBtn setTitle:@"关门记录" forState:UIControlStateNormal];
    }];
    UIAlertAction *alermAction = [UIAlertAction actionWithTitle:@"告警记录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.logCategories = @"alarm_record";
        [self reloadData];
        [self.filterView.typeBtn setTitle:@"告警记录" forState:UIControlStateNormal];
    }];
    UIAlertAction *operateAction = [UIAlertAction actionWithTitle:@"操作日志" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        self.logCategories = @"operation";
        [self reloadData];
        [self.filterView.typeBtn setTitle:@"操作日志" forState:UIControlStateNormal];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alertViewController addAction:allAction];
    [alertViewController addAction:openAction];
    [alertViewController addAction:closeAction];
    [alertViewController addAction:alermAction];
    [alertViewController addAction:operateAction];
    [alertViewController addAction:cancelAction];
    
    return alertViewController;
}

- (UIAlertController *)memberAlert{
    WEAKSELF_ThingSDK
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"成员" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    ThingSmartHome *home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
    [home getHomeMemberListWithSuccess:^(NSArray<ThingSmartHomeMemberModel *> *memberList) {
        for (int i = 0; i< memberList.count; i++) {
            ThingSmartHomeMemberModel *member = [memberList objectAtIndex:i];
            UIAlertAction *action = [UIAlertAction actionWithTitle:member.name style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                self.userIds = [NSString stringWithFormat:@"%lld",member.memberId];
                [self reloadData];
                [self.filterView.memberBtn setTitle:member.name forState:UIControlStateNormal];
            }];
            [alertViewController addAction:action];
            
            if (i == (memberList.count - 1)){
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
                [alertViewController addAction:cancelAction];
            }
        }
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取成员列表失败" message:error.localizedDescription];
    }];
    
    return alertViewController;
}

@end
