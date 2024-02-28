//
//  TuyaLockDeviceRecordFilterView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceRecordFilterView.h"
#import <Masonry/Masonry.h>

@interface TuyaLockDeviceRecordFilterView()

@end

@implementation TuyaLockDeviceRecordFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
//    self.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:245.f/255.f alpha:1];
    self.backgroundColor = [UIColor grayColor];
    
    self.timeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.timeBtn.backgroundColor = [UIColor blueColor];
    [self.timeBtn setTitle:@"时间" forState:UIControlStateNormal];
    [self.timeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.timeBtn addTarget:self action:@selector(timeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.typeBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.typeBtn.backgroundColor = [UIColor blueColor];
    [self.typeBtn setTitle:@"类型" forState:UIControlStateNormal];
    [self.typeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.typeBtn addTarget:self action:@selector(typeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.memberBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.memberBtn.backgroundColor = [UIColor blueColor];
    [self.memberBtn setTitle:@"成员" forState:UIControlStateNormal];
    [self.memberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.memberBtn addTarget:self action:@selector(memberBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.timeBtn];
    [self addSubview:self.typeBtn];
    [self addSubview:self.memberBtn];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat margin = 25, btnWidth = ((screenWidth / 3.0) - 2*margin);
    [self.timeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(margin);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
    
    [self.typeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
    
    [self.memberBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-margin);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
}

#pragma mark - action

- (void)timeBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeFilter)]){
        [self.delegate timeFilter];
    }
}

- (void)typeBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(typeFilter)]){
        [self.delegate typeFilter];
    }
}

- (void)memberBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(memberFilter)]){
        [self.delegate memberFilter];
    }
}

@end
