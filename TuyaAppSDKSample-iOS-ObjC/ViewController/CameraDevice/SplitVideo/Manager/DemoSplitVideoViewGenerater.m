//
//  DemoSplitVideoViewGenerater.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoViewGenerater.h"

#import <ThingSmartCameraM/ThingSmartCameraM.h>

#import "DemoSplitVideoInfoProcesser.h"

#import "DemoSplitVideoInfo.h"

static const NSInteger kDemoCameraSplitVideoViewMaxCount = 2;

@interface DemoSplitVideoViewGenerater () {
    NSArray<NSArray<DemoSplitVideoNodeView *> *> *_videoViews;
    NSHashTable<DemoSplitVideoNodeView *> *_allVideoViews;
    NSArray<DemoSplitVideoNodeView *> *_bigViews;
    NSArray<DemoSplitVideoNodeView *> *_smallViews;
}

@end

@implementation DemoSplitVideoViewGenerater

- (instancetype)initWithAdvancedConfig:(id<ThingSmartCameraAdvancedConfig>)advancedConfig videoViewContext:(nonnull id<DemoSplitVideoViewContext>)videoViewContext{
    self = [super init];
    if (self) {
        _allVideoViews = NSHashTable.weakObjectsHashTable;
        NSArray<NSArray<DemoSplitVideoInfo *>*> *videoInfos = [DemoSplitVideoInfoProcesser processVideoSplitInfoWithAdvancedConfig:advancedConfig];
        NSMutableArray *videoViews = [[NSMutableArray alloc] init];
        NSMutableArray *bigViews = [[NSMutableArray alloc] init];
        NSMutableArray *smallViews = [[NSMutableArray alloc] init];
        for (NSArray<DemoSplitVideoInfo *>*subVideoInfos in videoInfos) {
            NSMutableArray *suvVideoViews = [[NSMutableArray alloc] init];
            for (DemoSplitVideoInfo *subVideoInfo in subVideoInfos) {
                DemoSplitVideoNodeView *videoNodeView = [[DemoSplitVideoNodeView alloc] initWithFrame:CGRectZero videoViewContext:videoViewContext splitVideoInfo:subVideoInfo];
                [suvVideoViews addObject:videoNodeView];
                [_allVideoViews addObject:videoNodeView];
                if (subVideoInfo.isFirstIndex) {
                    videoNodeView.isMainView = YES;
                    [bigViews addObject:videoNodeView];
                } else {
                    videoNodeView.isMainView = NO;
                    [smallViews addObject:videoNodeView];
                }
            }
            [videoViews addObject:suvVideoViews.copy];
        }
        _videoViews = videoViews.copy;
        _bigViews = bigViews.copy;
        _smallViews = smallViews.copy;
    }
    return self;
}

- (NSArray<DemoSplitVideoNodeView *> *)allViews {
    return _allVideoViews.allObjects;
}

#pragma mark - Portrait

- (NSArray<DemoSplitVideoNodeView *> *)topViews {
    if (_videoViews.firstObject.count <= kDemoCameraSplitVideoViewMaxCount) {
        return _videoViews.firstObject;
    }
    return [_videoViews.firstObject subarrayWithRange:NSMakeRange(0, kDemoCameraSplitVideoViewMaxCount)];
}

- (NSArray<DemoSplitVideoNodeView *> *)bottomViews {
    if (_videoViews.count == 1) {
        return @[];
    }
    if (_videoViews.lastObject.count <= kDemoCameraSplitVideoViewMaxCount) {
        return _videoViews.lastObject;
    }
    return [_videoViews.lastObject subarrayWithRange:NSMakeRange(0, kDemoCameraSplitVideoViewMaxCount)];
}


#pragma mark - Landscape

- (NSArray<DemoSplitVideoNodeView *> *)bigViews {
    if (_bigViews.count) {
        return _bigViews;
    }
    DemoSplitVideoNodeView *firstSplitVideoNodeView = _videoViews.firstObject.firstObject;
    firstSplitVideoNodeView.isMainView = YES;
    return @[firstSplitVideoNodeView];
}

- (NSArray<DemoSplitVideoNodeView *> *)smallViews {
    if (_smallViews.count) {
        return _smallViews;
    }
    NSMutableArray *tempSmallViews = [[NSMutableArray alloc] init];
    NSArray *firstVideoViews = _videoViews.firstObject;
    for (NSInteger i = 1; i < firstVideoViews.count; i++) {
        [tempSmallViews addObject:firstVideoViews[i]];
    }
    if (_videoViews.count > 1) {
        [tempSmallViews addObjectsFromArray:_videoViews.lastObject];
    }
    [tempSmallViews setValue:@NO forKeyPath:@"isMainView"];
    return tempSmallViews.copy;
}

@end
