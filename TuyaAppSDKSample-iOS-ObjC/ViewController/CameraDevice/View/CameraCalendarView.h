//
//  CameraCalendarView.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>

@class CameraCalendarView;

@protocol CameraCalendarViewDelegate <NSObject>

/// change selected month
- (void)calendarView:(CameraCalendarView *)calendarView didSelectYear:(NSInteger)year month:(NSInteger)month;

/// select a day
- (void)calendarView:(CameraCalendarView *)calendarView didSelectYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day date:(NSDate *)date;

@end

@protocol CameraCalendarViewDataSource <NSObject>

- (BOOL)calendarView:(CameraCalendarView *)calendarView hasVideoOnYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end

@interface CameraCalendarView : UIView

- (void)show:(NSDate *)date;

- (void)hide;

- (void)reloadData;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, weak) id<CameraCalendarViewDelegate> delegate;

@property (nonatomic, weak) id<CameraCalendarViewDataSource> dataSource;

@end

