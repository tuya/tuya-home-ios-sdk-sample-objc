//
//  LoginTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "LoginTableViewController.h"

@interface LoginTableViewController ()

@property (nonatomic, strong) UIAlertController *alertController;

@property (weak, nonatomic) IBOutlet UITextField *countryCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [self.alertController addAction:action];
}

#pragma mark - IBAction

- (IBAction)loginTapped:(UIButton *)sender {
    __weak typeof (self) weakSelf = self;
    [[TuyaSmartUser sharedInstance] loginByEmail:self.countryCodeTextField.text email:self.emailAddressTextField.text password:self.passwordTextField.text success:^{
        [weakSelf.alertController setTitle:@"Successfully Logged"];
        [weakSelf.alertController setMessage:@"Please navigate back."];

        [weakSelf presentViewController:weakSelf.alertController animated:true completion:nil];
    } failure:^(NSError *error) {
        [weakSelf.alertController setTitle:@"Failed to Login"];
        [weakSelf.alertController setMessage:error.localizedDescription];

        [weakSelf presentViewController:weakSelf.alertController animated:true completion:nil];
    }];
}

@end
