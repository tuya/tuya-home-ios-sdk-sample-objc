//
//  RegisterTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "RegisterTableViewController.h"

@interface RegisterTableViewController ()

@property (nonatomic, strong) UIAlertController *alertController;

@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *verificationCodeTextField;

@end

@implementation RegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [self.alertController addAction:action];
}

#pragma mark - IBAction

- (IBAction)sendVerificationCode:(UIButton *)sender {
    __weak typeof (self) weakSelf = self;
    [[TuyaSmartUser sharedInstance] sendVerifyCodeByRegisterEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text success:^{
        [weakSelf.alertController setTitle:@"Verification Code Sent Successfully"];
        [weakSelf.alertController setMessage:@"Please check your email for the code."];

        [weakSelf presentViewController:weakSelf.alertController animated:true completion:nil];
    } failure:^(NSError *error) {
        [weakSelf.alertController setTitle:@"Failed to Sent Verification Code"];
        [weakSelf.alertController setMessage:error.localizedDescription];

        [weakSelf presentViewController:weakSelf.alertController animated:true completion:nil];
    }];
}

- (IBAction)registerTapped:(UIButton *)sender {
    __weak typeof (self) weakSelf = self;
    [[TuyaSmartUser sharedInstance] registerByEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text password:self.passwordTextField.text code:self.verificationCodeTextField.text success:^{
        [weakSelf.alertController setTitle:@"Registered Successfully"];
        [weakSelf.alertController setMessage:@"Please navigate back to login your account."];
        
        [weakSelf presentViewController:weakSelf.alertController animated:true completion:nil];
    } failure:^(NSError *error) {
        [weakSelf.alertController setTitle:@"Failed to Register"];
        [weakSelf.alertController setMessage:error.localizedDescription];

        [weakSelf presentViewController:weakSelf.alertController animated:true completion:nil];
    }];
}

@end
