//
//  CameraCruiseSelectView.h
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraCruiseSelectView : UIView
@property (nonatomic, strong) NSArray<NSString *> *dataSource;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL isShowTimeView;
@property (nonatomic, copy) void(^didClickConfirmBtn)(CameraCruiseSelectView *view, NSInteger index);
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@end

NS_ASSUME_NONNULL_END
