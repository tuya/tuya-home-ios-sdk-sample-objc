//
//  Home.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "Home.h"

@implementation Home

+ (TuyaSmartHomeModel *)getCurrentHome {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:@"CurrentHome"]) {
        return nil;
    }
    long long homeId = [[defaults valueForKey:@"CurrentHome"] longLongValue];
    if (![TuyaSmartHome homeWithHomeId:homeId]) {
        return nil;
    }
    return [TuyaSmartHome homeWithHomeId:homeId].homeModel;
}

+ (void)setCurrentHome:(TuyaSmartHomeModel *)homeModel {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSString stringWithFormat:@"%lld", homeModel.homeId] forKey:@"CurrentHome"];
}

@end
