//
//  CameraDeviceModel.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraDeviceModel.h"

@interface NSString (CameraJson)

@property (nonatomic,strong, readonly) id p_objectFromJSONString;

@end

@implementation NSString (CameraJson)

- (id)p_objectFromJSONString {
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:NULL];
    return jsonObj;
}

@end

@implementation CameraDeviceModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutedForPreview = YES;
        _mutedForPlayback = YES;
    }
    return self;
}

- (BOOL)isOnPreviewMode {
    return self.previewState != CameraDevicePreviewNone;
}

- (void)resetCameraAbility:(TuyaSmartCameraAbility *)cameraAbility {
    _isSupportSpeaker = cameraAbility.isSupportSpeaker;
    _isSupportPickup = cameraAbility.isSupportPickup;
    _defaultTalkbackMode = cameraAbility.defaultTalkbackMode;
    _couldChangeTalkbackMode = cameraAbility.couldChangeTalkbackMode;
    _defaultDefinition = cameraAbility.defaultDefinition;
    _configInfoData = cameraAbility.rowData;
}

- (BOOL)isSupportNewRecordEvent {
    NSDictionary *configInfoData = self.configInfoData;
    id skills = [[configInfoData objectForKey:@"skill"] p_objectFromJSONString];
    if ([skills isKindOfClass:[NSDictionary class]]) {
        NSUInteger localStorage = [skills[@"localStorage"] unsignedIntegerValue];
        if (localStorage & (1ULL << 25)) {
            return YES;
        }
    }
    return NO;
}

@end
