//
//  TuyaWiFiDeviceUnlockViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiDeviceUnlockViewController.h"
#import "Alert.h"

@interface TuyaWiFiDeviceUnlockViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;

@end

@implementation TuyaWiFiDeviceUnlockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Lock";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.datalist = @[
        @"远程开锁",
        @"远程关锁",
        @"获取动态密码",
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
        case 0: {
            [self.wifiDevice replyRemoteUnlock:YES success:^{
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"开锁成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"开锁失败" message:@""];
            }];
        }
            break;
        case 1:
        {
            [self.wifiDevice replyRemoteUnlock:NO success:^{
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"关锁成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"关锁失败" message:@""];
            }];
        }
            break;
        case 2:
        {
            [self.wifiDevice getLockDynamicPasswordWithSuccess:^(NSString *result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"动态密码是：" message:result];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取动态密码失败" message:@""];
            }];
        }
            break;
        default:
            break;
    }
}

@end
