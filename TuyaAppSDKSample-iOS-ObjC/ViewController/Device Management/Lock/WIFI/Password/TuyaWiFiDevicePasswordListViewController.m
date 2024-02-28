//
//  TuyaWiFiDevicePasswordListViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiDevicePasswordListViewController.h"
#import "TuyaWiFiDevicePasswordDetailViewController.h"
#import <Masonry/Masonry.h>
#import "Alert.h"

@interface TuyaWiFiDevicePasswordListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray<ThingSmartLockTempPwdModel *> *datalist;
@property (strong, nonatomic) UIButton *addBtn;

@end

@implementation TuyaWiFiDevicePasswordListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.title = @"密码列表";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    self.addBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.addBtn.backgroundColor = [UIColor redColor];
    [self.addBtn setTitle:@"添加密码" forState:UIControlStateNormal];
    [self.addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addBtn];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-30);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
        make.centerX.equalTo(self.view);
    }];
    
    [self reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"WiFiDevicePasswordListRefresh" object:nil];
}

- (void)reloadData{
    WEAKSELF_ThingSDK
    [self.wifiDevice getLockTempPwdListWithSuccess:^(NSArray<ThingSmartLockTempPwdModel *> * _Nonnull lockTempPwdModels) {
        weakSelf_ThingSDK.datalist = lockTempPwdModels;
        [weakSelf_ThingSDK.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"接口请求失败" message:error.localizedDescription];
    }];
}

- (void)addBtnClicked{
    TuyaWiFiDevicePasswordDetailViewController *vc = [[TuyaWiFiDevicePasswordDetailViewController alloc] init];
    vc.devId = self.devId;
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
    ThingSmartLockTempPwdModel *model = self.datalist[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ ：%lu  ",model.name,(unsigned long)model.effective];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartLockTempPwdModel *model = self.datalist[indexPath.row];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"删除密码？"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    WEAKSELF_ThingSDK
    UIAlertAction* deleteAction = [UIAlertAction actionWithTitle:@"删除"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
        [weakSelf_ThingSDK.wifiDevice deleteLockTempPwdWithPwdId:model.code force:NO success:^(BOOL result) {
            [weakSelf_ThingSDK reloadData];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"删除失败" message:error.localizedDescription];
        }];
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];

    [alert addAction:cancelAction];
    [alert addAction:deleteAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
