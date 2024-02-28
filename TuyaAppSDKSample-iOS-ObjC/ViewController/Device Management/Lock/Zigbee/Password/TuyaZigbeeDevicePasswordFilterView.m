//
//  TuyaZigbeeDevicePasswordFilterView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaZigbeeDevicePasswordFilterView.h"
#import <Masonry/Masonry.h>

@interface TuyaZigbeeDevicePasswordFilterView()

@end

@implementation TuyaZigbeeDevicePasswordFilterView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor grayColor];
    
    self.validBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.validBtn.backgroundColor = [UIColor blueColor];
    [self.validBtn setTitle:@"有效密码列表" forState:UIControlStateNormal];
    [self.validBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.validBtn addTarget:self action:@selector(validBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.invalidBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.invalidBtn.backgroundColor = [UIColor grayColor];
    [self.invalidBtn setTitle:@"无效密码列表" forState:UIControlStateNormal];
    [self.invalidBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.invalidBtn addTarget:self action:@selector(invalidBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.validBtn];
    [self addSubview:self.invalidBtn];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnWidth = (screenWidth / 2.0);
    [self.validBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
    
    [self.invalidBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(btnWidth);
    }];
}

#pragma mark - action

- (void)validBtnClicked{
    self.validBtn.backgroundColor = [UIColor blueColor];
    self.invalidBtn.backgroundColor = [UIColor grayColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(validFilter)]){
        [self.delegate validFilter];
    }
}

- (void)invalidBtnClicked{
    self.validBtn.backgroundColor = [UIColor grayColor];
    self.invalidBtn.backgroundColor = [UIColor blueColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(invalidFilter)]){
        [self.delegate invalidFilter];
    }
}

@end
