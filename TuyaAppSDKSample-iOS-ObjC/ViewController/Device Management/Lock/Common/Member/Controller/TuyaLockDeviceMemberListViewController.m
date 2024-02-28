//
//  TuyaLockDeviceMemberListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceMemberListViewController.h"
#import "TuyaLockDeviceMemberListCell.h"
#import "Alert.h"
#import "TuyaLockDeviceMemberDetailViewController.h"
#import "TuyaLockDeviceAddMemberViewController.h"
#import "TuyaLockDeviceUnBoundListViewController.h"

@interface TuyaLockDeviceMemberListViewController ()<UITableViewDelegate,UITableViewDataSource,TuyaLockDeviceMemberListCellDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;

@end

@implementation TuyaLockDeviceMemberListViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[TuyaLockDeviceMemberListCell class] forCellReuseIdentifier:@"TuyaLockDeviceMemberListCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"LockDeviceMemberListRefresh" object:nil];
    
    [self reloadData];
}

- (void)reloadData{
    WEAKSELF_ThingSDK
    if ([self isBLEDevice]){
        self.title = @"家庭成员列表（BLE门锁）";
        [self.bleDevice getProLockMemberListWithDevId:self.bleDevice.deviceModel.devId
                                              success:^(id result) {
            [weakSelf_ThingSDK reloadTableWithData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
        
        //判断是否有需要分配的开锁方式
        [self.bleDevice isProNeedAllocUnlockOpModeWithDevId:self.bleDevice.deviceModel.devId
                                                    success:^(id result) {
            BOOL value = [result boolValue];
            if (value){
                [self showUnBoundAlert];
            }
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取是否有需要分配的开锁方式接口失败" message:error.localizedDescription];
        }];
    }
    else if ([self isZigbeeDevice]){
        self.title = @"家庭成员列表（ZigBee门锁）";
        [self.zigbeeDevice getMemberListWithDevId:self.devId success:^(id result) {
            [weakSelf_ThingSDK reloadTableWithData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
        
        [self.zigbeeDevice getUnallocOpModeWithDevId:self.devId success:^(id result) {
            NSArray *array = (NSArray *)result;
            if (array.count > 0){
                [self showUnBoundAlert];
            }
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取未被分配的开锁方式失败" message:error.localizedDescription];
        }];
    }
}

- (void)showUnBoundAlert{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"有未分配的开锁方式"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"查看"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        TuyaLockDeviceUnBoundListViewController *vc = [[TuyaLockDeviceUnBoundListViewController alloc] init];
        vc.devId = self.devId;
        vc.memberList = self.datalist;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];

    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reloadTableWithData:(id)data{
    if ([data isKindOfClass:[NSArray class]]){
        self.datalist = (NSArray *)data;
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datalist.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TuyaLockDeviceMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TuyaLockDeviceMemberListCell" forIndexPath:indexPath];
    NSDictionary *dicValue = self.datalist[indexPath.row];
    [cell reloadData:dicValue];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicValue = self.datalist[indexPath.row];
    TuyaLockDeviceMemberDetailViewController *vc = [[TuyaLockDeviceMemberDetailViewController alloc] init];
    vc.devId = self.devId;
    vc.dataSource = dicValue;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TuyaLockDeviceMemberListCellDelegate

- (void)deleteMemberWithUserId:(NSDictionary *)model{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"确定删除？"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        int userType = [model[@"userType"] intValue];
        int lockUserId = [model[@"lockUserId"] intValue];
        BOOL isAdmin = (userType == 10 || userType == 50) ? YES : NO;
        WEAKSELF_ThingSDK
        if ([self isBLEDevice]){
            [self.bleDevice removeProLockMemberWithUserId:model[@"userId"] isAdmin:isAdmin success:^{
                [weakSelf_ThingSDK reloadData];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除成员失败" message:error.localizedDescription];
            }];
        }else if ([self isZigbeeDevice]){
            [self.zigbeeDevice removeMemberWithMemberId:model[@"userId"] isAdmin:isAdmin lockUserId:lockUserId success:^{
                [weakSelf_ThingSDK reloadData];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除成员失败" message:error.localizedDescription];
            }];
        }
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateMemberWithModel:(NSDictionary *)model{
    TuyaLockDeviceAddMemberViewController *vc = [[TuyaLockDeviceAddMemberViewController alloc] init];
    vc.devId = self.devId;
    vc.isEdit = YES;
    vc.dataSource = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
