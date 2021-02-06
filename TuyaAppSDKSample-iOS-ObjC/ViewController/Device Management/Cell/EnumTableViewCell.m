//
//  EnumTableViewCell.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "EnumTableViewCell.h"

@implementation EnumTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.optionArray = [NSMutableArray new];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected && self.optionArray > 0) {
        UIViewController *vc = [[UIApplication sharedApplication] delegate].window.rootViewController;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Option", @"") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSString *option in self.optionArray) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:option style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.currentOption = option;
                self.detailLabel.text = self.currentOption;
                if (self.selectAction) {
                    self.selectAction(option);
                }
            }];
            [alert addAction:action];
        }
        
        alert.popoverPresentationController.sourceView = self;
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        
        [vc presentViewController:alert animated:YES completion:nil];
    } else {
        return;
    }
}

- (void)enableControls {
    [self setUserInteractionEnabled:YES];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)disableControls {
    [self setUserInteractionEnabled:NO];
    self.accessoryType = UITableViewCellAccessoryNone;
}

@end
