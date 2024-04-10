//
//  CameraControlNewView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

#import "CameraControlButtonItemProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class CameraControlNewView;

@protocol CameraControlNewViewDelegate <NSObject>

- (void)controlView:(CameraControlNewView *)controlView didSelectedControl:(NSString *)identifier;

@end

@interface CameraControlNewView : UIView

@property (nonatomic, assign) BOOL isSmallSize;

@property (nonatomic, copy) NSArray<NSArray<id<CameraControlButtonItem>>*> *buttonItems;

@property (nonatomic, weak) id<CameraControlNewViewDelegate> delegate;

- (void)enableControl:(NSString *)identifier;

- (void)disableControl:(NSString *)identifier;

- (void)selectedControl:(NSString *)identifier;

- (void)deselectedControl:(NSString *)identifier;

- (void)enableAllControl;

- (void)disableAllControl;

@end

NS_ASSUME_NONNULL_END
