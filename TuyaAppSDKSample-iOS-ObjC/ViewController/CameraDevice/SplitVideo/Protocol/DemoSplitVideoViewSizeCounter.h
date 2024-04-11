//
//  DemoSplitVideoViewSizeCounter.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DemoSplitVideoViewSizeCounter <NSObject>

@property (nonatomic, assign, readonly) CGFloat padding;

@property (nonatomic, assign, readonly) CGSize landscapeSmallSize;
@property (nonatomic, assign, readonly) CGFloat landscapeViewMargin;
@property (nonatomic, assign, readonly) CGSize landscapeCoverSize;


@property (nonatomic, assign, readonly) CGSize portraitSmallSize;
@property (nonatomic, assign, readonly) CGSize portraitNormalSize;


@property (nonatomic, assign, readonly) CGFloat videoViewWidth;
@property (nonatomic, assign, readonly) CGFloat videoViewHeight;

@end

NS_ASSUME_NONNULL_END
