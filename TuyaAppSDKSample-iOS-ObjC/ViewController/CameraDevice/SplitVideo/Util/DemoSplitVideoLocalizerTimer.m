//
//  DemoSplitVideoLocalizerTimer.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoLocalizerTimer.h"

@interface DemoSplitVideoLocalizerTimer () {
    dispatch_source_t _gcdTimer;
    NSTimeInterval _interval;
    NSUInteger _times;
    __weak id _aTarget;
    SEL _aSelector;
    id _userInfo;
    
    NSUInteger _innerTimes;
}

@end

@implementation DemoSplitVideoLocalizerTimer

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)interval times:(NSUInteger)times target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo {
    self = [super init];
    if (self) {
        _interval = interval;
        _times = times == 0 ? NSUIntegerMax : times;
        _aTarget = aTarget;
        _aSelector = aSelector;
        _userInfo = userInfo;
    }
    return self;
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval times:(NSUInteger)times target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo {
    return [[self alloc] initWithTimeInterval:interval times:times target:aTarget selector:aSelector userInfo:userInfo];
}

+ (instancetype)timerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo {
    return [[self alloc] initWithTimeInterval:interval times:1 target:aTarget selector:aSelector userInfo:userInfo];
}

- (void)fire {
    _innerTimes = 0;
    [self invalidate];
    
    _gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_gcdTimer, dispatch_time(DISPATCH_TIME_NOW, (uint64_t)(_interval * NSEC_PER_SEC)), (uint64_t)(_interval * NSEC_PER_SEC), 0);
    __weak typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(_gcdTimer, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf executeTask];
        if (strongSelf->_innerTimes + 1 >= strongSelf->_times) {
            [strongSelf invalidate];
        }
        strongSelf->_innerTimes++;
    });
    dispatch_resume(_gcdTimer);
}

- (void)invalidate {
    if (_gcdTimer) {
        dispatch_source_cancel(_gcdTimer);
        _gcdTimer = nil;
    }
}

- (void)executeTask {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_aTarget performSelector:_aSelector withObject:self];
#pragma clang diagnostic pop
}

- (id)userInfo {
    return _userInfo;
}

@end

