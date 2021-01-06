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
    [[TuyaSmartUser sharedInstance] sendVerifyCodeByRegisterEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text success:^{
        [Alert showBasicAlertOnVC:self withTitle:@"Verification Code Sent Successfully" message:@"Please check your email for the code."];

    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Sent Verification Code" message:error.localizedDescription];
    }];
}

- (IBAction)resetPassword:(UIButton *)sender {
    [[TuyaSmartUser sharedInstance] resetPasswordByEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text newPassword:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
        [Alert showBasicAlertOnVC:self withTitle:@"Password Reset Successfully" message:@"Please navigate back."];

    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Reset Password" message:error.localizedDescription];
    }];
}


@end
