//
//  TuyaLockDeviceUnlockOrLockViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockOrLockViewController.h"
#import <ThingSmartLockKit/ThingSmartBLELockDevice.h>
#import "Alert.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDeviceUnlockOrLockViewController ()<UITableViewDelegate,UITableViewDataSource,ThingSmartBLELockDeviceDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示
@property (strong, nonatomic) ThingSmartBLELockDevice *bleLockDevice;

@end

@implementation TuyaLockDeviceUnlockOrLockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bleDevice = [[ThingSmartBLELockDevice alloc] initWithDeviceId:self.devId];
    self.bleDevice.delegate = self;
    
    ///Init view.
    self.title = @"Lock";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(kResultLabelMargin, [UIScreen mainScreen].bounds.size.height - kResultLabelHeight, [UIScreen mainScreen].bounds.size.width - 2*kResultLabelMargin, kResultLabelHeight)];
    self.resultLabel.backgroundColor = [UIColor clearColor];
    self.resultLabel.textColor = [UIColor blueColor];
    self.resultLabel.font = [UIFont systemFontOfSize:20];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.resultLabel.numberOfLines = 0;
    [self.view addSubview:self.resultLabel];
    
    self.datalist = @[
        @"单击开锁",
        @"单击关锁",
        @"远程开锁",
        @"远程解锁",
        @"蓝牙状态查询",
        @"下发T0时间",
        @"面板配置信息查询"
    ];
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
        case 0: {//蓝牙开锁
            [self.bleLockDevice getCurrentMemberDetailWithDevId:self.devId gid:self.bleLockDevice.deviceModel.homeId success:^(NSDictionary *dict) {
                NSString *bleUnlock = [dict objectForKey:@"lockUserId"];
                [weakSelf_ThingSDK.bleLockDevice bleUnlock:bleUnlock success:^{
                    NSLog(@"bleLockDevice success!");
                    [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"开锁成功" message:@""];
                } failure:^(NSError *error) {
                    NSLog(@"bleLockDevice failure!");
                }];
            } failure:^(NSError *error) {
                NSLog(@"getCurrentMemberDetailWithDevId failure!");
            }];
        }
            break;
        case 1://蓝牙关锁
        {
            [self.bleLockDevice bleManualLock:^{
                NSLog(@"bleManualLock success!");
            } failure:^(NSError *error) {
                NSLog(@"bleManualLock failure: %ld", error.code);
            }];
        }
            break;
        case 2://远程解锁
        {
            [self.bleLockDevice remoteSwitchLock:^(BOOL result) {
                NSLog(@"remoteSwitchLock success!");
            } failure:^(NSError *error) {
                NSLog(@"remoteSwitchLock failure!");
            }];
        }
            break;
        case 3://远程关锁
        {
            [self.bleLockDevice manualLockWithStatus:^{
                NSLog(@"manualLockWithStatus success!");
            } failure:^(NSError *error) {
                NSLog(@"manualLockWithStatus failure!");
            }];
        }
            break;
        case 4:
        {
            if (![self.bleLockDevice isBLEConnected]){
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"连接失败" message:@""];
            }else{
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"蓝牙已连接" message:@""];
            }
        }
            break;
        case 5:
        {
            [self.bleDevice getSyncBatchDataWithDevId:self.devId
                                              success:^(id result) {
                NSDictionary *activeTimeDic = result[@"activeTime"];
                if (activeTimeDic) {
                    BOOL distributed = [activeTimeDic[@"distributed"] boolValue];
                    NSString *dpId = [activeTimeDic[@"dpId"] stringValue];
                    NSString *dpValue = [activeTimeDic[@"ins"] stringValue];
                    if (distributed) {
                        [self.bleDevice publishDps:@{dpId : dpValue} success:^{
                            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"同步数据下发成功" message:@""];
                        } failure:^(NSError *error) {
                            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"同步数据下发失败" message:@""];
                        }];
                    }
                    else{
                        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"无需同步下发数据" message:@""];
                    }
                }
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"同步数据接口请求失败" message:error.localizedDescription];
            }];
        }
            
            break;
        case 6:
        {   
            [self.bleDevice getLockDeviceConfigWithProductId:self.bleLockDevice.deviceModel.productId
                                                     options:@"uiContent,cloudDp,powerCode"
                                                     success:^(id result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"接口请求成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"配置接口请求失败" message:error.localizedDescription];
            }];
            
        }
            break;
            
        default:
            break;
    }
}

- (ThingSmartBLELockDevice *)bleLockDevice{
    if (!_bleLockDevice){
        _bleLockDevice = [[ThingSmartBLELockDevice alloc] initWithDeviceId:self.devId];
    }
    
    return _bleLockDevice;
}

#pragma mark - Helper
- (int)hexToInt:(NSString *)hexString {
    if (!([hexString hasPrefix:@"0x"] || [hexString hasPrefix:@"0X"])) {
        return 0;
    }
    int result = 0;
    for (unsigned long i = hexString.length - 1; i > 1; i--) { // 最后一位到x之前
        NSString *subStr = [[hexString substringFromIndex:i] substringToIndex:1];
        int value = [subStr intValue];
        int multiplier = pow(16, hexString.length - 1 - i);
        result += value * multiplier;
    }
    return result;
}

@end
