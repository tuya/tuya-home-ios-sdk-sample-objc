//
//  SwitchTableViewCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "SwitchTableViewCell.h"

@implementation SwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    if (self.switchButton) {
        [self.controls addObject:self.switchButton];
    }
}

- (IBAction)switchTapped:(UISwitch *)sender {
    if (self.switchAction) {
        self.switchAction(sender);
    }
}

@end
