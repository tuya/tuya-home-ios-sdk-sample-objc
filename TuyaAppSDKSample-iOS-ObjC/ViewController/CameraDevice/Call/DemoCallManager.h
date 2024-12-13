//
//  DemoCallManager.h
//  ThingCallModule
//
//  Created by 后主 on 2022/12/1.
//

#import <Foundation/Foundation.h>
#import <ThingSmartCallChannelKit/ThingSmartCallChannelKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface DemoCallManager : NSObject

+ (instancetype)sharedInstance;

/// start call
- (void)startCallWithTargetId:(NSString *)targetId timeout:(NSInteger)timeout extra:(NSDictionary *)extra success:(nullable ThingSmartCallSuccess)success failure:(nullable ThingSmartCallFailure)failure;

///fetch device call ability from cloud, which is dependent on device's ability and product's advanced ability.
- (void)fetchDeviceCallAbilityByDevId:(NSString *)devId completion:(ThingSmartCallFetchCompletion)completion;

/// whether app can start call
- (BOOL)canStartCall;

- (BOOL)isCalling;

@end

NS_ASSUME_NONNULL_END
