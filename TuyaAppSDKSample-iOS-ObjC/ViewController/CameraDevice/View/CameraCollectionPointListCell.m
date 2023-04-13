//
//  CameraCollectionPointListCell.m
//  TuyaSmartIPCDemo_Example
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraCollectionPointListCell.h"
#import <ThingEncryptImage/ThingEncryptImage.h>
#import <Masonry/Masonry.h>

@interface CameraCollectionPointListCell ()
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIButton *renameBtn;
@property (nonatomic, strong) UIButton *removeBtn;
@end

@implementation CameraCollectionPointListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.renameBtn];
        [self.contentView addSubview:self.removeBtn];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(128, 72));
            make.left.mas_equalTo(15);
            make.top.mas_equalTo(4.5);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.iconView.mas_right).offset(10);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-80);
        }];
        
        [self.renameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 36));
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(3);
        }];
        
        [self.removeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 36));
            make.right.mas_equalTo(-15);
            make.bottom.mas_equalTo(-3);
        }];
    }
    return self;
}

- (void)setModel:(ThingCameraCollectionPointModel *)model {
    _model = model;
    [self.iconView thing_setAESImageWithPath:model.pic encryptKey:model.encryption];
    self.nameLabel.text = model.name;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.backgroundColor = [UIColor lightGrayColor];
        _iconView.layer.cornerRadius = 4;
        _iconView.layer.masksToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [UIColor blackColor];
    }
    return _nameLabel;
}

- (void)renameBtnClick:(UIButton *)btn {
    if (self.didClickRenameButton) {
        self.didClickRenameButton(_model);
    }
}

- (UIButton *)renameBtn {
    if (!_renameBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:NSLocalizedStringFromTable(@"rename", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(renameBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
        _renameBtn = btn;
    }
    return _renameBtn;
}

- (void)removeBtnClick:(UIButton *)btn {
    if (self.didClickRemoveButton) {
        self.didClickRemoveButton(_model);
    }
}

- (UIButton *)removeBtn {
    if (!_removeBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:NSLocalizedStringFromTable(@"remove", @"IPCLocalizable", @"") forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13.0];
        btn.backgroundColor = [UIColor lightGrayColor];
        [btn addTarget:self action:@selector(removeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
        _removeBtn = btn;
    }
    return _removeBtn;
}

@end
