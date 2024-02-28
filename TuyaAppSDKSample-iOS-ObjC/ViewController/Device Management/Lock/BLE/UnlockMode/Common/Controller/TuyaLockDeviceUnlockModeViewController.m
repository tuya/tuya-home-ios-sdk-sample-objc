//
//  TuyaLockDeviceUnlockModeViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeViewController.h"
#import "Alert.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDeviceUnlockModeViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;
@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示
@end

@implementation TuyaLockDeviceUnlockModeViewController

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
    
    self.datalist = @[
        @"解锁方式同步",
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
            //添加解锁方式之后，dpIds：添加解锁方式的dp
            [self.bleDevice syncDataWithDevId:self.bleDevice.deviceModel.devId
                                        dpIds:@[@"12",@"13"]
                                      success:^(id result) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"解锁方式同步成功" message:@""];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"解锁方式同步失败" message:error.localizedDescription];
            }];
        }
            break;
            
        default:
            break;
    }
}

@end
