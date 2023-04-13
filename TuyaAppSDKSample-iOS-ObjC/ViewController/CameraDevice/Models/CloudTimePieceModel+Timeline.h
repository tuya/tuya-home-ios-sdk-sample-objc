//
//  CloudTimePieceModel+Timeline.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import <ThingCameraUIKit/ThingCameraUIKit.h>

@interface ThingSmartCloudTimePieceModel (Timeline)<ThingTimelineViewSource>

- (BOOL)containsTime:(NSInteger)time;

@end


