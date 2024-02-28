//
//  TuyaZigbeeDeviceUnlockViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaZigbeeDeviceUnlockViewController.h"
#import <ThingSmartLockKit/ThingSmartZigbeeLockDevice.h>
#import <ThingSmartLockKit/ThingSmartLockUtil.h>
#import "Alert.h"

@interface TuyaZigbeeDeviceUnlockViewController ()<UITableViewDelegate,UITableViewDataSource,ThingSmartZigbeeLockDeviceDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;

@property (assign, nonatomic) BOOL isAdmin;//是否管理员
@property (assign, nonatomic) BOOL isRemoteOpen;//是否支持远程开锁

@property (strong, nonatomic) ThingSmartZigbeeLockRemotePermissionModel *permissionModel;

@end

@implementation TuyaZigbeeDeviceUnlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.zigbeeDevice = [[ThingSmartZigbeeLockDevice alloc] initWithDeviceId:self.devId];
    
    self.title = @"开关锁";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.datalist = @[
        @"远程开锁",
        @"远程关锁",
        @"安全守护天数",
        @"告警未读数",
    ];
    
    for (NSDictionary *dic in self.memberList) {
        if ([[ThingSmartUser sharedInstance].uid isEqualToString:dic[@"uid"]]){
            int userType = [dic[@"userType"] intValue];
            self.isAdmin = ((userType == 10 || userType == 50) ? YES : NO);
            break;
        }
    }
    
    WEAKSELF_ThingSDK
    [self.zigbeeDevice fetchRemoteUnlockTypeWithDevId:self.devId
                                           success:^(id result) {
        weakSelf_ThingSDK.isRemoteOpen = [result[@"isRemoteOpen"] boolValue];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取远程解锁开关失败" message:error.localizedDescription];
    }];
        
    [self.zigbeeDevice getRemoteUnlockPermissionValueWithDevId:self.devId success:^(ThingSmartZigbeeLockRemotePermissionModel * _Nonnull model) {
        weakSelf_ThingSDK.permissionModel = model;
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"权限设置接口报错" message:error.localizedDescription];
    }];
}

- (void)enterPwd{
    WEAKSELF_ThingSDK
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"请输入开门密码"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
        NSString *pwdString = alert.textFields.firstObject.text;
        if (pwdString.length > 0){
            [weakSelf_ThingSDK.zigbeeDevice remoteUnlockWithDevId:self.devId 
                                                      password:pwdString
                                                       success:^(id result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"含密远程开锁成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"含密远程开锁失败" message:@""];
            }];
        }else{
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"请输入密码" message:@""];
        }
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"密码内容";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];
        
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
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
    cell.textLabel.text = self.datalist[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAKSELF_ThingSDK
    switch (indexPath.row) {
        case 0: {//远程开锁
            if (!self.isRemoteOpen){
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"请打开远程开锁开关" message:@""];
                return;
            }
            
            if ([self.permissionModel.user isEqualToString:@"admin"] && !self.isAdmin){
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"当前用户不是管理员" message:@""];
                return;
            }
            
            //含密远程开锁
            if ([self.permissionModel.way isEqualToString:@"remote_unlock"]){
                [self enterPwd];
            }
            
            //免密远程开锁
            if ([self.permissionModel.way isEqualToString:@"remote_no_dp_key"]){
                [self.zigbeeDevice remoteUnlockWithDevId:self.devId success:^(id result) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程开锁成功" message:@""];
                } failure:^(NSError *error) {
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程开锁失败" message:error.localizedDescription];
                }];
            }
        }
            break;
        case 1://远程关锁
        {
            [self.zigbeeDevice remoteLockWithDevId:self.devId success:^(id result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程关锁成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"远程关锁失败" message:error.localizedDescription];
            }];
        }
            break;
        case 2://安全守护天数
        {
            [self.zigbeeDevice getSecurityGuardDaysWithDevId:self.devId success:^(id result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"安全守护天数" message:[NSString stringWithFormat:@"%d 天",[result intValue]]];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"接口请求失败" message:error.localizedDescription];
            }];
        }
            break;
        case 3://告警未读数
        {
            [self.zigbeeDevice getUnreadAlarmNumberWithDevId:self.devId success:^(id result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"告警未读数" message:[NSString stringWithFormat:@"%d 条",[result intValue]]];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"接口请求失败" message:error.localizedDescription];
            }];
        }
            break;
        default:
            break;
    }
}

@end
