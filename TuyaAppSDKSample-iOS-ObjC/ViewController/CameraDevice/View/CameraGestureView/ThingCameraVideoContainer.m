//
//  ThingCameraVideoContainer.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "ThingCameraVideoContainer.h"
#import <Masonry/Masonry.h>

@interface ThingCameraVideoContainer()<UIScrollViewDelegate, CameraVideoGestureViewDelegate>

@property (nonatomic, strong) UIScrollView *videoContainer;

@end

@implementation ThingCameraVideoContainer


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _preferredScaled = 1.0;
        [self addSubview:self.videoContainer];
        [self.videoContainer addSubview:self.videoGestureView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.videoGestureView.frame = self.bounds;
    CGFloat scale = self.videoContainer.zoomScale;
    CGPoint offset = self.videoContainer.contentOffset;
    self.videoContainer.zoomScale = 1;
    self.videoContainer.frame = self.bounds;
    if (self.LayoutContentView) {
        self.LayoutContentView(self.videoGestureView);
    }else {
        CGFloat height = MIN(CGRectGetHeight(self.frame), CGRectGetWidth(self.frame) / 16.0 * 9.0);
        self.videoGestureView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), height);
        self.videoGestureView.center = CGPointMake(self.videoGestureView.center.x, CGRectGetHeight(self.frame) / 2);
    }
    self.videoContainer.contentSize = self.videoContainer.frame.size;
    self.videoView.frame = self.videoGestureView.bounds;
    self.videoContainer.zoomScale = scale;
    self.videoContainer.contentOffset = self.videoOffset;
}

- (void)setVideoView:(UIView *)videoView {
    if (_videoView) {
        [_videoView removeFromSuperview];
    }
    if (videoView) {
        videoView.userInteractionEnabled = YES;
        [self.videoGestureView addSubview:videoView];
        videoView.frame = self.videoGestureView.frame;
        [videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.videoGestureView);
        }];
    }
    _videoView = videoView;
}

- (void)clearImage {
    if ([_videoView conformsToProtocol:@protocol(ThingSmartVideoViewType)]) {
        UIView<ThingSmartVideoViewType> * videoView = (UIView<ThingSmartVideoViewType> *)_videoView;
        [videoView thing_clear];
    }
}

- (void)setVideoOffset:(CGPoint)videoOffset {
    _videoOffset = videoOffset;
    [self.videoContainer setContentOffset:videoOffset];
}

- (void)setVideoScaled:(CGFloat)videoScaled {
    [self setVideoScaled:videoScaled animated:NO];
}

- (void)setVideoScaled:(CGFloat)scaled animated:(BOOL)animated; {
    [self.videoContainer setZoomScale:scaled animated:animated];
    if (self.videoOffset.x != 0 || self.videoOffset.y != 0) {
        [self.videoContainer setContentOffset:self.videoOffset animated:NO];
    }
}

- (CGFloat)videoScaled {
    return self.videoContainer.zoomScale;
}

- (void)setMaxScaled:(CGFloat)maxScaled {
    self.videoContainer.maximumZoomScale = maxScaled;
}

- (CGFloat)maxScaled {
    return self.videoContainer.maximumZoomScale;
}

- (void)setMinScaled:(CGFloat)minScaled {
    self.videoContainer.minimumZoomScale = minScaled;
}

- (CGFloat)minScaled {
    return self.videoContainer.minimumZoomScale;
}

#pragma mark - ThingCameraVideoGestureViewDelegate

- (void)gestureView:(CameraVideoGestureView *)gestureView didRecognizedDoubleTapGesture:(UITapGestureRecognizer *)doubleTapRecognizer {
    if (self.videoScaled > 1) {
        [self setVideoScaled:1.0 animated:YES];
    }else {
        [self setVideoScaled:3.0 animated:YES];
//        CGPoint touchPoint = [doubleTapRecognizer locationInView:gestureView];
//        CGFloat xsize = CGRectGetWidth(self.frame) / self.preferredScaled;
//        CGFloat ysize = CGRectGetHeight(self.frame) / self.preferredScaled;
//        [self.videoContainer zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(videoContainer:didDoubleTap:)]) {
        [self.delegate videoContainer:self didDoubleTap:doubleTapRecognizer];
    }
}

- (void)gestureView:(CameraVideoGestureView *)gestureView didRecognizedTapGesture:(UITapGestureRecognizer *)tapRecognizer {
    if ([self.delegate respondsToSelector:@selector(videoContainer:didTap:)]) {
        [self.delegate videoContainer:self didTap:tapRecognizer];
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.videoGestureView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.contentInset = UIEdgeInsetsZero;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self refreshContentViewCenter:scrollView];
    if ([self.delegate respondsToSelector:@selector(videoContainer:didZoomScale:)]) {
        [self.delegate videoContainer:self didZoomScale:scrollView.zoomScale];
    }
}

- (void)refreshContentViewCenter:(UIScrollView *)scrollView {
    CGFloat offsetX = (CGRectGetWidth(scrollView.frame) > scrollView.contentSize.width) ? ((CGRectGetWidth(scrollView.frame) - scrollView.contentSize.width) * 0.5) : 0.0;
    CGFloat offsetY = (CGRectGetHeight(scrollView.frame) > scrollView.contentSize.height) ? ((CGRectGetHeight(scrollView.frame)  - scrollView.contentSize.height) * 0.5) : 0.0;
    self.videoGestureView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (UIScrollView *)videoContainer {
    if (!_videoContainer) {
        _videoContainer = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _videoContainer.bouncesZoom = NO;
        _videoContainer.maximumZoomScale = 3.0f;
        _videoContainer.minimumZoomScale = 1.0f;
        _videoContainer.multipleTouchEnabled = YES;
        _videoContainer.scrollsToTop = NO;
        _videoContainer.delegate = self;
        _videoContainer.bounces = NO;
        _videoContainer.delaysContentTouches = NO;
        _videoContainer.canCancelContentTouches = YES;
        _videoContainer.showsVerticalScrollIndicator = NO;
        _videoContainer.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11, *)) {
            _videoContainer.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
    }
    return _videoContainer;
}

- (CameraVideoGestureView *)videoGestureView {
    if (!_videoGestureView) {
        _videoGestureView = [[CameraVideoGestureView alloc] initWithFrame:CGRectZero];
        _videoGestureView.delegate = self;
    }
    return _videoGestureView;
}

- (void)thing_clear {
    if ([self.videoView conformsToProtocol:@protocol(ThingSmartVideoViewType)]) {
        UIView<ThingSmartVideoViewType> *videoView = (UIView<ThingSmartVideoViewType> *)_videoView;
        [videoView thing_clear];
    }

}

@end
