//
//  TuyaZigbeeDevicePasswordListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaZigbeeDevicePasswordListViewController.h"
#import <ThingSmartLockKit/ThingSmartZigbeeLockDevice.h>
#import "TuyaZigbeeDevicePasswordFilterView.h"
#import <Masonry/Masonry.h>
#import "Alert.h"
#import "TuyaZigbeeDevicePasswordDetailViewController.h"

@interface TuyaZigbeeDevicePasswordListViewController ()<UITableViewDelegate,UITableViewDataSource,TuyaZigbeeDevicePasswordFilterViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) TuyaZigbeeDevicePasswordFilterView *filterView;
@property (strong, nonatomic) UIButton *addBtn;
@property (strong, nonatomic) UIButton *deleteBtn;

@end

@implementation TuyaZigbeeDevicePasswordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    ///Init view.
    self.title = @"密码列表";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    self.tableView.tableHeaderView = self.filterView;
    
    self.addBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.addBtn.backgroundColor = [UIColor redColor];
    [self.addBtn setTitle:@"添加密码" forState:UIControlStateNormal];
    [self.addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addBtn];
    
    self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.deleteBtn.backgroundColor = [UIColor redColor];
    [self.deleteBtn setTitle:@"删除无效密码" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.deleteBtn.hidden = YES;
    [self.view addSubview:self.deleteBtn];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-30);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(self.view);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-30);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(30);
        make.centerX.equalTo(self.view);
    }];
    
    [self reloadValidData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadValidData) name:@"ZigbeeDevicePasswordListRefresh" object:nil];
}

- (void)reloadValidData{
    WEAKSELF_ThingSDK
    [self.zigbeeDevice getPasswordListWithDevId:self.devId offset:0 limit:50 success:^(id result) {
        weakSelf_ThingSDK.datalist = (NSArray *)result[@"datas"];
        [weakSelf_ThingSDK.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"接口请求失败" message:error.localizedDescription];
    }];
}

- (void)reloadInValidData{
    WEAKSELF_ThingSDK
    [self.zigbeeDevice getInvalidPasswordListWithDevId:self.devId offset:0 limit:50 success:^(id result) {
        weakSelf_ThingSDK.datalist = (NSArray *)result[@"datas"];
        [weakSelf_ThingSDK.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"接口请求失败" message:error.localizedDescription];
    }];
}

- (void)addBtnClicked{
    [self.navigationController presentViewController:[self timeAlert] animated:YES completion:nil];
}

- (void)deleteBtnClicked{
    WEAKSELF_ThingSDK
    [self.zigbeeDevice removeInvalidPasswordWithDevId:self.devId success:^(id result) {
        [weakSelf_ThingSDK reloadInValidData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除失败" message:error.localizedDescription];
    }];
}

#pragma mark TuyaZigbeeDevicePasswordFilterViewDelegate

- (void)validFilter{
    self.addBtn.hidden = NO;
    self.deleteBtn.hidden = YES;
    [self reloadValidData];
}

- (void)invalidFilter{
    self.addBtn.hidden = YES;
    self.deleteBtn.hidden = NO;
    [self reloadInValidData];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ：%@   %@",[dic[@"name"] stringValue],[dic[@"password"] stringValue],[self getPhaseString:dic]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAKSELF_ThingSDK
    NSDictionary *dic = self.datalist[indexPath.row];
    int oneTime = [dic[@"oneTime"] intValue];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@""
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* editAction = [UIAlertAction actionWithTitle:@"编辑"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
        
        TuyaZigbeeDevicePasswordDetailViewController *vc = [TuyaZigbeeDevicePasswordDetailViewController new];
        vc.devId = self.devId;
        vc.title = @"编辑周期密码（ZigBee）";
        vc.pwdType = PasswordType_ZigbeeTempCycle;
        vc.actionType = PasswordActionType_Modify;
        vc.pwdDic = dic;
        [weakSelf_ThingSDK.navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [weakSelf_ThingSDK.zigbeeDevice removeTemporaryPasswordWithDevId:self.devId
                                                                pwdId:[dic[@"id"] integerValue]
                                                                 name:[dic[@"name"] stringValue]
                                                        effectiveTime:[dic[@"effectiveTime"] integerValue]
                                                          invalidTime:[dic[@"invalidTime"] integerValue]
                                                              oneTime:[dic[@"oneTime"] intValue]
                                                              success:^(id result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigbeeDevicePasswordListRefresh" object:nil];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除失败" message:error.localizedDescription];
        }];
    }];
    
    int phase = [dic[@"phase"] intValue];
    UIAlertAction* freezeAction = [UIAlertAction actionWithTitle:(phase == 2 ? @"冻结":@"解冻")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        if (phase == 2){
            [weakSelf_ThingSDK.zigbeeDevice freezeTemporaryPasswordWithDevId:self.devId
                                                                    pwdId:[dic[@"id"] integerValue]
                                                                     name:[dic[@"name"] stringValue]
                                                            effectiveTime:[dic[@"effectiveTime"] integerValue]
                                                              invalidTime:[dic[@"invalidTime"] integerValue]
                                                                  oneTime:[dic[@"oneTime"] intValue]
                                                                  success:^(id result) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigbeeDevicePasswordListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"冻结失败" message:error.localizedDescription];
            }];
        }
        else if (phase == 3){
            [weakSelf_ThingSDK.zigbeeDevice unfreezeTemporaryPasswordWithDevId:self.devId
                                                                      pwdId:[dic[@"id"] integerValue]
                                                                       name:[dic[@"name"] stringValue]
                                                              effectiveTime:[dic[@"effectiveTime"] integerValue]
                                                                invalidTime:[dic[@"invalidTime"] integerValue]
                                                                    oneTime:[dic[@"oneTime"] intValue]
                                                                    success:^(id result) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigbeeDevicePasswordListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"解冻失败" message:error.localizedDescription];
            }];
        }
    }];
    
    UIAlertAction* renameAction = [UIAlertAction actionWithTitle:@"重命名"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [weakSelf_ThingSDK renameAlert:dic];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
    if (phase == 2 && oneTime == 0){
        [alert addAction:editAction];
    }

    [alert addAction:deleteAction];
    
    if (oneTime == 0){
        [alert addAction:freezeAction];
    }
    
    [alert addAction:renameAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)getPhaseString:(NSDictionary *)dic {
    int phase = [dic[@"phase"] intValue];
    int deliveryStatus = [dic[@"phase"] intValue];
    int operate = [dic[@"operate"] intValue];
    Boolean ifEffective = [dic[@"ifEffective"] boolValue];
    
    if (phase == 1){
        return @"待创建";
    }
    else if (phase == 2){
        if (operate == 125){
            if (deliveryStatus == 1){
                return @"删除中";
            }
        }else{
            if (deliveryStatus == 1){
                return @"修改中";
            }
            else if (deliveryStatus == 2 && ifEffective){
                return @"已生效";
            }
            else if (deliveryStatus == 2 && !ifEffective){
                return @"未生效";
            }
        }
        
        return @"正常";
    }
    else if (phase == 3){
        if (deliveryStatus == 1){
            return @"冻结中";
        }
        else if (deliveryStatus == 2){
            return @"已冻结";
        }
    }
    else if (phase == 4){
        return @"已删除";
    }
    else if (phase == 5){
        return @"创建失败";
    }
    
    return nil;
}

- (void)renameAlert:(NSDictionary *)data{
    WEAKSELF_ThingSDK
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"输入密码名称"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        NSString *pwdName = alert.textFields.firstObject.text;
        if (pwdName.length > 0){
            [weakSelf_ThingSDK.zigbeeDevice updateTemporaryPasswordWithDevId:self.devId
                                                                    pwdId:[data[@"id"] integerValue]
                                                                     name:pwdName
                                                                  success:^(id result) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ZigbeeDevicePasswordListRefresh" object:nil];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"重命名失败" message:error.localizedDescription];
            }];
        }else{
            [Alert showBasicAlertOnVC:self withTitle:@"请输入密码名称" message:@""];
        }
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"密码名称";
    }];
        
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UIAlertController *)timeAlert{
    WEAKSELF_ThingSDK
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:@"创建密码" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *onceAction = [UIAlertAction actionWithTitle:@"创建一次性密码" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        TuyaZigbeeDevicePasswordDetailViewController *vc = [TuyaZigbeeDevicePasswordDetailViewController new];
        vc.devId = self.devId;
        vc.title = @"创建一次性密码（ZigBee）";
        vc.pwdType = PasswordType_ZigbeeTempOne;
        vc.actionType = PasswordActionType_Add;
        [weakSelf_ThingSDK.navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction *weekAction = [UIAlertAction actionWithTitle:@"创建周期密码" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        TuyaZigbeeDevicePasswordDetailViewController *vc = [TuyaZigbeeDevicePasswordDetailViewController new];
        vc.title = @"创建周期密码（ZigBee）";
        vc.devId = self.devId;
        vc.pwdType = PasswordType_ZigbeeTempCycle;
        vc.actionType = PasswordActionType_Add;
        [weakSelf_ThingSDK.navigationController pushViewController:vc animated:YES];
    }];
    
    UIAlertAction *dyAction = [UIAlertAction actionWithTitle:@"创建动态密码" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf_ThingSDK.zigbeeDevice getDynamicPasswordWithDevId:self.devId success:^(id result) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"动态密码" message:[result[@"dynamicPassword"] stringValue]];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程开锁失败" message:error.localizedDescription];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {}];
    
    if ([self getDpIdWithDpCode:@"single_use_password"].length > 0){
        [alertViewController addAction:onceAction];
    }

    if ([self getDpIdWithDpCode:@"unlock_dynamic"].length > 0){
        [alertViewController addAction:dyAction];
    }
    
    [alertViewController addAction:weekAction];
    [alertViewController addAction:cancelAction];
    
    return alertViewController;
}


#pragma mark - property

- (TuyaZigbeeDevicePasswordFilterView *)filterView{
    if (!_filterView){
        _filterView = [[TuyaZigbeeDevicePasswordFilterView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 30)];
        _filterView.delegate = self;
    }
    
    return _filterView;
}

@end
