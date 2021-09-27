//
//  SIGMeshTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "SIGMeshTableViewController.h"

@interface SIGMeshTableViewController ()<TuyaSmartSIGMeshManagerDelegate>

@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, strong) NSMutableArray<TuyaSmartSIGMeshDiscoverDeviceInfo *> *dataSource;

@end

@implementation SIGMeshTableViewController

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopScan];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"SIGMeshCellID"];
}

- (void)stopScan{
    if (!self.isSuccess) {
        [SVProgressHUD dismiss];
    }
    [TuyaSmartSIGMeshManager.sharedInstance stopActiveDevice];
    [TuyaSmartSIGMeshManager.sharedInstance stopSerachDevice];
    TuyaSmartSIGMeshManager.sharedInstance.delegate = nil;
}

- (IBAction)searchClicked:(id)sender {
    long long homeId = [Home getCurrentHome].homeId;
    TuyaSmartBleMeshModel *model = [TuyaSmartHome homeWithHomeId:homeId].sigMeshModel;
    
    if (model == nil) {
        [SVProgressHUD show];
        [TuyaSmartBleMesh createSIGMeshWithHomeId:homeId success:^(TuyaSmartBleMeshModel * _Nonnull meshModel) {
            [TuyaSmartSIGMeshManager.sharedInstance startScanWithScanType:ScanForUnprovision meshModel:meshModel];
            TuyaSmartSIGMeshManager.sharedInstance.delegate = self;
        } failure:^(NSError *error) {
            [SVProgressHUD dismiss];
        }];
        return;
    }
    
    [TuyaSmartSIGMeshManager.sharedInstance startScanWithScanType:ScanForUnprovision meshModel:model];
    TuyaSmartSIGMeshManager.sharedInstance.delegate = self;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = NSMutableArray.new;
    }
    return _dataSource;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SIGMeshCellID" forIndexPath:indexPath];
    TuyaSmartSIGMeshDiscoverDeviceInfo *info = self.dataSource[indexPath.row];
    cell.textLabel.text = info.mac;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    long long homeId = [Home getCurrentHome].homeId;
    TuyaSmartBleMeshModel *model = [TuyaSmartHome homeWithHomeId:homeId].sigMeshModel;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    [TuyaSmartSIGMeshManager.sharedInstance startActive:self.dataSource meshModel:model];
}

#pragma mark - TuyaSmartSIGMeshManagerDelegate

- (void)sigMeshManager:(TuyaSmartSIGMeshManager *)manager didScanedDevice:(TuyaSmartSIGMeshDiscoverDeviceInfo *)device{
    [self.dataSource addObject:device];
    [self.tableView reloadData];
}

- (void)sigMeshManager:(TuyaSmartSIGMeshManager *)manager didActiveSubDevice:(TuyaSmartSIGMeshDiscoverDeviceInfo *)device devId:(NSString *)devId error:(NSError *)error{
    long long homeId = [Home getCurrentHome].homeId;
    TuyaSmartBleMeshModel *model = [TuyaSmartHome homeWithHomeId:homeId].sigMeshModel;
    [TuyaSmartSIGMeshManager.sharedInstance startScanWithScanType:ScanForProxyed meshModel:model];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
        self.isSuccess = YES;
        NSString *name = device.mac ?: NSLocalizedString(@"Unknown Name", @"Unknown name device.");
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@" ,NSLocalizedString(@"Successfully Added", @"") ,name]];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)sigMeshManager:(TuyaSmartSIGMeshManager *)manager didFailToActiveDevice:(TuyaSmartSIGMeshDiscoverDeviceInfo *)device error:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:error.localizedDescription ?: NSLocalizedString(@"Failed to configuration", "")];
}

@end
