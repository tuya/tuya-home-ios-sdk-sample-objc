//
//  DeviceControlCellHelper.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceControlCellHelper.h"

@implementation DeviceControlCellHelper
+ (NSString *)cellIdentifierWithSchemaModel:(TuyaSmartSchemaModel *)schema {
    NSString *type = [schema.type isEqualToString:@"obj"] ? schema.property.type : schema.type;
    NSString *identifier = [self _cellIdentifierFromTypeString:type];
    return identifier;
}

+ (DeviceControlCellType)cellTypeWithSchemaModel:(TuyaSmartSchemaModel *)schema {
    NSString *typeStr = [schema.type isEqualToString:@"obj"] ? schema.property.type : schema.type;
    DeviceControlCellType type = [self _cellTypeFormTypeString:typeStr];
    return type;
}

+ (NSString *)cellIdentifierWithPropertyModel:(TuyaSmartSchemaPropertyModel *)property {
    NSString *identifier = [self _cellIdentifierFromTypeString:property.type];
    return identifier;
}

+ (DeviceControlCellType)cellTypeWithPropertyModel:(TuyaSmartSchemaPropertyModel *)property {
    DeviceControlCellType type = [self _cellTypeFormTypeString:property.type];
    return type;
}

+ (NSString *)_cellIdentifierFromTypeString:(NSString *)typeString {
    NSString *type = [typeString copy];
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
    } else if ([type isEqualToString:@"array"]) {
        return @"device-textview-cell";
    } else if ([type isEqualToString:@"struct"]) {
        return @"device-textview-cell";
    }
    return @"device-label-cell";
}

+ (DeviceControlCellType)_cellTypeFormTypeString:(NSString *)typeString {
    NSString *type = [typeString copy];
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
    } else if ([type isEqualToString:@"array"]) {
        return DeviceControlCellTypeTextviewCell;
    } else if ([type isEqualToString:@"struct"]) {
        return DeviceControlCellTypeTextviewCell;
    }
    return DeviceControlCellTypeLabelCell;
}
@end
