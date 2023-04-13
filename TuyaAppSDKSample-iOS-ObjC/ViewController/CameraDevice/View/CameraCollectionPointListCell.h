//
//  CameraCollectionPointListCell.h
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CameraCollectionPointListCell : UITableViewCell
@property (nonatomic, strong) ThingCameraCollectionPointModel *model;
@property (nonatomic, copy) void (^didClickRenameButton)(ThingCameraCollectionPointModel *model);
@property (nonatomic, copy) void (^didClickRemoveButton)(ThingCameraCollectionPointModel *model);
@end

NS_ASSUME_NONNULL_END
