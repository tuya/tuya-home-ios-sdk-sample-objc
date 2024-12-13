//
//  DemoSplitVideoViewDispatcher.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoViewDispatcher.h"

#import "DemoSplitVideoViewGenerater.h"
#import "DemoVideoViewIndexPair.h"

#import "DemoSplitVideoInfo.h"

#import "DemoSplitVideoNodeView.h"

@interface DemoSplitVideoViewDispatcher () <DemoSplitVideoViewGestureDelegate> {
    ThingSmartCameraAdvancedConfig *_advancedConfig;
    DemoSplitVideoViewGenerater *_videoViewGenerater;
    id<DemoSplitVideoViewContext> _videoViewContext;
    BOOL _toolbarFolding;
    BOOL _smallVideoViewsHidden;
    BOOL _isLandscape;
}
@property (nonatomic, strong) CameraSplitVideoView *topView;
@property (nonatomic, strong) CameraSplitVideoView *bottomView;

@property (nonatomic, copy, readwrite) NSArray<CameraSplitVideoView *> *bindViews;

@end

@implementation DemoSplitVideoViewDispatcher


- (instancetype)initWithAdvancedConfig:(id<ThingSmartCameraAdvancedConfig>)advancedConfig videoViewContext:(id<DemoSplitVideoViewContext>)videoViewContext {
    self = [super init];
    if (self) {
        _advancedConfig = advancedConfig;
        _videoViewContext = videoViewContext;
        
        _topView = [[CameraSplitVideoView alloc] initWithFrame:CGRectZero];
        _topView.gestureDelegate = self;
        _topView.videoViewContext = _videoViewContext;

        _bottomView = [[CameraSplitVideoView alloc] initWithFrame:CGRectZero];
        _bottomView.gestureDelegate = self;
        _bottomView.videoViewContext = _videoViewContext;
        
        _bindViews = @[_topView, _bottomView];
        
        _videoViewGenerater = [[DemoSplitVideoViewGenerater alloc] initWithAdvancedConfig:_advancedConfig videoViewContext:_videoViewContext];
        NSArray<DemoSplitVideoNodeView *> *allVideoViews = [_videoViewGenerater allViews];
        NSMutableArray *pairInfos = [[NSMutableArray alloc] initWithCapacity:allVideoViews.count];
        for (DemoSplitVideoNodeView *videoView in allVideoViews) {
            DemoVideoViewIndexPair *pairInfo = [[DemoVideoViewIndexPair alloc] initWithVideoView:videoView.videoView videoIndex:videoView.splitVideoInfo.index];
            [pairInfos addObject:pairInfo];
        }
        
        [self rebindVideoNodeViews];
    }
    return self;
}


- (void)rebindVideoNodeViews {
    if (_isLandscape) {
        [_topView rebindVideoNodeViews:_videoViewGenerater.bigViews];
        [_bottomView rebindVideoNodeViews:_videoViewGenerater.smallViews];
    } else {
        [_topView rebindVideoNodeViews:_videoViewGenerater.topViews];
        [_bottomView rebindVideoNodeViews:_videoViewGenerater.bottomViews];
    }
}

- (void)destoryBindViews {
    [_topView destory];
    [_bottomView destory];
}

- (NSArray<CameraSplitVideoView *> *)bindViews {
    return _bindViews;
}

- (void)relayoutBindViewsBasedOnSuperView:(UIView *)superView isLandscape:(BOOL)isLandscape {
    _topView.isLandscape = isLandscape;
    _bottomView.isLandscape = isLandscape;
    if (_isLandscape != isLandscape) {
        _isLandscape = isLandscape;
        [self rebindVideoNodeViews];
    }
    if (isLandscape) {
        _topView.frame = superView.bounds;
        CGSize landscapeCoverSize = _videoViewContext.viewSizeCounter.landscapeCoverSize;
        _bottomView.frame = (CGRect){superView.width - landscapeCoverSize.width, 0, landscapeCoverSize};
        [_topView triggerLayoutImmediately];
        [_bottomView triggerLayoutImmediately];
    } else {
        self.bottomView.alpha = 1;
        self.bottomView.hidden = NO;
        
        CGSize portraitSmallSize = _videoViewContext.viewSizeCounter.portraitSmallSize;
        CGSize portraitNormalSize = _videoViewContext.viewSizeCounter.portraitNormalSize;
        
        CGFloat mediaViewsOriginX = 0;
        CGFloat mediaViewsSizeW = portraitNormalSize.width;
        
        CGFloat topViewSizeH = portraitNormalSize.height;
        CGFloat bottomViewSizeH = topViewSizeH;
        BOOL isBinocularCamera = YES;
        if (_topView.videoNodeViews.count > 1) {
            topViewSizeH = portraitSmallSize.height;
            isBinocularCamera = NO;
        }
        
        if (_bottomView.videoNodeViews.count > 1) {
            bottomViewSizeH = portraitSmallSize.height;
            isBinocularCamera = NO;
        } else if (_bottomView.videoNodeViews.count == 0) {
            bottomViewSizeH = 0;
        }
        BOOL needsSmallSize = (!_toolbarFolding && isBinocularCamera);
        CGFloat frameOffset = MAX(0, (superView.height - (topViewSizeH + bottomViewSizeH + (bottomViewSizeH ? _videoViewContext.viewSizeCounter.padding : 0))) * 0.5);
        if (needsSmallSize) {
            topViewSizeH = portraitSmallSize.height;
            bottomViewSizeH = _bottomView.videoNodeViews.count == 0 ? 0 : portraitSmallSize.height;
            mediaViewsSizeW = (mediaViewsSizeW - _videoViewContext.viewSizeCounter.padding) * 0.5;
            frameOffset = MAX(0, (superView.height - topViewSizeH) * 0.5);
        }
    
        CGRect topViewFrame = CGRectMake(mediaViewsOriginX, frameOffset, mediaViewsSizeW, topViewSizeH);
        CGRect bottomViewFrame = CGRectMake(mediaViewsOriginX, CGRectGetMaxY(topViewFrame) + _videoViewContext.viewSizeCounter.padding, mediaViewsSizeW, bottomViewSizeH);
        if (needsSmallSize) {
            bottomViewFrame = CGRectMake(CGRectGetMaxX(topViewFrame) + _videoViewContext.viewSizeCounter.padding, CGRectGetMinY(topViewFrame), mediaViewsSizeW, bottomViewSizeH);
        }
        self.topView.frame = topViewFrame;
        self.bottomView.frame = bottomViewFrame;
        [self.topView triggerLayoutImmediately];
        [self.bottomView triggerLayoutImmediately];
        NSLog(@"[frame]-superViewFrame=%@,frameOffset=%.f,topViewFrame=%@,bottomViewFrame=%@", NSStringFromCGRect(superView.frame),frameOffset,NSStringFromCGRect(topViewFrame),NSStringFromCGRect(bottomViewFrame));
    }
}

- (void)modifyVideoExtInfo:(id<ThingSmartVideoExtInfo>)videoExtInfo {
    NSArray<DemoSplitVideoNodeView *> *allVideoViews = [_videoViewGenerater allViews];
    for (DemoSplitVideoNodeView *videoNodeView in allVideoViews) {
        if (videoNodeView.splitVideoInfo.index == videoExtInfo.videoIndex) {
            videoNodeView.frameSize = videoExtInfo.frameSize;
            break;
        }
    }
}


- (void)setToolbarFolding:(BOOL)toolbarFolding {
    _toolbarFolding = toolbarFolding;
    [self enumerateBindViewsUsingBlock:^(CameraSplitVideoView *bindView) {
        [bindView setToolbarFolding:toolbarFolding];
    }];
}

- (void)setSmallVideoViewsHidden:(BOOL)smallVideoViewsHidden {
    _smallVideoViewsHidden = smallVideoViewsHidden;
    [UIView animateWithDuration:_bottomView.animatedDuration animations:^{
        self.bottomView.alpha = smallVideoViewsHidden ? 0 : 1;
    } completion:^(BOOL finished) {
        self.bottomView.hidden = smallVideoViewsHidden;
    }];
}

- (void)setShowLocalizer:(BOOL)showLocalizer {
    [self enumerateBindViewsUsingBlock:^(CameraSplitVideoView *bindView) {
        if (bindView.hasLocalizer) {
            [bindView setShowLocalizer:showLocalizer];
        }
    }];
}

- (DemoSplitVideoNodeView *)filterTappedVideoNodeView:(UIView *)tappedView {
    for (CameraSplitVideoView *bindView in _bindViews) {
        for (DemoSplitVideoNodeView *videoNodeView in bindView.videoNodeViews) {
            if (videoNodeView == tappedView) {
                return videoNodeView;
            }
        }
    }
    return nil;
}

- (void)enumerateBindViewsUsingBlock:(void (^)(CameraSplitVideoView *bindView))block {
    for (CameraSplitVideoView *bindView in _bindViews) {
        block(bindView);
    }
}

#pragma mark - DemoSplitVideoViewGestureDelegate

- (BOOL)didTapVideoNodeView:(DemoSplitVideoNodeView *)videoNodeView {
    if (NO == _isLandscape) {
        return NO;
    }
    DemoSplitVideoNodeView *filteredVideoNodeView = [self filterTappedVideoNodeView:videoNodeView];
    if (filteredVideoNodeView) {
        DemoSplitVideoNodeView *mainVideoNodeView = _topView.videoNodeViews.firstObject;
        ThingSmartVideoIndex videoIndex = mainVideoNodeView.currentVideoIndex;
        ThingSmartVideoIndex forVideoIndex = filteredVideoNodeView.currentVideoIndex;
        BOOL succeed = [_videoViewContext.videoOperator swapVideoIndex:videoIndex forVideoIndex:forVideoIndex];
        if (succeed) {
            [mainVideoNodeView triggerLayoutImmediately];
            [filteredVideoNodeView triggerLayoutImmediately];
            mainVideoNodeView.currentVideoIndex = forVideoIndex;
            filteredVideoNodeView.currentVideoIndex = videoIndex;
        }
        return succeed;
    }
    return NO;
}

@end
