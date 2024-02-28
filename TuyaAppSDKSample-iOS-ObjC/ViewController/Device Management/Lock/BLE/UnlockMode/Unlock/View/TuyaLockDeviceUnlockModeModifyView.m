//
//  TuyaLockDeviceUnlockModeModifyView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnlockModeModifyView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

@interface TuyaLockDeviceUnlockModeModifyView()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *ajackLabel;

@end

@implementation TuyaLockDeviceUnlockModeModifyView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.nameTextField.font = [UIFont systemFontOfSize:16];
    self.nameTextField.textAlignment = NSTextAlignmentLeft;
    self.nameTextField.delegate = self;
    self.nameTextField.textColor = [UIColor blackColor];
    self.nameTextField.layer.borderWidth = 2;
    self.nameTextField.layer.borderColor = [UIColor grayColor].CGColor;
    
    self.ajackLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.ajackLabel.textColor = [UIColor grayColor];
    self.ajackLabel.font = [UIFont boldSystemFontOfSize:16];
    self.ajackLabel.textAlignment = NSTextAlignmentLeft;
    self.ajackLabel.text = @"劫持密码";
    
    self.swBtn = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.swBtn addTarget:self action:@selector(swBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.nameTextField];
    [self addSubview:self.ajackLabel];
    [self addSubview:self.swBtn];
    
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self).with.offset(150);
        make.height.mas_equalTo(60);
    }];
    
    [self.ajackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.top.equalTo(self.nameTextField.mas_bottom).with.offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    
    [self.swBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.nameTextField.mas_bottom).with.offset(20);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(20);
    }];
}

- (void)reloadData:(ThingSmartBLELockOpmodeModel *)model{
    self.nameTextField.text = model.unlockName;
    [self.swBtn setOn:model.unlockAttr];
}

- (void)reloadZigbeeData:(ThingSmartZigbeeLockOpmodeModel *)model{
    self.nameTextField.text = model.unlockName;
    [self.swBtn setOn:model.unlockAttr];
}

- (void)swBtnClick:(UISwitch *)sw{
    
}

@end
