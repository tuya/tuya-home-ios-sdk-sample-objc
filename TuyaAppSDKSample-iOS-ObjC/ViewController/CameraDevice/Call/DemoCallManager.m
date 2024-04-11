//
//  DemoCallManager.m
//  ThingCallModule
//
//  Created by 后主 on 2022/12/1.
//

#import "DemoCallManager.h"

#import <ThingSmartNetworkKit/ThingSmartNetworkKit.h>
#import <ThingSmartBaseKit/ThingSmartBaseKit.h>
#import <ThingSmartUtil/ThingSmartUtil.h>

#import "CameraCallInterfaceManager.h"


@interface DemoCallManager () <ThingSmartCallChannelDelegate,ThingSmartCallChannelDataSource>

@property (nonatomic, strong) CameraCallInterfaceManager *interfaceManager;

@end

@implementation DemoCallManager

+ (void)load {
    [DemoCallManager.sharedInstance configurateCallSDK];
}

#pragma mark - 处理voip/push消息
- (void)handlePushMessageHandle:(NSDictionary *)message {
    [ThingSmartCallChannel.sharedInstance handlePushMessage:message];
}

#pragma mark - 单例
+ (instancetype)sharedInstance {
    static DemoCallManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DemoCallManager alloc] init];
    });
    return instance;
}

+ (instancetype)oneInstance {
    return [self sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _interfaceManager = [[CameraCallInterfaceManager alloc] init];
        _interfaceManager.identifier = ThingCallInterfaceManagerScreenIPCIdentifier;
    }
    return self;
}

- (void)configurateCallSDK {
    [ThingSmartCallChannel.sharedInstance launch];
    ThingSmartCallChannel.sharedInstance.dataSource = self;
    [ThingSmartCallChannel.sharedInstance addDelegate:self];
    [ThingSmartCallChannel.sharedInstance registerCallInterfaceManager:_interfaceManager];
}

#pragma mark - 是否在通话中
/// 是否正在通话中
- (BOOL)isCalling {
    return [ThingSmartCallChannel.sharedInstance isOnCalling];
}

/// 是否可以发起呼叫
- (BOOL)canStartCall {
    return ![self isCalling];
}


#pragma mark - 呼出

- (void)startCallWithTargetId:(NSString *)targetId timeout:(NSInteger)timeout extra:(NSDictionary *)extra success:(ThingSmartCallSuccess)success failure:(ThingSmartCallFailure)failure {
    [ThingSmartCallChannel.sharedInstance startCallWithTargetId:targetId timeout:timeout extra:extra success:success failure:failure];
}

- (void)fetchDeviceCallAbilityByDevId:(NSString *)devId completion:(ThingSmartCallFetchCompletion)completion {
    [ThingSmartCallChannel.sharedInstance fetchDeviceCallAbilityByDevId:devId completion:completion];
}

#pragma mark - ThingSmartCallChannelDelegate

//receive a call, but it is an invalid call, then will call it, eg: go to device panel or an error page.
- (void)callChannel:(ThingSmartCallChannel *)callChannel didReceiveInvalidPushCall:(id<ThingSmartCallProtocol>)call error:(NSError *)error {
    if ([call.targetId isKindOfClass:NSString.class] && call.targetId.length) {
        NSLog(@"The call is invalid");
    }
}

- (void)callChannel:(ThingSmartCallChannel *)callChannel didReceiveInvalidCall:(id<ThingSmartCallProtocol>)call error:(NSError *)error {
    if (error.code == ThingSmartCallErrorOnCalling) {
        NSLog(@"is on calling");
    }
}

#pragma mark - ThingSmartCallChannelDataSource

- (id<ThingSmartCallKitExecuter>)callKitExecuter {
    return nil;
}

@end
