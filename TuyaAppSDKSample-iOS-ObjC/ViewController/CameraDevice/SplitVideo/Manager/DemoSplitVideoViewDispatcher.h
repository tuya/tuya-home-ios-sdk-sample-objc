//
//  DemoSplitVideoViewDispatcher.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import <ThingSmartCameraBase/ThingSmartCameraBase.h>

#import "DemoSplitVideoViewContext.h"

#import "CameraSplitVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoViewDispatcher : NSObject

@property (nonatomic, copy, readonly) NSArray<CameraSplitVideoView *> *bindViews;

- (instancetype)initWithAdvancedConfig:(id<ThingSmartCameraAdvancedConfig>)advancedConfig videoViewContext:(id<DemoSplitVideoViewContext>)videoViewContext;

- (void)setToolbarFolding:(BOOL)toolbarFolding;
- (void)setSmallVideoViewsHidden:(BOOL)smallVideoViewsHidden;
- (void)setShowLocalizer:(BOOL)showLocalizer;

- (void)relayoutBindViewsBasedOnSuperView:(UIView *)superView isLandscape:(BOOL)isLandscape;
- (void)rebindVideoNodeViews;
- (void)destoryBindViews;
- (void)modifyVideoExtInfo:(id<ThingSmartVideoExtInfo>)videoExtInfo;

@end

NS_ASSUME_NONNULL_END
