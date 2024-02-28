//
//  TuyaZigbeeDeviceOncePasswordView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaZigbeeDeviceOncePasswordView.h"
#import <Masonry/Masonry.h>

@interface TuyaZigbeeDeviceOncePasswordView()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *createBtn;

@end

@implementation TuyaZigbeeDeviceOncePasswordView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"输入密码名称";
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nameTextField.font = [UIFont systemFontOfSize:16];
    self.nameTextField.textAlignment = NSTextAlignmentLeft;
    self.nameTextField.textColor = [UIColor blackColor];
    self.nameTextField.backgroundColor = [UIColor greenColor];
    self.nameTextField.delegate = self;
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipsLabel.textColor = [UIColor blueColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.text = @"有效期为24小时，失效前仅能使用一次";
    
    self.createBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.createBtn.backgroundColor = [UIColor redColor];
    [self.createBtn setTitle:@"获取密码" forState:UIControlStateNormal];
    [self.createBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.createBtn addTarget:self action:@selector(createBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.nameTextField];
    [self addSubview:self.tipsLabel];
    [self addSubview:self.createBtn];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(120);
        make.height.mas_equalTo(20);
        make.left.right.equalTo(self);
    }];
    
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(20);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(200);
        make.centerX.equalTo(self);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameTextField.mas_bottom).with.offset(20);
        make.height.mas_equalTo(20);
        make.left.right.equalTo(self);
    }];
    
    [self.createBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsLabel.mas_bottom).with.offset(20);
        make.height.mas_equalTo(40);
        make.width.mas_equalTo(150);
        make.centerX.equalTo(self);
    }];
}

- (void)createBtnClicked{
    NSString *name = self.nameTextField.text;
    if (self.delegate && [self.delegate respondsToSelector:@selector(createOncePwd:)]){
        [self.delegate createOncePwd:(name.length>0?name:@"一次性密码")];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.nameTextField resignFirstResponder];
    return YES;
}

@end

