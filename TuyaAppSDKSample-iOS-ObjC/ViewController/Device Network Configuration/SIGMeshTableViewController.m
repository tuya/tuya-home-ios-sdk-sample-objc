//
//  SIGMeshTableViewController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "SIGMeshTableViewController.h"

@interface SIGMeshTableViewController ()<ThingSmartSIGMeshManagerDelegate>

@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, strong) NSMutableArray<ThingSmartSIGMeshDiscoverDeviceInfo *> *dataSource;
@property (nonatomic, strong) ThingSmartSIGMeshManager *manager;

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
    [ThingSmartSIGMeshManager.sharedInstance stopActiveDevice];
    [ThingSmartSIGMeshManager.sharedInstance stopSerachDevice];
    ThingSmartSIGMeshManager.sharedInstance.delegate = nil;
}

- (IBAction)searchClicked:(id)sender {
    long long homeId = [Home getCurrentHome].homeId;
    ThingSmartHome *home = [ThingSmartHome homeWithHomeId:homeId];
    [home getSIGMeshListWithSuccess:^(NSArray<ThingSmartBleMeshModel *> * _Nonnull list) {
        self.manager = [ThingSmartBleMesh initSIGMeshManager:home.sigMeshModel ttl:8 nodeIds:nil];
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
    ThingSmartSIGMeshDiscoverDeviceInfo *info = self.dataSource[indexPath.row];
    cell.textLabel.text = info.mac;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Configuring", @"")];
    [self.manager startActive:self.dataSource];
}

#pragma mark - ThingSmartSIGMeshManagerDelegate

- (void)sigMeshManager:(ThingSmartSIGMeshManager *)manager didScanedDevice:(ThingSmartSIGMeshDiscoverDeviceInfo *)device{
    [self.dataSource addObject:device];
    [self.tableView reloadData];
}

- (void)sigMeshManager:(ThingSmartSIGMeshManager *)manager didActiveSubDevice:(ThingSmartSIGMeshDiscoverDeviceInfo *)device devId:(NSString *)devId error:(NSError *)error{
    if (!error) {
        [self.dataSource removeObject:device];
        [self.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ %@" ,NSLocalizedString(@"Successfully Added", @"") ,device.mac]];
    }
}

- (void)sigMeshManager:(ThingSmartSIGMeshManager *)manager didFailToActiveDevice:(ThingSmartSIGMeshDiscoverDeviceInfo *)device error:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:error.localizedDescription ?: NSLocalizedString(@"Failed to configuration", "")];
}

@end
