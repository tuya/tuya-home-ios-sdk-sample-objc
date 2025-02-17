//
//  aiot_mqtt_sign.h
//  ThingSmartCameraLiteDemo
//
//  Created by MokZF on 2025/1/3.
//  Copyright. All rights reserved.
//

#ifndef aiot_mqtt_sign_h
#define aiot_mqtt_sign_h

int aiotMqttSign(const char *productKey, const char *deviceName, const char *deviceSecret,
                 char clientId[150], char username[64], char password[65]);

#endif /* aiot_mqtt_sign_h */
