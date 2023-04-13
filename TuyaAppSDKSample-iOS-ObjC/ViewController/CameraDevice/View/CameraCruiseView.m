//
//  CameraCruiseView.m
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraCruiseView.h"
#import <Masonry/Masonry.h>
#import "CameraCruiseSelectView.h"
#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>

@interface CameraCruiseView ()<TuyaSmartPTZManagerDeletate>
@property (nonatomic, strong) UILabel *motionDetectLabel;
@property (nonatomic, strong) UISwitch *motionDetectSwitch;

@property (nonatomic, strong) UILabel *cruiseLabel;
@property (nonatomic, strong) UISwitch *cruiseSwitch;

@property (nonatomic, strong) UIButton *cruiseModeButton;
@property (nonatomic, strong) UIButton *cruiseModeValueButton;

@property (nonatomic, strong) UIButton *cruiseTimeButton;
@property (nonatomic, strong) UIButton *cruiseTimeValueButton;
@property (nonatomic, strong) TuyaSmartPTZManager *ptzManager;

@property (nonatomic, strong) CameraCruiseSelectView *selectView;
@end

@implementation CameraCruiseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.motionDetectLabel];
        [self addSubview:self.motionDetectSwitch];
        
        [self addSubview:self.cruiseLabel];
        [self addSubview:self.cruiseSwitch];
        
        [self addSubview:self.cruiseModeButton];
        [self addSubview:self.cruiseModeValueButton];
        
        [self addSubview:self.cruiseTimeButton];
        [self addSubview:self.cruiseTimeValueButton];
        
        [self setupConstraints];
    }
    return self;
}

- (void)setDeviceId:(NSString *)deviceId {
    _deviceId = deviceId;
    [self updateValue];
}

- (void)refreshView {
    NSMutableString *tips = [NSMutableString string];
    if (![self.ptzManager isSupportCruise]) {
        [tips appendString:NSLocalizedStringFromTable(@"Cruise Mode  is unsupported", @"IPCLocalizable", @"")];
        [tips appendString:@"\n"];
    }
    if (![self.ptzManager isSupportMotionTracking]) {
        [tips appendString:NSLocalizedStringFromTable(@"Motion Tracking is unsupported", @"IPCLocalizable", @"")];
    }
    if (tips.length == 0) {
        return;
    }
    [SVProgressHUD showInfoWithStatus:tips.copy];
}

- (void)updateValue {
    if (![self.ptzManager isSupportMotionTracking]) {
        self.motionDetectLabel.hidden = YES;
        self.motionDetectSwitch.hidden = YES;
    } else {
        self.motionDetectLabel.hidden = NO;
        self.motionDetectSwitch.hidden = NO;
        
        BOOL isOpen = [self.ptzManager isOpenMotionTracking];
        [self.motionDetectSwitch setOn:isOpen];
    }
    
    if (![self.ptzManager isSupportCruise]) {
        self.cruiseLabel.hidden = YES;
        self.cruiseSwitch.hidden = YES;
        
        [self setBodyViewHidden:YES];
        return;
    }
    
    if (![self.ptzManager isOpenCruise]) {
        [self.cruiseSwitch setOn:NO];
        [self setBodyViewHidden:YES];
        
    } else {
        [self.cruiseSwitch setOn:YES];
        [self setBodyViewHidden:NO];
        [self updateCruiseModeValueButton];
        [self updateCruiseTimeValueButton];
    }
}

- (void)updateCruiseModeValueButton {
    TuyaSmartPTZControlCruiseMode cruiseMode = [self.ptzManager getCurrentCruiseMode];
    NSString *modeStr = (cruiseMode == TuyaSmartPTZControlCruiseModePanoramic) ? NSLocalizedStringFromTable(@"Panoramic", @"IPCLocalizable", @""):NSLocalizedStringFromTable(@"Collection Points", @"IPCLocalizable", @"");
    [self.cruiseModeValueButton setTitle:modeStr forState:UIControlStateNormal];
}

- (void)updateCruiseTimeValueButton {
    TuyaSmartPTZControlCruiseTimeMode timeMode = [self.ptzManager getCurrentCruiseTimeMode];
    NSString *timeStr = @"";
    if (timeMode == TuyaSmartPTZControlCruiseTimeModeAllDay) {
        timeStr = NSLocalizedStringFromTable(@"All Day", @"IPCLocalizable", @"");
    } else {
        timeStr = [self.ptzManager getCurrentCruiseTime];
    }
    [self.cruiseTimeValueButton setTitle:timeStr forState:UIControlStateNormal];
}

- (void)setBodyViewHidden:(BOOL)hidden {
    self.cruiseModeButton.hidden = hidden;
    self.cruiseModeValueButton.hidden = hidden;
    self.cruiseTimeButton.hidden = hidden;
    self.cruiseTimeValueButton.hidden = hidden;
}

#pragma mark - Actions

- (void)cruiseModeButtonClick:(UIButton *)btn {
    [self addSubview:self.selectView];
    TuyaSmartPTZControlCruiseMode cruiseMode = [self.ptzManager getCurrentCruiseMode];
    self.selectView.isShowTimeView = NO;
    self.selectView.index = (cruiseMode == TuyaSmartPTZControlCruiseModePanoramic) ? 0:1;
    self.selectView.dataSource = @[NSLocalizedStringFromTable(@"Panoramic", @"IPCLocalizable", @""), NSLocalizedStringFromTable(@"Collection Points", @"IPCLocalizable", @"")];
    
    __weak typeof(self) weakSelf = self;
    self.selectView.didClickConfirmBtn = ^(CameraCruiseSelectView * _Nonnull view, NSInteger index) {
        TuyaSmartPTZControlCruiseMode cruiseMode = index==0 ? TuyaSmartPTZControlCruiseModePanoramic:TuyaSmartPTZControlCruiseModeCollectionPoint;
        [weakSelf.ptzManager setCruiseMode:cruiseMode success:^(id result) {
            [weakSelf updateCruiseModeValueButton];
        } failure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];
    };
}

- (void)cruiseTimeButtonClick:(UIButton *)btn {
    [self addSubview:self.selectView];
    TuyaSmartPTZControlCruiseTimeMode timeMode = [self.ptzManager getCurrentCruiseTimeMode];
    self.selectView.isShowTimeView = YES;
    self.selectView.index = (timeMode == TuyaSmartPTZControlCruiseTimeModeAllDay) ? 0:1;
    self.selectView.dataSource = @[NSLocalizedStringFromTable(@"All Day", @"IPCLocalizable", @""), NSLocalizedStringFromTable(@"Custom Time", @"IPCLocalizable", @"")];
    
    __weak typeof(self) weakSelf = self;
    self.selectView.didClickConfirmBtn = ^(CameraCruiseSelectView * _Nonnull view, NSInteger index) {
        
        TuyaSmartPTZControlCruiseTimeMode timeMode = index==0 ? TuyaSmartPTZControlCruiseTimeModeAllDay:TuyaSmartPTZControlCruiseTimeModeCustom;
        [weakSelf.ptzManager setCruiseTimeMode:timeMode success:^{
            [weakSelf updateCruiseTimeValueButton];
        } failure:^(NSError *error) {

        }];
        
        if (view.isShowTimeView && index==1) {
            [weakSelf.ptzManager setCruiseCustomWithStartTime:view.startTime endTime:view.endTime success:^{
                [SVProgressHUD showSuccessWithStatus:NSLocalizedStringFromTable(@"success", @"IPCLocalizable", @"")];
                [weakSelf updateCruiseTimeValueButton];
            } failure:^(NSError *error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            }];
        }
    };
}

#pragma mark - UI

- (void)setupConstraints {
    [self.motionDetectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(15);
    }];
    
    [self.motionDetectSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.motionDetectLabel);
    }];
    
    [self.cruiseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.motionDetectLabel);
        make.top.mas_equalTo(self.motionDetectLabel.mas_bottom).offset(30);
    }];
    
    [self.cruiseSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.centerY.mas_equalTo(self.cruiseLabel);
    }];
    
    [self.cruiseModeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(-100);
        make.top.mas_equalTo(self.cruiseLabel.mas_bottom).offset(50);
        make.size.mas_equalTo(CGSizeMake(100, 36));
    }];
    
    [self.cruiseModeValueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.cruiseModeButton);
        make.top.mas_equalTo(self.cruiseModeButton.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 36));
    }];
    
    [self.cruiseTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(100);
        make.top.mas_equalTo(self.cruiseModeButton);
        make.size.mas_equalTo(CGSizeMake(100, 36));
    }];
    
    [self.cruiseTimeValueButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.cruiseTimeButton);
        make.top.mas_equalTo(self.cruiseTimeButton.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 36));
    }];
}

#pragma mark - Action

- (void)motionDetectSwitchValueChanged:(UISwitch *)switcher {
    BOOL isOn = switcher.isOn;
    [self.ptzManager setMotionTrackingState:isOn success:^{
        [SVProgressHUD showSuccessWithStatus:NSLocalizedStringFromTable(@"success", @"IPCLocalizable", @"")];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        [switcher setOn:!isOn];
    }];
}

- (void)cruiseSwitchValueChanged:(UISwitch *)switcher {
    BOOL isOn = switcher.isOn;
    __weak typeof(self) weakSelf = self;
    [self.ptzManager setCruiseOpen:isOn success:^(id result) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedStringFromTable(@"success", @"IPCLocalizable", @"")];
        [weakSelf setBodyViewHidden:!isOn];
        if (isOn) {
            [weakSelf updateCruiseModeValueButton];
            [weakSelf updateCruiseTimeValueButton];
        }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        [switcher setOn:!isOn];
        [weakSelf setBodyViewHidden:isOn];
    }];
}

#pragma mark - Getters

- (UILabel *)motionDetectLabel {
    if (!_motionDetectLabel) {
        _motionDetectLabel = [[UILabel alloc] init];
        _motionDetectLabel.textAlignment = NSTextAlignmentLeft;
        _motionDetectLabel.textColor = [UIColor blackColor];
        _motionDetectLabel.text = NSLocalizedStringFromTable(@"Motion Detect", @"IPCLocalizable", @"");
    }
    return _motionDetectLabel;
}

- (UISwitch *)motionDetectSwitch {
    if (!_motionDetectSwitch) {
        _motionDetectSwitch = [[UISwitch alloc] init];
        [_motionDetectSwitch addTarget:self action:@selector(motionDetectSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _motionDetectSwitch;
}

- (UILabel *)cruiseLabel {
    if (!_cruiseLabel) {
        _cruiseLabel = [[UILabel alloc] init];
        _cruiseLabel.textAlignment = NSTextAlignmentLeft;
        _cruiseLabel.textColor = [UIColor blackColor];
        _cruiseLabel.text = NSLocalizedStringFromTable(@"Open Cruise", @"IPCLocalizable", @"");
    }
    return _cruiseLabel;
}

- (UISwitch *)cruiseSwitch {
    if (!_cruiseSwitch) {
        _cruiseSwitch = [[UISwitch alloc] init];
        [_cruiseSwitch addTarget:self action:@selector(cruiseSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _cruiseSwitch;
}

- (UIButton *)cruiseModeButton {
    if (!_cruiseModeButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:NSLocalizedStringFromTable(@"Cruise Mode", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(cruiseModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cruiseModeButton = btn;
    }
    return _cruiseModeButton;
}

- (UIButton *)cruiseModeValueButton {
    if (!_cruiseModeValueButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(cruiseModeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cruiseModeValueButton = btn;
    }
    return _cruiseModeValueButton;
}

- (UIButton *)cruiseTimeButton {
    if (!_cruiseTimeButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:NSLocalizedStringFromTable(@"Cruise Time", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(cruiseTimeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cruiseTimeButton = btn;
    }
    return _cruiseTimeButton;
}

- (UIButton *)cruiseTimeValueButton {
    if (!_cruiseTimeValueButton) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:11.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(cruiseTimeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cruiseTimeValueButton = btn;
    }
    return _cruiseTimeValueButton;
}

#pragma mark - Getters
- (TuyaSmartPTZManager *)ptzManager {
    if (!_ptzManager) {
        _ptzManager = [[TuyaSmartPTZManager alloc] initWithDeviceId:_deviceId];
        _ptzManager.delegate = self;
    }
    return _ptzManager;
}

- (CameraCruiseSelectView *)selectView {
    if (!_selectView) {
        _selectView = [[CameraCruiseSelectView alloc] initWithFrame:self.bounds];
    }
    return _selectView;
}

@end
