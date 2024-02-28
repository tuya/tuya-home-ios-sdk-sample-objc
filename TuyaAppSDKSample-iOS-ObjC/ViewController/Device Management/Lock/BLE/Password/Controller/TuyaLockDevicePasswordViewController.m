//
//  TuyaLockDevicePasswordViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDevicePasswordViewController.h"
#import <ThingSmartLockKit/ThingSmartBLELockDevice.h>
#import <ThingSmartLockKit/ThingSmartBLELockScheduleModel.h>
#import "TuyaLockDevicePasswordListViewController.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDevicePasswordViewController ()
<UITableViewDelegate,
UITableViewDataSource,
ThingSmartBLELockDeviceDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示
@property (strong, nonatomic) UIButton *clearResultBtn;//结果清除按钮
@property (strong, nonatomic) NSDictionary *dicData;

@property (strong, nonatomic) NSArray *sectionArray;

@end

@implementation TuyaLockDevicePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.bleDevice.deviceModel.name;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    
    self.clearResultBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.resultLabel.frame.size.width - 100,0,100, 40)];
    self.clearResultBtn.backgroundColor = [UIColor redColor];
    [self.clearResultBtn setTitle:@"清除结果" forState:UIControlStateNormal];
    [self.clearResultBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.clearResultBtn addTarget:self action:@selector(clearResultBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.resultLabel addSubview:self.clearResultBtn];
    
    self.sectionArray = @[
        @"动态密码",
        @"在线密码（老公版）",
        @"离线密码（老公版）",
        @"在线密码（Pro）",
        @"离线密码（Pro）"
    ];
    
    self.dicData = @{@"动态密码":@[@"创建动态密码"],
                     @"在线密码（老公版）":@[@"一次性密码",@"周期性密码"],
                     @"离线密码（老公版）":@[@"一次性密码",@"不限次数密码",@"清空码"],
                     @"在线密码（Pro）":@[@"自定义"],
                     @"离线密码（Pro）":@[@"限时",@"单次",@"清空码"],
    };
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.sectionArray.count > 0){
        return self.sectionArray.count;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *keySection = [self.sectionArray objectAtIndex:section];
    NSArray *rowsArray = [self.dicData objectForKey:keySection];
    return rowsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *keySection = [self.sectionArray objectAtIndex:section];
    return keySection;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *keySection = [self.sectionArray objectAtIndex:indexPath.section];
    NSArray *rowsArray = [self.dicData objectForKey:keySection];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = rowsArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            [self.bleDevice getLockDynamicPasswordWithSuccess:^(NSString *result) {
                [self showResultLabel:[@"动态密码：" stringByAppendingString:result]];
            } failure:^(NSError *error) {
                [self showResultLabel:[@"获取动态密码报错：" stringByAppendingString:error.localizedDescription]];
            }];
        }
    }
    //在线密码（老公版）
    else if (indexPath.section == 1){
        TuyaLockDevicePasswordListViewController *vc = [[TuyaLockDevicePasswordListViewController alloc] init];
        vc.devId = self.devId;
        //一次性密码
        if (indexPath.row == 0){
            vc.passwordType = PasswordType_OldOnlineOnce;
        }
        //周期性密码
        else if (indexPath.row == 1){
            vc.passwordType = PasswordType_OldOnlineCycle;
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    //离线密码（老公版）
    else if (indexPath.section == 2){
        TuyaLockDevicePasswordListViewController *vc = [[TuyaLockDevicePasswordListViewController alloc] init];

        //一次性密码
        if (indexPath.row == 0){
            vc.passwordType = PasswordType_OldOfflineOnce;
        }
        //不限次数密码
        else if (indexPath.row == 1){
            vc.passwordType = PasswordType_OldOfflineTimes;
        }
        //清空码（所有）
        else if (indexPath.row == 2){
            vc.passwordType = PasswordType_OldOfflineEmptyAll;
        }

        
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    //在线密码(Pro)
    else if (indexPath.section == 3){
        //自定义密码
        if (indexPath.row == 0){
            TuyaLockDevicePasswordListViewController *vc = [[TuyaLockDevicePasswordListViewController alloc] init];
            vc.devId = self.devId;
            vc.passwordType = PasswordType_ProOnlineCycle;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    //离线密码(Pro)
    else if (indexPath.section == 4){
        TuyaLockDevicePasswordListViewController *vc = [[TuyaLockDevicePasswordListViewController alloc] init];
        //限时密码
        if (indexPath.row == 0){
            vc.passwordType = PasswordType_ProOfflineTimes;
        }
        //单次密码
        else if (indexPath.row == 1){
            vc.passwordType = PasswordType_ProOfflineOnce;
        }
        //清空码
        else if (indexPath.row == 2){
            vc.passwordType = PasswordType_ProOfflineEmptyAll;
        }
        
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)clearResultBtnClicked:(UIButton *)btn{
    self.resultLabel.hidden = YES;
}

- (void)showResultLabel:(NSString *)text{
    self.resultLabel.text = text;
    self.resultLabel.hidden = NO;
}

#pragma mark - ThingSmartBLELockDeviceDelegate

- (void)device:(ThingSmartBLELockDevice *)device didReceiveCreatePasswordMessage:(ThingSmartBLELockPasswordModel *)model{
    NSLog(@"");
}

- (void)device:(ThingSmartBLELockDevice *)device didReceiveModifyPasswordMessage:(ThingSmartBLELockPasswordModel *)model{
    NSLog(@"");
}

- (void)device:(ThingSmartBLELockDevice *)device didReceiveDeletePasswordMessage:(ThingSmartBLELockPasswordModel *)model{
    NSLog(@"");
}

@end
