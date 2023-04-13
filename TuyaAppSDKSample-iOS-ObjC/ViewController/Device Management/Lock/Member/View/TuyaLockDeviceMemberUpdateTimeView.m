//
//  TuyaLockDeviceMemberUpdateTimeView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceMemberUpdateTimeView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"
#import "TuyaLockDeviceCycleView.h"

#define kMemberUpdateTimeItemViewHeight  50

@interface TuyaLockDeviceMemberUpdateTimeView()

@property (nonatomic, strong) TuyaLockDeviceMemberUpdateTimeItemView *longView;//永久
@property (nonatomic, strong) TuyaLockDeviceMemberUpdateTimeItemView *customView;//自定义
@property (nonatomic, strong) TuyaLockDeviceMemberUpdateTimeItemView *effectiveView;//生效时间
@property (nonatomic, strong) TuyaLockDeviceMemberUpdateTimeItemView *invalidView;//失效时间

@property (nonatomic, strong) TuyaLockDeviceCycleView *cycleView;//周期设置
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, assign) BOOL isLong;//失效时间是否是「永久」
@property (nonatomic, strong) UIButton *saveBtn;

@end

@implementation TuyaLockDeviceMemberUpdateTimeView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:245.f/255.f alpha:1];
    
    self.longView = [[TuyaLockDeviceMemberUpdateTimeItemView alloc] init];
    self.longView.selectBtn.hidden = NO;
    self.longView.titleLabel.text = @"永久";
    self.longView.lineView.hidden = YES;
    self.longView.delegate = self;
    
    self.customView = [[TuyaLockDeviceMemberUpdateTimeItemView alloc] init];
    self.customView.selectBtn.hidden = NO;
    self.customView.titleLabel.text = @"自定义";
    self.customView.delegate = self;
    
    self.effectiveView = [[TuyaLockDeviceMemberUpdateTimeItemView alloc] init];
    self.effectiveView.timeLabel.hidden = NO;
    self.effectiveView.titleLabel.text = @"生效时间";
    self.effectiveView.delegate = self;
    self.effectiveView.hidden = YES;
    
    self.invalidView = [[TuyaLockDeviceMemberUpdateTimeItemView alloc] init];
    self.invalidView.timeLabel.hidden = NO;
    self.invalidView.titleLabel.text = @"失效时间";
    self.invalidView.delegate = self;
    self.invalidView.hidden = YES;
    
    self.cycleView = [[TuyaLockDeviceCycleView alloc] init];
    self.cycleView.hidden = YES;
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.saveBtn.backgroundColor = [UIColor blueColor];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.longView];
    [self addSubview:self.customView];
    [self addSubview:self.effectiveView];
    [self addSubview:self.invalidView];
    [self addSubview:self.cycleView];
    [self addSubview:self.saveBtn];
    
    [self.longView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).with.offset(150);
        make.height.mas_equalTo(kMemberUpdateTimeItemViewHeight);
    }];
    
    [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.longView.mas_bottom).with.offset(30);
        make.height.mas_equalTo(kMemberUpdateTimeItemViewHeight);
    }];
    
    [self.effectiveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.customView.mas_bottom);
        make.height.mas_equalTo(kMemberUpdateTimeItemViewHeight);
    }];
    
    [self.invalidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.effectiveView.mas_bottom);
        make.height.mas_equalTo(kMemberUpdateTimeItemViewHeight);
    }];
        
    [self.cycleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.invalidView.mas_bottom).with.offset(30);
        make.height.mas_equalTo(220);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cycleView.mas_bottom).with.offset(10);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
    }];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)reloadData:(NSDictionary *)data{
    NSDictionary *timeScheduleInfo = data[@"timeScheduleInfo"];
    BOOL permanent = [timeScheduleInfo[@"permanent"] boolValue];
    if (permanent){
        self.isLong = YES;
    }
    else{
        self.isLong = NO;
        
        NSInteger effectiveTime = [timeScheduleInfo[@"effectiveTime"] integerValue];
        NSInteger expiredTime = [timeScheduleInfo[@"expiredTime"] integerValue];
        
        NSDate *effectiveData = [NSDate dateWithTimeIntervalSince1970:effectiveTime];
        NSString *effectiveStr = [self.formatter stringFromDate:effectiveData];
        self.effectiveView.timeLabel.text = effectiveStr;
        
        NSDate *invalidData = [NSDate dateWithTimeIntervalSince1970:expiredTime];
        NSString *invalidStr = [self.formatter stringFromDate:invalidData];
        self.invalidView.timeLabel.text = invalidStr;
        
        [self.cycleView reloadData:timeScheduleInfo];
    }
}

- (void)saveBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(saveMemberTimeInfo)]){
        [self.delegate saveMemberTimeInfo];
    }
}

- (NSDate *)getEffectiveData{
    NSDate *effectiveData = [self.formatter dateFromString:self.effectiveView.timeLabel.text];
    return effectiveData;
}

- (NSDate *)getInvalidData{
    NSDate *invalidData = [self.formatter dateFromString:self.invalidView.timeLabel.text];
    return invalidData;
}

- (ThingSmartBLELockTimeScheduleInfo *)getScheduleInfo{
    ThingSmartBLELockTimeScheduleInfo *scheduleInfo = [[ThingSmartBLELockTimeScheduleInfo alloc] init];
    ThingSmartBLELockScheduleList *model = [self.cycleView getScheduleListModel];
    scheduleInfo.scheduleDetails = model.scheduleList;
    scheduleInfo.permanent = self.longView.swBtn.isOn;
    scheduleInfo.effectiveTime = [self getEffectiveData].timeIntervalSince1970;
    scheduleInfo.expiredTime = [self getInvalidData].timeIntervalSince1970;
    
    return scheduleInfo;
}

#pragma mark - TuyaLockDeviceMemberUpdateTimeItemViewDelegate

- (void)selectBtnClicked:(UIButton *)btn{
    if (btn == self.longView.selectBtn){
        if (!self.isLong){
            self.isLong = !self.isLong;
        }
    }
    else if (btn == self.customView.selectBtn){
        if (self.isLong){
            self.isLong = !self.isLong;
        }
    }
}

- (void)setIsLong:(BOOL)isLong{
    _isLong = isLong;
    if (_isLong){
        self.longView.selectBtn.backgroundColor = [UIColor greenColor];
        self.customView.selectBtn.backgroundColor = [UIColor whiteColor];
        self.effectiveView.hidden = YES;
        self.invalidView.hidden = YES;
        self.cycleView.hidden = YES;
    }
    else{
        self.longView.selectBtn.backgroundColor = [UIColor whiteColor];
        self.customView.selectBtn.backgroundColor = [UIColor greenColor];
        self.effectiveView.hidden = NO;
        self.invalidView.hidden = NO;
        self.cycleView.hidden = NO;
    }
}

- (void)swBtnClicked:(UISwitch *)sw{
    
}

@end

#define kSelectBtnHeight 18

@interface TuyaLockDeviceMemberUpdateTimeItemView()

@end

@implementation TuyaLockDeviceMemberUpdateTimeItemView

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
    
    self.selectBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.selectBtn.backgroundColor = [UIColor greenColor];
    [self.selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectBtn addTarget:self action:@selector(selectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.selectBtn.hidden = YES;
    self.selectBtn.layer.cornerRadius = kSelectBtnHeight/2;
    self.selectBtn.layer.masksToBounds = YES;
    self.selectBtn.layer.borderColor = [UIColor blackColor].CGColor;
    self.selectBtn.layer.borderWidth = 1;
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.textColor = [UIColor blueColor];
    self.timeLabel.font = [UIFont systemFontOfSize:16];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    self.timeLabel.hidden = YES;
    
    self.swBtn = [[UISwitch alloc] init];
    [self.swBtn addTarget:self action:@selector(swBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.swBtn.hidden = YES;
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:239.f/255.f alpha:1];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.selectBtn];
    [self addSubview:self.timeLabel];
    [self addSubview:self.swBtn];
    [self addSubview:self.lineView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(100);
    }];
    
    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-20);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(kSelectBtnHeight);
        make.height.mas_equalTo(kSelectBtnHeight);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-20);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(250);
    }];
    
    [self.swBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-20);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Action

- (void)selectBtnClicked:(UIButton *)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectBtnClicked:)]){
        [self.delegate selectBtnClicked:btn];
    }
}

- (void)swBtnClicked:(UISwitch *)sw{
    if (self.delegate && [self.delegate respondsToSelector:@selector(swBtnClicked:)]){
        [self.delegate swBtnClicked:sw];
    }
}

@end
