//
//  DemoSplitVideoInfo.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoInfo.h"

@implementation DemoSplitVideoInfo

- (instancetype)initWithVideo_info:(thing_ipc_split_video_info *)video_info isLocalizer:(BOOL)isLocalizer isFirstIndex:(BOOL)isFirstIndex {
    self = [super init];
    if (self) {
        self.index = video_info.index;
        self.type = video_info.type;
        self.res_pos = video_info.res_pos;
        _isLocalizer = isLocalizer;
        _isFirstIndex = isFirstIndex;
    }
    return self;
}


@end
