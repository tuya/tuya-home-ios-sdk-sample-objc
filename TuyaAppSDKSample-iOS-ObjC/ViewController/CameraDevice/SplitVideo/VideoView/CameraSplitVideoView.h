//
//  CameraSplitVideoView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraSplitVideoBaseView.h"

#import "DemoSplitVideoViewContextQuoter.h"
#import "DemoSplitVideoNodeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CameraSplitVideoView : CameraSplitVideoBaseView <DemoSplitVideoViewContextQuoter>

@property (nonatomic, assign) BOOL isLandscape;
@property (nonatomic, assign) NSTimeInterval animatedDuration;

@property (nonatomic, assign, readonly) BOOL hasLocalizer;

@property (nonatomic, copy, readonly) NSArray<DemoSplitVideoNodeView *> *videoNodeViews;

@property (nonatomic, weak) id <DemoSplitVideoViewGestureDelegate> gestureDelegate;

- (void)setToolbarFolding:(BOOL)toolbarFolding;
- (void)setSmallVideoViewsHidden:(BOOL)smallVideoViewsHidden;
- (void)setShowLocalizer:(BOOL)showLocalizer;

- (void)destory;
- (void)rebindVideoNodeViews:(NSArray<DemoSplitVideoNodeView *> *)videoNodeViews;

@end

NS_ASSUME_NONNULL_END
