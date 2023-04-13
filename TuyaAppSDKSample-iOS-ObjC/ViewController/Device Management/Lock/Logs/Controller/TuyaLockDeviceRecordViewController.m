//
//  TuyaLockDeviceRecordViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceRecordViewController.h"
#import "TuyaLockDeviceRecordListViewController.h"
#import "TuyaLockDeviceRecordListCell.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDeviceRecordViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示
@property (assign, nonatomic) BOOL isPro;
@end

@implementation TuyaLockDeviceRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    if ([self.bleDevice.deviceModel.categoryCode isEqualToString:@"jtmspro_2b_2"]){
        self.datalist = @[
//            @"获取门锁告警记录（老公版）",
//            @"获取门锁开锁记录（老公版）",
            @"带筛选的最新的记录接口（蓝牙PRO）",
        ];
        
        self.isPro = YES;
    }
    else if ([self.bleDevice.deviceModel.categoryCode isEqualToString:@"ble_ms"]){
        self.datalist = @[
            @"获取门锁告警记录（老公版）",
            @"获取门锁开锁记录（老公版）",
//            @"带筛选的最新的记录接口（蓝牙PRO）",
        ];
        
        self.isPro = NO;
    }
}

- (void)gotoRecordList:(int)logType{
    TuyaLockDeviceRecordListViewController *vc = [[TuyaLockDeviceRecordListViewController alloc] init];
    vc.logType = logType;
    vc.bleDevice = self.bleDevice;
    [self.navigationController pushViewController:vc animated:YES];
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
    switch (indexPath.row) {
        case 0: {
            if (self.isPro){
                [self gotoRecordList:3];
            }else{
                [self gotoRecordList:1];
            }
        }
            break;
        case 1:
        {
            [self gotoRecordList:2];
        }
            break;
            
        default:
            break;
    }
}
@end
