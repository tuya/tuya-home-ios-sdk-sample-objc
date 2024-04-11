//
//  DemoSplitVideoViewSizeCounter.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoViewSizeCounter+interface.h"

@interface DemoSplitVideoViewSizeCounter () {
    CGFloat _sizeRate;
    CGFloat _portraitSmallSizeHeight;
    
    CGSize _landscapeSmallSize;
    CGSize _portraitSmallSize;
    CGSize _portraitNormalSize;
}

@property (nonatomic, assign, readwrite) CGFloat padding;

@end

@implementation DemoSplitVideoViewSizeCounter

- (instancetype)initWithVideoSizeRate:(CGFloat)videoSizeRate padding:(CGFloat)padding {
    self = [super init];
    if (self) {
        _padding = padding;
        _sizeRate = videoSizeRate;
        if (_sizeRate == 0) {
            _sizeRate = 9 / 16.;
        }
        if (_padding == 0) {
            _padding = 2;
        }
    }
    return self;
}

- (CGSize)landscapeSmallSize {
    if (_landscapeSmallSize.width && _landscapeSmallSize.height) {
        return _landscapeSmallSize;
    }
    CGFloat height = 105.;
    if (_portraitSmallSizeHeight) {
        height = _portraitSmallSizeHeight;
    }
    CGFloat width = height / _sizeRate;
    _landscapeSmallSize = CGSizeMake(width, height);
    return _landscapeSmallSize;
}

- (CGFloat)landscapeViewMargin {
    return 10;
}

- (CGSize)landscapeCoverSize {
    CGFloat sizeRate = 320 / 812.;
    CGFloat width = [self videoViewWidth];
    CGFloat height = [self videoViewHeight];
    CGFloat realWidth = (MAX(width, height)) * sizeRate;
    CGFloat realHeight = MIN(width, height);
    return CGSizeMake(realWidth, realHeight);
}

- (CGSize)portraitSmallSize {
    if (_portraitSmallSize.width && _portraitSmallSize.height) {
        return _portraitSmallSize;
    }
    CGFloat videoViewWidth = [self videoViewWidth];
    CGFloat width = (videoViewWidth - _padding) * 0.5;
    CGFloat height = width * _sizeRate;
    _portraitSmallSizeHeight = height;
    _portraitSmallSize = CGSizeMake(width, height);
    return _portraitSmallSize;
}

- (CGSize)portraitNormalSize {
    if (_portraitNormalSize.width && _portraitNormalSize.height) {
        return _portraitNormalSize;
    }
    CGFloat videoViewWidth = [self videoViewWidth];
    CGFloat height = videoViewWidth * _sizeRate;
    _portraitNormalSize = CGSizeMake(videoViewWidth, height);
    return _portraitNormalSize;
}

#pragma mark - Private

- (CGFloat)videoViewWidth {
    return UIScreen.mainScreen.bounds.size.width;
}

- (CGFloat)videoViewHeight {
    return UIScreen.mainScreen.bounds.size.height;
}


@end

