//
//  CameraSplitVideoView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraSplitVideoView.h"

#import "DemoVideoLocalizerView.h"
#import "DemoSplitVideoUtil.h"

typedef NS_ENUM(NSUInteger, CameraSplitVideoViewLocalizerLayoutStyle) {
    CameraSplitVideoViewLocalizerLayoutHidden,
    CameraSplitVideoViewLocalizerLayoutHalfLeft,
    CameraSplitVideoViewLocalizerLayoutHalfRight,
    CameraSplitVideoViewLocalizerLayoutFull
};

@interface CameraSplitVideoView () <DemoSplitVideoViewGestureDelegate> {
    BOOL _toolbarFolding;
    BOOL _smallVideoViewsHidden;

    BOOL _showLocalizer;
}

@property (nonatomic, copy, readwrite) NSArray<DemoSplitVideoNodeView *> *videoNodeViews;

@property (nonatomic, assign) CGFloat sizeRate;

@property (nonatomic, assign) CGFloat padding;

@property (nonatomic, strong) DemoVideoLocalizerView *localizerView;

@property (nonatomic, assign) CameraSplitVideoViewLocalizerLayoutStyle localizerLayoutStyle;

@property (nonatomic, strong) CAGradientLayer *landscapeGradientLayer;

@end

@implementation CameraSplitVideoView

@synthesize videoViewContext = _videoViewContext;

- (void)setIsLandscape:(BOOL)isLandscape {
    _isLandscape = isLandscape;
    if (_isLandscape) {
        [_localizerView showLocalizerView:NO];
    }
    self.landscapeGradientLayer.hidden = !isLandscape;
}

- (BOOL)hasLocalizer {
    return [self isSupportedLocalizer];
}


- (void)setToolbarFolding:(BOOL)toolbarFolding {
    _toolbarFolding = toolbarFolding;
    [_localizerView hideLocalizerViewImmediately];
}

- (void)setSmallVideoViewsHidden:(BOOL)smallVideoViewsHidden {
    _smallVideoViewsHidden = smallVideoViewsHidden;
}

- (void)setShowLocalizer:(BOOL)showLocalizer {
    _showLocalizer = showLocalizer;
    if (_showLocalizer) {
        [self.localizerView showLocalizerView:_showLocalizer];
    } else {
        [_localizerView showLocalizerView:_showLocalizer];
    }
}

- (void)destory {
    [self enumerateNodeViewsUsingBlock:^(DemoSplitVideoNodeView *videoNodeView) {
        [videoNodeView removeFromSuperview];
    }];
    _videoNodeViews = nil;
}


#pragma mark - Inner

- (void)dealloc {
    NSLog(@"[dealloc]-%s", __func__);
    [self enumerateNodeViewsUsingBlock:^(DemoSplitVideoNodeView *videoNodeView) {
        [videoNodeView removeFromSuperview];
    }];
    _videoNodeViews = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeRate =  9 / 16.;
        self.padding = 2;
        self.animatedDuration = 0.3;
    }
    return self;
}

- (void)rebindVideoNodeViews:(NSArray<DemoSplitVideoNodeView *> *)videoNodeViews {
    _videoNodeViews = videoNodeViews;
    if (videoNodeViews.count == 0) {
        return;
    }
    for (DemoSplitVideoNodeView *videoNodeView in _videoNodeViews) {
        videoNodeView.gestureDelegate = self;
        [videoNodeView resetVideoIndex];
        [self addSubview:videoNodeView];
    }
    
    [self refreshLocalizerViewLayoutStyle];
    [self triggerLayoutImmediately];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.width == 0 || self.height == 0) {
        return;
    }
    if (_isLandscape) {
        DemoSplitVideoNodeView *firstSplitVideoNodeView = self.videoNodeViews.firstObject;
        if (firstSplitVideoNodeView.isMainView) {
            firstSplitVideoNodeView.frame = self.bounds;
        } else {
            CGSize landscapeSmallSize = _videoViewContext.viewSizeCounter.landscapeSmallSize;
            CGFloat landscapeMargin = _videoViewContext.viewSizeCounter.landscapeViewMargin;

            CGFloat videoViewsHeight = self.videoNodeViews.count * landscapeSmallSize.height + MAX(0, self.videoNodeViews.count - 1) * landscapeMargin;
            
            CGFloat videoViewsYOffset = (self.height - videoViewsHeight) * 0.5;
    
            CGFloat subviewWidth = landscapeSmallSize.width;
            CGFloat subviewHeight = landscapeSmallSize.height;

            for (NSInteger i = 0; i < self.videoNodeViews.count; i++) {
                UIView *subview = self.videoNodeViews[i];
                subview.frame = CGRectMake(landscapeMargin, videoViewsYOffset + i * (subviewHeight + landscapeMargin), subviewWidth, subviewHeight);
            }
        }
        CGSize landscapeGradientLayerSize = _videoViewContext.viewSizeCounter.landscapeCoverSize;
        self.landscapeGradientLayer.frame = (CGRect){self.width - landscapeGradientLayerSize.width, 0, landscapeGradientLayerSize};
    } else {
        CGFloat totalPadding = MAX(0, _videoNodeViews.count - 1) * self.padding;
        CGFloat subviewWidth = (self.width - totalPadding) / MAX(_videoNodeViews.count, 1);
        CGFloat subviewHeight = subviewWidth * self.sizeRate;
        for (NSInteger i = 0; i < self.videoNodeViews.count; i++) {
            UIView *subview = self.videoNodeViews[i];
            subview.frame = CGRectMake(i * (subviewWidth + self.padding), 0, subviewWidth, subviewHeight);
        }
        if ([self isSupportedLocalizer]) {
            [self reloadLocalizerViewLayout];
        }
    }
}

- (void)enumerateNodeViewsUsingBlock:(void (^)(DemoSplitVideoNodeView *videoNodeView))block {
    for (DemoSplitVideoNodeView *videoNodeView in _videoNodeViews) {
        block(videoNodeView);
    }
}

#pragma mark - DemoSplitVideoViewGestureDelegate

- (BOOL)respondWrappedTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint tapPoint = [tapGesture locationInView:self];
    BOOL containsTapPoint = NO;
    if (_localizerView) {
        containsTapPoint = CGRectContainsPoint(_localizerView.frame, tapPoint);
    }
    if (containsTapPoint && [self isSupportedLocalizer] && _showLocalizer) {
        [self.localizerView showLocalizerView:YES];
        return YES;
    }
    
    UIView* (^filterNodeView)(UIView *) = ^(UIView *subview) {
        do {
            if ([subview isKindOfClass:DemoSplitVideoNodeView.class]) {
                break;
            }
            if ([subview isKindOfClass:UIWindow.class]) {
                break;
            }
            subview = subview.superview;
        } while (subview.superview);
        return subview;
    };
    BOOL wrapped = NO;

    DemoSplitVideoNodeView *videoNodeView = (DemoSplitVideoNodeView *)filterNodeView(tapGesture.view);
    if ([videoNodeView isKindOfClass:DemoSplitVideoNodeView.class]) {
        if ([self.gestureDelegate respondsToSelector:@selector(didTapVideoNodeView:)]) {
            wrapped = [self.gestureDelegate didTapVideoNodeView:videoNodeView];
        }
    }
    if (NO == wrapped) {
        if ([self.gestureDelegate respondsToSelector:@selector(respondWrappedTapGesture:)]) {
            [self.gestureDelegate respondWrappedTapGesture:tapGesture];
        }
    }

    
    return wrapped;
}

#pragma mark - Localizer

- (void)refreshLocalizerViewLayoutStyle {
    self.localizerLayoutStyle = CameraSplitVideoViewLocalizerLayoutHidden;
    if (_videoNodeViews.firstObject.splitVideoInfo.isLocalizer) {
        if (_videoNodeViews.lastObject.splitVideoInfo.isLocalizer) {
            self.localizerLayoutStyle = CameraSplitVideoViewLocalizerLayoutFull;
        } else {
            self.localizerLayoutStyle = CameraSplitVideoViewLocalizerLayoutHalfLeft;
        }
    } else {
        if (_videoNodeViews.lastObject.splitVideoInfo.isLocalizer) {
            self.localizerLayoutStyle = CameraSplitVideoViewLocalizerLayoutHalfRight;
        }
    }
    [self hideLocalizerViewIfNeeded];
}

- (void)reloadLocalizerViewLayout {
    [self bringSubviewToFront:self.localizerView];
    switch (self.localizerLayoutStyle) {
        case CameraSplitVideoViewLocalizerLayoutHalfLeft:
            self.localizerView.frame = self.videoNodeViews.firstObject.frame;
            break;
        case CameraSplitVideoViewLocalizerLayoutHalfRight:
            self.localizerView.frame = self.videoNodeViews.lastObject.frame;
            break;
        case CameraSplitVideoViewLocalizerLayoutFull:
            self.localizerView.frame = self.bounds;
            break;
        default:
            break;
    }
    [self.localizerView triggerLayoutImmediately];
}

- (void)hideLocalizerViewIfNeeded {
    if (![self isSupportedLocalizer]) {
        [_localizerView showLocalizerView:NO];
    }
}

- (BOOL)isSupportedLocalizer {
    if (self.isLandscape) {
        return NO;
    }
    return !(self.localizerLayoutStyle == CameraSplitVideoViewLocalizerLayoutHidden);
}

- (DemoVideoLocalizerView *)localizerView {
    if (!_localizerView) {
        _localizerView = [[DemoVideoLocalizerView alloc] initWithFrame:CGRectZero];
        __weak typeof(self) weakSelf = self;
        _localizerView.movedCompletion = ^(NSString * _Nonnull coordinateInfo) {
            [weakSelf.videoViewContext.videoOperator publishLocalizerCoordinateInfo:coordinateInfo];
        };
        [self addSubview:_localizerView];
    }
    return _localizerView;
}

- (CAGradientLayer *)landscapeGradientLayer {
    if (!_landscapeGradientLayer) {
        _landscapeGradientLayer = [CAGradientLayer layer];
        CGSize landscapeGradientLayerSize = _videoViewContext.viewSizeCounter.landscapeCoverSize;
        _landscapeGradientLayer.frame = (CGRect){0, 0, landscapeGradientLayerSize};
        _landscapeGradientLayer.contentsScale = [UIScreen mainScreen].scale;
        _landscapeGradientLayer.colors = @[(__bridge id)DemoHexAlphaColor(0x000000, 0.).CGColor, (__bridge id)DemoHexAlphaColor(0x000000, 0.4).CGColor];
        _landscapeGradientLayer.locations = @[@(0), @(1)];
        _landscapeGradientLayer.startPoint = CGPointMake(0, 0);
        _landscapeGradientLayer.endPoint = CGPointMake(0, 1);
        [self.layer addSublayer:_landscapeGradientLayer];
    }
    return _landscapeGradientLayer;
}

@end
