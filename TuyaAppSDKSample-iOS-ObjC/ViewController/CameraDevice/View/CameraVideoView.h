//
//  CameraVideoView.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

#import <TuyaSmartCameraBase/TuyaSmartVideoViewType.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraVideoView : UIView<TuyaSmartVideoViewType>

@property (nonatomic, strong) UIView<TuyaSmartVideoViewType> *renderView;

@end


NS_ASSUME_NONNULL_END
