//
//  TuyaLockDeviceSettingViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceSettingViewController.h"
#import "ThingSmartBLELockDevice.h"
#import "TuyaLockDeviceRemoteSettingViewController.h"
#import "TuyaLinkDeviceControlController.h"
#import "DeviceControlTableViewController.h"

#define kResultLabelMargin 20
#define kResultLabelHeight 250

@interface TuyaLockDeviceSettingViewController ()<
UITableViewDelegate,
UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *datalist;
@property (strong, nonatomic) UILabel *resultLabel;//操作成功、操作失败、失败原因提示
@property (strong, nonatomic) NSMutableDictionary *dpDic;

@end

@implementation TuyaLockDeviceSettingViewController

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
    
    self.datalist = [NSMutableArray arrayWithArray:@[
        @"远程解锁设置",
    ]];
    
    self.dpDic = [[NSMutableDictionary alloc] init];
    
    //自动落锁
    if ([self getDpIdWithDpCode:@"automatic_lock"].length > 0){
        [self.datalist addObject:@"自动落锁"];
    }
    
    //门锁音量
    if ([self getDpIdWithDpCode:@"doorbell_volume"].length > 0){
        [self.datalist addObject:@"门锁音量"];
    }
    
    //按键音量
    if ([self getDpIdWithDpCode:@"key_tone"].length > 0){
        [self.datalist addObject:@"按键音量"];
    }
    
    //语音播报音量
    if ([self getDpIdWithDpCode:@"beep_volume"].length > 0){
        [self.datalist addObject:@"语音播报音量"];
    }
    
    //门锁语言
    if ([self getDpIdWithDpCode:@"language"].length > 0){
        [self.datalist addObject:@"门锁语言"];
    }
    
    //电机扭力
    if ([self getDpIdWithDpCode:@"motor_torque"].length > 0){
        [self.datalist addObject:@"电机扭力"];
    }
    
    //门锁方向
    if ([self getDpIdWithDpCode:@"lock_motor_direction"].length > 0){
        [self.datalist addObject:@"门锁方向"];
    }
    
    //特殊功能
    if ([self getDpIdWithDpCode:@"special_function"].length > 0){
        [self.datalist addObject:@"特殊功能"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = self.datalist[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0){
        TuyaLockDeviceRemoteSettingViewController *vc = [[TuyaLockDeviceRemoteSettingViewController alloc] init];
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];

        BOOL isSupportThingModel = [device.deviceModel isSupportThingModelDevice];
        
        NSString *identifier = isSupportThingModel ? @"TuyaLinkDeviceControlController" : @"DeviceControlTableViewController";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DeviceList" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
        
        if (isSupportThingModel) {
            [self _jumpTuyaLinkDeviceControl:(TuyaLinkDeviceControlController*)vc device:device];
        } else {
            [self _jumpNormalDeviceControl:(DeviceControlTableViewController*)vc device:device];
        }
    }
}

#pragma mark - jump

- (void)_jumpTuyaLinkDeviceControl:(TuyaLinkDeviceControlController *)vc device:(ThingSmartDevice *)device {
    void(^goTuyaLinkControl)(void) = ^() {
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    if (device.deviceModel.thingModel) {
        goTuyaLinkControl();
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching Thing Model", @"")];
    [device getThingModelWithSuccess:^(ThingSmartThingModel * _Nullable thingModel) {
        [SVProgressHUD dismiss];
        goTuyaLinkControl();
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to Fetch Thing Model", @"")];
    }];
}

- (void)_jumpNormalDeviceControl:(DeviceControlTableViewController *)vc device:(ThingSmartDevice *)device {
    vc.device = device;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
