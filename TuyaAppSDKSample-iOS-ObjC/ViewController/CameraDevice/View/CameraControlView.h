//
//  CameraControlView.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

@class CameraControlView;

@protocol CameraControlViewDelegate <NSObject>

- (void)controlView:(CameraControlView *)controlView didSelectedControl:(NSString *)identifier;

@end

@interface CameraControlView : UIView

@property (nonatomic, strong) NSArray *sourceData;

@property (nonatomic, weak) id<CameraControlViewDelegate> delegate;

- (void)enableControl:(NSString *)identifier;

- (void)disableControl:(NSString *)identifier;

- (void)selectedControl:(NSString *)identifier;

- (void)deselectedControl:(NSString *)identifier;

- (void)enableAllControl;

- (void)disableAllControl;

@end

