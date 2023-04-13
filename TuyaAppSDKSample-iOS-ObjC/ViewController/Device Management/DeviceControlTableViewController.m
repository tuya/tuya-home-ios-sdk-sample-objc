//
//  DeviceControlTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceControlTableViewController.h"
#import "SVProgressHUD.h"
#import "DeviceControlCellHelper.h"
#import "NotificationName.h"
#import "SwitchTableViewCell.h"
#import "SliderTableViewCell.h"
#import "EnumTableViewCell.h"
#import "StringTableViewCell.h"
#import "LabelTableViewCell.h"
#import "NotificationName.h"
#import "DeviceDetailTableViewController.h"

@interface DeviceControlTableViewController () <TuyaSmartDeviceDelegate>

@end

@implementation DeviceControlTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.device.deviceModel.name;
    self.device.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceHasRemoved:) name:SVProgressHUDDidDisappearNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self detectDeviceAvailability];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceHasRemoved:) name:SVProgressHUDDidDisappearNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show-device-detail"]) {
        ((DeviceDetailTableViewController *)segue.destinationViewController).device = self.device;
    }
}

- (void)publishMessage:(NSDictionary *) dps {
    [self.device publishDps:dps success:^{
            
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)detectDeviceAvailability {
    bool isOnline = self.device.deviceModel.isOnline;
    if (!isOnline) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceOffline object:nil];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"The device is offline. The control panel is unavailable.", @"")];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceOnline object:nil];
        [SVProgressHUD dismiss];
    }
}

- (void)deviceHasRemoved:(NSNotification *)notification {
    NSString *key = notification.userInfo[SVProgressHUDStatusUserInfoKey];
    if ([key containsString:@"removed"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.device) {
        return 0;
    } else {
        return self.device.deviceModel.schemaArray.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    TuyaSmartDevice *device = self.device;
    TuyaSmartSchemaModel *schema = device.deviceModel.schemaArray[indexPath.row];
    NSDictionary *dps = device.deviceModel.dps;
    bool isReadOnly = NO;
    NSString *cellIdentifier = [DeviceControlCellHelper cellIdentifierWithSchemaModel:schema];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    isReadOnly = [@"ro" isEqualToString:schema.mode];
    
    switch ([DeviceControlCellHelper cellTypeWithSchemaModel:schema]) {
        case DeviceControlCellTypeSwitchCell:
        {
            ((SwitchTableViewCell *)cell).label.text = schema.name;
            [((SwitchTableViewCell *)cell).switchButton setOn:[dps[schema.dpId] boolValue]];
            ((SwitchTableViewCell *)cell).isReadOnly = isReadOnly;
            ((SwitchTableViewCell *)cell).switchAction = ^(UISwitch *switchButton) {
                [self publishMessage:@{schema.dpId: [NSNumber numberWithBool:switchButton.isOn]}];
            };
            break;
        }
        case DeviceControlCellTypeSliderCell:
        {
            ((SliderTableViewCell *)cell).label.text = schema.name;
            ((SliderTableViewCell *)cell).detailLabel.text = [dps[schema.dpId] stringValue];
            ((SliderTableViewCell *)cell).slider.minimumValue = schema.property.min;
            ((SliderTableViewCell *)cell).slider.maximumValue = schema.property.max;
            [((SliderTableViewCell *)cell).slider setContinuous:NO];
            ((SliderTableViewCell *)cell).slider.value = [dps[schema.dpId] floatValue];
            ((SliderTableViewCell *)cell).isReadOnly = isReadOnly;
            ((SliderTableViewCell *)cell).sliderAction = ^(UISlider * _Nonnull slider) {
                float step = schema.property.step;
                float roundedValue = round(slider.value / step) * step;
                [self publishMessage:@{schema.dpId : @((int)roundedValue)}];
            };
            break;
        }
        case DeviceControlCellTypeEnumCell:
        {
            ((EnumTableViewCell *)cell).label.text = schema.name;
            ((EnumTableViewCell *)cell).optionArray = [schema.property.range mutableCopy];
            ((EnumTableViewCell *)cell).currentOption = dps[schema.dpId];
            ((EnumTableViewCell *)cell).detailLabel.text = dps[schema.dpId];
            ((EnumTableViewCell *)cell).isReadOnly = isReadOnly;
            ((EnumTableViewCell *)cell).selectAction = ^(NSString * _Nonnull option) {
                [self publishMessage:@{schema.dpId: option}];
            };
            break;
        }
        case DeviceControlCellTypeStringCell:
        {
            ((StringTableViewCell *)cell).label.text = schema.name;
            ((StringTableViewCell *)cell).textField.text = dps[schema.dpId];
            ((StringTableViewCell *)cell).isReadOnly = isReadOnly;
            ((StringTableViewCell *)cell).buttonAction = ^(NSString * _Nonnull text) {
                [self publishMessage:@{schema.dpId: dps[schema.dpId]}];
            };
            break;
        }
        case DeviceControlCellTypeLabelCell:
        {
            ((LabelTableViewCell *)cell).label.text = schema.name;
            ((LabelTableViewCell *)cell).detailLabel.text = [dps[schema.dpId] tysdk_toString];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

-(void)deviceInfoUpdate:(TuyaSmartDevice *)device {
    [self detectDeviceAvailability];
    [self.tableView reloadData];
}

-(void)deviceRemoved:(TuyaSmartDevice *)device {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceOffline object:nil];
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"The device has been removed.", @"")];
}

-(void)device:(TuyaSmartDevice *)device dpsUpdate:(NSDictionary *)dps {
    [self detectDeviceAvailability];
    [self.tableView reloadData];
}
@end
