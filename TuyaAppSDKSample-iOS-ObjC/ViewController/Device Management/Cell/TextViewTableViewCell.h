//
//  TextViewTableViewCell.h
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Thing Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "DeviceStatusBehaveCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TextViewTableViewCell : DeviceStatusBehaveCell

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (strong, nonatomic) void(^buttonAction)(NSString *text);

@end

NS_ASSUME_NONNULL_END
