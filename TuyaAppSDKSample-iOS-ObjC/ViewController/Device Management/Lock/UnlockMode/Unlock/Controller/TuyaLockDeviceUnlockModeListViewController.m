//
//  TuyaLockDeviceFingerListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeListViewController.h"
#import "TuyaLockDeviceUnlockModeListCell.h"
#import "TuyaLockDeviceUnlockModeGuideViewController.h"
#import "Alert.h"
#import "TuyaLockDeviceUnlockModePasswordViewController.h"
#import "TuyaLockDeviceUnlockModeModifyViewController.h"

@interface TuyaLockDeviceUnlockModeListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<ThingSmartBLELockOpmodeModel *> *datalist;

@end

@implementation TuyaLockDeviceUnlockModeListViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addAction)];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[TuyaLockDeviceUnlockModeListCell class] forCellReuseIdentifier:@"TuyaLockDeviceFingerListCell"];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"LockDeviceUnlockModeListRefresh" object:nil];
}

- (void)reloadData{
    WEAKSELF_ThingSDK
    if (self.unlockModeType == 0){
        self.title = @"指纹列表";
        [self.bleDevice getFingerPrintListWithSuccess:^(NSArray<ThingSmartBLELockOpmodeModel *> * _Nonnull models) {
            weakSelf_ThingSDK.datalist = models;
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取指纹列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.unlockModeType == 1){
        self.title = @"密码列表";
        [self.bleDevice getPasswordListWithSuccess:^(NSArray<ThingSmartBLELockOpmodeModel *> * _Nonnull models) {
            weakSelf_ThingSDK.datalist = models;
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取密码列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.unlockModeType == 2){
        self.title = @"卡片列表";
        [self.bleDevice getCardListWithSuccess:^(NSArray<ThingSmartBLELockOpmodeModel *> * _Nonnull models) {
            weakSelf_ThingSDK.datalist = models;
            [weakSelf_ThingSDK.tableView reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取卡片列表失败" message:error.localizedDescription];
        }];
    }
}

- (void)addAction{
    if (self.unlockModeType != 1){
        TuyaLockDeviceUnlockModeGuideViewController *vc = [[TuyaLockDeviceUnlockModeGuideViewController alloc] init];
        vc.bleDevice = self.bleDevice;
        vc.unlockModeType = self.unlockModeType;
        vc.memberId = self.memberId;
        vc.userType = self.userType;
        vc.lockUserId = self.lockUserId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        TuyaLockDeviceUnlockModePasswordViewController *vc = [[TuyaLockDeviceUnlockModePasswordViewController alloc] init];
        vc.isEdit = NO;
        vc.bleDevice = self.bleDevice;
        vc.memberId = self.memberId;
        [self.navigationController pushViewController:vc animated:YES];
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
    TuyaLockDeviceUnlockModeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TuyaLockDeviceFingerListCell" forIndexPath:indexPath];
    ThingSmartBLELockOpmodeModel *model = self.datalist[indexPath.row];
    [cell reloadData:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartBLELockOpmodeModel *model = self.datalist[indexPath.row];
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"操作" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *modifyAction = [UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (self.unlockModeType == 1){
            TuyaLockDeviceUnlockModePasswordViewController *vc = [[TuyaLockDeviceUnlockModePasswordViewController alloc] init];
            vc.model = model;
            vc.isEdit = YES;
            vc.bleDevice = self.bleDevice;
            vc.memberId = self.memberId;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else{
            TuyaLockDeviceUnlockModeModifyViewController *vc = [[TuyaLockDeviceUnlockModeModifyViewController alloc] init];
            vc.model = model;
            vc.bleDevice = self.bleDevice;
            vc.memberId = self.memberId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (![self.bleDevice isBLEConnected]){
            [Alert showBasicAlertOnVC:self withTitle:@"蓝牙已断开" message:@""];
        }
        
        WEAKSELF_ThingSDK
        //Pro
        if ([self.bleDevice.deviceModel.categoryCode isEqualToString:@"jtmspro_2b_2"]){
            if (self.unlockModeType == 0){
                [self.bleDevice removeProUnlockOpModeForMemberWithOpmodeModel:model
                                                                      isAdmin:NO
                                                                 unlockDpCode:@"unlock_fingerprint"
                                                                 unlockOpType:ThingUnlockOpTypeFinger
                                                                      timeout:5
                                                                      success:^{
                    [weakSelf_ThingSDK reloadData];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除指纹失败" message:error.localizedDescription];
                }];
            }
            else if (self.unlockModeType == 1){
                [self.bleDevice removeProUnlockOpModeForMemberWithOpmodeModel:model
                                                                      isAdmin:NO
                                                                 unlockDpCode:@"unlock_password"
                                                                 unlockOpType:ThingUnlockOpTypePassword
                                                                      timeout:5
                                                                      success:^{
                    [weakSelf_ThingSDK reloadData];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除密码失败" message:error.localizedDescription];
                }];
            }
            else if (self.unlockModeType == 2){
                [self.bleDevice removeProUnlockOpModeForMemberWithOpmodeModel:model
                                                                      isAdmin:NO
                                                                 unlockDpCode:@"unlock_card"
                                                                 unlockOpType:ThingUnlockOpTypeCard
                                                                      timeout:5
                                                                      success:^{
                    [weakSelf_ThingSDK reloadData];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除卡片失败" message:error.localizedDescription];
                }];
            }
        }
        else{
            if (self.unlockModeType == 0){
                [self.bleDevice removeFingerPrintForMemberWithOpmodeModel:model success:^{
                    [weakSelf_ThingSDK reloadData];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除指纹失败" message:error.localizedDescription];
                }];
            }
            else if (self.unlockModeType == 1){
                [self.bleDevice removePasswordForMemberWithOpmodeModel:model success:^{
                    [weakSelf_ThingSDK reloadData];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除密码失败" message:error.localizedDescription];
                }];
            }
            else if (self.unlockModeType == 2){
                [self.bleDevice removeCardForMemberWithOpmodeModel:model success:^{
                    [weakSelf_ThingSDK reloadData];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除卡片失败" message:error.localizedDescription];
                }];
            }
        }
    }];
   
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alertViewController addAction:modifyAction];
    [alertViewController addAction:deleteAction];
    [alertViewController addAction:cancelAction];
    
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}

@end
