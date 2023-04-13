//
//  TuyaLockDeviceFingerEntryView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeEntryView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

@interface TuyaLockDeviceUnlockModeEntryView()

@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation TuyaLockDeviceUnlockModeEntryView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    
    self.stepLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.stepLabel.textColor = [UIColor grayColor];
    self.stepLabel.font = [UIFont boldSystemFontOfSize:26];
    self.stepLabel.textAlignment = NSTextAlignmentLeft;
    self.stepLabel.text = @"";
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipsLabel.textColor = [UIColor grayColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:16];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.numberOfLines = 5;
    self.tipsLabel.text = @"将手指放在门锁指纹识别区域上再移开，重复此步骤";
    
    [self addSubview:self.stepLabel];
    [self addSubview:self.tipsLabel];
    
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.stepLabel.mas_bottom).with.offset(10);
        make.height.mas_equalTo(150);
    }];
}

- (void)reloadStep:(int)step total:(int)total{
    self.step = step;
    if (total != 0){
        self.total = total;
    }
    
    NSString *stepString = [NSString stringWithFormat:@"%d/%d",step,self.total];
    self.stepLabel.text = stepString;
}

@end


@interface TuyaLockDeviceUnlockModeEntryErrorView()

@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIButton *retyrBtn;

@end

@implementation TuyaLockDeviceUnlockModeEntryErrorView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    
    self.errorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.errorLabel.textColor = [UIColor grayColor];
    self.errorLabel.font = [UIFont boldSystemFontOfSize:26];
    self.errorLabel.textAlignment = NSTextAlignmentLeft;
    self.errorLabel.text = @"录入超时";
    
    self.retyrBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.retyrBtn.backgroundColor = [UIColor blueColor];
    [self.retyrBtn setTitle:@"请重试" forState:UIControlStateNormal];
    [self.retyrBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.retyrBtn addTarget:self action:@selector(retyrBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.errorLabel];
    [self addSubview:self.retyrBtn];
    
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self);
        make.top.equalTo(self).with.offset(150);
        make.height.mas_equalTo(30);
    }];
    
    [self.retyrBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.height.mas_equalTo(60);
        make.bottom.equalTo(self).with.offset(-60);
    }];
}

- (void)retyrBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(retryAction)]){
        [self.delegate retryAction];
    }
}

@end
