//
//  DeviceControlCellHelper.h
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DeviceControlCellType) {
    DeviceControlCellTypeSwitchCell, //"device-switch-cell"
    DeviceControlCellTypeSliderCell, //"device-slider-cell"
    DeviceControlCellTypeEnumCell,   //"device-enum-cell"
    DeviceControlCellTypeStringCell, //"device-string-cell"
    DeviceControlCellTypeLabelCell,   //"device-label-cell"
    DeviceControlCellTypeTextviewCell,   //"device-textview-cell"
};

@interface DeviceControlCellHelper : NSObject
+ (NSString *)cellIdentifierWithSchemaModel:(ThingSmartSchemaModel *)schema;
+ (DeviceControlCellType)cellTypeWithSchemaModel:(ThingSmartSchemaModel *)schema;

+ (NSString *)cellIdentifierWithPropertyModel:(ThingSmartSchemaPropertyModel *)property;
+ (DeviceControlCellType)cellTypeWithPropertyModel:(ThingSmartSchemaPropertyModel *)property;

@end

NS_ASSUME_NONNULL_END
