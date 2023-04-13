//
//  CameraControlNewView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraControlNewView.h"

#import "CameraControlButton.h"

@interface CameraControlNewView ()

@end

@implementation CameraControlNewView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, width, 0);
    
    CGContextMoveToPoint(ctx, width / 3, 0);
    CGContextAddLineToPoint(ctx, width / 3, height);
    CGContextMoveToPoint(ctx, width / 3 * 2, 0);
    CGContextAddLineToPoint(ctx, width / 3 * 2, height);
    
    CGContextMoveToPoint(ctx, 0, height / 2);
    CGContextAddLineToPoint(ctx, width, height / 2);
    
    [[UIColor darkGrayColor] setStroke];
    CGContextSetLineWidth(ctx, 0.5);
    CGContextStrokePath(ctx);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat buttonWith = self.frame.size.width / 3;
    CGFloat buttonHeight = self.frame.size.height / 2;
    
    CGFloat subbuttonWith = buttonWith;
    CGFloat subbuttonHeight = buttonHeight / 2;
    
    NSArray <CameraControlButton *> *items = self.subviews;
    
    [items enumerateObjectsUsingBlock:^(CameraControlButton *button, NSUInteger idx, BOOL *stop) {
        button.frame = CGRectMake((idx % 3) * (buttonWith + 0.5), idx / 3 * (buttonHeight + 0.5), buttonWith - 1, buttonHeight - 1);
        if ([button.identifier isEqualToString:@"Cloud"]) {
            [button.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                obj.frame = CGRectMake(0, idx * subbuttonHeight, subbuttonWith, subbuttonHeight);
            }];
        }
    }];
}

- (void)setSourceData:(NSArray *)sourceData {
    [self removeAllSubviews];
    [sourceData enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
        NSString *imageName = [obj objectForKey:@"image"];
        NSString *title = [obj objectForKey:@"title"];
        NSString *identifier = [obj objectForKey:@"identifier"];
        CameraControlButton *controlButton = [CameraControlButton new];
        controlButton.identifier = identifier;
        if ([identifier isEqualToString:@"Cloud"]) {
            [self addCloudStorageItem:controlButton];
        } else {
            controlButton.imageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            controlButton.titleLabel.text = title;
            [controlButton addTarget:self action:@selector(controlAction:)];
        }
        [self addSubview:controlButton];
    }];
}

- (void)addCloudStorageItem:(CameraControlButton *)superView {
    CameraControlButton *cloudControlButton = [CameraControlButton new];
    cloudControlButton.imageView.image = [[UIImage imageNamed:@"ty_camera_cloud_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cloudControlButton.titleLabel.text = NSLocalizedStringFromTable(@"ipc_panel_button_cstorage", @"IPCLocalizable", @"");
    cloudControlButton.identifier = @"Cloud";
    [cloudControlButton addTarget:self action:@selector(controlAction:)];
    [superView addSubview:cloudControlButton];
    
    CameraControlButton *cloudDebugControlButton = [CameraControlButton new];
    cloudDebugControlButton.imageView.image = cloudControlButton.imageView.image;
    cloudDebugControlButton.titleLabel.text = NSLocalizedStringFromTable(@"ipc_panel_button_cstorage_debug", @"IPCLocalizable", @"");
    cloudDebugControlButton.identifier = @"CloudDebug";
    [cloudDebugControlButton addTarget:self action:@selector(controlAction:)];
    [superView addSubview:cloudDebugControlButton];
}

- (void)enableControl:(NSString *)identifier {
    [self.subviews enumerateObjectsUsingBlock:^(CameraControlButton *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            obj.disabled = NO;
            *stop = YES;
        }
    }];
}

- (void)disableControl:(NSString *)identifier {
    [self.subviews enumerateObjectsUsingBlock:^(CameraControlButton *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            obj.disabled = YES;
            *stop = YES;
        }
    }];
}

- (void)selectedControl:(NSString *)identifier {
    [self.subviews enumerateObjectsUsingBlock:^(CameraControlButton *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            obj.highLighted = YES;
            *stop = YES;
        }
    }];
}

- (void)deselectedControl:(NSString *)identifier {
    [self.subviews enumerateObjectsUsingBlock:^(CameraControlButton *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            obj.highLighted = NO;
            *stop = YES;
        }
    }];
}

- (void)enableAllControl {
    [self.subviews enumerateObjectsUsingBlock:^(CameraControlButton *obj, NSUInteger idx, BOOL *stop) {
        obj.disabled = NO;
    }];
}

- (void)disableAllControl {
    [self.subviews enumerateObjectsUsingBlock:^(CameraControlButton *obj, NSUInteger idx, BOOL *stop) {
        obj.disabled = YES;
    }];
}

- (void)controlAction:(UITapGestureRecognizer *)recognizer {
    CameraControlButton *controlButton = (CameraControlButton *)recognizer.view;
    if (!controlButton.disabled) {
        [self.delegate controlView:self didSelectedControl:controlButton.identifier];
    }
}

- (void)removeAllSubviews {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

@end
