//
//  CameraLocalPathUtil.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraLocalPathUtil.h"

#import <AVFoundation/AVFoundation.h>


@interface CameraLocalPathUtil ()

@property (class, nonatomic, strong, readonly) CameraLocalPathUtil *sharedManager;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, copy) NSString *innerPlaybackLoclPath;

@end

@implementation CameraLocalPathUtil

+ (instancetype)sharedManager {
    static CameraLocalPathUtil *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [CameraLocalPathUtil new];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    }
    return self;
}


- (NSString *)innerPlaybackLoclPath {
    if (!_innerPlaybackLoclPath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _innerPlaybackLoclPath = [paths.firstObject stringByAppendingPathComponent:@"playback"];
        BOOL isDirectory = YES;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:_innerPlaybackLoclPath isDirectory:&isDirectory];
        if (isExist && !isDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:_innerPlaybackLoclPath error:nil];
            [[NSFileManager defaultManager] createDirectoryAtPath:_innerPlaybackLoclPath withIntermediateDirectories:NO attributes:nil error:nil];
        }else if (!isExist) {
            [[NSFileManager defaultManager] createDirectoryAtPath:_innerPlaybackLoclPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    return _innerPlaybackLoclPath;
}

#pragma mark - util

- (NSString *)filePrefixWithDate:(NSDate *)date {
    self.dateFormatter.dateFormat = @"yyyy_MM_dd_HH_mm_ss_S";
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    NSString *filePrefix = [[NSString alloc] initWithFormat:@"%@_%@", dateString, [self randomStringWithLength:6]];
    return filePrefix;
}

- (NSString *)randomStringWithLength:(NSUInteger)length {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *string = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0; i < length; i++) {
        u_int32_t index = arc4random() % [letters length];
        unichar character = [letters characterAtIndex:index];
        [string appendFormat:@"%C", character];
    }
    return [NSString stringWithString:string];
}


+ (NSString *)generateRandomLocalPath {
    NSString *filePrefix = [[self.sharedManager filePrefixWithDate:NSDate.date] stringByAppendingString:@".mp4"];
    return [self.sharedManager.innerPlaybackLoclPath stringByAppendingPathComponent:filePrefix];
}

@end
