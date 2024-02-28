//
//  TuyaLockDeviceMemberDetailView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TuyaLockDeviceMemberDetailViewDelegate <NSObject>

- (void)addUnlockMode:(int)type;
- (void)gotoUpdateVC:(NSDictionary *)data;

@end

@protocol TuyaLockDeviceMemberDetailItemViewDelete <NSObject>

- (void)addBtnClicked:(int)type;

@end

@interface TuyaLockDeviceMemberDetailView : UIView<TuyaLockDeviceMemberDetailItemViewDelete>

@property (nonatomic, weak) id<TuyaLockDeviceMemberDetailViewDelegate> delegate;

- (void)reloadData:(NSDictionary *)data;

- (void)reloadMsgCount:(int)msgCount cardCount:(int)cardCount fingerCount:(int)fingerCount;

@end

@interface TuyaLockDeviceMemberDetailHeaderView : UIView

- (void)reloadData:(NSDictionary *)data;

@end

@interface TuyaLockDeviceMemberDetailItemView : UIView

@property (nonatomic, weak) id<TuyaLockDeviceMemberDetailItemViewDelete> delegate;
@property (nonatomic, assign) int unlockMode;
@property (nonatomic, strong) UIButton *addBtn;

@end

NS_ASSUME_NONNULL_END
