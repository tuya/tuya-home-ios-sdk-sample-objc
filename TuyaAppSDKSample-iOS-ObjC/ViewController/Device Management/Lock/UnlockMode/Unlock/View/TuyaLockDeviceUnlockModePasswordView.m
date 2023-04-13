//
//  TuyaLockDeviceUnlockModePasswordView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModePasswordView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

@interface TuyaLockDeviceUnlockModePasswordView()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *inputLabel;
@property (nonatomic, strong) UITextField *pwdTextField;
@property (nonatomic, strong) UIButton *generateBtn;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *ajackLabel;

@end

@implementation TuyaLockDeviceUnlockModePasswordView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipsLabel.textColor = [UIColor grayColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.text = @"请及时保存密码，App上不显示此密码";
    
    self.inputLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.inputLabel.textColor = [UIColor grayColor];
    self.inputLabel.font = [UIFont systemFontOfSize:16];
    self.inputLabel.textAlignment = NSTextAlignmentLeft;
    self.inputLabel.text = @"请输入6-10位密码";
    
    self.pwdTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.pwdTextField.font = [UIFont systemFontOfSize:16];
    self.pwdTextField.textAlignment = NSTextAlignmentLeft;
    self.pwdTextField.delegate = self;
    self.pwdTextField.textColor = [UIColor blackColor];
    self.pwdTextField.layer.borderWidth = 2;
    self.pwdTextField.layer.borderColor = [UIColor grayColor].CGColor;
    self.pwdTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    self.generateBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.generateBtn.backgroundColor = [UIColor blueColor];
    self.generateBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.generateBtn setTitle:@"随机生成" forState:UIControlStateNormal];
    [self.generateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.generateBtn addTarget:self action:@selector(generateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.textColor = [UIColor grayColor];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    self.nameLabel.text = @"密码名称";
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nameTextField.font = [UIFont systemFontOfSize:16];
    self.nameTextField.textAlignment = NSTextAlignmentLeft;
    self.nameTextField.delegate = self;
    self.nameTextField.textColor = [UIColor blackColor];
    self.nameTextField.placeholder = @"请输入";
    
    self.ajackLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.ajackLabel.textColor = [UIColor grayColor];
    self.ajackLabel.font = [UIFont boldSystemFontOfSize:16];
    self.ajackLabel.textAlignment = NSTextAlignmentLeft;
    self.ajackLabel.text = @"劫持密码";
    
    self.swBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.swBtn addTarget:self action:@selector(swBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.tipsLabel];
    [self addSubview:self.inputLabel];
    [self addSubview:self.pwdTextField];
    [self addSubview:self.generateBtn];
    [self addSubview:self.nameLabel];
    [self addSubview:self.nameTextField];
    [self addSubview:self.ajackLabel];
    [self addSubview:self.swBtn];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self);
        make.top.equalTo(self).with.offset(150);
        make.height.mas_equalTo(20);
    }];
    
    [self.inputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self);
        make.top.equalTo(self.tipsLabel.mas_bottom).with.offset(20);
        make.height.mas_equalTo(20);
    }];
    
    [self.pwdTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.inputLabel.mas_bottom).with.offset(10);
        make.height.mas_equalTo(40);
    }];
    
    [self.generateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.inputLabel.mas_bottom).with.offset(10);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(40);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.top.equalTo(self.pwdTextField.mas_bottom).with.offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.nameLabel);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self.ajackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self.swBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(20);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(20);
    }];
}

- (void)reloadData:(ThingSmartBLELockOpmodeModel *)model{
    self.pwdTextField.text = @"******";
    self.nameTextField.text = model.unlockName;
    [self.swBtn setOn:model.unlockAttr];
}

- (void)swBtnClick:(UISwitch *)sw{
    
}

- (void)generateBtnClicked{
    NSString *pwd = [self getRandom:6];
    self.pwdTextField.text = pwd;
    self.password = pwd;
}

//生成密码
- (NSString *)getRandom:(int)digits{
    NSString *password = @"";
    for (int i = 0; i < digits; i++) {
        NSString *value = [NSString stringWithFormat:@"%d",arc4random() % 10];
        password = [password stringByAppendingString:value];
    }
    
    return password;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField == self.pwdTextField){
        if ([textField.text containsString:@"*"]){
            textField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.pwdTextField){
        self.password = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.pwdTextField){
        if (string.length == 0){
            return YES;
        }
        
        if (textField.text.length > 10){
            return NO;
        }
        
        if ([@"1234567890" containsString:string]){
            return YES;
        }
    }
        
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField == self.pwdTextField){
        self.password = textField.text;
    }
    
    [self.pwdTextField resignFirstResponder];
    return YES;
}

@end
