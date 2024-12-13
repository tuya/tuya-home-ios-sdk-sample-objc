//
//  DemoSplitVideoOperator.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoSplitVideoOperator.h"

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>

#import "DemoVideoViewIndexPair.h"

static NSString * const kSplitVideoLocalizerCoordinateDPCode = @"ipc_multi_locate_coor";

@interface DemoSplitVideoOperator () {
    __weak CameraDevice *_cameraDevice;
    id <ThingSmartCameraAdvancedConfig> _advancedConfig;
}

@end

@implementation DemoSplitVideoOperator

- (instancetype)initWithCameraDevice:(CameraDevice *)cameraDevice {
    self = [super init];
    if (self) {
        _cameraDevice = cameraDevice;
        _advancedConfig = _cameraDevice.camera.advancedConfig;
    }
    return self;
}

- (BOOL)bindVideoViewIndexPairs:(NSArray<id<ThingSmartVideoViewIndexPair>> *)viewIndexPairs {
    return [_cameraDevice.camera registerVideoViewIndexPairs:viewIndexPairs];
}

- (BOOL)unbindVideoViewIndexPairs:(NSArray<id<ThingSmartVideoViewIndexPair>> *)viewIndexPairs {
    return [_cameraDevice.camera uninstallVideoViewIndexPairs:viewIndexPairs];
}

- (BOOL)swapVideoIndex:(ThingSmartVideoIndex)videoIndex forVideoIndex:(ThingSmartVideoIndex)forVideoIndex {
    return [_cameraDevice.camera swapVideoIndex:videoIndex forVideoIndex:forVideoIndex];
}

- (BOOL)bindVideoView:(UIView<ThingSmartVideoViewType> *)videoView videoIndex:(ThingSmartVideoIndex)videoIndex {
    DemoVideoViewIndexPair *pairInfo = [[DemoVideoViewIndexPair alloc] initWithVideoView:videoView videoIndex:videoIndex];
    return [self bindVideoViewIndexPairs:@[pairInfo]];
}

- (BOOL)unbindVideoView:(UIView<ThingSmartVideoViewType> *)videoView videoIndex:(ThingSmartVideoIndex)videoIndex {
    DemoVideoViewIndexPair *pairInfo = [[DemoVideoViewIndexPair alloc] initWithVideoView:videoView videoIndex:videoIndex];
    return [self unbindVideoViewIndexPairs:@[pairInfo]];
}

- (BOOL)publishLocalizerCoordinateInfo:(NSString *)coordinateInfo {
    NSLog(@"publish localizer coordinate(%@) to device(%@)",coordinateInfo,_cameraDevice.deviceModel.devId);
    if (NO == [_cameraDevice.dpManager isSupportDPCode:kSplitVideoLocalizerCoordinateDPCode]) {
        return NO;
    }
    [_cameraDevice.dpManager setValue:coordinateInfo forDPCode:kSplitVideoLocalizerCoordinateDPCode success:^(id  _Nonnull result) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
    return YES;
}

- (id<ThingSmartCameraAdvancedConfig>)advancedConfig {
    return _advancedConfig;
}

@end
