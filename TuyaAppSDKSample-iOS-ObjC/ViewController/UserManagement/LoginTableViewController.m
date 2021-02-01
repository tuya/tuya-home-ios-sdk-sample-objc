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

@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - IBAction

- (IBAction)login:(UIButton *)sender {
    [[TuyaSmartUser sharedInstance] loginByEmail:self.countryCodeTextField.text email:self.accountTextField.text password:self.passwordTextField.text success:^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TuyaSmartMain" bundle:nil];
        UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Login" message:error.localizedDescription];
    }];
}

@end
