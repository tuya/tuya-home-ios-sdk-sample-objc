//
//  ThingLinkDeviceControlController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

#import "ThingLinkDeviceControlController.h"
#import "DeviceDetailTableViewController.h"
#import "SVProgressHUD.h"
#import "DeviceControlCellHelper.h"
#import "NotificationName.h"
#import <YYModel/YYModel.h>
#import "SwitchTableViewCell.h"
#import "SliderTableViewCell.h"
#import "EnumTableViewCell.h"
#import "StringTableViewCell.h"
#import "LabelTableViewCell.h"
#import "TextViewTableViewCell.h"
#import "ThingLinkActionMsgSendController.h"

@interface ThingLinkDeviceControlController ()<ThingSmartDeviceDelegate>

@end

@implementation ThingLinkDeviceControlController

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

- (void)publishProperty:(NSDictionary *)payload {
    [self.device publishThingMessageWithType:ThingSmartThingMessageTypeProperty payload:payload success:^{
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)publishAction:(NSString *)action payload:(NSDictionary *)payload {
    if (!action || !payload) {
        [SVProgressHUD showErrorWithStatus:@"params error"];
        return;
    }
    [self.device publishThingMessageWithType:ThingSmartThingMessageTypeAction payload:@{
        @"actionCode": action,
        @"inputParams": payload
    } success:^{
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"properties";
    } else if (section == 1) {
        return @"actions";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ThingSmartThingModel *thing = self.device.deviceModel.thingModel;
    if (!thing) {
        return 0;
    } else {
        if (section == 0) {
            return thing.services.firstObject.properties.count;
        } else if (section == 1) {
            return thing.services.firstObject.actions.count;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartDevice *device = self.device;
    ThingSmartThingModel *thing = self.device.deviceModel.thingModel;
    ThingSmartThingServiceModel *service = thing.services.firstObject;
    
    if (indexPath.section == 0) {
        NSArray *properties = service.properties;
        ThingSmartThingProperty *property = properties[indexPath.row];
        bool isReadOnly = [property.accessMode isEqualToString:@"ro"];
        
        NSDictionary *dps = device.deviceModel.dps;
        
        ThingSmartSchemaPropertyModel *typeSpec = [ThingSmartSchemaPropertyModel yy_modelWithDictionary:property.typeSpec];
        NSString *cellIdentifier       = [DeviceControlCellHelper cellIdentifierWithPropertyModel:typeSpec];
        DeviceControlCellType cellType = [DeviceControlCellHelper cellTypeWithPropertyModel:typeSpec];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        NSString *dpId = @(property.abilityId).stringValue;
        NSString *code = property.code;
        
        switch (cellType) {
            case DeviceControlCellTypeSwitchCell:
            {
                ((SwitchTableViewCell *)cell).label.text = code;
                [((SwitchTableViewCell *)cell).switchButton setOn:[dps[dpId] boolValue]];
                ((SwitchTableViewCell *)cell).isReadOnly = isReadOnly;
                ((SwitchTableViewCell *)cell).switchAction = ^(UISwitch *switchButton) {
                    [self publishProperty:@{ code: [NSNumber numberWithBool:switchButton.isOn] }];
                };
                break;
            }
            case DeviceControlCellTypeSliderCell:
            {
                ((SliderTableViewCell *)cell).label.text = code;
                ((SliderTableViewCell *)cell).detailLabel.text = [dps[dpId] stringValue];
                ((SliderTableViewCell *)cell).slider.minimumValue = typeSpec.min;
                ((SliderTableViewCell *)cell).slider.maximumValue = typeSpec.max;
                [((SliderTableViewCell *)cell).slider setContinuous:NO];
                ((SliderTableViewCell *)cell).slider.value = [dps[dpId] floatValue];
                ((SliderTableViewCell *)cell).isReadOnly = isReadOnly;
                ((SliderTableViewCell *)cell).sliderAction = ^(UISlider * _Nonnull slider) {
                    float step = typeSpec.step;
                    float roundedValue = round(slider.value / step) * step;
                    [self publishProperty:@{code : @((int)roundedValue)}];
                };
                break;
            }
            case DeviceControlCellTypeEnumCell:
            {
                ((EnumTableViewCell *)cell).label.text = code;
                ((EnumTableViewCell *)cell).optionArray = [typeSpec.range mutableCopy];
                ((EnumTableViewCell *)cell).currentOption = dps[dpId];
                ((EnumTableViewCell *)cell).detailLabel.text = dps[dpId];
                ((EnumTableViewCell *)cell).isReadOnly = isReadOnly;
                ((EnumTableViewCell *)cell).selectAction = ^(NSString * _Nonnull option) {
                    [self publishProperty:@{code: option}];
                };
                break;
            }
            case DeviceControlCellTypeStringCell:
            {
                ((StringTableViewCell *)cell).label.text = code;
                ((StringTableViewCell *)cell).textField.text = dps[dpId];
                ((StringTableViewCell *)cell).isReadOnly = isReadOnly;
                ((StringTableViewCell *)cell).buttonAction = ^(NSString * _Nonnull text) {
                    [self publishProperty:@{code: text}];
                };
                break;
            }
            case DeviceControlCellTypeLabelCell:
            {
                ((LabelTableViewCell *)cell).label.text = code;
                ((LabelTableViewCell *)cell).detailLabel.text = [dps[dpId] thingsdk_JSONString];
                break;
            }
            case DeviceControlCellTypeTextviewCell:
            {
                ((TextViewTableViewCell *)cell).title.text = code;
                ((TextViewTableViewCell *)cell).textview.text = [dps[dpId] thingsdk_JSONString];
                ((TextViewTableViewCell *)cell).isReadOnly = isReadOnly;
                ((TextViewTableViewCell *)cell).buttonAction = ^(NSString * _Nonnull text) {
                    NSDictionary *dict = [text thingsdk_objectFromJSONString];
                    if (dict) {
                        [self publishProperty:@{code: dict}];
                    } else {
                        [SVProgressHUD showErrorWithStatus:@"Not json string"];
                    }
                };
                    
                break;
            }
            default:
                break;
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        NSArray *actions = service.actions;
        ThingSmartThingAction *action = actions[indexPath.row];
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"default-cell"];
        cell.textLabel.text = action.code;
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSArray *actions = self.device.deviceModel.thingModel.services.firstObject.actions;
        ThingSmartThingAction *action = actions[indexPath.row];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"DeviceList" bundle:nil];
        ThingLinkActionMsgSendController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ThingLinkActionMsgSendController"];
        vc.action = action;
        WEAKSELF_ThingSDK
        [vc setCallback:^(NSDictionary *dict) {
            [weakSelf_ThingSDK publishAction:action.code payload:dict];
        }];
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(void)deviceInfoUpdate:(ThingSmartDevice *)device {
    [self detectDeviceAvailability];
    [self.tableView reloadData];
}

-(void)deviceRemoved:(ThingSmartDevice *)device {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeviceOffline object:nil];
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"The device has been removed.", @"")];
}

- (void)device:(ThingSmartDevice *)device didReceiveThingMessageWithType:(ThingSmartThingMessageType)thingMessageType payload:(NSDictionary *)payload {
    if (thingMessageType == ThingSmartThingMessageTypeProperty) {
        [self detectDeviceAvailability];
        [self.tableView reloadData];
    } else if (thingMessageType == ThingSmartThingMessageTypeAction) {
        NSLog(@"--- action: %@", payload);
        NSString *code = payload[@"actionCode"];
        NSDictionary *outputParams = payload[@"outputParams"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:code message:outputParams.thingsdk_JSONString preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else if (thingMessageType == ThingSmartThingMessageTypeEvent) {
        NSLog(@"--- event: %@", payload);
        
        NSString *code = payload[@"eventCode"];
        NSDictionary *outputParams = payload[@"outputParams"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:code message:outputParams.thingsdk_JSONString preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void)device:(ThingSmartDevice *)device dpsUpdate:(NSDictionary *)dps {
    NSLog(@"---dps update: %@", dps);
}
@end
