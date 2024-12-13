//
//  DemoSplitVideoViewManager.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoViewManager.h"

#import <YYModel/YYModel.h>
#import <ThingSmartCameraM/ThingSmartCameraM.h>


#import "DemoSplitVideoViewDispatcher.h"
#import "DemoSplitVideoOperator.h"
#import "DemoSplitVideoViewSizeCounter+interface.h"

@interface DemoSplitVideoViewContext : NSObject <DemoSplitVideoViewContext>

@end

@implementation DemoSplitVideoViewContext
@synthesize videoOperator = _videoOperator;
@synthesize viewSizeCounter = _viewSizeCounter;

- (instancetype)initWithVideoOperator:(id<DemoSplitVideoOperatorProtocol>)videoOperator viewSizeCounter:( id<DemoSplitVideoViewSizeCounter>)viewSizeCounter {
    self = [super init];
    if (self) {
        _videoOperator = videoOperator;
        _viewSizeCounter = viewSizeCounter;
    }
    return self;
}

@end

@interface DemoSplitVideoViewManager () <ThingSmartCameraDelegate> {
    CameraDevice *_cameraDevice;
    ThingSmartCameraAdvancedConfig *_cameraAdvancedConfig;
    DemoSplitVideoOperator *_videoOperator;
    DemoSplitVideoViewDispatcher *_videoViewDispatcher;
    DemoSplitVideoViewContext *_videoViewContext;
    DemoSplitVideoViewSizeCounter *_viewSizeCounter;
}

@end

@implementation DemoSplitVideoViewManager

@synthesize isSupportedVideoSplitting = _isSupportedVideoSplitting;

- (void)dealloc {
    [_cameraDevice removeDelegate:self];
}

- (instancetype)initWithCameraDevice:(CameraDevice *)cameraDevice {
    self = [super init];
    if (self) {
        _cameraDevice = cameraDevice;
        [_cameraDevice addDelegate:self];
        _videoOperator = [[DemoSplitVideoOperator alloc] initWithCameraDevice:_cameraDevice];
        _viewSizeCounter = [[DemoSplitVideoViewSizeCounter alloc] initWithVideoSizeRate:0 padding:0];
        _cameraAdvancedConfig = _videoOperator.advancedConfig;
        _isSupportedVideoSplitting = _cameraAdvancedConfig.isSupportedVideoSplitting;

        _videoViewContext = [[DemoSplitVideoViewContext alloc] initWithVideoOperator:_videoOperator viewSizeCounter:_viewSizeCounter];
        
        _videoViewDispatcher = [[DemoSplitVideoViewDispatcher alloc] initWithAdvancedConfig:_cameraAdvancedConfig videoViewContext:_videoViewContext];
    }
    return self;
}

- (CameraSplitVideoContainerView *)splitVideoView {
    if (!_isSupportedVideoSplitting) {
        return nil;
    }
    if (_cameraAdvancedConfig.split_video_sum_info.align_info) {
        CameraSplitVideoContainerView *videoView = [[CameraSplitVideoContainerView alloc] initWithFrame:CGRectZero cameraDevice:_cameraDevice videoViewDispatcher:_videoViewDispatcher];
        return videoView;
    }
    return nil;
}

#pragma mark - ThingSmartCameraDelegate

- (void)camera:(id<ThingSmartCameraType>)camera resolutionDidChangeWithVideoExtInfo:(id<ThingSmartVideoExtInfo>)videoExtInfo {
    [_videoViewDispatcher modifyVideoExtInfo:videoExtInfo];
}


@end
