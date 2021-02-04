//
//  DeviceControlCellHelper.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceControlCellHelper.h"

@implementation DeviceControlCellHelper
+ (NSString *)cellIdentifierWithSchemaModel:(TuyaSmartSchemaModel *)schema {
    NSString *type = [schema.type isEqualToString:@"obj"] ? schema.property.type : schema.type;
    if ([type isEqualToString:@"bool"]) {
        return @"device-switch-cell";
    } else if ([type isEqualToString:@"enum"]) {
        return @"device-enum-cell";
    } else if ([type isEqualToString:@"value"]) {
        return @"device-slider-cell";
    } else if ([type isEqualToString:@"bitmap"]) {
        return @"device-label-cell";
    } else if ([type isEqualToString:@"string"]) {
        return @"device-string-cell";
    } else if ([type isEqualToString:@"raw"]) {
        return @"device-string-cell";
    } else {
        return @"device-label-cell";
    }
}

+ (DeviceControlCellType)cellTypeWithSchemaModel:(TuyaSmartSchemaModel *)schema {
    NSString *type = [schema.type isEqualToString:@"obj"] ? schema.property.type : schema.type;
    if ([type isEqualToString:@"bool"]) {
        return DeviceControlCellTypeSwitchCell;
    } else if ([type isEqualToString:@"enum"]) {
        return DeviceControlCellTypeEnumCell;
    } else if ([type isEqualToString:@"value"]) {
        return DeviceControlCellTypeSliderCell;
    } else if ([type isEqualToString:@"bitmap"]) {
        return DeviceControlCellTypeLabelCell;
    } else if ([type isEqualToString:@"string"]) {
        return DeviceControlCellTypeStringCell;
    } else if ([type isEqualToString:@"raw"]) {
        return DeviceControlCellTypeStringCell;
    } else {
        return DeviceControlCellTypeLabelCell;
    }
}
@end
