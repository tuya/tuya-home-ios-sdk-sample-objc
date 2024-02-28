//
//  TuyaLockDeviceFingerResultView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeResultView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

@interface TuyaLockDeviceUnlockModeResultView()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UITextField *contentTextField;
@property (nonatomic, strong) UIButton *saveBtn;

@end

@implementation TuyaLockDeviceUnlockModeResultView


- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.resultLabel.textColor = [UIColor grayColor];
    self.resultLabel.font = [UIFont boldSystemFontOfSize:26];
    self.resultLabel.textAlignment = NSTextAlignmentLeft;
    self.resultLabel.text = @"";
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.text = @"指纹名称";
    
    self.contentTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.contentTextField.font = [UIFont systemFontOfSize:16];
    self.contentTextField.textAlignment = NSTextAlignmentLeft;
    self.contentTextField.delegate = self;
    self.contentTextField.textColor = [UIColor greenColor];
    self.contentTextField.placeholder = @"请输入";
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.saveBtn.backgroundColor = [UIColor blueColor];
    [self.saveBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.resultLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:self.saveBtn];
    
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.height.mas_equalTo(30);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(150);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.height.mas_equalTo(30);
        make.bottom.equalTo(self).with.offset(-60);
    }];
}

- (void)saveBtnClicked{
    
}

#pragma mark - UITextFieldDelegate



@end
