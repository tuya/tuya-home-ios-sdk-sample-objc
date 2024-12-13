//
//  CameraVideoGestureView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CameraVideoGestureView;

@protocol CameraVideoGestureViewDelegate <NSObject>

@optional
- (void)gestureView:(CameraVideoGestureView *)gestureView  didRecognizedPinchGesture:(UIPinchGestureRecognizer *)pinchRecognizer scaled:(CGFloat)scale centerPoint:(CGPoint)cPoint;

- (void)gestureView:(CameraVideoGestureView *)gestureView didRecognizedTapGesture:(UITapGestureRecognizer *)tapRecognizer;

- (void)gestureView:(CameraVideoGestureView *)gestureView didRecognizedDoubleTapGesture:(UITapGestureRecognizer *)doubleTapRecognizer;

- (void)gestureView:(CameraVideoGestureView *)gestureView didRecognizedPanGesture:(UIPanGestureRecognizer *)panRecognizer offset:(CGPoint)offset;

@end


@interface CameraVideoGestureView : UIView

@property (nonatomic, weak) id<CameraVideoGestureViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
