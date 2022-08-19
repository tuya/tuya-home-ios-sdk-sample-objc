//
//  TextViewTableViewCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "TextViewTableViewCell.h"

@implementation TextViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.button) {
        [self.controls addObject:self.button];
    }
    if (self.textview) {
        [self.controls addObject:self.textview];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)buttonTapped:(UIButton *)sender {
    [self endEditing:YES];
    if (self.buttonAction) {
        self.buttonAction(self.textview.text);
    }
}


@end
