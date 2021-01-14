//
//  HomeListTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "HomeListTableViewController.h"
#import "Alert.h"
#import "HomeDetailTableViewController.h"

@interface HomeListTableViewController ()
@property(strong, nonatomic) TuyaSmartHomeManager *homeManager;
@property(strong, nonatomic) NSMutableArray<TuyaSmartHomeModel *> *homeList;
@end

@implementation HomeListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"home-list-cell" forIndexPath:indexPath];
    cell.textLabel.text = self.homeList[indexPath.row].name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"show-home-detail" sender:self.homeList[indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:@"show-home-detail"]) {
        return;
    }
    
    if (![sender isKindOfClass:[TuyaSmartHomeModel class]]) {
        return;
    }
    
    TuyaSmartHomeModel *model = sender;
    if ([segue.destinationViewController isKindOfClass:[HomeDetailTableViewController class]]) {
        ((HomeDetailTableViewController*)(segue.destinationViewController)).homeModel = model;
    }
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
