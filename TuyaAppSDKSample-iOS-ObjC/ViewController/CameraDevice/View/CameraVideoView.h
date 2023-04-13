//
//  CameraVideoView.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

#import <ThingSmartCameraBase/ThingSmartVideoViewType.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraVideoView : UIView<ThingSmartVideoViewType>

@property (nonatomic, strong) UIView<ThingSmartVideoViewType> *renderView;

@end


NS_ASSUME_NONNULL_END
