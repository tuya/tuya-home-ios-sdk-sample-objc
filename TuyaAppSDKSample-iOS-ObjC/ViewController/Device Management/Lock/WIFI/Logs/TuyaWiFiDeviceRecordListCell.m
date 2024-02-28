//
//  TuyaWiFiDeviceRecordListCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiDeviceRecordListCell.h"
#import <Masonry/Masonry.h>

@interface TuyaWiFiDeviceRecordListCell()

@property (nonatomic, strong) UIButton *bindBtn;

@end

@implementation TuyaWiFiDeviceRecordListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.bindBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.bindBtn.layer.borderColor = [UIColor blueColor].CGColor;
    self.bindBtn.layer.borderWidth = 1;
    self.bindBtn.backgroundColor = [UIColor whiteColor];
    self.bindBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.bindBtn.userInteractionEnabled = NO;
    [self.bindBtn setTitle:@"关联成员" forState:UIControlStateNormal];
    [self.bindBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.bindBtn];
    self.bindBtn.hidden = YES;
    
    [self.bindBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
        make.right.equalTo(self.contentView).with.offset(-20);
        make.centerY.equalTo(self.contentView);
    }];
}

- (void)makeBtnShow{
    self.bindBtn.hidden = NO;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    self.bindBtn.hidden = YES;
}

@end

