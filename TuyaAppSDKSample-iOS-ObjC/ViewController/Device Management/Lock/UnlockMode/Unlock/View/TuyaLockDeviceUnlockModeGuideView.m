//
//  TuyaLockDeviceFingerGuideView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeGuideView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

@interface TuyaLockDeviceUnlockModeGuideView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *startBtn;

@end

@implementation TuyaLockDeviceUnlockModeGuideView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:26];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipsLabel.textColor = [UIColor grayColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:16];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.numberOfLines = 5;
    
    self.startBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.startBtn.backgroundColor = [UIColor blueColor];
    [self.startBtn setTitle:@"开始采集" forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startBtn addTarget:self action:@selector(startBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.tipsLabel];
    [self addSubview:self.startBtn];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self);
        make.top.equalTo(self).with.offset(150);
        make.height.mas_equalTo(30);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.height.mas_equalTo(150);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.height.mas_equalTo(60);
        make.bottom.equalTo(self).with.offset(-60);
    }];
}

- (void)reloadTitle:(NSString *)title tipsStr:(NSString *)tipsStr{
    self.titleLabel.text = title;
    self.tipsLabel.text = tipsStr;
}

- (void)startBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(startToEntry)]){
        [self.delegate startToEntry];
    }
}

@end
