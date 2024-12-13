//
//  DemoVideoViewIndexPair.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoVideoViewIndexPair.h"

@implementation DemoVideoViewIndexPair

@synthesize videoIndex,videoView;

- (instancetype)initWithVideoView:(UIView<ThingSmartVideoViewType> *)videoView videoIndex:(ThingSmartVideoIndex)videoIndex {
    self = [super init];
    if (self) {
        self.videoIndex = videoIndex;
        self.videoView = videoView;
    }
    return self;
}

@end
