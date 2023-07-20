//
//  CameraDeviceOutlineProperty.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CameraDeviceOutlineWidth) {
    CameraDeviceOutlineWidthThin = 0,
    CameraDeviceOutlineWidthMiddle = 1,
    CameraDeviceOutlineWidthWide = 2,
    CameraDeviceOutlineWidthIllegal = 100
};

typedef NS_ENUM(NSUInteger, CameraDeviceOutlineFlashType) {
    CameraDeviceOutlineFlashNotAllow = 0,
    CameraDeviceOutlineFlashFast = 1,
    CameraDeviceOutlineFlashMiddle = 2,
    CameraDeviceOutlineFlashSlow = 3,
    CameraDeviceOutlineFlashIllegal = 100
};

typedef NS_ENUM(NSUInteger, CameraDeviceOutlineShapeStyle) {
    CameraDeviceOutlineShapeStyleFull = 0,
    CameraDeviceOutlineShapeStyleHorn,
    CameraDeviceOutlineShapeStyleIllegal = 100
};

// 闪动频率
// flash FPS
@interface CameraDeviceOutlineFlashFps : NSObject

//画几帧
//draw frames interval
@property (nonatomic, assign) CameraDeviceOutlineFlashType drawKeepFrames;

//停几帧
//stop draw frames interval
@property (nonatomic, assign) CameraDeviceOutlineFlashType stopKeepFrames;

@end

@interface CameraDeviceOutlineProperty : NSObject

//0 表示之前版本的框, 1表示越线警告框
//0 means object outline, 1 means out of bounds
@property (nonatomic, assign) NSInteger type;

// 框的索引
// index
@property (nonatomic, assign) NSInteger index;

// RGB值
// color RGB value
@property (nonatomic, strong) NSNumber *rgb;

// 框形状
// shape
@property (nonatomic, assign) CameraDeviceOutlineShapeStyle shape;

// 宽度
// width
@property (nonatomic, assign) CameraDeviceOutlineWidth brushWidth;

// 闪动频率
// flash FPS
@property (nonatomic, strong) CameraDeviceOutlineFlashFps *flashFps;

@end

NS_ASSUME_NONNULL_END
