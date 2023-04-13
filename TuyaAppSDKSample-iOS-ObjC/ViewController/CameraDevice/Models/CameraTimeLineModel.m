//
//  CameraTimeLineModel.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraTimeLineModel.h"

@implementation CameraTimeLineModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"stopTime" : @"endTime"
             };
}

- (NSTimeInterval)startTimeIntervalSinceDate:(NSDate *)date {
    return [self.startDate timeIntervalSinceDate:date];
}

- (NSTimeInterval)stopTimeIntervalSinceDate:(NSDate *)date {
    return [self.stopDate timeIntervalSinceDate:date];
}

- (BOOL)containsPlayTime:(NSInteger)playTime {
    return playTime >= self.startTime && playTime < self.stopTime;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<TYCameraTimeSliceModel: startTime = %@, stopTime = %@>", @(self.startTime), @(self.stopTime)];
}

- (NSDate *)startDate {
    if (!_startDate) {
        _startDate = [NSDate dateWithTimeIntervalSince1970:self.startTime];
    }
    return _startDate;
}

- (NSDate *)stopDate {
    if (!_stopDate) {
        _stopDate = [NSDate dateWithTimeIntervalSince1970:self.stopTime];
    }
    return _stopDate;
}

@end
