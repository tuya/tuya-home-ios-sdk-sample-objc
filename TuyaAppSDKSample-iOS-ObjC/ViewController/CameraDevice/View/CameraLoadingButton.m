//
//  CameraLoadingButton.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraLoadingButton.h"

@interface CameraLoadingButton ()

@property (nonatomic, strong) UIActivityIndicatorView *indecatorView;

@end

@implementation CameraLoadingButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self addSubview:self.indecatorView];
}

- (void)startLoading {
    if (self.indecatorView.animating) {
        return;
    }
    [self.indecatorView startAnimating];
}

- (void)startLoadingWithEnabled:(BOOL)isEnabled {
    [self startLoading];
    self.enabled = isEnabled;
}


- (void)stopLoading {
    [self.indecatorView stopAnimating];
}

- (void)stopLoadingWithEnabled:(BOOL)isEnabled {
    [self stopLoading];
    self.enabled = isEnabled;
}

- (UIActivityIndicatorView *)indecatorView {
    if (_indecatorView == nil) {
        _indecatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indecatorView.hidden = YES;
        _indecatorView.userInteractionEnabled = NO;
    }
    return _indecatorView;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.indecatorView.frame = self.bounds;
}


@end
