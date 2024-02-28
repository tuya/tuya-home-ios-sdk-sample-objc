//
//  TuyaLockDeviceCycleView.h
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "TuyaLockDeviceInputView.h"
#import "TuyaLockDevice.h"

NS_ASSUME_NONNULL_BEGIN

#define viewHeight 40

//周期密码选择view
@interface TuyaLockDeviceCycleView : UIView

@property (nonatomic, assign) BOOL isZigbee;

- (ThingSmartBLELockScheduleList *)getScheduleListModel;

- (void)reloadData:(NSDictionary *)data;

@end

@interface TuyaLockDevicePwdInfoView : UIView

- (void)reloadPwdName:(NSString *)pwdName pwdValue:(NSString *)pwdValue effectiveTime:(NSInteger)effectiveTime invalidTime:(NSInteger)invalidTime;

- (BOOL)getWeekRepeat;
- (NSString *)getPwdValue;
- (NSString *)getPwdName;
- (NSInteger )getEffectiveTime;
- (NSInteger )getInvalidTime;
- (NSDate *)getEffectiveDate;
- (NSDate *)getInvalidDate;

@end

@protocol TuyaLockDeviceOffinePwdViewDelegate <NSObject>

- (void)addOfflinePasswordActionWithEffectiveTime:(NSInteger)effectiveTime invalidTime:(NSInteger)invalidTime;
- (void)modifyPwdName:(NSString *)pwdName;

@end

@interface TuyaLockDeviceOffinePwdView : UIView

@property (nonatomic,weak) id<TuyaLockDeviceOffinePwdViewDelegate> delegate;

- (void)reloadView:(PasswordType)type;
- (void)showPwdInfo:(NSDictionary *)dicValue;

@end


NS_ASSUME_NONNULL_END
