//
//  LoginTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "LoginTableViewController.h"
#import "Alert.h"

@interface LoginTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - IBAction

- (IBAction)loginTapped:(UIButton *)sender {
    [[TuyaSmartUser sharedInstance] loginByEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text password:self.passwordTextField.text success:^{
        [Alert showBasicAlertOnVC:self withTitle:@"Successfully Logged" message:@"Please navigate back."];

    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Login" message:error.localizedDescription];
    }];
}

@end
