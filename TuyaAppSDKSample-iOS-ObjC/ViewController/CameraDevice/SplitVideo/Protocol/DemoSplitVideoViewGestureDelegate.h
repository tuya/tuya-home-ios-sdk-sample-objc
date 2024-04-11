//
//  DemoSplitVideoViewGestureDelegate.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DemoSplitVideoNodeView;
@protocol DemoSplitVideoViewGestureDelegate <NSObject>

@optional

- (BOOL)respondWrappedTapGesture:(UITapGestureRecognizer *)tapGesture;

- (BOOL)didTapVideoNodeView:(DemoSplitVideoNodeView *)videoNodeView;

@end

NS_ASSUME_NONNULL_END
