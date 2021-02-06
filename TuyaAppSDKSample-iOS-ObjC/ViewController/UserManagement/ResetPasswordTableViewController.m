//
//  ResetPasswordTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "ResetPasswordTableViewController.h"
#import "Alert.h"

@interface ResetPasswordTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;
@end
@implementation ResetPasswordTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - IBAction

- (IBAction)sendVerificationCode:(UIButton *)sender {
    if ([self.emailAddressTextField.text containsString:@"@"]) {
        [[TuyaSmartUser sharedInstance] sendVerifyCodeByRegisterEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text success:^{
            [Alert showBasicAlertOnVC:self withTitle:@"Verification Code Sent Successfully" message:@"Please check your email for the code."];

        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Sent Verification Code" message:error.localizedDescription];
        }];
    } else {
        [[TuyaSmartUser sharedInstance] sendVerifyCode:self.countryCodeTextField.text phoneNumber:self.emailAddressTextField.text type:2 success:^{
            [Alert showBasicAlertOnVC:self withTitle:@"Verification Code Sent Successfully" message:@"Please check your message for the code."];

        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Sent Verification Code" message:error.localizedDescription];
        }];
    }
}

- (IBAction)resetPassword:(UIButton *)sender {
    if ([self.emailAddressTextField.text containsString:@"@"]) {
        [[TuyaSmartUser sharedInstance] resetPasswordByEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text newPassword:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
            [Alert showBasicAlertOnVC:self withTitle:@"Password Reset Successfully" message:@"Please navigate back."];

        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Reset Password" message:error.localizedDescription];
        }];
    } else {
        [[TuyaSmartUser sharedInstance] resetPasswordByPhone:self.countryCodeTextField.text phoneNumber:self.emailAddressTextField.text newPassword:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
            [Alert showBasicAlertOnVC:self withTitle:@"Password Reset Successfully" message:@"Please navigate back."];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Reset Password" message:error.localizedDescription];
        }];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        [self sendVerificationCode:nil];
    } else if (indexPath.section == 2) {
        [self resetPassword:nil];
    }
}


@end
