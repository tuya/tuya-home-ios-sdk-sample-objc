//
//  DeviceControlCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceControlCell.h"

@implementation DeviceControlCell
+ (NSString *)cellIdentifier:(TuyaSmartSchemaModel *)schema {
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

+ (DeviceControlCellId)cellIdentifierENUM:(TuyaSmartSchemaModel *)schema {
    NSString *type = [schema.type isEqualToString:@"obj"] ? schema.property.type : schema.type;
    if ([type isEqualToString:@"bool"]) {
        return switchCell;
    } else if ([type isEqualToString:@"enum"]) {
        return enumCell;
    } else if ([type isEqualToString:@"value"]) {
        return sliderCell;
    } else if ([type isEqualToString:@"bitmap"]) {
        return labelCell;
    } else if ([type isEqualToString:@"string"]) {
        return stringCell;
    } else if ([type isEqualToString:@"raw"]) {
        return stringCell;
    } else {
        return labelCell;
    }
}
@end
