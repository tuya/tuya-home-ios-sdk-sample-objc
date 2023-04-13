//
//  CameraVideoView.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraVideoView.h"

@implementation CameraVideoView

- (void)setRenderView:(UIView<ThingSmartVideoViewType> *)renderView {
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

- (void)thing_clear {
    [self.renderView thing_clear];
}

- (void)thing_setOffset:(CGPoint)offset {
    [self.renderView thing_setOffset:offset];
}

- (void)thing_setScaled:(float)scaled {
    [self.renderView thing_setScaled:scaled];
}

- (void)setScaleToFill:(BOOL)scaleToFill {
    [self.renderView setScaleToFill:scaleToFill];
}

- (BOOL)scaleToFill {
    return self.renderView.scaleToFill;
}

@end
