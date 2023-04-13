//
//  CameraCruiseSelectView.m
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraCruiseSelectView.h"
#import <Masonry/Masonry.h>
#import "CameraCustomTimeView.h"
#import "UIView+CameraAdditions.h"

@interface CameraCruiseSelectView ()
@property (nonatomic, strong) UILabel *titleLabel1;
@property (nonatomic, strong) UIView *choosedView;
@property (nonatomic, strong) UILabel *titleLabel2;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) CameraCustomTimeView *timeView;
@end

@implementation CameraCruiseSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.titleLabel1];
        [self addSubview:self.titleLabel2];
        [self addSubview:self.choosedView];
        [self addSubview:self.cancelBtn];
        [self addSubview:self.confirmBtn];
        [self addSubview:self.timeView];
        
        [self.titleLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(15);
            make.size.mas_equalTo(CGSizeMake(200, 40));
        }];
        
        [self.titleLabel2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(self.titleLabel1.mas_bottom).offset(0);
            make.size.mas_equalTo(CGSizeMake(200, 40));
        }];
        
        [self.choosedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.mas_equalTo(self.titleLabel1);
            make.right.mas_equalTo(-30);
        }];
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 30));
            make.bottom.mas_equalTo(-20);
            make.left.mas_equalTo(80);
        }];
        
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(80, 30));
            make.bottom.mas_equalTo(-20);
            make.right.mas_equalTo(-80);
        }];
        
        [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(UIScreen.mainScreen.bounds.size.width);
            make.top.mas_equalTo(self.titleLabel2.mas_bottom).offset(10);
            make.bottom.mas_equalTo(self.confirmBtn.mas_top).offset(-10);
            make.left.mas_equalTo(0);
        }];
        
        self.choosedView.layer.cornerRadius = 10;
        self.choosedView.layer.masksToBounds = YES;
        self.timeView.hidden = YES;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGFloat titleLabel2Top = self.titleLabel2.origin.y;
    if (point.y<titleLabel2Top) {
        self.index = 0;
    } else if (point.y>=titleLabel2Top && point.y<=titleLabel2Top+self.titleLabel2.bounds.size.height){
        self.index = 1;
    }
}

- (void)setIndex:(NSInteger)index {
    _index = index;
    self.timeView.hidden = !(self.isShowTimeView && index==1);
    if (index==0) {
        [self.choosedView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.mas_equalTo(self.titleLabel1);
            make.right.mas_equalTo(-30);
        }];
    } else {
        [self.choosedView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.mas_equalTo(self.titleLabel2);
            make.right.mas_equalTo(-30);
        }];
    }
}

- (void)setDataSource:(NSArray *)dataSource {
    _dataSource = dataSource;
    if (dataSource.count==2) {
        self.titleLabel1.text = dataSource[0];
        self.titleLabel2.text = dataSource[1];
    }
}

#pragma mark - Action
- (void)cancelBtnClick:(UIButton *)btn {
    [self removeFromSuperview];
}

- (void)confirmBtnClick:(UIButton *)btn {
    if (self.didClickConfirmBtn) {
        self.didClickConfirmBtn(self, self.index);
    }
    [self removeFromSuperview];
}

#pragma mark - Getters

- (NSString *)startTime {
    return [self.timeView getCurrentStartTime];
}

- (NSString *)endTime {
    return [self.timeView getCurrentEndTime];
}

- (UILabel *)titleLabel1 {
    if (!_titleLabel1) {
        _titleLabel1 = [[UILabel alloc] init];
        _titleLabel1.textAlignment = NSTextAlignmentLeft;
        _titleLabel1.textColor = [UIColor whiteColor];
        _titleLabel1.text = @"Panoramic";
    }
    return _titleLabel1;
}

- (UILabel *)titleLabel2 {
    if (!_titleLabel2) {
        _titleLabel2 = [[UILabel alloc] init];
        _titleLabel2.textAlignment = NSTextAlignmentLeft;
        _titleLabel2.textColor = [UIColor whiteColor];
        _titleLabel2.text = @"Collection Points";
    }
    return _titleLabel2;
}

- (UIView *)choosedView {
    if (!_choosedView) {
        _choosedView = [UIView new];
        _choosedView.backgroundColor = [UIColor blueColor];
        _choosedView.layer.borderWidth = 2.0;
        _choosedView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _choosedView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:NSLocalizedStringFromTable(@"Cancel", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
        _cancelBtn = btn;
    }
    return _cancelBtn;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:NSLocalizedStringFromTable(@"Confirm", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(confirmBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
        _confirmBtn = btn;
    }
    return _confirmBtn;
}

- (CameraCustomTimeView *)timeView {
    if (!_timeView) {
        _timeView = [[CameraCustomTimeView alloc] init];
    }
    return _timeView;
}

@end
