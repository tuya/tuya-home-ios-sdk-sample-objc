//
//  HomeDetailTableViewController.h
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeDetailTableViewController : UITableViewController
@property(strong, nonatomic) ThingSmartHomeModel *homeModel;
@property(strong, nonatomic) ThingSmartHome *home;
@end

NS_ASSUME_NONNULL_END
