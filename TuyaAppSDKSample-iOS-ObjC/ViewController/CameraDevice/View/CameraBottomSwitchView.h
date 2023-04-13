//
//  CameraBottomSwitchView.h
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CameraBottomButtonType) {
    CameraBottomButtonTypeMain = 0,
    CameraBottomButtonTypePTZ,
    CameraBottomButtonTypeCP,
    CameraBottomButtonTypeCruise
};

@class CameraBottomSwitchView;
@protocol CameraBottomSwitchViewDelegate <NSObject>
- (void)didClickBottomButton:(CameraBottomSwitchView *_Nonnull)switchView buttonType:(CameraBottomButtonType)buttonType;
@end

NS_ASSUME_NONNULL_BEGIN

@interface CameraBottomSwitchView : UIView
@property (nonatomic, weak) id<CameraBottomSwitchViewDelegate> delegate;

- (void)selecteItem:(NSInteger)item;

@end

NS_ASSUME_NONNULL_END
