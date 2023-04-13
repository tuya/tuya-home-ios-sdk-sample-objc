//
//  CameraDeviceManager.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraDeviceManager.h"

@interface CameraDeviceManager ()

@property (nonatomic, strong) NSMapTable<NSString *, CameraDevice *> *cameraDevices;

@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end


@implementation CameraDeviceManager

+ (CameraDeviceManager *)sharedManager {
    static CameraDeviceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = self.new;
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cameraDevices = [NSMapTable strongToWeakObjectsMapTable];
        _semaphore = dispatch_semaphore_create(1);
    }
    return self;
}

- (CameraDevice *)getCameraDeviceWithDevId:(NSString *)devId {
    dispatch_semaphore_wait(_semaphore, dispatch_time(DISPATCH_TIME_NOW, 300.0f * NSEC_PER_SEC));
    CameraDevice *cameraDevice = [self.cameraDevices objectForKey:devId];
    if (!cameraDevice) {
        cameraDevice = [CameraDevice deviceWithDeviceId:devId];
        [self.cameraDevices setObject:cameraDevice forKey:devId];
    }
    dispatch_semaphore_signal(_semaphore);
    return cameraDevice;
}

@end
