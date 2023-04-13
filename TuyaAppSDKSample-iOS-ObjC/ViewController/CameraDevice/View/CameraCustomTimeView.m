//
//  CameraCustomTimeView.m
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraCustomTimeView.h"
#import <Masonry/Masonry.h>

@interface CameraCustomTimeView ()<UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UILabel *startTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UIPickerView *pickerView1;
@property (nonatomic, strong) UIPickerView *pickerView2;
@end

@implementation CameraCustomTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.startTimeLabel];
        [self addSubview:self.endTimeLabel];
        [self addSubview:self.pickerView1];
        [self addSubview:self.pickerView2];
        
        [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(50);
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
        
        [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-50);
            make.top.mas_equalTo(self.startTimeLabel);
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
        
        [self.pickerView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.startTimeLabel);
            make.top.mas_equalTo(self.startTimeLabel.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(120, 90));
        }];
        
        [self.pickerView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.endTimeLabel);
            make.top.mas_equalTo(self.endTimeLabel.mas_bottom).offset(10);
            make.size.mas_equalTo(CGSizeMake(120, 90));
        }];
    }
    return self;
}

- (NSString *)getCurrentStartTime {
    NSInteger row0 = [self.pickerView1 selectedRowInComponent:0];
    NSInteger row1 = [self.pickerView1 selectedRowInComponent:1];
    NSString *time = [NSString stringWithFormat:@"%02d:%02d", row0, row1];
    return time;
}

- (NSString *)getCurrentEndTime {
    NSInteger row0 = [self.pickerView2 selectedRowInComponent:0];
    NSInteger row1 = [self.pickerView2 selectedRowInComponent:1];
    NSString *time = [NSString stringWithFormat:@"%02d:%02d", row0, row1];
    return time;
}

#pragma mark - UIPickerView

- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component==0) {
        return 24;
    }
    return 60;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 60;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 30;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = [NSString stringWithFormat:@"%02ld", (long)row];
    return title;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    NSString *title = [NSString stringWithFormat:@"%02ld", (long)row];
    UILabel *titleLabel = [self getLabel];
    titleLabel.text = title;
    return titleLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
}

- (UILabel *)getLabel {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    return label;
}

#pragma mark - Getters

- (UILabel *)startTimeLabel {
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc] init];
        _startTimeLabel.textAlignment = NSTextAlignmentCenter;
        _startTimeLabel.textColor = [UIColor whiteColor];
        _startTimeLabel.text = NSLocalizedStringFromTable(@"Start Time", @"IPCLocalizable", @"");
    }
    return _startTimeLabel;
}

- (UILabel *)endTimeLabel {
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] init];
        _endTimeLabel.textAlignment = NSTextAlignmentCenter;
        _endTimeLabel.textColor = [UIColor whiteColor];
        _endTimeLabel.text = NSLocalizedStringFromTable(@"End Time", @"IPCLocalizable", @"");
    }
    return _endTimeLabel;
}

- (UIPickerView *)pickerView1 {
    if (!_pickerView1) {
        _pickerView1 = [[UIPickerView alloc] init];
        _pickerView1.dataSource = self;
        _pickerView1.delegate = self;
    }
    return _pickerView1;
}

- (UIPickerView *)pickerView2 {
    if (!_pickerView2) {
        _pickerView2 = [[UIPickerView alloc] init];
        _pickerView2.dataSource = self;
        _pickerView2.delegate = self;
    }
    return _pickerView2;
}

@end
