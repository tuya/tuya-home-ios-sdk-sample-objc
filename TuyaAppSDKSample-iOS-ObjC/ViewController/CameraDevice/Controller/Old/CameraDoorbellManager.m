//
//  CameraDoorbellManager.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraDoorbellManager.h"
#import "CameraDoorbellNewViewController.h"
#import <ThingSmartCameraKit/ThingSmartCameraKit.h>

#import "UIView+CameraAdditions.h"

static const NSInteger kDoorbellRingTimeoutMaxInterval = 30;

@interface CameraDoorbellManager ()<ThingSmartDoorBellObserver, ThingSmartDoorBellConfigDataSource>

@property (nonatomic, weak) UIAlertController *alertVc;

@property (nonatomic, copy) NSString *messageId;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber*> *timeoutIntervalMap;

@end


@implementation CameraDoorbellManager

+ (instancetype)sharedInstance {
    static CameraDoorbellManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [CameraDoorbellManager new];
        [_instance setupDoorBellMannager];
    });
    return _instance;;
}

- (void)setupDoorBellMannager {
    ThingSmartDoorBellManager *manager = [ThingSmartDoorBellManager sharedInstance];
    manager.ignoreWhenCalling = YES;
    manager.doorbellRingTimeOut = kDoorbellRingTimeoutMaxInterval;
}

- (void)addDoorbellObserver {
    [[ThingSmartDoorBellManager sharedInstance] addObserver:self];
}

- (void)removeDoorbellObserver {
    [[ThingSmartDoorBellManager sharedInstance] removeObserver:self];
}

- (void)hangupDoorBellCall {
    [[ThingSmartDoorBellManager sharedInstance] hangupDoorBellCall:self.messageId];
}


- (void)setDoorbellRingTimeoutInterval:(NSInteger)timeoutInterval ofDevId:(NSString *)devId {
    if (!devId) {
        return;
    }
    [self.timeoutIntervalMap setValue:@(timeoutInterval) forKeyPath:devId];
}

#pragma mark - ThingSmartDoorBellConfigDataSource

- (NSInteger)doorbellRingTimeOut:(NSInteger)defaultRingTimeOut withDevId:(NSString *)devId {
    NSNumber *intervalNumber = self.timeoutIntervalMap[devId];
    if (intervalNumber) {
        return kDoorbellRingTimeoutMaxInterval;
    }
    return intervalNumber.integerValue;
}

#pragma mark - ThingSmartDoorBellObserver

- (void)doorBellCall:(ThingSmartDoorBellCallModel *)callModel didReceivedFromDevice:(ThingSmartDeviceModel *)deviceModel {
    self.messageId = callModel.messageId;
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromTable(@"Dollbell is ringing", @"IPCLocalizable", @"") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Answer", @"IPCLocalizable", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        CameraDoorbellNewViewController *vc = [[CameraDoorbellNewViewController alloc] initWithDeviceId:deviceModel.devId];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        
        [[ThingSmartDoorBellManager sharedInstance] answerDoorBellCall:self.messageId];
        
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [tp_topMostViewController() presentViewController:nav animated:YES completion:nil];
        
    }];
    [alertVc addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"Hangup", @"IPCLocalizable", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [[ThingSmartDoorBellManager sharedInstance] hangupDoorBellCall:self.messageId];
        
    }];
    [alertVc addAction:action2];
    
    [tp_topMostViewController() presentViewController:alertVc animated:YES completion:nil];
    self.alertVc = alertVc;
}

- (void)doorBellCallDidRefuse:(ThingSmartDoorBellCallModel *)callModel {
    [self.alertVc dismissViewControllerAnimated:YES completion:^{
        [self showAlertWithMessage:@"doorBellCallDidRefuse"];
    }];
}

- (void)doorBellCallDidHangUp:(ThingSmartDoorBellCallModel *)callModel {
    [self.alertVc dismissViewControllerAnimated:YES completion:^{
        [self showAlertWithMessage:@"doorBellCallDidHangUp"];
    }];
}

- (void)doorBellCallDidAnsweredByOther:(ThingSmartDoorBellCallModel *)callModel {
    [self.alertVc dismissViewControllerAnimated:YES completion:^{
        [self showAlertWithMessage:@"doorBellCallDidAnsweredByOther"];
    }];
}

- (void)doorBellCallDidCanceled:(ThingSmartDoorBellCallModel *)callModel timeOut:(BOOL)isTimeOut {
    [self.alertVc dismissViewControllerAnimated:YES completion:^{
        if (isTimeOut) {
            [self showAlertWithMessage:NSLocalizedStringFromTable(@"Dollbell is ringing timeOut", @"IPCLocalizable", @"")];
        } else {
            [self showAlertWithMessage:NSLocalizedStringFromTable(@"The device has canceled doorbell ringing", @"IPCLocalizable", @"")];
        }
    }];
}

- (void)showAlertWithMessage:(NSString *)message {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVc addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ty_smart_scene_pop_know", @"IPCLocalizable", @"") style:UIAlertActionStyleCancel handler:nil]];
    [tp_topMostViewController() presentViewController:alertVc animated:YES completion:nil];
}


- (NSMutableDictionary<NSString *,NSNumber *> *)timeoutIntervalMap {
    if (!_timeoutIntervalMap) {
        _timeoutIntervalMap = [NSMutableDictionary dictionary];
    }
    return _timeoutIntervalMap;
}

@end

