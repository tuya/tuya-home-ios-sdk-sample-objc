//
//  CameraControlView.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraControlButton.h"

@implementation CameraControlButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.borderColor = UIColor.blackColor.CGColor;
        self.layer.borderWidth = 0.5;
        _imageToTitleMargin = 8;
    }
    return self;
}

- (void)layoutSubviews {
    if (!_imageView || !_titleLabel) {
        return;
    }
    [self.imageView sizeToFit];
    [self.titleLabel sizeToFit];
    
    CGFloat imageHeight = self.imageView.frame.size.height;
    CGFloat titleHeight = self.titleLabel.frame.size.height;
    CGFloat imageToTitle = self.imageToTitleMargin;
    
    CGFloat imageTop = (self.frame.size.height - imageHeight - titleHeight - imageToTitle) / 2;
    CGFloat imageLeft = (self.frame.size.width - self.imageView.frame.size.width) / 2;
    self.imageView.frame = CGRectMake(imageLeft, imageTop, self.imageView.frame.size.width, imageHeight);
    self.titleLabel.frame = CGRectMake(0, imageTop + imageHeight + imageToTitle, self.frame.size.width, titleHeight);
}

- (void)addTarget:(id)target action:(SEL)action {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
}

- (void)setHighLighted:(BOOL)highLighted {
    _highLighted = highLighted;
    if (!_imageView || !_titleLabel) {
        return;
    }
    if (highLighted) {
        self.imageView.tintColor = [UIColor blueColor];
        self.titleLabel.textColor = [UIColor blueColor];
    }else {
        self.imageView.tintColor = [UIColor blackColor];
        self.titleLabel.textColor = [UIColor blackColor];
    }
}

- (void)setDisabled:(BOOL)disabled {
    _disabled = disabled;
    if (!_imageView || !_titleLabel) {
        return;
    }
    if (disabled) {
        self.imageView.tintColor = [UIColor lightGrayColor];
        self.titleLabel.textColor = [UIColor lightGrayColor];
    }else {
        self.imageView.tintColor = [UIColor blackColor];
        self.titleLabel.textColor = [UIColor blackColor];
    }
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.tintColor = [UIColor blackColor];
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
