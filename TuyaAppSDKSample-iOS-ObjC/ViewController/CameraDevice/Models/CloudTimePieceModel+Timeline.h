//
//  CloudTimePieceModel+Timeline.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>
#import <TuyaCameraUIKit/TuyaCameraUIKit.h>

@interface TuyaSmartCloudTimePieceModel (Timeline)<TuyaTimelineViewSource>

- (BOOL)containsTime:(NSInteger)time;

@end


