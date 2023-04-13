//
//  TuyaLinkActionMsgSendController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLinkActionMsgSendController.h"
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

@interface TuyaLinkActionMsgSendController ()
@property (nonatomic, strong) NSMutableDictionary *payload;
@property (nonatomic, strong) NSArray<NSDictionary *> *inputParams;
@end

@implementation TuyaLinkActionMsgSendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title       = self.action.code;
    self.payload     = [NSMutableDictionary dictionary];
    self.inputParams = self.action.inputParams;
}

- (IBAction)clicKSendBtn:(id)sender {
    if (self.callback) {
        self.callback(self.payload);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inputParams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *params = self.inputParams[indexPath.row];
    NSString *code = params[@"code"];
    TuyaSmartSchemaPropertyModel *typeSpec = [TuyaSmartSchemaPropertyModel yy_modelWithDictionary:params[@"typeSpec"]];
    
    NSString *cellIdentifier       = [DeviceControlCellHelper cellIdentifierWithPropertyModel:typeSpec];
    DeviceControlCellType cellType = [DeviceControlCellHelper cellTypeWithPropertyModel:typeSpec];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    BOOL isReadOnly = NO;
    
    WEAKSELF_TYSDK
    switch (cellType) {
        case DeviceControlCellTypeSwitchCell:
        {
            ((SwitchTableViewCell *)cell).label.text = code;
            [((SwitchTableViewCell *)cell).switchButton setOn:NO];
            ((SwitchTableViewCell *)cell).isReadOnly = isReadOnly;
            ((SwitchTableViewCell *)cell).switchAction = ^(UISwitch *switchButton) {
                weakSelf_TYSDK.payload[code] = [NSNumber numberWithBool:switchButton.isOn];
            };
            break;
        }
        case DeviceControlCellTypeSliderCell:
        {
            ((SliderTableViewCell *)cell).label.text = code;
            ((SliderTableViewCell *)cell).detailLabel.text = @(typeSpec.min).stringValue;
            ((SliderTableViewCell *)cell).slider.minimumValue = typeSpec.min;
            ((SliderTableViewCell *)cell).slider.maximumValue = typeSpec.max;
            [((SliderTableViewCell *)cell).slider setContinuous:NO];
            ((SliderTableViewCell *)cell).slider.value = typeSpec.min;
            ((SliderTableViewCell *)cell).isReadOnly = isReadOnly;
            ((SliderTableViewCell *)cell).sliderAction = ^(UISlider * _Nonnull slider) {
                float step = typeSpec.step;
                float roundedValue = round(slider.value / step) * step;
                weakSelf_TYSDK.payload[code] =  @((int)roundedValue);
            };
            break;
        }
        case DeviceControlCellTypeEnumCell:
        {
            ((EnumTableViewCell *)cell).label.text = code;
            ((EnumTableViewCell *)cell).optionArray = [typeSpec.range mutableCopy];
            ((EnumTableViewCell *)cell).currentOption = typeSpec.range.firstObject;
            ((EnumTableViewCell *)cell).detailLabel.text = typeSpec.range.firstObject;
            ((EnumTableViewCell *)cell).isReadOnly = isReadOnly;
            ((EnumTableViewCell *)cell).selectAction = ^(NSString * _Nonnull option) {
                weakSelf_TYSDK.payload[code] =  option;
            };
            break;
        }
        case DeviceControlCellTypeStringCell:
        {
            ((StringTableViewCell *)cell).label.text = code;
            ((StringTableViewCell *)cell).textField.text = @"";
            ((StringTableViewCell *)cell).isReadOnly = isReadOnly;
            ((StringTableViewCell *)cell).buttonAction = ^(NSString * _Nonnull text) {
                weakSelf_TYSDK.payload[code] = text;
            };
            break;
        }
        case DeviceControlCellTypeLabelCell:
        {
            ((LabelTableViewCell *)cell).label.text = code;
            ((LabelTableViewCell *)cell).detailLabel.text = @"";
            break;
        }
        case DeviceControlCellTypeTextviewCell:
        {
            ((TextViewTableViewCell *)cell).title.text = code;
            ((TextViewTableViewCell *)cell).textview.text = @"";
            ((TextViewTableViewCell *)cell).isReadOnly = isReadOnly;
            ((TextViewTableViewCell *)cell).buttonAction = ^(NSString * _Nonnull text) {
                NSDictionary *dict = [text tysdk_objectFromJSONString];
                if (dict) {
                    weakSelf_TYSDK.payload[code] =  dict;
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
}

@end
