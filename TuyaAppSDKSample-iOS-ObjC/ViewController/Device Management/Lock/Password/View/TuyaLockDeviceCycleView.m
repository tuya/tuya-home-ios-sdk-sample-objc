//
//  TuyaLockDeviceCycleView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceCycleView.h"
#import <Masonry/Masonry.h>
#import <ThingSmartLockKit/ThingSmartLockUtil.h>

@interface TuyaLockDeviceCycleView()

@property (nonatomic, strong) UIView *weekRepeatContainerView;

@property (nonatomic, strong) UILabel *weekRepeatLabel;//每周重复
@property (nonatomic, strong) UISwitch *switchBtn;//开关
@property (nonatomic, strong) TuyaLockDeviceInputView *startTimeView;//开始时间
@property (nonatomic, strong) TuyaLockDeviceInputView *endTimeView;//结束时间
@property (nonatomic, strong) TuyaLockDeviceWeekSelectView *weekSelectView;//星期选择

@end


@implementation TuyaLockDeviceCycleView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
//    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    self.titleLabel.textColor = [UIColor blackColor];
//    self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
//    self.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.titleLabel.text = @"周期密码设置";
    
    self.weekRepeatContainerView = [[UIView alloc] init];
    self.weekRepeatContainerView.backgroundColor = [UIColor whiteColor];
    
    self.weekRepeatLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.weekRepeatLabel.textColor = [UIColor blueColor];
    self.weekRepeatLabel.font = [UIFont systemFontOfSize:16];
    self.weekRepeatLabel.textAlignment = NSTextAlignmentLeft;
    self.weekRepeatLabel.text = @"每周重复";
    
    self.switchBtn = [[UISwitch alloc] init];
    [self.switchBtn addTarget:self action:@selector(switchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchBtn setOn:YES];
    
    self.startTimeView = [[TuyaLockDeviceInputView alloc] init];
    self.endTimeView = [[TuyaLockDeviceInputView alloc] init];
    self.weekSelectView = [[TuyaLockDeviceWeekSelectView alloc] init];
    
    [self.startTimeView reloadTitle:@"开始时间"];
    [self.endTimeView reloadTitle:@"结束时间"];
    
    [self.weekRepeatContainerView addSubview:self.weekRepeatLabel];
    [self.weekRepeatContainerView addSubview:self.switchBtn];
    
    [self addSubview:self.weekRepeatContainerView];
    [self addSubview:self.startTimeView];
    [self addSubview:self.endTimeView];
    [self addSubview:self.weekSelectView];
    
    [self.weekRepeatContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.weekRepeatLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.weekRepeatContainerView);
        make.height.mas_equalTo(viewHeight);
        make.width.mas_equalTo(100);
        make.left.equalTo(self.weekRepeatContainerView).with.offset(30);
    }];
    
    [self.switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.weekRepeatLabel.mas_centerY);
        make.right.equalTo(self.weekRepeatContainerView).with.offset(-20);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(30);
    }];
    
    [self.startTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.weekRepeatLabel.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.endTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.startTimeView.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.weekSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.endTimeView.mas_bottom).with.offset(20);
        make.height.mas_equalTo(viewHeight * 2);
    }];
    
    self.startTimeView.contentTextField.text = @"6";
    self.endTimeView.contentTextField.text = @"24";
}

- (void)reloadData:(NSDictionary *)data{
    NSArray *array = data[@"scheduleDetails"];
    NSDictionary *scheduleDetails = array.firstObject;
    
    BOOL allDay = [scheduleDetails[@"allDay"] boolValue];
    int scheduleEffectiveTime = [scheduleDetails[@"effectiveTime"] intValue];
    int scheduleInvalidTime = [scheduleDetails[@"invalidTime"] intValue];
    NSInteger workingDay = [scheduleDetails[@"workingDay"] integerValue];
    NSString *bin_workingDay = [ThingSmartLockUtil getBinaryByDecimal:workingDay];
    
    [self.switchBtn setOn:!allDay];
    if(allDay){
        [self switchBtnClicked:self.switchBtn];
        return;
    }
    
    [self.switchBtn setOn:YES];
    self.startTimeView.contentTextField.text = [NSString stringWithFormat:@"%d",scheduleEffectiveTime/60];
    self.endTimeView.contentTextField.text = [NSString stringWithFormat:@"%d",scheduleInvalidTime/60];
    [self.weekSelectView reloadData:bin_workingDay];
}

- (void)switchBtnClicked:(UISwitch *)sw{
    if (sw.isOn){
        self.startTimeView.hidden = NO;
        self.endTimeView.hidden = NO;
        self.weekSelectView.hidden = NO;
    }else{
        self.startTimeView.hidden = YES;
        self.endTimeView.hidden = YES;
        self.weekSelectView.hidden = YES;
    }
}

- (BOOL)getWeekRepeat{
    return self.switchBtn.isOn;
}

- (ThingSmartBLELockScheduleList *)getScheduleListModel{
    ThingSmartBLELockScheduleModel *scheduleModel = [[ThingSmartBLELockScheduleModel alloc] init];
    //16进制转成10进制
    NSInteger workingDay = strtoul([self.weekSelectView getScheduleModelWorkingDay].UTF8String, 0, 16);
    scheduleModel.workingDay = workingDay;
    
    scheduleModel.allDay = !self.switchBtn.isOn;
    
    int startTime = [self.startTimeView.contentTextField.text intValue];
    int endTime = [self.endTimeView.contentTextField.text intValue];
    scheduleModel.effectiveTime = 60 * startTime;
    scheduleModel.invalidTime = 60 * endTime;

    ThingSmartBLELockScheduleList *listModel = [[ThingSmartBLELockScheduleList alloc] init];
    [listModel.scheduleList addObject:scheduleModel];
    
    return listModel;
}

@end

@interface TuyaLockDevicePwdInfoView()

@property (nonatomic, strong) TuyaLockDeviceInputView *pwdValueInputView;
@property (nonatomic, strong) TuyaLockDeviceInputView *pwdNameInputView;
@property (nonatomic, strong) TuyaLockDeviceInputView *effectiveTimeView;//生效时间
@property (nonatomic, strong) TuyaLockDeviceInputView *invalidTimeView;//失效时间

@property (nonatomic, strong) NSDateFormatter *formatter;

@end


@implementation TuyaLockDevicePwdInfoView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.pwdValueInputView = [[TuyaLockDeviceInputView alloc] init];
    self.pwdNameInputView = [[TuyaLockDeviceInputView alloc] init];
    self.effectiveTimeView = [[TuyaLockDeviceInputView alloc] init];
    self.invalidTimeView = [[TuyaLockDeviceInputView alloc] init];
    [self.pwdValueInputView reloadTitle:@"密码内容（6-10位）"];
    [self.pwdNameInputView reloadTitle:@"密码名称"];
    [self.effectiveTimeView reloadTitle:@"生效时间"];
    [self.invalidTimeView reloadTitle:@"失效时间"];
    
    [self addSubview:self.pwdValueInputView];
    [self addSubview:self.pwdNameInputView];
    [self addSubview:self.effectiveTimeView];
    [self addSubview:self.invalidTimeView];
    
    [self.pwdValueInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.pwdNameInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.pwdValueInputView.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.effectiveTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.pwdNameInputView.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.invalidTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.effectiveTimeView.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    NSDate *date = [NSDate date];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [self.formatter stringFromDate:date];
    
    self.effectiveTimeView.contentTextField.text = dateStr;
    self.invalidTimeView.contentTextField.text = dateStr;
}

- (void)reloadPwdName:(NSString *)pwdName pwdValue:(NSString *)pwdValue effectiveTime:(NSInteger)effectiveTime invalidTime:(NSInteger)invalidTime{
    self.pwdNameInputView.contentTextField.text = pwdName;
    self.pwdValueInputView.contentTextField.text = pwdValue;
    
    NSDate *effectiveData = [NSDate dateWithTimeIntervalSince1970:effectiveTime];
    NSString *effectiveStr = [self.formatter stringFromDate:effectiveData];
    self.effectiveTimeView.contentTextField.text = effectiveStr;
    
    NSDate *invalidData = [NSDate dateWithTimeIntervalSince1970:invalidTime];
    NSString *invalidStr = [self.formatter stringFromDate:invalidData];
    self.invalidTimeView.contentTextField.text = invalidStr;
}

- (NSString *)getPwdValue{
    return self.pwdValueInputView.contentTextField.text;
}

- (NSString *)getPwdName{
    return self.pwdNameInputView.contentTextField.text;
}

- (NSInteger )getEffectiveTime{
    NSString *dateString = self.effectiveTimeView.contentTextField.text;
    NSDate *date = [self.formatter dateFromString:dateString];
    return [date timeIntervalSince1970];
}

- (NSInteger )getInvalidTime{
    NSString *dateString = self.invalidTimeView.contentTextField.text;
    NSDate *date = [self.formatter dateFromString:dateString];
    return [date timeIntervalSince1970];
}

@end


@interface TuyaLockDeviceOffinePwdView()

@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) TuyaLockDeviceInputView *pwdValueInputView;
@property (nonatomic, strong) TuyaLockDeviceInputView *pwdNameInputView;
@property (nonatomic, strong) TuyaLockDeviceInputView *effectiveTimeView;//生效时间
@property (nonatomic, strong) TuyaLockDeviceInputView *invalidTimeView;//失效时间
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) UIButton *getPwdBtn;//获取密码
@property (nonatomic, assign) PasswordType pwdType;
@property (nonatomic, strong) UIButton *modifyPwdNameBtn;//修改密码名称

@end


@implementation TuyaLockDeviceOffinePwdView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipsLabel.textColor = [UIColor blueColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:20];
    self.tipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel.text = @"有效期为6小时，失效前仅能使用一次";
    self.tipsLabel.hidden = YES;
    
    self.pwdValueInputView = [[TuyaLockDeviceInputView alloc] init];
    self.pwdValueInputView.hidden = YES;
    self.pwdValueInputView.canEdit = NO;
    self.pwdNameInputView = [[TuyaLockDeviceInputView alloc] init];
    self.pwdNameInputView.hidden = YES;
    self.effectiveTimeView = [[TuyaLockDeviceInputView alloc] init];
    self.invalidTimeView = [[TuyaLockDeviceInputView alloc] init];
    [self.pwdValueInputView reloadTitle:@"密码内容"];
    [self.pwdNameInputView reloadTitle:@"密码名称"];
    [self.effectiveTimeView reloadTitle:@"生效时间"];
    [self.invalidTimeView reloadTitle:@"失效时间"];
    
    self.getPwdBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.getPwdBtn.backgroundColor = [UIColor redColor];
    [self.getPwdBtn setTitle:@"获取密码" forState:UIControlStateNormal];
    [self.getPwdBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.getPwdBtn addTarget:self action:@selector(getPwdBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.modifyPwdNameBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.modifyPwdNameBtn.backgroundColor = [UIColor redColor];
    [self.modifyPwdNameBtn setTitle:@"修改密码名称" forState:UIControlStateNormal];
    [self.modifyPwdNameBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.modifyPwdNameBtn addTarget:self action:@selector(modifyPwdNameBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.modifyPwdNameBtn.hidden = YES;
    
    [self addSubview:self.tipsLabel];
    [self addSubview:self.getPwdBtn];
    [self addSubview:self.modifyPwdNameBtn];
    [self addSubview:self.pwdValueInputView];
    [self addSubview:self.pwdNameInputView];
    [self addSubview:self.effectiveTimeView];
    [self addSubview:self.invalidTimeView];
        
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.effectiveTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.invalidTimeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.effectiveTimeView.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
        
    [self.pwdValueInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.invalidTimeView.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.pwdNameInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.pwdValueInputView.mas_bottom);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.getPwdBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(viewHeight);
    }];
    
    [self.modifyPwdNameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.getPwdBtn.mas_top);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(viewHeight);
    }];
    
    NSDate *date = [NSDate date];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [self.formatter stringFromDate:date];
    
    self.effectiveTimeView.contentTextField.text = dateStr;
    self.invalidTimeView.contentTextField.text = dateStr;
}

- (void)getPwdBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(addOfflinePasswordActionWithEffectiveTime:invalidTime:)]){
        [self.delegate addOfflinePasswordActionWithEffectiveTime:[self getEffectiveTime] invalidTime:[self getInvalidTime]];
    }
}

- (void)modifyPwdNameBtnClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(modifyPwdName:)]){
        [self.delegate modifyPwdName:self.pwdNameInputView.contentTextField.text];
    }
}

- (void)reloadView:(PasswordType)type{
    if (type == PasswordType_OldOfflineOnce || type == PasswordType_OldOfflineEmptyAll
        || type == PasswordType_OldOfflineEmptyOne){
        self.effectiveTimeView.hidden = YES;
        self.invalidTimeView.hidden = YES;
    }
    else if (type == PasswordType_OldOfflineTimes){
        self.effectiveTimeView.hidden = NO;
        self.invalidTimeView.hidden = NO;
    }
    
    //离线单次密码，有效时间6小时
    if (type == PasswordType_OldOfflineOnce || type == PasswordType_ProOfflineOnce){
        self.effectiveTimeView.hidden = YES;
        self.invalidTimeView.hidden = YES;
        self.pwdValueInputView.hidden = YES;
        self.pwdNameInputView.hidden = YES;
        self.tipsLabel.hidden = NO;
    }
    
}

- (void)showPwdInfo:(NSDictionary *)dicValue{
    self.pwdValueInputView.hidden = NO;
    self.pwdNameInputView.hidden = NO;
    
    self.pwdNameInputView.contentTextField.text = [dicValue[@"pwdName"] stringValue];
    self.pwdValueInputView.contentTextField.text = [dicValue[@"pwd"] stringValue];
    
//    self.modifyPwdNameBtn.hidden = NO;
    self.getPwdBtn.hidden = YES;
}

- (NSInteger )getEffectiveTime{
    NSString *dateString = self.effectiveTimeView.contentTextField.text;
    NSDate *date = [self.formatter dateFromString:dateString];
    return [date timeIntervalSince1970];
}

- (NSInteger )getInvalidTime{
    NSString *dateString = self.invalidTimeView.contentTextField.text;
    NSDate *date = [self.formatter dateFromString:dateString];
    return [date timeIntervalSince1970];
}

@end
