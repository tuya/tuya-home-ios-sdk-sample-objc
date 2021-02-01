//
//  DeviceStatusBehaveCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceStatusBehaveCell.h"
#import "NotificationName.h"

@implementation DeviceStatusBehaveCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.controls = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOffline) name:kDeviceOffline object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOnline) name:kDeviceOnline object:nil];
}

- (void)deviceOffline {
    for (UIControl *control in self.controls) {
        [control setEnabled:NO];
    }
}

- (void)deviceOnline {
    for (UIControl *control in self.controls) {
        [control setEnabled:YES];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeviceOffline object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDeviceOnline object:nil];
}
@end
