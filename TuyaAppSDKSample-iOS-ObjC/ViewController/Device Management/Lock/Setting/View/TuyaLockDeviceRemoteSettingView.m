//
//  TuyaLockDeviceRemoteSettingView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceRemoteSettingView.h"
#import <Masonry/Masonry.h>

@interface TuyaLockDeviceRemoteSettingView()

@property (nonatomic, strong) UILabel *remoteLabel;
@property (nonatomic, strong) UISwitch *remoteSwitch;
@property (nonatomic, strong) UILabel *voiceLabel;
@property (nonatomic, strong) UISwitch *voiceSwitch;

@end


@implementation TuyaLockDeviceRemoteSettingView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:245.f/255.f alpha:1];
    
    self.remoteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.remoteLabel.textColor = [UIColor blueColor];
    self.remoteLabel.font = [UIFont systemFontOfSize:16];
    self.remoteLabel.textAlignment = NSTextAlignmentLeft;
    self.remoteLabel.text = @"远程解锁";
    
    self.voiceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.voiceLabel.textColor = [UIColor blueColor];
    self.voiceLabel.font = [UIFont systemFontOfSize:16];
    self.voiceLabel.textAlignment = NSTextAlignmentLeft;
    self.voiceLabel.text = @"远程语音解锁";
    
    self.remoteSwitch = [[UISwitch alloc] init];
    [self.remoteSwitch addTarget:self action:@selector(remoteSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.voiceSwitch = [[UISwitch alloc] init];
    [self.voiceSwitch addTarget:self action:@selector(voiceSwitchAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.remoteLabel];
    [self addSubview:self.voiceLabel];
    [self addSubview:self.remoteSwitch];
    [self addSubview:self.voiceSwitch];
    
    [self.remoteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.top.equalTo(self).with.offset(150);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    [self.remoteSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self).with.offset(150);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
    
    [self.voiceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.top.equalTo(self.remoteLabel.mas_bottom).with.offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
    }];
    
    [self.voiceSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.equalTo(self.remoteLabel.mas_bottom).with.offset(20);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(40);
    }];
}

- (void)setRemoteValue:(BOOL)value{
    [self.remoteSwitch setOn:value];
    [self setupType:value];
}

- (void)setVoiceValue:(BOOL)value{
    [self.voiceSwitch setOn:value];
}

- (void)setupType:(BOOL)type{
    if (type){
        self.voiceLabel.hidden = NO;
        self.voiceSwitch.hidden = NO;
    }else{
        self.voiceLabel.hidden = YES;
        self.voiceSwitch.hidden = YES;
    }
}

- (void)setRemoteHidden:(BOOL)hidden{
    self.remoteSwitch.hidden = hidden;
    self.remoteLabel.hidden = hidden;
}

- (void)setVoiceHidden:(BOOL)hidden{
    self.voiceLabel.hidden = hidden;
    self.voiceSwitch.hidden = hidden;
}

#pragma mark - action

- (void)remoteSwitchAction:(UISwitch *)sw{
    if (self.delegate && [self.delegate respondsToSelector:@selector(remoteSwitchAction:)]){
        [self.delegate remoteSwitchAction:sw.isOn];
    }
    
    [self setupType:sw.isOn];
}

- (void)voiceSwitchAction:(UISwitch *)sw{
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceSwitchAction:)]){
        [self.delegate voiceSwitchAction:sw.isOn];
    }
}

@end
