//
//  SwitchHomeTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "SwitchHomeTableViewController.h"
#import "Alert.h"
#import "Home.h"

@interface SwitchHomeTableViewController ()
@property(strong, nonatomic) TuyaSmartHomeManager *homeManager;
@property(strong, nonatomic) NSMutableArray<TuyaSmartHomeModel *> *homeList;
@end

@implementation SwitchHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.homeManager getHomeListWithSuccess:^(NSArray<TuyaSmartHomeModel *> *homes) {
        self.homeList = [homes mutableCopy];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"Failed to Fetch Home List" message:error.localizedDescription];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.homeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switch-home-cell" forIndexPath:indexPath];
    cell.textLabel.text = self.homeList[indexPath.row].name;
    if (Home.getCurrentHome.homeId == self.homeList[indexPath.row].homeId) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (Home.getCurrentHome.homeId == self.homeList[indexPath.row].homeId) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    for (UITableViewCell *cell in tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [Home setCurrentHome:self.homeList[indexPath.row]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (TuyaSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[TuyaSmartHomeManager alloc] init];
    }
    return _homeManager;
}

- (NSMutableArray<TuyaSmartHomeModel *> *)homeList {
    if (!_homeList) {
        _homeList = [[NSMutableArray alloc] init];
    }
    return _homeList;
}

@end
