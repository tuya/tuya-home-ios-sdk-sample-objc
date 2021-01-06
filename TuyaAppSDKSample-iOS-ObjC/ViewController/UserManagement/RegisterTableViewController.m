//
//  RegisterTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "RegisterTableViewController.h"
#import "Alert.h"

@interface RegisterTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

@end

@implementation RegisterTableViewController

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

- (IBAction)registerTapped:(UIButton *)sender {
    [[TuyaSmartUser sharedInstance] registerByEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text password:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
        [Alert showBasicAlertOnVC:self withTitle:@"Registered Successfully" message:@"Please navigate back to login your account."];

    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Register" message:error.localizedDescription];
    }];
}

@end
