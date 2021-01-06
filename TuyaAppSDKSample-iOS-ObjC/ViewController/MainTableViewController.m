//
//  MainTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "MainTableViewController.h"

@interface MainTableViewController ()

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [self.alertController addAction:action];
}

#pragma mark - IBAction

- (IBAction)logout:(UIButton *)sender {
    [sender setEnabled:NO];
    __weak typeof (self) weakSelf = self;
    
    [[TuyaSmartUser sharedInstance] loginOut:^{
        [weakSelf.alertController setTitle:@"Successfully Logged Out"];
        [weakSelf.alertController setMessage:@"Most of the functions will be unusable."];

        [weakSelf presentViewController:weakSelf.alertController animated:true completion:^{
            [sender setEnabled:YES];
        }];
    } failure:^(NSError *error) {
        [weakSelf.alertController setTitle:@"Failed to Logout."];
        [weakSelf.alertController setMessage:error.localizedDescription];

        [weakSelf presentViewController:weakSelf.alertController animated:true completion:^{
            [sender setEnabled:YES];
        }];
    }];
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
