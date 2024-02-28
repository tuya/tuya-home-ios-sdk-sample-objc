//
//  TuyaWiFiDeviceRecordFilterView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiDeviceRecordFilterView.h"
#import <Masonry/Masonry.h>

@implementation TuyaWiFiDeviceRecordFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor grayColor];
    
    self.alarmBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.alarmBtn.backgroundColor = [UIColor blueColor];
    [self.alarmBtn setTitle:@"告警列表" forState:UIControlStateNormal];
    [self.alarmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.alarmBtn addTarget:self action:@selector(alarmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.recordBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.recordBtn.backgroundColor = [UIColor grayColor];
    [self.recordBtn setTitle:@"开门记录" forState:UIControlStateNormal];
    [self.recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.recordBtn addTarget:self action:@selector(recordBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.hijackBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.hijackBtn.backgroundColor = [UIColor grayColor];
    [self.hijackBtn setTitle:@"劫持记录" forState:UIControlStateNormal];
    [self.hijackBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.hijackBtn addTarget:self action:@selector(hijackBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.alarmBtn];
    [self addSubview:self.recordBtn];
    [self addSubview:self.hijackBtn];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnWidth = (screenWidth / 3.0);
    [self.alarmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
    
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.alarmBtn.mas_right);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
    
    [self.hijackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
}

#pragma mark - action

- (void)alarmBtnClicked{
    self.alarmBtn.backgroundColor = [UIColor blueColor];
    self.recordBtn.backgroundColor = [UIColor grayColor];
    self.hijackBtn.backgroundColor = [UIColor grayColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alarmFilter)]){
        [self.delegate alarmFilter];
    }
}

- (void)recordBtnClicked{
    self.alarmBtn.backgroundColor = [UIColor grayColor];
    self.recordBtn.backgroundColor = [UIColor blueColor];
    self.hijackBtn.backgroundColor = [UIColor grayColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordFilter)]){
        [self.delegate recordFilter];
    }
}

- (void)hijackBtnClicked{
    self.alarmBtn.backgroundColor = [UIColor grayColor];
    self.recordBtn.backgroundColor = [UIColor grayColor];
    self.hijackBtn.backgroundColor = [UIColor blueColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(hijackFilter)]){
        [self.delegate hijackFilter];
    }
}

@end
