//
//  TuyaWiFiAddMemberView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaWiFiAddMemberView.h"
#import "TuyaLockDeviceAddMemberView.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/UIView+BlocksKit.h>
#import "Alert.h"

@interface TuyaWiFiAddMemberView()

@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *nameView;
@property (nonatomic, strong) UIButton *saveBtn;//保存
@property (nonatomic, strong) ThingSmartLockMemberModel *currentModel;

@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *pwdView;
@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *cardView;
@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *fingerView;

@property (nonatomic, strong) TuyaLockDeviceAddMemberItemView *snView;//已有解锁方式sn

@end

@implementation TuyaWiFiAddMemberView

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
    
    self.pwdView = [[TuyaLockDeviceAddMemberItemView alloc] init];
    self.pwdView.titleLabel.text = @"密码";
    self.pwdView.contentTextField.placeholder = @"请输入sn";
    self.pwdView.contentTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.cardView = [[TuyaLockDeviceAddMemberItemView alloc] init];
    self.cardView.titleLabel.text = @"卡片";
    self.cardView.contentTextField.placeholder = @"请输入sn";
    self.cardView.contentTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.fingerView = [[TuyaLockDeviceAddMemberItemView alloc] init];
    self.fingerView.titleLabel.text = @"指纹";
    self.fingerView.contentTextField.placeholder = @"请输入sn";
    self.fingerView.contentTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    self.snView = [[TuyaLockDeviceAddMemberItemView alloc] init];
    self.snView.titleLabel.text = @"解锁方式";
    self.snView.contentTextField.enabled = NO;
    self.snView.hidden = YES;
    
    self.saveBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    self.saveBtn.backgroundColor = [UIColor blueColor];
    [self.saveBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.nameView];
    [self addSubview:self.pwdView];
    [self addSubview:self.cardView];
    [self addSubview:self.fingerView];
    [self addSubview:self.snView];
    [self addSubview:self.saveBtn];
    
    [self.nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(150);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.pwdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameView.mas_bottom).with.offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pwdView.mas_bottom).with.offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.fingerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardView.mas_bottom).with.offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.snView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fingerView.mas_bottom).with.offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(50);
    }];
    
    [self.saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).with.offset(-100);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(50);
        make.centerX.equalTo(self);
    }];
}

- (void)reloadModel:(ThingSmartLockMemberModel *)model{
    self.currentModel = model;
    self.nameView.contentTextField.text = model.userName;
    if (model.unlockRelations.count > 0){
        self.snView.hidden = NO;
        __block NSString *contentValue = @"";
        [model.unlockRelations enumerateObjectsUsingBlock:^(ThingSmartLockRelationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            contentValue = [NSString stringWithFormat:@"%@ %ld-%ld",contentValue,obj.unlockType,obj.sn];
        }];
        
        self.snView.contentTextField.text = contentValue;
    }
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
            self.currentModel.userName = self.nameView.contentTextField.text;
            
            NSMutableArray *unlockRelations = [self getUnlockRelations:self.currentModel.unlockRelations];
            if (unlockRelations.count > 0){
                self.currentModel.unlockRelations = unlockRelations;
            }
            [self.delegate updateMemberAction:self.currentModel];
        }
    }else{
        if (self.nameView.contentTextField.text.length == 0){
            if (self.delegate && [self.delegate respondsToSelector:@selector(warningAlert)]){
                [self.delegate warningAlert];
            }
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(addMemberAction:)]){
            ThingSmartLockMemberModel *model = [[ThingSmartLockMemberModel alloc] init];
            model.userName = self.nameView.contentTextField.text;
            
            NSMutableArray *unlockRelations = [self getUnlockRelations:nil];
            if (unlockRelations.count > 0){
                model.unlockRelations = unlockRelations;
            }
            
            [self.delegate addMemberAction:model];
        }
    }
}

- (NSMutableArray *)getUnlockRelations:(NSArray *)array{
    if (!array){
        array = [NSArray new];
    }
    
    NSMutableArray *unlockRelations = [[NSMutableArray alloc] initWithArray:array];
    if (self.pwdView.contentTextField.text > 0){
        ThingSmartLockRelationModel *pwdModel = [[ThingSmartLockRelationModel alloc] init];
        pwdModel.sn = [self.pwdView.contentTextField.text integerValue];
        pwdModel.unlockType = ThingLockUnlockTypePassword;
        [unlockRelations addObject:pwdModel];
    }
    
    if (self.cardView.contentTextField.text > 0){
        ThingSmartLockRelationModel *cardModel = [[ThingSmartLockRelationModel alloc] init];
        cardModel.sn = [self.cardView.contentTextField.text integerValue];
        cardModel.unlockType = ThingLockUnlockTypeCard;
        [unlockRelations addObject:cardModel];
    }
    
    if (self.fingerView.contentTextField.text > 0){
        ThingSmartLockRelationModel *fingerModel = [[ThingSmartLockRelationModel alloc] init];
        fingerModel.sn = [self.fingerView.contentTextField.text integerValue];
        fingerModel.unlockType = ThingLockUnlockTypeFingerprint;
        [unlockRelations addObject:fingerModel];
    }
    
    return unlockRelations;
}

@end
