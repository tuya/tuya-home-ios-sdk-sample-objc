//
//  DemoSplitVideoNodeView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoNodeView.h"

#import <ThingSmartMediaUIKit/ThingSmartMediaUIKit.h>

@interface DemoSplitVideoNodeView ()

@property (nonatomic, assign, readonly) CGFloat videoViewHToWRate;

@property (nonatomic, weak) id <DemoSplitVideoViewContext> videoViewContext;

@end

@implementation DemoSplitVideoNodeView

- (void)dealloc {
    if (self.videoView) {
        [self.videoViewContext.videoOperator unbindVideoView:self.videoView videoIndex:self.splitVideoInfo.index];
    }
}

- (instancetype)initWithFrame:(CGRect)frame videoViewContext:(id<DemoSplitVideoViewContext>)videoViewContext splitVideoInfo:(DemoSplitVideoInfo *)splitVideoInfo {
    self = [super initWithFrame:frame];
    if (self) {
        _videoViewContext = videoViewContext;
        _splitVideoInfo = splitVideoInfo;
        
        self.backgroundColor = UIColor.blackColor;

        _videoView = [[ThingSmartMediaVideoView alloc] initWithFrame:CGRectZero];
        [self addSubview:_videoView];
        
        [_videoViewContext.videoOperator bindVideoView:_videoView videoIndex:_splitVideoInfo.index];
        _currentVideoIndex = _splitVideoInfo.index;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.height == 0 || self.width == 0) {
        return;
    }
    
    CGFloat videoViewHToWRate = self.videoViewHToWRate;
    CGFloat selfViewHToWRate = self.height / self.width;
    CGFloat videoViewWidth = self.width;
    CGFloat videoViewHeight = videoViewWidth * videoViewHToWRate;
    if (videoViewHToWRate > selfViewHToWRate) {
        videoViewHeight = self.height;
        videoViewWidth = videoViewHeight / videoViewHToWRate;
    }
    self.videoView.frame = CGRectMake((self.width - videoViewWidth) * 0.5, (self.height - videoViewHeight) * 0.5, videoViewWidth, videoViewHeight);
}

- (CGFloat)videoViewHToWRate {
    CGFloat sizeRate = self.splitVideoInfo.frame_infos.firstObject.sizeRate;
    if (self.frameSize.height > 0 && self.frameSize.width > 0) {
        sizeRate = self.frameSize.height / self.frameSize.width;
    }
    return sizeRate;
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer {
    if ([self.gestureDelegate respondsToSelector:@selector(respondWrappedTapGesture:)]) {
        [self.gestureDelegate respondWrappedTapGesture:recognizer];
    }
}

- (void)setFrameSize:(CGSize)frameSize {
    if (frameSize.width == 0 || frameSize.height == 0) {
        return;
    }
    if (!CGSizeEqualToSize(_frameSize, frameSize)) {
        _frameSize = frameSize;
        [self triggerLayoutImmediately];
    }
}

- (void)resetVideoIndex {
    [_videoViewContext.videoOperator bindVideoView:_videoView videoIndex:_splitVideoInfo.index];
}


@end
