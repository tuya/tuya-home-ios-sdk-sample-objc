//
//  DemoSplitVideoViewContext.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import "DemoSplitVideoOperatorProtocol.h"
#import "DemoSplitVideoViewSizeCounter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DemoSplitVideoViewContext <NSObject>

@property (nonatomic, weak, readonly) id <DemoSplitVideoOperatorProtocol> videoOperator;
@property (nonatomic, weak, readonly) id <DemoSplitVideoViewSizeCounter> viewSizeCounter;

@end

NS_ASSUME_NONNULL_END
