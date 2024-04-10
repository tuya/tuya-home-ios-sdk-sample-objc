//
//  CameraSplitVideoContainerView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

#import "DemoSplitVideoViewDispatcher.h"

NS_ASSUME_NONNULL_BEGIN

@class CameraDevice;
@interface CameraSplitVideoContainerView : UIView

- (instancetype)initWithFrame:(CGRect)frame cameraDevice:(CameraDevice *)cameraDevice videoViewDispatcher:(DemoSplitVideoViewDispatcher *)videoViewDispatcher;

@property (nonatomic, assign) CGSize frameSize;

- (void)setToolbarFolding:(BOOL)toolbarFolding;

- (void)setSmallVideoViewsHidden:(BOOL)smallVideoViewsHidden;

- (void)setShowLocalizer:(BOOL)showLocalizer;

- (void)setLandscape:(BOOL)isLandscape;

@end

NS_ASSUME_NONNULL_END
