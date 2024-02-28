//
//  TuyaWiFiMemberListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiMemberListViewController.h"
#import "TuyaWiFiDeviceMemberListCell.h"
#import "Alert.h"
#import "TuyaWiFiAddMemberViewController.h"

@interface TuyaWiFiMemberListViewController ()<UITableViewDelegate,UITableViewDataSource,TuyaWiFiDeviceMemberListCellDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<ThingSmartLockMemberModel *> *datalist;

@end

@implementation TuyaWiFiMemberListViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"家庭成员列表（WIFI门锁）";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[TuyaWiFiDeviceMemberListCell class] forCellReuseIdentifier:@"TuyaWiFiDeviceMemberListCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"LockDeviceMemberListRefresh" object:nil];
    
    [self reloadData];
}

- (void)reloadData{
    WEAKSELF_ThingSDK
    [self.wifiDevice getLockMemberListWithSuccess:^(NSArray<ThingSmartLockMemberModel *> * _Nonnull lockMemberModels) {
        weakSelf_ThingSDK.datalist = lockMemberModels;
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
    TuyaWiFiDeviceMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TuyaWiFiDeviceMemberListCell" forIndexPath:indexPath];
    ThingSmartLockMemberModel *model = self.datalist[indexPath.row];
    [cell reloadData:model];
    cell.delegate = self;
    return cell;
}

#pragma mark - TuyaLockDeviceMemberListCellDelegate

- (void)deleteMemberWithUserId:(ThingSmartLockMemberModel *)model{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"确定删除？"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    WEAKSELF_ThingSDK
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        //这个接口只能删除非面板成员，家庭成员删除请调用homesdk的家庭成员删除接口
        [weakSelf_ThingSDK.wifiDevice deleteLockUserWithUserId:model.userId
                                                       success:^(BOOL result) {
            [weakSelf_ThingSDK reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除失败" message:error.localizedDescription];
        }];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateMemberWithModel:(ThingSmartLockMemberModel *)model{
    TuyaWiFiAddMemberViewController *vc = [[TuyaWiFiAddMemberViewController alloc] init];
    vc.devId = self.devId;
    vc.isEdit = YES;
    vc.dataSource = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
