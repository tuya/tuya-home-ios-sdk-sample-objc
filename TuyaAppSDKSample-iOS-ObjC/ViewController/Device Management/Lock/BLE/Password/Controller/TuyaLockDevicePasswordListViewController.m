//
//  TuyaLockDevicePasswordListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDevicePasswordListViewController.h"
#import "TuyaLockDevicePasswordDetailViewController.h"
#import "Alert.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDevicePasswordListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示
@property (strong, nonatomic) UIButton *addPwdBtn;//添加密码按钮
@property (copy, nonatomic)   NSString *vcTitle;//标题
@property (strong, nonatomic) UIButton *clearResultBtn;//结果清除按钮
@end

@implementation TuyaLockDevicePasswordListViewController

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ///Init view.
    self.title = [self getVCTitle];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(kResultLabelMargin, [UIScreen mainScreen].bounds.size.height - kResultLabelHeight, [UIScreen mainScreen].bounds.size.width - 2*kResultLabelMargin, kResultLabelHeight)];
    self.resultLabel.backgroundColor = [UIColor whiteColor];
    self.resultLabel.textColor = [UIColor blueColor];
    self.resultLabel.font = [UIFont systemFontOfSize:20];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.hidden = YES;
    self.resultLabel.userInteractionEnabled = YES;
    [self.view addSubview:self.resultLabel];
    
    self.addPwdBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 50,[UIScreen mainScreen].bounds.size.height-50,100, 40)];
    self.addPwdBtn.backgroundColor = [UIColor redColor];
    [self.addPwdBtn setTitle:@"添加密码" forState:UIControlStateNormal];
    [self.addPwdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addPwdBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addPwdBtn];
    
    self.clearResultBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.resultLabel.frame.size.width - 100,0,100, 40)];
    self.clearResultBtn.backgroundColor = [UIColor redColor];
    [self.clearResultBtn setTitle:@"清除结果" forState:UIControlStateNormal];
    [self.clearResultBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.clearResultBtn addTarget:self action:@selector(clearResultBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.resultLabel addSubview:self.clearResultBtn];
    
    [self requestListData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestListData) name:@"LockDevicePasswordListRefresh" object:nil];
}

- (void)requestListData{
    WEAKSELF_ThingSDK
    if (self.passwordType == PasswordType_OldOnlineOnce){
        [self.bleDevice getOnlinePasswordListWithDevId:self.bleDevice.deviceModel.devId
                                                 availTime:1
                                                   success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_OldOnlineCycle){
        [self.bleDevice getOnlinePasswordListWithDevId:self.bleDevice.deviceModel.devId
                                                 availTime:0
                                                   success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_OldOfflineOnce){
        [self.bleDevice getOfflinePasswordListWithDevId:self.bleDevice.deviceModel.devId
                                                    pwdType:@"1"
                                                     status:1
                                                     offset:0
                                                      limit:20
                                                    success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_OldOfflineTimes){
        [self.bleDevice getOfflinePasswordListWithDevId:self.bleDevice.deviceModel.devId
                                                    pwdType:@"0"
                                                     status:1
                                                     offset:0
                                                      limit:20
                                                    success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_OldOfflineEmptyAll){
        [self.bleDevice getOfflinePasswordListWithDevId:self.bleDevice.deviceModel.devId
                                                    pwdType:@"9"
                                                     status:1
                                                     offset:0
                                                      limit:40
                                                    success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_OldOfflineEmptyOne){
        [self.bleDevice getOfflinePasswordListWithDevId:self.bleDevice.deviceModel.devId
                                                    pwdType:@"9"
                                                     status:1
                                                     offset:0
                                                      limit:20
                                                    success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_ProOnlineCycle){
        [self.bleDevice getProPasswordListWithDevId:self.bleDevice.deviceModel.devId
                                              authTypes:@[@"LOCK_TEMP_PWD"]
                                                success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_ProOfflineTimes){
        [self.bleDevice getProPasswordListWithDevId:self.bleDevice.deviceModel.devId
                                              authTypes:@[@"LOCK_OFFLINE_TEMP_PWD"]
                                                success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_ProOfflineOnce){
        [self.bleDevice getProPasswordListWithDevId:self.bleDevice.deviceModel.devId
                                              authTypes:@[@"LOCK_OFFLINE_TEMP_PWD"]
                                                success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_ProOfflineEmptyAll){
        [self.bleDevice getProPasswordListWithDevId:self.bleDevice.deviceModel.devId
                                              authTypes:@[@"LOCK_OFFLINE_TEMP_PWD"]
                                                success:^(id result) {
            [weakSelf_ThingSDK reloadData:result];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取列表失败" message:error.localizedDescription];
        }];
    }
}

- (void)reloadData:(id)data{
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    NSDictionary *dicValue = self.datalist[indexPath.row];
    NSString *name = dicValue[@"name"];
    if (!name){
        name = dicValue[@"pwdName"];
    }
    cell.textLabel.text = name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //离线一次性密码不做处理
    if (self.passwordType == PasswordType_OldOfflineOnce || self.passwordType == PasswordType_ProOfflineOnce){
        return;
    }
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (self.passwordType == PasswordType_OldOnlineOnce
        || self.passwordType == PasswordType_OldOnlineCycle
        || self.passwordType == PasswordType_ProOnlineCycle){
        
        UIAlertAction *modifyAction = [UIAlertAction actionWithTitle:@"修改" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self modifyAction:indexPath];
        }];
        
        [alertViewController addAction:modifyAction];
    }
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAction:indexPath];
    }];
    
    [alertViewController addAction:deleteAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
    
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}

#pragma mark - private

- (void)getOneEmptyPwd:(NSIndexPath *)indexPath{
    WEAKSELF_ThingSDK
    NSDictionary *dicValue = self.datalist[indexPath.row];
    if (self.passwordType == PasswordType_OldOfflineTimes){
        [self.bleDevice getSingleRevokeOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                          pwdId:[dicValue[@"pwdId"] integerValue]
                                                        success:^(id result) {
            if (result && [result isKindOfClass:[NSDictionary class]]){
                NSString *pwdName = [result[@"pwdName"] stringValue];
                NSString *pwdValue = [result[@"pwd"] stringValue];
                [weakSelf_ThingSDK requestListData];
                [weakSelf_ThingSDK showResultLabel:[NSString stringWithFormat:@"%@:%@",pwdName,pwdValue]];
            }
        } failure:^(NSError *error) {
            [weakSelf_ThingSDK showResultLabel:[@"获取单个清空码报错：" stringByAppendingString:error.localizedDescription]];
        }];
    }
    else if (self.passwordType == PasswordType_ProOfflineTimes){
        [self.bleDevice getProSingleRevokeOfflinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                   unlockBindingId:[dicValue[@"unlockBindingId"] integerValue]
                                                              name:@""
                                                           success:^(id result) {
            if (result && [result isKindOfClass:[NSDictionary class]]){
                NSString *pwdName = [result[@"pwdName"] stringValue];
                NSString *pwdValue = [result[@"pwd"] stringValue];
                [weakSelf_ThingSDK requestListData];
                [weakSelf_ThingSDK showResultLabel:[NSString stringWithFormat:@"%@:%@",pwdName,pwdValue]];
            }
        }failure:^(NSError *error) {
            [weakSelf_ThingSDK showResultLabel:[@"获取单个清空码报错：" stringByAppendingString:error.localizedDescription]];
        }];
    }
}

- (void)addBtnClicked{
    TuyaLockDevicePasswordDetailViewController *vc = [[TuyaLockDevicePasswordDetailViewController alloc] init];
    vc.actionType = PasswordActionType_Add;
    vc.pwdType = self.passwordType;
    vc.devId = self.devId;
    
    if (self.passwordType == PasswordType_OldOnlineOnce){
        vc.title = @"新增一次性密码（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOnlineCycle){
        vc.title = @"新增周期性密码（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOfflineOnce){
        vc.title = @"新增离线单次密码（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOfflineTimes){
        vc.title = @"新增离线不限次数密码（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOfflineEmptyAll){
        vc.title = @"新增离线清空码（老公版）";
    }
    else if (self.passwordType == PasswordType_ProOnlineCycle){
        vc.title = @"新增在线自定义密码（Pro）";
    }
    else if (self.passwordType == PasswordType_ProOfflineTimes){
        vc.title = @"新增离线不限次数密码（Pro）";
    }
    else if (self.passwordType == PasswordType_ProOfflineOnce){
        vc.title = @"新增离线单次密码（Pro）";
    }
    else if (self.passwordType == PasswordType_ProOfflineEmptyAll){
        vc.title = @"新增离线清空码（Pro）";
    }

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)modifyAction:(NSIndexPath *)indexPath{
    //只能重命名
    if (self.passwordType == PasswordType_OldOfflineOnce ||
             self.passwordType == PasswordType_OldOfflineTimes ||
             self.passwordType == PasswordType_OldOfflineEmptyAll){
        [Alert showBasicAlertOnVC:self withTitle:@"不支持修改" message:@""];
        
        return;
    }
    
    NSDictionary *dicValue = self.datalist[indexPath.row];
    
    TuyaLockDevicePasswordDetailViewController *vc = [[TuyaLockDevicePasswordDetailViewController alloc] init];
    vc.actionType = PasswordActionType_Modify;
    vc.pwdType = self.passwordType;
    vc.bleDevice = self.bleDevice;
    vc.pwdDic = dicValue;
    
    if (self.passwordType == PasswordType_OldOnlineOnce){
        vc.title = @"修改在线一次性密码（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOnlineCycle){
        vc.title = @"修改在线周期性密码（老公版）";
    }
    else if (self.passwordType == PasswordType_ProOnlineCycle){
        vc.title = @"修改在线自定义密码（Pro）";
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)deleteAction:(NSIndexPath *)indexPath{
    if (![self.bleDevice isBLEConnected]){
        [Alert showBasicAlertOnVC:self withTitle:@"蓝牙已断开" message:@""];
    }
    
    NSDictionary *dicValue = self.datalist[indexPath.row];
    
    WEAKSELF_ThingSDK
    //删除在线临时密码
    if (self.passwordType == PasswordType_OldOnlineOnce
        || self.passwordType == PasswordType_OldOnlineCycle){
        [self.bleDevice deleteOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                                    pwdId:[dicValue[@"id"] integerValue]
                                                       sn:[dicValue[@"sn"] integerValue]
                                                  success:^(id result) {
            [weakSelf_ThingSDK showAlertOcVC:@"删除在线临时密码成功" message:@""];
        } failure:^(NSError *error) {
            [weakSelf_ThingSDK showAlertOcVC:@"删除在线临时密码报错" message:error.localizedDescription];
        }];
    }
    else if (self.passwordType == PasswordType_ProOnlineCycle){
        [self.bleDevice deleteProOnlinePasswordWithDevId:self.bleDevice.deviceModel.devId
                                             unlockBindingId:[dicValue[@"unlockBindingId"] integerValue]
                                                          sn:[dicValue[@"sn"] integerValue]
                                                     success:^(id result) {
            [weakSelf_ThingSDK showAlertOcVC:@"删除在线临时密码成功" message:@""];
        } failure:^(NSError *error) {
            [weakSelf_ThingSDK showAlertOcVC:@"删除在线临时密码报错" message:error.localizedDescription];
        }];
    }
    
    //离线临时密码需要清空码删除，一次性离线密码没有清空码
    if (self.passwordType == PasswordType_OldOfflineTimes ||
        self.passwordType == PasswordType_ProOfflineTimes){
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"离线密码删除使用清空码"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"获取单个清空码"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
            [self getOneEmptyPwd:indexPath];
        }];
            
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSString *)getVCTitle{
    if (self.passwordType == PasswordType_OldOnlineOnce){
        self.vcTitle = @"在线一次性密码列表（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOnlineCycle){
        self.vcTitle = @"在线周期性密码列表（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOfflineOnce){
        self.vcTitle = @"离线一次性密码列表（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOfflineTimes){
        self.vcTitle = @"离线不限次数密码列表（老公版）";
    }
    else if (self.passwordType == PasswordType_OldOfflineEmptyAll){
        self.vcTitle = @"离线清空码列表（老公版）";
    }
    else if (self.passwordType == PasswordType_ProOnlineCycle){
        self.vcTitle = @"在线自定义密码列表（Pro）";
    }
    else if (self.passwordType == PasswordType_ProOfflineTimes
             || self.passwordType == PasswordType_ProOfflineOnce
             || self.passwordType == PasswordType_ProOfflineEmptyAll){
        self.vcTitle = @"离线密码列表（Pro）";
    }
    
    return self.vcTitle;
}

- (void)clearResultBtnClicked:(UIButton *)btn{
    self.resultLabel.hidden = YES;
}

- (void)showResultLabel:(NSString *)text{
    self.resultLabel.text = text;
    self.resultLabel.hidden = NO;
}

- (void)showAlertOcVC:(NSString *)title message:(NSString *)message{
    [Alert showBasicAlertOnVC:self withTitle:title message:message];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LockDevicePasswordListRefresh" object:nil];
}

@end
