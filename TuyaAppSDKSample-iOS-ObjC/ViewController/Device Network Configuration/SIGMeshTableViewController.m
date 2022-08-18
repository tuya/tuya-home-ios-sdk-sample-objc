//
//  SIGMeshTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "SIGMeshTableViewController.h"

@interface SIGMeshTableViewController ()<TuyaSmartSIGMeshManagerDelegate>

@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, strong) NSMutableArray<TuyaSmartSIGMeshDiscoverDeviceInfo *> *dataSource;
@property (nonatomic, strong) TuyaSmartSIGMeshManager *manager;

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
    TuyaSmartHome *home = [TuyaSmartHome homeWithHomeId:homeId];
    [home getSIGMeshListWithSuccess:^(NSArray<TuyaSmartBleMeshModel *> * _Nonnull list) {
        self.manager = [TuyaSmartBleMesh initSIGMeshManager:home.sigMeshModel ttl:8 nodeIds:nil];
        self.manager.delegate = self;
        [self.manager startSearch];
    } failure:^(NSError *error) {
        
    }];
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
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    [self.manager startActive:self.dataSource];
}

#pragma mark - TuyaSmartSIGMeshManagerDelegate

- (void)sigMeshManager:(TuyaSmartSIGMeshManager *)manager didScanedDevice:(TuyaSmartSIGMeshDiscoverDeviceInfo *)device{
    [self.dataSource addObject:device];
    [self.tableView reloadData];
}

- (void)sigMeshManager:(TuyaSmartSIGMeshManager *)manager didActiveSubDevice:(TuyaSmartSIGMeshDiscoverDeviceInfo *)device devId:(NSString *)devId error:(NSError *)error{
    if (!error) {
        [self.dataSource removeObject:device];
        [self.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@" ,NSLocalizedString(@"Successfully Added", @"") ,device.mac]];
    }
}

- (void)sigMeshManager:(TuyaSmartSIGMeshManager *)manager didFailToActiveDevice:(TuyaSmartSIGMeshDiscoverDeviceInfo *)device error:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:error.localizedDescription ?: NSLocalizedString(@"Failed to configuration", "")];
}

@end
