//
//  DeviceControlCellHelper.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DeviceControlCellType) {
    DeviceControlCellTypeSwitchCell, //"device-switch-cell"
    DeviceControlCellTypeSliderCell, //"device-slider-cell"
    DeviceControlCellTypeEnumCell,   //"device-enum-cell"
    DeviceControlCellTypeStringCell, //"device-string-cell"
    DeviceControlCellTypeLabelCell   //"device-label-cell"
};

@interface DeviceControlCellHelper : NSObject
+ (NSString *)cellIdentifierWithSchemaModel:(TuyaSmartSchemaModel *)schema;
+ (DeviceControlCellType)cellTypeWithSchemaModel:(TuyaSmartSchemaModel *)schema;
@end

NS_ASSUME_NONNULL_END
