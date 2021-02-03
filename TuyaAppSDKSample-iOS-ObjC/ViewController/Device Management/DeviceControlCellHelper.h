//
//  DeviceControlCellHelper.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DeviceControlCellType) {
    switchCell, //"device-switch-cell"
    sliderCell, //"device-slider-cell"
    enumCell,   //"device-enum-cell"
    stringCell, //"device-string-cell"
    labelCell   //"device-label-cell"
};

@interface DeviceControlCellHelper : NSObject
+ (NSString *)cellIdentifierWithSchemaModel:(TuyaSmartSchemaModel *)schema;
+ (DeviceControlCellType)cellTypeWithSchemaModel:(TuyaSmartSchemaModel *)schema;
@end

NS_ASSUME_NONNULL_END
