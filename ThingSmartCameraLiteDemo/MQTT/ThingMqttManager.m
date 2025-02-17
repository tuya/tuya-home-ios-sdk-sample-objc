//
//  ThingMqttManager.m
//  ThingSmartVisual
//
//  Created by MokZF on 2024/12/31.
//

#import "ThingMqttManager.h"
#include "aiot_mqtt_sign.h"
#import "ViewController.h"

static dispatch_queue_t thing_pixcel_buffer_async_queue;

@interface ThingMqttManager()<MQTTSessionDelegate,MQTTSessionManagerDelegate>

@property (nonatomic, strong) MQTTSessionManager *mqttSessionManager;

@property (nonatomic, assign) CGFloat sendT;
@property (nonatomic, assign) CGFloat sendedT;

@end

@implementation ThingMqttManager


+ (instancetype)sharedInstance {
    static ThingMqttManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ThingMqttManager alloc] init];
    });
    return _instance;
}


- (void)connectMqtt {
    if (!thing_pixcel_buffer_async_queue) {
        thing_pixcel_buffer_async_queue = dispatch_queue_create("com.thing.camera.mqtt", DISPATCH_QUEUE_CONCURRENT);

    }
    [self mqttSessionManagerInit];
}


- (void)sendData:(NSData *)value {
    NSLog(@"mtTimeDawei:SendTime=========%.0f",[[NSDate date] timeIntervalSince1970]);
    self.sendT = [[NSDate date] timeIntervalSince1970];
    [self.mqttSessionManager sendData:value topic:testDeviceTopicIn qos:MQTTQosLevelAtLeastOnce retain:NO];
}

- (void)disconnect {
    [self.mqttSessionManager disconnectWithDisconnectHandler:^(NSError *error) {
        if (error) {
            NSLog(@"=====disconnect error:%@",error);
        }
    }];
}

- (void)subScribTopic {
    if (!self.mqttSessionManager) {
        return;
    }
    //订阅topic
    [self.mqttSessionManager.session subscribeToTopic:testDeviceTopicOut atLevel:MQTTQosLevelAtLeastOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"=====error:%@",error);
        }
    }];
    
    
}

- (MQTTSessionManagerState)mqttConnectState {
    return self.mqttSessionManager.state;
}

//- (void)connectWithHost {
//    
//    MQTTSSLSecurityPolicy *defaultPolicy = [MQTTSSLSecurityPolicy defaultPolicy];
////    defaultPolicy.domainName = _mqttConfig.mbHost;
//    MQTTSession *_mqttSession = [[MQTTSession alloc] initWithClientId:@""
//                                                userName:@""
//                                                password:@""
//                                               keepAlive:60
//                                          connectMessage:nil
//                                            cleanSession:YES
//                                                    will:NO
//                                               willTopic:nil
//                                                 willMsg:nil
//                                                 willQoS:MQTTQosLevelAtMostOnce
//                                          willRetainFlag:NO
//                                           protocolLevel:4
//                                                   queue:dispatch_get_main_queue()
//                                          securityPolicy:defaultPolicy
//                                            certificates:nil];
////    _mqttSession.disableDupOnlyOnce = [ThingSmartMQTTChannelConfig sharedInstance].disableDupOnlyOnce;
////    if ([ThingSmartMQTTChannelConfig sharedInstance].dupTime > 0) {
////        _mqttSession.dupTimeout = [ThingSmartMQTTChannelConfig sharedInstance].dupTime;
////    } else {
////    }
//    _mqttSession.dupTimeout = 5;
//    [MQTTLog setLogLevel:DDLogLevelOff];
//    [_mqttSession setDelegate:self];
//    
//    ThingMQTTConcurrentTransport *transport = [[ThingMQTTConcurrentTransport alloc] initWithConfig:_mqttConfig queue:_internalQueue];
//    _mqttSession.transport = transport;
//    
//    [[ThingMQTTEventUtil sharedInstance] clearAllMsgDate];
//    [[ThingMQTTEventUtil sharedInstance] connectStartEvent];
//    [_mqttSession connectWithConnectHandler:^(NSError *error) {
//        
//    }];
//}

- (void)mqttSessionManagerInit {
    if (![ThingMqttManager sharedInstance].mqttSessionManager) {
        MQTTSessionManager *manager = [[MQTTSessionManager alloc] init];
        self.mqttSessionManager = manager;
        self.mqttSessionManager.delegate = self;
    }
    
    NSString *mqttHost = @"si-1cf34299fc574b9782cd.tuyacloud.com";
    
    const char *productKey = "";
    const char *deviceName = "";
    const char *deviceSecret = "";

    if ([self.mqttManagerDataSource respondsToSelector:@selector(productKey)]) {
        productKey = [[self.mqttManagerDataSource productKey] UTF8String];
    }
    
    if ([self.mqttManagerDataSource respondsToSelector:@selector(deviceSecret)]) {
        deviceSecret = [[self.mqttManagerDataSource deviceSecret] UTF8String];
    }
    
    if ([self.mqttManagerDataSource respondsToSelector:@selector(deviceName)]) {
        deviceName = [[self.mqttManagerDataSource deviceName] UTF8String];
    }
    
    char clientId[150] = {0};
    char username[64] = {0};
    char password[65] = {0};
    //根据cer文件加载
    NSArray *certificates = [self cerArray:YES];
    
    aiotMqttSign(productKey, deviceName, deviceSecret, clientId, username, password);
    
    NSString *clientIdString = [NSString stringWithCString:clientId encoding:NSUTF8StringEncoding];
    NSString *usernameString = [NSString stringWithCString:username encoding:NSUTF8StringEncoding];
    NSString *passwordString = [NSString stringWithCString:password encoding:NSUTF8StringEncoding];
    
    NSUInteger mqttPort = 8883;
    BOOL useTLS = YES;
    NSInteger keepAlive = 60;
    BOOL cleanSession = YES;
    MQTTQosLevel willQos = MQTTQosLevelAtLeastOnce;
    MQTTProtocolVersion protocolVersion = MQTTProtocolVersion311;

    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = YES;
    securityPolicy.pinnedCertificates = certificates;

    [self.mqttSessionManager connectTo:mqttHost
                                  port:mqttPort
                                   tls:useTLS
                             keepalive:keepAlive
                                 clean:cleanSession
                                  auth:YES
                                  user:usernameString
                                  pass:passwordString
                                  will:NO   //是否启用遗嘱消息（MQTT 的 Last Will 和 Testament），`YES` 表示启用
                             willTopic:nil  //遗嘱消息的主题，只有在 `will` 设置为 `YES` 时有效
                               willMsg:nil  //遗嘱消息内容，只有在 `will` 设置为 `YES` 时有效
                               willQos:willQos    // 遗嘱消息的 QoS 级别（服务质量）。0 表示最多一次交付，1 表示至少一次交付，2 表示只交付一次
                        willRetainFlag:NO   // 遗嘱消息是否保留。`YES` 表示遗嘱消息会被代理保留，直到订阅者接收到该消息
                          withClientId:clientIdString
                        securityPolicy:securityPolicy
                          certificates:nil
                         protocolLevel:protocolVersion connectHandler:^(NSError *error) {
        
    }];
}


#pragma mark - MQTTSessionManagerDelegate delegate
//
///** gets called when a new message was received
//
// @param data the data received, might be zero length
// @param topic the topic the data was published to
// @param retained indicates if the data retransmitted from server storage
// */
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSLog(@"【current log】==handleMessage  onTopic====+%@",data);
}

/** gets called when a new message was received
 @param sessionManager the instance of MQTTSessionManager whose state changed
 @param data the data received, might be zero length
 @param topic the topic the data was published to
 @param retained indicates if the data retransmitted from server storage
 */
- (void)sessionManager:(MQTTSessionManager *)sessionManager
     didReceiveMessage:(NSData *)data
               onTopic:(NSString *)topic
              retained:(BOOL)retained {
    NSLog(@"【current log】didReceiveMessage:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if ([self.mqttManagerDelegate respondsToSelector:@selector(thing_handleMessage:onTopic:retained:)]) {
        [self.mqttManagerDelegate thing_handleMessage:data onTopic:topic retained:retained];
    }
}

/** gets called when a published message was actually delivered
 @param sessionManager the instance of MQTTSessionManager whose state changed
 @param msgID the Message Identifier of the delivered message
 @note this method is called after a publish with qos 1 or 2 only
 */
- (void)sessionManager:(MQTTSessionManager *)sessionManager didDeliverMessage:(UInt16)msgID {
    NSLog(@"【current log】 didDeliverMessage==== %d",msgID);
    self.sendedT = [[NSDate date] timeIntervalSince1970];
    NSLog(@"mtTimeDawei:SendedTime=========%.0f",self.sendedT);
    CGFloat tt = self.sendedT - self.sendT;
    NSLog(@"mtTimeDawei:cost=========%.0f",tt);
    
    if ([self.mqttManagerDelegate respondsToSelector:@selector(thing_sessionManager:didDeliverMessage:)]) {
        [self.mqttManagerDelegate thing_sessionManager:sessionManager didDeliverMessage:msgID];
    }
}

/** gets called when the connection status changes
 @param sessionManager the instance of MQTTSessionManager whose state changed
 @param newState the new connection state of the sessionManager. This will be identical to `sessionManager.state`.
 */
- (void)sessionManager:(MQTTSessionManager *)sessionManager didChangeState:(MQTTSessionManagerState)newState {
    NSLog(@"【current log】 connect state==== %d",newState);
    if (newState == MQTTSessionManagerStateConnected) {
        [self subScribTopic];
    }
    if ([self.mqttManagerDelegate respondsToSelector:@selector(thing_sessionManager:didChangeState:)]) {
        [self.mqttManagerDelegate thing_sessionManager:sessionManager didChangeState:newState];
    }
}


- (NSString *)_commonCer {
    NSString *cString = @"-----BEGIN CERTIFICATE-----\r\n" \
    "MIIFgTCCBGmgAwIBAgIQOXJEOvkit1HX02wQ3TE1lTANBgkqhkiG9w0BAQwFADB7\r\n" \
    "MQswCQYDVQQGEwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD\r\n" \
    "VQQHDAdTYWxmb3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UE\r\n" \
    "AwwYQUFBIENlcnRpZmljYXRlIFNlcnZpY2VzMB4XDTE5MDMxMjAwMDAwMFoXDTI4\r\n" \
    "MTIzMTIzNTk1OVowgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVyc2V5\r\n" \
    "MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBO\r\n" \
    "ZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRpb24gQXV0\r\n" \
    "aG9yaXR5MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAgBJlFzYOw9sI\r\n" \
    "s9CsVw127c0n00ytUINh4qogTQktZAnczomfzD2p7PbPwdzx07HWezcoEStH2jnG\r\n" \
    "vDoZtF+mvX2do2NCtnbyqTsrkfjib9DsFiCQCT7i6HTJGLSR1GJk23+jBvGIGGqQ\r\n" \
    "Ijy8/hPwhxR79uQfjtTkUcYRZ0YIUcuGFFQ/vDP+fmyc/xadGL1RjjWmp2bIcmfb\r\n" \
    "IWax1Jt4A8BQOujM8Ny8nkz+rwWWNR9XWrf/zvk9tyy29lTdyOcSOk2uTIq3XJq0\r\n" \
    "tyA9yn8iNK5+O2hmAUTnAU5GU5szYPeUvlM3kHND8zLDU+/bqv50TmnHa4xgk97E\r\n" \
    "xwzf4TKuzJM7UXiVZ4vuPVb+DNBpDxsP8yUmazNt925H+nND5X4OpWaxKXwyhGNV\r\n" \
    "icQNwZNUMBkTrNN9N6frXTpsNVzbQdcS2qlJC9/YgIoJk2KOtWbPJYjNhLixP6Q5\r\n" \
    "D9kCnusSTJV882sFqV4Wg8y4Z+LoE53MW4LTTLPtW//e5XOsIzstAL81VXQJSdhJ\r\n" \
    "WBp/kjbmUZIO8yZ9HE0XvMnsQybQv0FfQKlERPSZ51eHnlAfV1SoPv10Yy+xUGUJ\r\n" \
    "5lhCLkMaTLTwJUdZ+gQek9QmRkpQgbLevni3/GcV4clXhB4PY9bpYrrWX1Uu6lzG\r\n" \
    "KAgEJTm4Diup8kyXHAc/DVL17e8vgg8CAwEAAaOB8jCB7zAfBgNVHSMEGDAWgBSg\r\n" \
    "EQojPpbxB+zirynvgqV/0DCktDAdBgNVHQ4EFgQUU3m/WqorSs9UgOHYm8Cd8rID\r\n" \
    "ZsswDgYDVR0PAQH/BAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wEQYDVR0gBAowCDAG\r\n" \
    "BgRVHSAAMEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwuY29tb2RvY2EuY29t\r\n" \
    "L0FBQUNlcnRpZmljYXRlU2VydmljZXMuY3JsMDQGCCsGAQUFBwEBBCgwJjAkBggr\r\n" \
    "BgEFBQcwAYYYaHR0cDovL29jc3AuY29tb2RvY2EuY29tMA0GCSqGSIb3DQEBDAUA\r\n" \
    "A4IBAQAYh1HcdCE9nIrgJ7cz0C7M7PDmy14R3iJvm3WOnnL+5Nb+qh+cli3vA0p+\r\n" \
    "rvSNb3I8QzvAP+u431yqqcau8vzY7qN7Q/aGNnwU4M309z/+3ri0ivCRlv79Q2R+\r\n" \
    "/czSAaF9ffgZGclCKxO/WIu6pKJmBHaIkU4MiRTOok3JMrO66BQavHHxW/BBC5gA\r\n" \
    "CiIDEOUMsfnNkjcZ7Tvx5Dq2+UUTJnWvu6rvP3t3O9LEApE9GQDTF1w52z97GA1F\r\n" \
    "zZOFli9d31kWTz9RvdVFGD/tSo7oBmF0Ixa1DVBzJ0RHfxBdiSprhTEUxOipakyA\r\n" \
    "vGp4z7h/jnZymQyd/teRCBaho1+V\r\n" \
    "-----END CERTIFICATE-----\r\n";
    return cString;
}

- (NSString *)_tuysCer {
    NSString *certString = @"-----BEGIN CERTIFICATE-----\r\n" \
    "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\r\n" \
    "-----END CERTIFICATE-----\r\n";
    return certString;
}

- (NSArray *)cerArray:(BOOL)needData {
    NSString *certPath = [[NSBundle mainBundle] pathForResource:@"tuyarootca" ofType:@"pem"];
    if (!certPath) {
        NSLog(@"证书文件不存在");
        return nil;
    }
    
    NSError *error = nil;
    NSString *certString = [NSString stringWithContentsOfFile:certPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"读取证书文件失败: %@", error.localizedDescription);
        return @[];
    }

    NSString *cleanedCertString = [certString stringByReplacingOccurrencesOfString:@"-----BEGIN CERTIFICATE-----" withString:@""];
    cleanedCertString = [cleanedCertString stringByReplacingOccurrencesOfString:@"-----END CERTIFICATE-----" withString:@""];
    cleanedCertString = [cleanedCertString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    cleanedCertString = [cleanedCertString stringByReplacingOccurrencesOfString:@"\n" withString:@""];

    // 转换为 Base64 编码的 NSData
    NSData *certData1 = [[NSData alloc] initWithBase64EncodedString:cleanedCertString options:0];
    if (!certData1) {
        NSLog(@"证书数据无效");
        return @[];
    }
    
    if (needData) {
        return @[certData1];
    }

    // 创建证书对象
    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certData1);
    if (!certificate) {
        NSLog(@"无法创建证书对象，证书数据无效");
        return @[];
    }

    
    NSArray *certificates = @[ (__bridge id)certificate ];
    return certificates;
}

@end
