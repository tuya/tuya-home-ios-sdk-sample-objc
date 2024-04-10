//
//  DemoVideoLocalizerView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraSplitVideoBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^TRCTCameraMultiVideoLocalizerMovedCompletion)(NSString *coordinateInfo);

@interface DemoVideoLocalizerView : CameraSplitVideoBaseView

@property (nonatomic, copy) TRCTCameraMultiVideoLocalizerMovedCompletion movedCompletion;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, assign, readonly) BOOL isLocalizerShown;

- (void)showLocalizerView:(BOOL)isShown;

- (void)hideLocalizerViewImmediately;

@end

NS_ASSUME_NONNULL_END
