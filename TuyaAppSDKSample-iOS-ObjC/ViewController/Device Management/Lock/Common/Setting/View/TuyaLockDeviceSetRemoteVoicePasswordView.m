//
//  TuyaLockDeviceSetRemoteVoicePasswordView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceSetRemoteVoicePasswordView.h"
#import <Masonry/Masonry.h>
#import "Alert.h"

@interface TuyaLockDeviceSetRemoteVoicePasswordView()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UITextField *confirmPwdTextField;
@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, copy) NSString *password;

@end

@implementation TuyaLockDeviceSetRemoteVoicePasswordView

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
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.text = @"请输入 4~6 位数字密码";
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipsLabel.textColor = [UIColor blueColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.text = @"语音开门需验证此密码";
    
    self.pwdTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.pwdTextField.font = [UIFont systemFontOfSize:16];
    self.pwdTextField.textAlignment = NSTextAlignmentLeft;
    self.pwdTextField.delegate = self;
    self.pwdTextField.textColor = [UIColor greenColor];
    self.pwdTextField.placeholder = @"请输入";
    self.pwdTextField.layer.borderColor = [UIColor blackColor].CGColor;
    self.pwdTextField.layer.borderWidth = 1;
    
    self.confirmPwdTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.confirmPwdTextField.font = [UIFont systemFontOfSize:16];
    self.confirmPwdTextField.textAlignment = NSTextAlignmentLeft;
    self.confirmPwdTextField.delegate = self;
    self.confirmPwdTextField.textColor = [UIColor greenColor];
    self.confirmPwdTextField.placeholder = @"请再次输入";
    self.confirmPwdTextField.layer.borderColor = [UIColor blackColor].CGColor;
    self.confirmPwdTextField.layer.borderWidth = 1;
    
    self.confirmBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.confirmBtn.backgroundColor = [UIColor redColor];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.tipsLabel];
    [self addSubview:self.pwdTextField];
    [self addSubview:self.confirmPwdTextField];
    [self addSubview:self.confirmBtn];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self).with.offset(150);
        make.height.mas_equalTo(30);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(5);
        make.height.mas_equalTo(20);
    }];
    
    [self.pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.tipsLabel.mas_bottom).with.offset(5);
        make.height.mas_equalTo(30);
    }];
    
    [self.confirmPwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.pwdTextField.mas_bottom).with.offset(5);
        make.height.mas_equalTo(30);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.confirmPwdTextField.mas_bottom).with.offset(20);
        make.height.mas_equalTo(30);
    }];
}


- (void)confirmBtnClicked{
    if (![self.confirmPwdTextField.text isEqualToString:self.pwdTextField.text] || self.confirmPwdTextField.text.length == 0 || self.pwdTextField.text.length == 0){
        if (self.delegate && [self.delegate respondsToSelector:@selector(errorPwd)]){
            [self.delegate errorPwd];
        }
        
        return;
    }
    
    self.password = self.pwdTextField.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(confirmAction:)]){
        [self.delegate confirmAction:self.password];
    }
}

@end
