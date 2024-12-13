//
//  ThingCameraVideoContainer.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "CameraVideoGestureView.h"
#import <ThingSmartCameraBase/ThingSmartVideoViewType.h>

@protocol ThingCameraVideoContainerDelegate <NSObject>

@optional

- (void)videoContainer:(UIView<CameraVideoGestureViewDelegate> *_Nullable)videoContainer didTap:(UITapGestureRecognizer *_Nonnull)tapRecognizer;

- (void)videoContainer:(UIView<CameraVideoGestureViewDelegate> *_Nullable)videoContainer didDoubleTap:(UITapGestureRecognizer *_Nullable)tapRecognizer;

- (void)videoContainer:(UIView<CameraVideoGestureViewDelegate> *_Nullable)videoContainer
          didZoomScale:(CGFloat)scale;

@end

@protocol ThingCameraVideoContainerProtocol <NSObject>

@property (nonatomic, weak) id<ThingCameraVideoContainerDelegate> _Nullable delegate;

- (void)clearImage;

@end


NS_ASSUME_NONNULL_BEGIN

@interface ThingCameraVideoContainer : UIView

@property (nonatomic, weak) id<ThingCameraVideoContainerDelegate> delegate;
@property (nonatomic, strong) CameraVideoGestureView *videoGestureView;


@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, assign) CGPoint videoOffset;

@property (nonatomic, assign) CGFloat videoScaled;

@property (nonatomic, assign) CGFloat maxScaled;

@property (nonatomic, assign) CGFloat minScaled;

@property (nonatomic, assign) CGFloat preferredScaled;

@property (nonatomic, copy) void(^LayoutContentView)(UIView *contentView);

- (void)setVideoScaled:(CGFloat)scaled animated:(BOOL)animated;

- (void)thing_clear;

@end

NS_ASSUME_NONNULL_END
