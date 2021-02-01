//
//  StringTableViewCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "StringTableViewCell.h"

@implementation StringTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.button) {
        [self.controls addObject:self.button];
    }
    if (self.textField) {
        [self.controls addObject:self.textField];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)buttonTapped:(UIButton *)sender {
    if (self.buttonAction) {
        self.buttonAction(self.textField.text);
    }
}

@end
