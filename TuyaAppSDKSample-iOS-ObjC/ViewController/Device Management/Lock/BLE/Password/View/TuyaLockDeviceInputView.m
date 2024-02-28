//
//  TuyaLockDeviceInputView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceInputView.h"
#import <Masonry/Masonry.h>

@interface TuyaLockDeviceInputView()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation TuyaLockDeviceInputView

- (instancetype)init{
    self = [super init];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.canEdit = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.lineView.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:239.f/255.f alpha:1];
    
    self.contentTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.contentTextField.font = [UIFont systemFontOfSize:16];
    self.contentTextField.textAlignment = NSTextAlignmentLeft;
    self.contentTextField.delegate = self;
    self.contentTextField.textColor = [UIColor greenColor];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.lineView];
    [self addSubview:self.contentTextField];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.width.mas_equalTo(200);
        make.height.equalTo(self);
    }];
    
    [self.contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
        make.width.mas_equalTo(200);
        make.height.equalTo(self);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];
}

- (void)reloadTitle:(NSString *)title{
    self.titleLabel.text = title;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return self.canEdit;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.contentTextField.text = textField.text;
    [self.contentTextField resignFirstResponder];
    return YES;
}

@end

@interface TuyaLockDeviceWeekSelectView()

@property (nonatomic, strong) UIButton *mondayBtn;
@property (nonatomic, strong) UIButton *tuesdayBtn;
@property (nonatomic, strong) UIButton *wednesdayBtn;
@property (nonatomic, strong) UIButton *thursdayBtn;
@property (nonatomic, strong) UIButton *fridayBtn;
@property (nonatomic, strong) UIButton *saturdayBtn;
@property (nonatomic, strong) UIButton *sundayBtn;

@end

@implementation TuyaLockDeviceWeekSelectView

- (instancetype)init{
    self = [super init];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.mondayBtn = [self getWeekBtn:@"周一"];
    self.tuesdayBtn = [self getWeekBtn:@"周二"];
    self.wednesdayBtn = [self getWeekBtn:@"周三"];
    self.thursdayBtn = [self getWeekBtn:@"周四"];
    self.fridayBtn = [self getWeekBtn:@"周五"];
    self.saturdayBtn = [self getWeekBtn:@"周六"];
    self.sundayBtn = [self getWeekBtn:@"周日"];
    
    [self.mondayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.height.mas_equalTo(weekSelectWidth);
    }];
    
    [self.tuesdayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mondayBtn.mas_right);
        make.width.height.mas_equalTo(weekSelectWidth);
    }];
    
    [self.wednesdayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tuesdayBtn.mas_right);
        make.width.height.mas_equalTo(weekSelectWidth);
    }];
    
    [self.thursdayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.wednesdayBtn.mas_right);
        make.width.height.mas_equalTo(weekSelectWidth);
    }];
    
    [self.fridayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.thursdayBtn.mas_right);
        make.width.height.mas_equalTo(weekSelectWidth);
    }];
    
    [self.saturdayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.fridayBtn.mas_right);
        make.width.height.mas_equalTo(weekSelectWidth);
    }];
    
    [self.sundayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.saturdayBtn.mas_right);
        make.width.height.mas_equalTo(weekSelectWidth);
    }];
}

- (UIButton *)getWeekBtn:(NSString *)title{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    btn.layer.cornerRadius = weekSelectWidth/2;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor blackColor].CGColor;
    btn.backgroundColor = [UIColor whiteColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 0;
    [self addSubview:btn];
    
    return btn;
}

- (void)btnClicked:(UIButton *)btn{
    if (btn.tag == 0){
        btn.tag = 1;
        btn.backgroundColor = [UIColor blueColor];
    }
    else if (btn.tag == 1){
        btn.tag = 0;
        btn.backgroundColor = [UIColor whiteColor];
    }
}

- (void)btnReload:(int)value btn:(UIButton *)btn{
    btn.tag = value;
    if (value == 0){
        btn.backgroundColor = [UIColor whiteColor];
    }else if (value == 1){
        btn.backgroundColor = [UIColor blueColor];
    }
}

- (NSString *)getScheduleModelWorkingDay:(BOOL)isZigbee{
    ThingSmartBLELockScheduleModel *scheduleModel = [[ThingSmartBLELockScheduleModel alloc] init];
    NSMutableSet *dayOfWeeks = [[NSMutableSet alloc] initWithCapacity:3];
    if (self.mondayBtn.tag == 1)
    [dayOfWeeks addObject:@(ScheduleDayOfWeek_MONDAY)];
    if (self.tuesdayBtn.tag == 1)
    [dayOfWeeks addObject:@(ScheduleDayOfWeek_TUESDAY)];
    if (self.wednesdayBtn.tag == 1)
    [dayOfWeeks addObject:@(ScheduleDayOfWeek_WEDNESDAY)];
    if (self.thursdayBtn.tag == 1)
    [dayOfWeeks addObject:@(ScheduleDayOfWeek_THURSDAY)];
    if (self.fridayBtn.tag == 1)
    [dayOfWeeks addObject:@(ScheduleDayOfWeek_FRIDAY)];
    if (self.saturdayBtn.tag == 1)
    [dayOfWeeks addObject:@(ScheduleDayOfWeek_SATURDAY)];
    if (self.sundayBtn.tag == 1)
    [dayOfWeeks addObject:@(ScheduleDayOfWeek_SUNDAY)];
    
    NSString *workingDay = [scheduleModel convertWorkingDay:dayOfWeeks isZigbee:isZigbee];
    return workingDay;
}

- (void)reloadData:(NSString *)workingDay isZigbee:(BOOL)isZigbee{
    if (isZigbee){
        int sunValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:1]] intValue];
        int monValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:2]] intValue];
        int tueValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:3]] intValue];
        int wedValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:4]] intValue];
        int thuValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:5]] intValue];
        int friValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:6]] intValue];
        int satValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:7]] intValue];
        
        [self btnReload:satValue btn:_saturdayBtn];
        [self btnReload:friValue btn:_fridayBtn];
        [self btnReload:thuValue btn:_thursdayBtn];
        [self btnReload:wedValue btn:_wednesdayBtn];
        [self btnReload:tueValue btn:_tuesdayBtn];
        [self btnReload:monValue btn:_mondayBtn];
        [self btnReload:sunValue btn:_sundayBtn];
    }
    else{
        int satValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:1]] intValue];
        int friValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:2]] intValue];
        int thuValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:3]] intValue];
        int wedValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:4]] intValue];
        int tueValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:5]] intValue];
        int monValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:6]] intValue];
        int sunValue = [[NSString stringWithFormat:@"%c",[workingDay characterAtIndex:7]] intValue];
        
        [self btnReload:satValue btn:_saturdayBtn];
        [self btnReload:friValue btn:_fridayBtn];
        [self btnReload:thuValue btn:_thursdayBtn];
        [self btnReload:wedValue btn:_wednesdayBtn];
        [self btnReload:tueValue btn:_tuesdayBtn];
        [self btnReload:monValue btn:_mondayBtn];
        [self btnReload:sunValue btn:_sundayBtn];
    }
}

@end

