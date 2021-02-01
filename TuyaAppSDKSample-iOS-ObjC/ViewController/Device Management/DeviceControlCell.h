//
//  DeviceControlCell.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DeviceControlCellId) {
    switchCell, //"device-switch-cell"
    sliderCell, //"device-slider-cell"
    enumCell,   //"device-enum-cell"
    stringCell, //"device-string-cell"
    labelCell   //"device-label-cell"
};

@interface DeviceControlCell : NSObject
+ (NSString *)cellIdentifier:(TuyaSmartSchemaModel *)schema;
+ (DeviceControlCellId)cellIdentifierENUM:(TuyaSmartSchemaModel *)schema;
@end

NS_ASSUME_NONNULL_END
