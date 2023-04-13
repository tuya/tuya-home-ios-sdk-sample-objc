//
//  LoginTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "LoginTableViewController.h"
#import "Alert.h"

@interface LoginTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordButton;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - IBAction

- (IBAction)login:(UIButton *)sender {
    if ([self.accountTextField.text containsString:@"@"]) {
        [[TuyaSmartUser sharedInstance] loginByEmail:self.countryCodeTextField.text email:self.accountTextField.text password:self.passwordTextField.text success:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TuyaSmartMain" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Login" message:error.localizedDescription];
        }];
    } else {
        [[TuyaSmartUser sharedInstance] loginByPhone:self.countryCodeTextField.text phoneNumber:self.accountTextField.text password:self.passwordTextField.text success:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TuyaSmartMain" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Login" message:error.localizedDescription];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self login:nil];
    } else if (indexPath.section == 2) {
        [self.forgetPasswordButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
