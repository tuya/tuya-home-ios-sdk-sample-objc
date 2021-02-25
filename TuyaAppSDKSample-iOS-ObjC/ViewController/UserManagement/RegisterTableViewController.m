//
//  RegisterTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "RegisterTableViewController.h"
#import "Alert.h"

@interface RegisterTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

@end

@implementation RegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - IBAction

- (IBAction)sendVerificationCode:(UIButton *)sender {
    if ([self.accountTextField.text containsString:@"@"]) {
        [[TuyaSmartUser sharedInstance] sendVerifyCodeByRegisterEmail:self.countryCodeTextField.text email:self.accountTextField.text success:^{
            [Alert showBasicAlertOnVC:self withTitle:@"Verification Code Sent Successfully" message:@"Please check your email for the code."];

        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Sent Verification Code" message:error.localizedDescription];
        }];
    } else {
        [[TuyaSmartUser sharedInstance] sendVerifyCode:self.countryCodeTextField.text phoneNumber:self.accountTextField.text type:1 success:^{
            [Alert showBasicAlertOnVC:self withTitle:@"Verification Code Sent Successfully" message:@"Please check your message for the code."];

        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Sent Verification Code" message:error.localizedDescription];
        }];
    }
}

- (IBAction)registerTapped:(UIButton *)sender {
    if ([self.accountTextField.text containsString:@"@"]) {
        [[TuyaSmartUser sharedInstance] registerByEmail:self.countryCodeTextField.text email:self.accountTextField.text password:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
            [Alert showBasicAlertOnVC:nav withTitle:@"Registered Successfully" message:@"Please navigate back to login your account."];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Register" message:error.localizedDescription];
        }];
    } else {
        [[TuyaSmartUser sharedInstance] registerByPhone:self.countryCodeTextField.text phoneNumber:self.accountTextField.text password:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
            [Alert showBasicAlertOnVC:nav withTitle:@"Registered Successfully" message:@"Please navigate back to login your account."];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Register" message:error.localizedDescription];
        }];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 4) {
        [self sendVerificationCode:nil];
    } else if (indexPath.section == 1) {
        [self registerTapped:nil];
    }
}
@end
