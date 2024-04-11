//
//  DemoSplitVideoNodeView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <ThingSmartMediaServices/ThingSmartMediaServices.h>

#import "CameraSplitVideoBaseView.h"

#import "DemoSplitVideoInfo.h"

#import "DemoSplitVideoViewContext.h"

#import "DemoSplitVideoViewGestureDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoSplitVideoNodeView : CameraSplitVideoBaseView

- (instancetype)initWithFrame:(CGRect)frame videoViewContext:(id<DemoSplitVideoViewContext>)videoViewContext splitVideoInfo:(DemoSplitVideoInfo *)splitVideoInfo;

@property (nonatomic, strong, readonly) UIView<ThingSmartVideoViewType> *videoView;
@property (nonatomic, strong, readonly) DemoSplitVideoInfo *splitVideoInfo;

@property (nonatomic, assign) CGSize frameSize;

@property (nonatomic, assign) BOOL isMainView;

@property (nonatomic, weak) id <DemoSplitVideoViewGestureDelegate> gestureDelegate;

@property (nonatomic, assign) ThingSmartVideoIndex currentVideoIndex;

- (void)resetVideoIndex;

@end

NS_ASSUME_NONNULL_END
