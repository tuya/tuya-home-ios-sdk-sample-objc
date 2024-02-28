//
//  TuyaLockDeviceBaseViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceBaseViewController.h"

@interface TuyaLockDeviceBaseViewController ()

@end

@implementation TuyaLockDeviceBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)isBLEDevice{
    if (self.devId.length == 0)
        return NO;
    
    if (_bleDevice)
        return YES;
    
    ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];
    if (device.deviceModel.deviceType == ThingSmartDeviceModelTypeBle){
        return YES;
    }
    
    return NO;
}

- (BOOL)isZigbeeDevice{
    if (self.devId.length == 0)
        return NO;
    
    if (_zigbeeDevice)
        return YES;
    
    ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];
    if (device.deviceModel.deviceType == ThingSmartDeviceModelTypeZigbeeSubDev){
        return YES;
    }
    
    return NO;
}

- (BOOL)isWiFiDevice{
    if (self.devId.length == 0)
        return NO;
    
    if (_wifiDevice)
        return YES;
    
    ThingSmartDevice *device = [ThingSmartDevice deviceWithDeviceId:self.devId];
    if (device.deviceModel.deviceType == ThingSmartDeviceModelTypeWifiDev){
        return YES;
    }
    
    return NO;
}

- (ThingSmartBLELockDevice *)bleDevice{
    if (!_bleDevice){
        _bleDevice = [ThingSmartBLELockDevice deviceWithDeviceId:self.devId];
        _bleDevice.delegate = self;
    }
    
    return _bleDevice;
}

- (ThingSmartZigbeeLockDevice *)zigbeeDevice{
    if (!_zigbeeDevice){
        _zigbeeDevice = [ThingSmartZigbeeLockDevice deviceWithDeviceId:self.devId];
        _zigbeeDevice.delegate = self;
    }
    
    return _zigbeeDevice;
}

- (ThingSmartLockDevice *)wifiDevice{
    if (!_wifiDevice){
        _wifiDevice = [ThingSmartLockDevice deviceWithDeviceId:self.devId];
        _wifiDevice.delegate = self;
    }
    
    return _wifiDevice;
}

- (NSString *)getDpIdWithDpCode:(NSString *)code{
    NSArray<ThingSmartSchemaModel *> *schemaArray = nil;
    if ([self isBLEDevice]){
        schemaArray = self.bleDevice.deviceModel.schemaArray;
    }
    else if ([self isZigbeeDevice]){
        schemaArray = self.zigbeeDevice.deviceModel.schemaArray;
    }
    
    for (ThingSmartSchemaModel *schema in schemaArray) {
        if ([schema.code isEqualToString:code]) {
            return schema.dpId;
        }
    }
    
    return nil;
}

@end
