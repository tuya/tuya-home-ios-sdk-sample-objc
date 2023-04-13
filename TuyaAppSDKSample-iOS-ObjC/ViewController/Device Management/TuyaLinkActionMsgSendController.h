//
//  TuyaLinkActionMsgSendController.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TuyaLinkActionMsgSendController : UITableViewController
@property (nonatomic, strong) ThingSmartThingAction *action;
@property (nonatomic, copy) ThingSuccessDict callback;
@end

NS_ASSUME_NONNULL_END
