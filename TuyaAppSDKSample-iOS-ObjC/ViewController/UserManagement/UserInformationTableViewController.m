//
//  UserInformationTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "UserInformationTableViewController.h"

@interface UserInformationTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeZoneLabel;

@end

@implementation UserInformationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self presentUserInformation];
}

- (void)presentUserInformation {
    [self.userNameLabel setText:[[TuyaSmartUser sharedInstance] userName]];
    [self.phoneNumberLabel setText:[[TuyaSmartUser sharedInstance] phoneNumber]];
    [self.emailAddressLabel setText:[[TuyaSmartUser sharedInstance] email]];
    [self.countryCodeLabel setText:[[TuyaSmartUser sharedInstance] countryCode]];
    [self.timeZoneLabel setText:[[TuyaSmartUser sharedInstance] timezoneId]];
}

@end
