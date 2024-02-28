//
//  TuyaLockDevice.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#ifndef TuyaLockDevice_h
#define TuyaLockDevice_h

typedef enum : NSInteger {
    PasswordType_OldOnlineOnce,//在线密码（老公版）：一次性密码
    PasswordType_OldOnlineCycle,//在线密码（老公版）：周期性密码
    PasswordType_OldOfflineOnce,//离线密码（老公版）：一次性密码
    PasswordType_OldOfflineTimes,//离线密码（老公版）：不限次数密码
    PasswordType_OldOfflineEmptyAll,//离线密码（老公版）：清空码(所有)
    PasswordType_OldOfflineEmptyOne,//离线密码（老公版）：清空码(单个)
    PasswordType_ProOnlineCycle,//在线密码（Pro）：自定义密码
    PasswordType_ProOfflineTimes,//离线密码（Pro）：限时
    PasswordType_ProOfflineOnce,//离线密码（Pro）：单次
    PasswordType_ProOfflineEmptyAll,//离线密码（Pro）：清空码（所有）
    PasswordType_ProOfflineEmptyOne,//离线密码（Pro）：清空码（单个）
    PasswordType_ZigbeeTempOne,//zigbee门锁临时一次性密码
    PasswordType_ZigbeeTempCycle,//zigbee门锁临时周期性密码
    PasswordType_WiFiTempCycle,//WiFi门锁临时密码
} PasswordType;

typedef enum : NSInteger {
    PasswordActionType_Add,//添加密码
    PasswordActionType_Modify,//修改密码
} PasswordActionType;

#endif /* TuyaLockDevice_h */
