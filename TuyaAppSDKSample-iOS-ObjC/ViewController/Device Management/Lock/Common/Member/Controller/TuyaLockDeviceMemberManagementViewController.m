//
//  TuyaLockDeviceMemberManagementViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceMemberManagementViewController.h"
#import "TuyaLockDeviceMemberListViewController.h"
#import "TuyaLockDeviceAddMemberViewController.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDeviceMemberManagementViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示

@property (strong, nonatomic) NSArray *sectionArray;
@property (strong, nonatomic) NSDictionary *dicData;

@end

@implementation TuyaLockDeviceMemberManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"家庭成员管理";
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
    
    if([self isBLEDevice]){
        self.sectionArray = @[
            @"BLE门锁",
        ];
        self.dicData = @{
            @"BLE门锁":@[@"获取门锁家庭成员列表（PRO）",@"创建单个家庭门锁成员（PRO）"],
        };
    }
    else if ([self isZigbeeDevice]){
        self.sectionArray = @[
            @"Zigbee门锁",
        ];
        self.dicData = @{
            @"Zigbee门锁":@[@"获取门锁家庭成员列表",@"创建单个家庭门锁成员"],
        };
    }
}

- (void)gotoMemberList{
    TuyaLockDeviceMemberListViewController *vc = [[TuyaLockDeviceMemberListViewController alloc] init];
    vc.devId = self.devId;
    [self.navigationController pushViewController:vc animated:YES];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *keySection = [self.sectionArray objectAtIndex:section];
    return keySection;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60;
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
    if (indexPath.row == 0){
        [self gotoMemberList];
    }else if (indexPath.row == 1){
        TuyaLockDeviceAddMemberViewController *vc = [[TuyaLockDeviceAddMemberViewController alloc] init];
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
