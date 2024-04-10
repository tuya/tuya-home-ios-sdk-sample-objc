//
//  DemoSplitVideoViewContextQuoter.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import "DemoSplitVideoViewContext.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DemoSplitVideoViewContextQuoter <NSObject>

@property (nonatomic, weak) id <DemoSplitVideoViewContext> videoViewContext;

@end

NS_ASSUME_NONNULL_END
