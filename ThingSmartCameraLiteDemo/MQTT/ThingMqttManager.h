//
//  ThingMqttManager.h
//  ThingSmartVisual
//
//  Created by MokZF on 2024/12/31.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ThingCameraP2PConnectDataSource <NSObject>

- (NSString *)productKey;
- (NSString *)deviceName;
- (NSString *)deviceSecret;

- (NSString *)mqttTopic;

@end

@protocol ThingCameraMqttProtocol <NSObject>

- (void)thing_handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained;

- (void)thing_sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState;

- (void)thing_sessionManager:(MQTTSessionManager *)sessionManager didDeliverMessage:(UInt16)msgID;

@end

@interface ThingMqttManager : NSObject

+ (instancetype)sharedInstance;

//发起连接
- (void)connectMqtt;

//发送数据
- (void)sendData:(NSData *)value;

/// 断开连接
- (void)disconnect;

- (MQTTSessionManagerState)mqttConnectState;

@property (nonatomic, weak) id<ThingCameraP2PConnectDataSource> mqttManagerDataSource;

@property (nonatomic, weak) id<ThingCameraMqttProtocol> mqttManagerDelegate;

@end

NS_ASSUME_NONNULL_END
