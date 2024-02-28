//
//  TuyaLockDeviceMemberDetailView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceMemberDetailView.h"
#import <Masonry/Masonry.h>
#import <ThingEncryptImage/UIImageView+ThingAESImage.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "ThingSmartBLELockOpMessageModel.h"

#define kImageIconViewWidth 80

@interface TuyaLockDeviceMemberDetailView()

@property (nonatomic, strong) TuyaLockDeviceMemberDetailHeaderView *headerView;
@property (nonatomic, strong) TuyaLockDeviceMemberDetailItemView *fingerView;
@property (nonatomic, strong) TuyaLockDeviceMemberDetailItemView *pwdView;
@property (nonatomic, strong) TuyaLockDeviceMemberDetailItemView *cardView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIView *lineView;

@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSDictionary *dataSource;

@end

@implementation TuyaLockDeviceMemberDetailView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    
    self.headerView = [[TuyaLockDeviceMemberDetailHeaderView alloc] init];
    self.fingerView = [[TuyaLockDeviceMemberDetailItemView alloc] init];
    self.fingerView.delegate = self;
    self.fingerView.unlockMode = ThingUnlockOpTypeFinger;
    self.pwdView = [[TuyaLockDeviceMemberDetailItemView alloc] init];
    self.pwdView.delegate = self;
    self.pwdView.unlockMode = ThingUnlockOpTypePassword;
    self.cardView = [[TuyaLockDeviceMemberDetailItemView alloc] init];
    self.cardView.delegate = self;
    self.cardView.unlockMode = ThingUnlockOpTypeCard;
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.countLabel.textColor = [UIColor blueColor];
    self.countLabel.font = [UIFont systemFontOfSize:16];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.fingerView.addBtn setTitle:@"添加指纹" forState:UIControlStateNormal];
    [self.pwdView.addBtn setTitle:@"添加密码" forState:UIControlStateNormal];
    [self.cardView.addBtn setTitle:@"添加卡片" forState:UIControlStateNormal];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentRight;
    self.titleLabel.text = @"失效时间";
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.textColor = [UIColor blueColor];
    self.timeLabel.font = [UIFont systemFontOfSize:16];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:239.f/255.f alpha:1];
    
    [self addSubview:self.headerView];
    [self addSubview:self.fingerView];
    [self addSubview:self.pwdView];
    [self addSubview:self.cardView];
    [self addSubview:self.countLabel];
    [self addSubview:self.titleLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.lineView];
    
    WEAKSELF_ThingSDK
    [self.titleLabel bk_whenTapped:^{
        [weakSelf_ThingSDK gotoUpdateVC];
    }];
    
    [self.timeLabel bk_whenTapped:^{
        [weakSelf_ThingSDK gotoUpdateVC];
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(300);
    }];
    
    [self.fingerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.headerView.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    
    [self.pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.fingerView.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.pwdView.mas_bottom);
        make.height.mas_equalTo(60);
    }];
    
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.cardView.mas_bottom);
        make.height.mas_equalTo(30);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countLabel.mas_bottom).with.offset(20);
        make.left.equalTo(self).with.offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.countLabel.mas_bottom).with.offset(20);
        make.right.equalTo(self).with.offset(-20);
        make.left.equalTo(self.titleLabel.mas_right);
        make.height.mas_equalTo(30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd"];
}

- (void)reloadData:(NSDictionary *)data{
    self.dataSource = data;
    [self.headerView reloadData:data];
    
    NSDictionary *timeScheduleInfo = data[@"timeScheduleInfo"];
    BOOL permanent = [timeScheduleInfo[@"permanent"] boolValue];
    
    self.titleLabel.userInteractionEnabled = YES;
    self.timeLabel.userInteractionEnabled = YES;
    if (permanent){
        self.timeLabel.text = @"永久";
//        self.titleLabel.userInteractionEnabled = NO;
//        self.timeLabel.userInteractionEnabled = NO;
    }
    else{
        NSInteger effectiveTime = [timeScheduleInfo[@"effectiveTime"] integerValue];
        NSInteger expiredTime = [timeScheduleInfo[@"expiredTime"] integerValue];
        
        NSDate *effectiveData = [NSDate dateWithTimeIntervalSince1970:effectiveTime];
        NSString *effectiveStr = [self.formatter stringFromDate:effectiveData];
        
        NSDate *invalidData = [NSDate dateWithTimeIntervalSince1970:expiredTime];
        NSString *invalidStr = [self.formatter stringFromDate:invalidData];
        
        self.timeLabel.text = [NSString stringWithFormat:@"%@-%@ >",effectiveStr,invalidStr];
    }
}

- (void)reloadMsgCount:(int)msgCount cardCount:(int)cardCount fingerCount:(int)fingerCount{
    NSString *value = [NSString stringWithFormat:@"%@%d %@%d %@%d ",@"密码:",msgCount,@"卡片:",cardCount,@"指纹:",fingerCount];
    self.countLabel.text = value;
}

- (void)gotoUpdateVC{
    if (self.delegate && [self.delegate respondsToSelector:@selector(gotoUpdateVC:)]){
        [self.delegate gotoUpdateVC:self.dataSource];
    }
}

#pragma mark - TuyaLockDeviceMemberDetailItemViewDelete

- (void)addBtnClicked:(int)type{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addUnlockMode:)]){
        [self.delegate addUnlockMode:type];
    }
}

@end


@interface TuyaLockDeviceMemberDetailHeaderView()

@property (nonatomic, strong) UIImageView *imageIconView;//头像
@property (nonatomic, strong) UILabel *nameLabel;//名字
@property (nonatomic, strong) UILabel *phoneLabel;//电话
@property (nonatomic, strong) UILabel *roleLabel;//角色

@end

@implementation TuyaLockDeviceMemberDetailHeaderView

- (instancetype)init{
    self = [super init];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.imageIconView = [[UIImageView alloc] init];
    self.imageIconView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageIconView.clipsToBounds = YES;
    self.imageIconView.layer.cornerRadius = kImageIconViewWidth / 2;
    self.imageIconView.layer.masksToBounds = YES;
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.nameLabel.textColor = [UIColor blueColor];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    
    self.phoneLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.phoneLabel.textColor = [UIColor blueColor];
    self.phoneLabel.font = [UIFont systemFontOfSize:16];
    self.phoneLabel.textAlignment = NSTextAlignmentCenter;
    
    self.roleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.roleLabel.textColor = [UIColor blueColor];
    self.roleLabel.font = [UIFont systemFontOfSize:16];
    self.roleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:self.imageIconView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.phoneLabel];
    [self addSubview:self.roleLabel];
    
    [self.imageIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(100);
        make.centerX.equalTo(self.mas_centerX);
        make.width.height.mas_equalTo(kImageIconViewWidth);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.imageIconView.mas_bottom).with.offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(15);
    }];
    
    [self.phoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(15);
    }];
    
    [self.roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.phoneLabel.mas_bottom).with.offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(15);
    }];
}

- (void)reloadData:(NSDictionary *)data{
    NSString *nickName = data[@"nickName"];
    NSString *userContact = data[@"userContact"];
    NSString *avatarUrl = data[@"avatarUrl"];
    int userType = [data[@"userType"] intValue];
    
    [self.imageIconView thing_setImageWithURL:[NSURL URLWithString:avatarUrl]];
    self.nameLabel.text = nickName;
    self.phoneLabel.text = userContact;
    self.roleLabel.text = [NSString stringWithFormat:@"%@%d",@"身份类型：",userType];
}

@end

@interface TuyaLockDeviceMemberDetailItemView()


@end

@implementation TuyaLockDeviceMemberDetailItemView

- (instancetype)init{
    self = [super init];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{

    self.addBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.addBtn.backgroundColor = [UIColor blueColor];
    [self.addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.addBtn];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.mas_equalTo(100);
        make.top.equalTo(self).with.offset(15);
        make.bottom.equalTo(self).with.offset(-15);
    }];
}

- (void)addBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addBtnClicked:)]){
        [self.delegate addBtnClicked:self.unlockMode];
    }
}

@end
