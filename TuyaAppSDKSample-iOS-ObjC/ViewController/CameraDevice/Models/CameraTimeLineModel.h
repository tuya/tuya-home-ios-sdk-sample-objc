//
//  CameraTimeLineModel.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>
#import <ThingCameraUIKit/ThingCameraUIKit.h>

@interface CameraTimeLineModel : NSObject <ThingTimelineViewSource>

@property (nonatomic, assign) NSInteger startTime;

@property (nonatomic, assign) NSInteger stopTime;

@property (nonatomic, strong) NSDate *startDate;

@property (nonatomic, strong) NSDate *stopDate;

- (BOOL)containsPlayTime:(NSInteger)playTime;

@end

