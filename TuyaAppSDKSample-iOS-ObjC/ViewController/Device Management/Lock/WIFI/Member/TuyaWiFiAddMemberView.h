//
//  TuyaWiFiAddMemberView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "ThingSmartLockMemberModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaWiFiAddMemberViewDelegate <NSObject>

- (void)addMemberAction:(ThingSmartLockMemberModel *)model;
- (void)updateMemberAction:(ThingSmartLockMemberModel *)model;
- (void)warningAlert;

@end

@interface TuyaWiFiAddMemberView : UIView

@property (nonatomic, assign) BOOL isEdit;//是否编辑
@property (nonatomic, weak) id<TuyaWiFiAddMemberViewDelegate> delegate;

- (void)reloadModel:(ThingSmartLockMemberModel *)model;

@end

NS_ASSUME_NONNULL_END
