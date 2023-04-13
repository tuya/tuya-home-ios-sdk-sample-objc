//
//  TuyaLockDeviceAddMemberView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceAddMemberView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

#define kAddMemberItemViewHeight  50
#define kAddMemberItemViewMargin  20

@interface TuyaLockDeviceAddMemberView()

@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *nameView;
@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *cityView;
@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *accountView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) TuyaLockDeviceAddMemberRoleView *roleView;
@property (nonatomic, strong) UIButton *saveBtn;//保存

@property (nonatomic, strong) NSDictionary *dataSource;

@end

@implementation TuyaLockDeviceAddMemberView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.backgroundColor = [UIColor whiteColor];
    
    self.nameView = [[TuyaLockDeviceAddMemberItemView alloc] init];
    self.nameView.titleLabel.text = @"昵称";
    self.nameView.contentTextField.placeholder = @"请输入家庭成员名称";
    self.cityView = [[TuyaLockDeviceAddMemberItemView alloc] init];
    self.cityView.titleLabel.text = @"国家";
    self.cityView.contentTextField.text = @"中国（Demo默认中国，不做修改）";
    self.cityView.canEdit = NO;
    
    self.accountView = [[TuyaLockDeviceAddMemberItemView alloc] init];
    self.accountView.titleLabel.text = @"账号";
    self.accountView.contentTextField.placeholder = @"请输入账号";
    self.accountView.contentTextField.textAlignment = NSTextAlignmentLeft;
    
    self.roleView = [[TuyaLockDeviceAddMemberRoleView alloc] init];
    self.roleView.titleLabel.text = @"家庭角色";
    
    self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.tipsLabel.textColor = [UIColor blackColor];
    self.tipsLabel.font = [UIFont systemFontOfSize:12];
    self.tipsLabel.textAlignment = NSTextAlignmentLeft;
    self.tipsLabel.text = @"关联账号接受邀请后，才能成为家庭成员并使用相关功能";
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.saveBtn.backgroundColor = [UIColor blueColor];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.nameView];
    [self addSubview:self.cityView];
    [self addSubview:self.accountView];
    [self addSubview:self.roleView];
    [self addSubview:self.tipsLabel];
    [self addSubview:self.saveBtn];
    
    WEAKSELF_ThingSDK
    [self.roleView bk_whenTapped:^{
        if (weakSelf_ThingSDK.delegate && [weakSelf_ThingSDK.delegate respondsToSelector:@selector(selectRoleType)]){
            [weakSelf_ThingSDK.delegate selectRoleType];
        }
    }];
    
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(150);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kAddMemberItemViewHeight);
    }];
    
    [self.cityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameView.mas_bottom).with.offset(kAddMemberItemViewMargin);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kAddMemberItemViewHeight);
    }];
    
    [self.accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cityView.mas_bottom).with.offset(kAddMemberItemViewMargin);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kAddMemberItemViewHeight);
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.accountView.mas_bottom).with.offset(5);
        make.right.equalTo(self);
        make.left.right.equalTo(self).with.offset(30);
        make.height.mas_equalTo(20);
    }];
    
    [self.roleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsLabel.mas_bottom).with.offset(kAddMemberItemViewMargin);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(kAddMemberItemViewHeight);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.roleView.mas_bottom).with.offset(40);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.centerX.equalTo(self);
    }];
}

- (void)saveBtnClicked{
    if (self.isEdit){
        if (self.nameView.contentTextField.text.length == 0){
            if (self.delegate && [self.delegate respondsToSelector:@selector(warningAlert)]){
                [self.delegate warningAlert];
            }
            
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateMemberAction:)]){
            ThingSmartHomeMemberRequestModel *model = [[ThingSmartHomeMemberRequestModel alloc] init];
            model.name = self.nameView.contentTextField.text;
            model.memberId = [self.dataSource[@"userId"] longLongValue];
            if ([self.roleView.roleLabel.text isEqualToString:@"管理员"]){
                model.role = 1;
            }
            else if ([self.roleView.roleLabel.text isEqualToString:@"普通成员"]){
                model.role = 0;
            }
            [self.delegate updateMemberAction:model];
        }
    }else{
        if (self.nameView.contentTextField.text.length == 0
            || self.accountView.contentTextField.text.length == 0){
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(warningAlert)]){
                [self.delegate warningAlert];
            }
            
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(addMemberAction:)]){
            ThingSmartHomeAddMemberRequestModel *model = [[ThingSmartHomeAddMemberRequestModel alloc] init];
            model.name = self.nameView.contentTextField.text;
            model.account = self.accountView.contentTextField.text;
            model.countryCode = @"86";
            model.autoAccept = NO;
            if ([self.roleView.roleLabel.text isEqualToString:@"管理员"]){
                model.role = 1;
            }
            else if ([self.roleView.roleLabel.text isEqualToString:@"普通成员"]){
                model.role = 0;
            }
            
            [self.delegate addMemberAction:model];
        }
    }
}

- (void)reloadRoleType:(NSString *)role{
    self.roleView.roleLabel.text = role;
}

- (void)reloadData:(NSDictionary *)model{
    self.dataSource = model;
    
    self.nameView.contentTextField.text = model[@"nickName"];
    self.accountView.hidden = YES;
    self.cityView.hidden = YES;
    self.tipsLabel.hidden = YES;
    
//    if (model.role == 1){
//        self.roleView.roleLabel.text = @"管理员";
//    }
//    else if (model.role == 0){
//        self.roleView.roleLabel.text = @"普通成员";
//    }
}

@end

@interface TuyaLockDeviceAddMemberItemView()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *lineView;

@end

@implementation TuyaLockDeviceAddMemberItemView

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
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:239.f/255.f alpha:1];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.contentTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.contentTextField.font = [UIFont systemFontOfSize:16];
    self.contentTextField.textAlignment = NSTextAlignmentLeft;
    self.contentTextField.delegate = self;
    self.contentTextField.textColor = [UIColor blackColor];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentTextField];
    [self addSubview:self.lineView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.width.mas_equalTo(50);
        make.height.equalTo(self);
    }];
    
    [self.contentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
        make.left.equalTo(self.titleLabel.mas_right);
        make.centerY.equalTo(self);
        make.height.equalTo(self);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self).with.offset(-10);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];
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

@interface TuyaLockDeviceAddMemberRoleView()

@property (nonatomic, strong) UIView *lineView;

@end

@implementation TuyaLockDeviceAddMemberRoleView

- (instancetype)init{
    self = [super init];
    if (self){
        [self setupViews];
    }
    
    return self;
}

- (void)setupViews{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [UIColor whiteColor];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithRed:238.f/255.f green:238.f/255.f blue:239.f/255.f alpha:1];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor blueColor];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.roleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.roleLabel.textColor = [UIColor blackColor];
    self.roleLabel.font = [UIFont systemFontOfSize:16];
    self.roleLabel.textAlignment = NSTextAlignmentLeft;
    self.roleLabel.text = @"点击选择（默认普通成员）";
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.roleLabel];
    [self addSubview:self.lineView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(30);
        make.width.mas_equalTo(100);
        make.height.equalTo(self);
    }];
    
    [self.roleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
        make.left.equalTo(self.titleLabel.mas_right);
        make.height.equalTo(self);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self).with.offset(-10);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];
}

@end
