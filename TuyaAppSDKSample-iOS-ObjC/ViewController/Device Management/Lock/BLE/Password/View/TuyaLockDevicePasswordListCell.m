//
//  TuyaLockDevicePasswordListCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDevicePasswordListCell.h"
#import <Masonry/Masonry.h>

@interface TuyaLockDevicePasswordListCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *modifyBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation TuyaLockDevicePasswordListCell

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
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.modifyBtn = [self getCellBtn:@"修改" action:@selector(modifyBtnClicked)];
    self.deleteBtn = [self getCellBtn:@"删除" action:@selector(deleteBtnClicked)];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.modifyBtn];
    [self addSubview:self.deleteBtn];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(10);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(200);
    }];
    
    [self.modifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.deleteBtn.mas_left).with.offset(-10);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(50);
    }];
    
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
        make.top.bottom.equalTo(self);
        make.width.mas_equalTo(50);
    }];
}

- (UIButton *)getCellBtn:(NSString *)title action:(SEL)action{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    
    return btn;
}

- (void)modifyBtnClicked{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(passwordListCellModifyAction)]){
        [self.cellDelegate passwordListCellModifyAction];
    }
}

- (void)deleteBtnClicked{
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(passwordListCellDeleteAction)]){
        [self.cellDelegate passwordListCellDeleteAction];
    }
}

@end
