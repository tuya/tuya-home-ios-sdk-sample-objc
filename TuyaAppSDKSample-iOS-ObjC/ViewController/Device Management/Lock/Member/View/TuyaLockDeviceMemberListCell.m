//
//  TuyaLockDeviceMemberListCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceMemberListCell.h"
#import <Masonry/Masonry.h>
#import <ThingEncryptImage/UIImageView+ThingAESImage.h>

#define kImageIconViewWidth 30

@interface TuyaLockDeviceMemberListCell()

@property (nonatomic, strong) UIImageView *imageIconView;//头像
@property (nonatomic, strong) UILabel *nameLabel;//名字
@property (nonatomic, strong) UILabel *phoneLabel;//电话
@property (nonatomic, strong) UILabel *roleLabel;//角色
@property (nonatomic, strong) UIButton *updateBtn;//编辑
@property (nonatomic, strong) UIButton *deleteBtn;//删除

@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, strong) NSDictionary *dataSource;


@end

@implementation TuyaLockDeviceMemberListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.imageIconView = [[UIImageView alloc] init];
    self.imageIconView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageIconView.clipsToBounds = YES;
    self.imageIconView.layer.cornerRadius = kImageIconViewWidth / 2;
    self.imageIconView.layer.masksToBounds = YES;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.textColor = [UIColor grayColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    
    self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.phoneLabel.textColor = [UIColor blueColor];
    self.phoneLabel.font = [UIFont systemFontOfSize:16];
    self.phoneLabel.textAlignment = NSTextAlignmentLeft;
    
    self.roleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.roleLabel.textColor = [UIColor blueColor];
    self.roleLabel.font = [UIFont systemFontOfSize:16];
    self.roleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.deleteBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.deleteBtn.backgroundColor = [UIColor blueColor];
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.deleteBtn addTarget:self action:@selector(deleteBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.updateBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.updateBtn.backgroundColor = [UIColor blueColor];
    [self.updateBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.updateBtn addTarget:self action:@selector(updateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.imageIconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.phoneLabel];
//    [self addSubview:self.roleLabel];
    [self.contentView addSubview:self.deleteBtn];
    [self.contentView addSubview:self.updateBtn];
    
    [self.imageIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).with.offset(20);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.height.mas_equalTo(kImageIconViewWidth);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.imageIconView.mas_right).with.offset(10);
        make.top.equalTo(self.contentView).with.offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(15);
    }];
    
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel.mas_left);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(10);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(15);
    }];
        
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).with.offset(-10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    [self.updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.deleteBtn.mas_left).with.offset(-10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
}

- (void)reloadData:(NSDictionary *)data{
    self.dataSource = data;
    
    NSString *nickName = data[@"nickName"];
    NSString *userContact = data[@"userContact"];
    NSString *avatarUrl = data[@"avatarUrl"];
    int userType = [data[@"userType"] intValue];
    
    self.userId = data[@"userId"];
    
    [self.imageIconView thing_setImageWithURL:[NSURL URLWithString:avatarUrl]];
    self.nameLabel.text = nickName;
    self.phoneLabel.text = userContact;
    self.roleLabel.text = [NSString stringWithFormat:@"%@%d",@"身份类型：",userType];
}

- (void)deleteBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteMemberWithUserId:)]){
        [self.delegate deleteMemberWithUserId:self.dataSource];
    }
}

- (void)updateBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateMemberWithModel:)]){
        [self.delegate updateMemberWithModel:self.dataSource];
    }
}

@end
