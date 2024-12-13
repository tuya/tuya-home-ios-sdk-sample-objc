//
//  CameraSplitVideoContainerView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraSplitVideoContainerView.h"

#import "CameraDevice.h"

@interface CameraSplitVideoContainerView () {
    BOOL _isLandscape;
}

@property (nonatomic, strong) DemoSplitVideoViewDispatcher *videoViewDispatcher;

@property (nonatomic, assign) BOOL needsTriggerLayoutFlag;

@property (nonatomic, strong) CameraDevice *cameraDevice;

@end


@implementation CameraSplitVideoContainerView

- (void)dealloc {
    if (self.videoViewDispatcher) {
        [self.videoViewDispatcher destoryBindViews];
    }
    self.cameraDevice = nil;
    NSLog(@"[dealloc]-%s", __func__);
}


- (instancetype)initWithFrame:(CGRect)frame cameraDevice:(CameraDevice *)cameraDevice videoViewDispatcher:(DemoSplitVideoViewDispatcher *)videoViewDispatcher {
    self = [super initWithFrame:frame];
    if (self) {
        _cameraDevice = cameraDevice;
        _videoViewDispatcher = videoViewDispatcher;
        
        self.backgroundColor = [UIColor blackColor];
        self.clipsToBounds = YES;
        [self rebindSplitVideoCoverViews];
    }
    return self;
}


- (void)setToolbarFolding:(BOOL)toolbarFolding {
    [self.videoViewDispatcher setToolbarFolding:toolbarFolding];
}

- (void)setSmallVideoViewsHidden:(BOOL)smallVideoViewsHidden {
    [self.videoViewDispatcher setSmallVideoViewsHidden:smallVideoViewsHidden];
}

- (void)setShowLocalizer:(BOOL)showLocalizer {
    [self.videoViewDispatcher setShowLocalizer:showLocalizer];
}

- (void)setLandscape:(BOOL)isLandscape {
    _isLandscape = isLandscape;
    [self.videoViewDispatcher relayoutBindViewsBasedOnSuperView:self isLandscape:_isLandscape];
}

- (void)triggerLayoutImmediately {
    self.needsTriggerLayoutFlag = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self triggerLayoutImmediatelyIfNeeded];
    });
}

- (void)triggerLayoutImmediatelyIfNeeded {
    if (!self.needsTriggerLayoutFlag) {
        return;
    }
    self.needsTriggerLayoutFlag = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.height == 0 || self.width == 0) {
        return;
    }
    [self.videoViewDispatcher relayoutBindViewsBasedOnSuperView:self isLandscape:_isLandscape];
}


- (void)setFrameSize:(CGSize)frameSize {
    _frameSize = frameSize;
    [self setNeedsLayout];
}


- (void)rebindSplitVideoCoverViews {
    for (CameraSplitVideoView *bindView in self.videoViewDispatcher.bindViews) {
        [self addSubview:bindView];
    }
    [self.videoViewDispatcher rebindVideoNodeViews];
}

@end
