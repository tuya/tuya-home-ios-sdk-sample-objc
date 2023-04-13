//
//  CameraControlView.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

@interface CameraControlButton : UIView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, assign) BOOL highLighted;

@property (nonatomic, assign) BOOL disabled;

- (void)addTarget:(id)target action:(SEL)action;

@end
