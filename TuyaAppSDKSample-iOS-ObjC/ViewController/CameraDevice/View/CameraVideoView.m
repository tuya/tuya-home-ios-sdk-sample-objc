//
//  CameraVideoView.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraVideoView.h"

@implementation CameraVideoView

- (void)setRenderView:(UIView<TuyaSmartVideoViewType> *)renderView {
    _renderView = renderView;
    if (_renderView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addSubview:self.renderView];
        });
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.renderView.frame = self.bounds;
}

- (UIImage *)screenshot {
    return [self.renderView screenshot];
}

- (void)tuya_clear {
    [self.renderView tuya_clear];
}

- (void)tuya_setOffset:(CGPoint)offset {
    [self.renderView tuya_setOffset:offset];
}

- (void)tuya_setScaled:(float)scaled {
    [self.renderView tuya_setScaled:scaled];
}

- (void)setScaleToFill:(BOOL)scaleToFill {
    [self.renderView setScaleToFill:scaleToFill];
}

- (BOOL)scaleToFill {
    return self.renderView.scaleToFill;
}

@end
