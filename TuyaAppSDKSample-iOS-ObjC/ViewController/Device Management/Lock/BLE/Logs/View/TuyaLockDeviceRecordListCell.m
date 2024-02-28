//
//  TuyaLockDeviceRecordListCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceRecordListCell.h"
#import <Masonry/Masonry.h>

@interface TuyaLockDeviceRecordListCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation TuyaLockDeviceRecordListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.textColor = [UIColor blueColor];
    self.timeLabel.font = [UIFont systemFontOfSize:16];
    self.timeLabel.textAlignment = NSTextAlignmentLeft;
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.timeLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(20);
        make.top.bottom.equalTo(self);
        make.right.equalTo(self.timeLabel.mas_left);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(180);
    }];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
}

- (void)reloadData:(NSString *)title time:(NSTimeInterval)time logType:(NSString *)logType{
    self.titleLabel.text = title;
    
    NSDate *timeData = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSString *timeStr = [self.formatter stringFromDate:timeData];
    self.timeLabel.text = timeStr;
    
    if (logType.length>0){
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)",title,logType];
    }
}

@end
