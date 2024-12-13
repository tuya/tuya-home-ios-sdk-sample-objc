//
//  DemoSplitVideoInfoProcesser.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoInfoProcesser.h"

#import <ThingSmartCameraM/ThingSmartCameraM.h>

@implementation DemoSplitVideoInfoProcesser

+ (NSArray<NSArray<DemoSplitVideoInfo *>*> *)processVideoSplitInfoWithAdvancedConfig:(id<ThingSmartCameraAdvancedConfig>)advancedConfig {
    @autoreleasepool {
        ThingSmartCameraAdvancedConfig *innerAdvancedConfig = (ThingSmartCameraAdvancedConfig *)advancedConfig;
        NSMutableArray *videoInfos = [[NSMutableArray alloc] init];
        thing_ipc_split_video_sum_info *split_video_sum_info = innerAdvancedConfig.split_video_sum_info;
        NSArray<NSArray<thing_ipc_split_video_index> *> *align_group = split_video_sum_info.align_info.align_group;
        NSArray<thing_ipc_split_video_index> *localizer_group = split_video_sum_info.align_info.localizer_group;
        NSArray <thing_ipc_split_video_info *> *split_info = split_video_sum_info.split_info;
        for (NSArray<thing_ipc_split_video_index> *videoIndexs in align_group) {
            if (![videoIndexs isKindOfClass:NSArray.class]) {
                continue;
            }
            NSMutableArray *subVideoInfos = [[NSMutableArray alloc] init];
            for (thing_ipc_split_video_index videoIndex in videoIndexs) {
                thing_ipc_split_video_info *video_info = [self queryVideoInfoFromOriginalInfos:split_info atIndex:videoIndex];
                if (video_info) {
                    BOOL isLocalizer = [localizer_group containsObject:videoIndex];
                    BOOL isFirstIndex = ([split_info indexOfObject:video_info] == 0);
                    DemoSplitVideoInfo *videoInfo = [[DemoSplitVideoInfo alloc] initWithVideo_info:video_info isLocalizer:isLocalizer isFirstIndex:isFirstIndex];
                    [subVideoInfos addObject:videoInfo];
                }
            }
            if (subVideoInfos.count) {
                [videoInfos addObject:subVideoInfos.copy];
            }
        }
        return videoInfos.copy;
    }
}

+ (thing_ipc_split_video_info *)queryVideoInfoFromOriginalInfos:(NSArray *)originalInfos atIndex:(thing_ipc_split_video_index)atIndex {
    for (thing_ipc_split_video_info *video_info in originalInfos) {
        if (video_info.index == atIndex.integerValue) {
            return video_info;
        }
    }
    return nil;
}

@end
