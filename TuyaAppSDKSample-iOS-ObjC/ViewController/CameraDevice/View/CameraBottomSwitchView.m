//
//  CameraBottomSwitchView.m
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraBottomSwitchView.h"

#define kCameraBottomSwitchViewBtnBaseTag 100
@interface CameraBottomSwitchView ()
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation CameraBottomSwitchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSString *str1 = NSLocalizedStringFromTable(@"Main", @"IPCLocalizable", @"");
        NSString *str2 = NSLocalizedStringFromTable(@"PTZ", @"IPCLocalizable", @"");
        NSString *str3 = NSLocalizedStringFromTable(@"Collection Points", @"IPCLocalizable", @"");
        NSString *str4 = NSLocalizedStringFromTable(@"Cruise", @"IPCLocalizable", @"");
        self.dataSource = @[str1, str2, str3, str4];
        for (int i = 0; i < self.dataSource.count; i++) {
            UIButton *btn = [self creatButtonWithTitle:self.dataSource[i] index:i];
            [self addSubview:btn];
        }
    }
    return self;
}

- (void)selecteItem:(NSInteger)item {
    UIButton *button = [self viewWithTag:kCameraBottomSwitchViewBtnBaseTag + item];
    if (!button) {
        return;
    }
    if (button.isSelected) {
        return;
    }
    for (int index=0; index<self.dataSource.count; index++) {
        UIButton *button = [self viewWithTag:kCameraBottomSwitchViewBtnBaseTag+index];
        button.selected = NO;
    }
    button.selected = YES;
}

- (void)btnClick:(UIButton *)btn {
    NSLog(@"tag:%ld", btn.tag-kCameraBottomSwitchViewBtnBaseTag);
    if (btn.isSelected) {
        return;
    }
    
    for (int index=0; index<self.dataSource.count; index++) {
        UIButton *button = [self viewWithTag:kCameraBottomSwitchViewBtnBaseTag+index];
        button.selected = NO;
    }
    
    btn.selected = YES;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickBottomButton:buttonType:)]) {
        CameraBottomButtonType type = (CameraBottomButtonType)(btn.tag-kCameraBottomSwitchViewBtnBaseTag);
        [self.delegate didClickBottomButton:self buttonType:type];
    }
}

- (UIButton *)creatButtonWithTitle:(NSString *)title index:(int)index {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    if (title && title.length>=15) {
        btn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    } else {
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    }
    CGFloat btnWidth = self.bounds.size.width/self.dataSource.count;
    CGFloat btnHeight = self.bounds.size.height;
    btn.frame = CGRectMake(index*btnWidth, 0, btnWidth, btnHeight);
    btn.tag = kCameraBottomSwitchViewBtnBaseTag + index;
    btn.backgroundColor = [UIColor whiteColor];
    btn.layer.borderColor = [UIColor lightTextColor].CGColor;
    btn.layer.borderWidth = 0.3;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.selected = index==0;
    return btn;
}

@end
