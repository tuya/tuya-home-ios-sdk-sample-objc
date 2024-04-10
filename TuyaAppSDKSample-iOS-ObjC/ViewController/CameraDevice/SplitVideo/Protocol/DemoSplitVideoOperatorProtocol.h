//
//  DemoSplitVideoOperatorProtocol.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <Foundation/Foundation.h>

#import <ThingSmartCameraBase/ThingSmartVideoExtInfoType.h>
#import <ThingSmartCameraBase/ThingSmartCameraAdvancedConfigType.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DemoSplitVideoOperatorProtocol <NSObject>

@property (nonatomic, strong, readonly) id <ThingSmartCameraAdvancedConfig> advancedConfig;

- (BOOL)bindVideoViewIndexPairs:(NSArray<id<ThingSmartVideoViewIndexPair>> *)viewIndexPairs;
- (BOOL)unbindVideoViewIndexPairs:(NSArray<id<ThingSmartVideoViewIndexPair>> *)viewIndexPairs;

- (BOOL)bindVideoView:(UIView<ThingSmartVideoViewType> *)videoView videoIndex:(ThingSmartVideoIndex)videoIndex;
- (BOOL)unbindVideoView:(UIView<ThingSmartVideoViewType> *)videoView videoIndex:(ThingSmartVideoIndex)videoIndex;

- (BOOL)swapVideoIndex:(ThingSmartVideoIndex)videoIndex forVideoIndex:(ThingSmartVideoIndex)forVideoIndex;

- (BOOL)publishLocalizerCoordinateInfo:(NSString *)coordinateInfo;

@end

NS_ASSUME_NONNULL_END
