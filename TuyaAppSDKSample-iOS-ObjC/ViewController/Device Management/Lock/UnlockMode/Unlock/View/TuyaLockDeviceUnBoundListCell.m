//
//  TuyaLockDeviceUnBoundListCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceUnBoundListCell.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

@interface TuyaLockDeviceUnBoundListCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation TuyaLockDeviceUnBoundListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.textColor = [UIColor grayColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.nameLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(150);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-30);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(150);
    }];
}

- (void)reloadData:(NSDictionary *)model{
    int opmode = [model[@"opmode"] intValue];
    NSArray *unlockInfo = (NSArray *)model[@"unlockInfo"];
    NSDictionary *dicValue = unlockInfo.firstObject;
    NSString *unlockName = [dicValue[@"unlockName"] stringValue];
    self.nameLabel.text = unlockName;
    //指纹
    if (opmode == 12){
        self.titleLabel.text = @"指纹";
    }
    //密码
    else if (opmode == 13){
        self.titleLabel.text = @"密码";
    }
    //门卡
    else if (opmode == 15){
        self.titleLabel.text = @"门卡";
    }
}

@end
