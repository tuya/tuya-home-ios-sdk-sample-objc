//
//  DeviceListTableViewController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "DeviceListTableViewController.h"
#import "Home.h"
#import "Alert.h"
#import "DeviceControlTableViewController.h"
#import "ThingLinkDeviceControlController.h"
#import "CameraPanelEntry.h"

@interface DeviceListTableViewController () <ThingSmartHomeDelegate>
@property (strong, nonatomic) ThingSmartHome *home;
@end

@implementation DeviceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([Home getCurrentHome]) {
        self.home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        self.home.delegate = self;
        [self updateHomeDetail];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.home?self.home.deviceList.count:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"device-list-cell" forIndexPath:indexPath];
    ThingSmartDeviceModel *deviceModel = self.home.deviceList[indexPath.row];
    cell.textLabel.text = deviceModel.name;
    cell.detailTextLabel.text = deviceModel.isOnline ? NSLocalizedString(@"Online", @"") : NSLocalizedString(@"Offline", @"");
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *deviceID = self.home.deviceList[indexPath.row].devId;
    ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:deviceID];
    
    ThingSmartDeviceModel *deviceModel = device.deviceModel;
    if ([CameraPanelEntry openCameraPanelWithDeviceModel:deviceModel]) {
        return;
    }

    BOOL isSupportThingModel = [deviceModel isSupportThingModelDevice];
    
    NSString *identifier = isSupportThingModel ? @"ThingLinkDeviceControlController" : @"DeviceControlTableViewController";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DeviceList" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    if (isSupportThingModel) {
        [self _jumpThingLinkDeviceControl:(ThingLinkDeviceControlController*)vc device:device];
    } else {
        [self _jumpNormalDeviceControl:(DeviceControlTableViewController*)vc device:device];
    }
}

- (void)_jumpThingLinkDeviceControl:(ThingLinkDeviceControlController *)vc device:(ThingSmartDevice *)device {
    void(^goThingLinkControl)(void) = ^() {
        vc.device = device;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    if (device.deviceModel.thingModel) {
        goThingLinkControl();
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Fetching Thing Model", @"")];
    [device getThingModelWithSuccess:^(ThingSmartThingModel * _Nullable thingModel) {
        [SVProgressHUD dismiss];
        goThingLinkControl();
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Failed to Fetch Thing Model", @"")];
    }];
}

- (void)_jumpNormalDeviceControl:(DeviceControlTableViewController *)vc device:(ThingSmartDevice *)device {
    vc.device = device;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)updateHomeDetail {
    [self.home getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:NSLocalizedString(@"Failed to Fetch Home", @"") message:error.localizedDescription];
    }];
}

- (void)homeDidUpdateInfo:(ThingSmartHome *)home {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home didAddDeivice:(ThingSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home didRemoveDeivice:(NSString *)devId {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home deviceInfoUpdate:(ThingSmartDeviceModel *)device {
    [self.tableView reloadData];
}

-(void)home:(ThingSmartHome *)home device:(ThingSmartDeviceModel *)device dpsUpdate:(NSDictionary *)dps {
    [self.tableView reloadData];
}
@end
