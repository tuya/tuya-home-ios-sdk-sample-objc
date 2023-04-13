//
//  CloudTimePieceModel+Timeline.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CloudTimePieceModel+Timeline.h"

@implementation TuyaSmartCloudTimePieceModel (Timeline)

- (NSTimeInterval)startTimeIntervalSinceDate:(NSDate *)date {
    return [self.startDate timeIntervalSinceDate:date];
}

- (NSTimeInterval)stopTimeIntervalSinceDate:(NSDate *)date {
    return [self.endDate timeIntervalSinceDate:date];
}

- (BOOL)containsTime:(NSInteger)time {
    return time >= self.startTime && time <= self.endTime;
}

@end
