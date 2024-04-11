//
//  CameraSplitVideoBaseView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraSplitVideoBaseView.h"

@implementation CameraSplitVideoBaseView

- (void)dealloc {
    NSLog(@"[dealloc]-%s", __func__);
}

- (void)triggerLayoutImmediately {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
