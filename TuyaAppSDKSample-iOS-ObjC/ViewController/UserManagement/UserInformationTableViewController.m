//
//  UserInformationTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "UserInformationTableViewController.h"

@interface UserInformationTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryCodeDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeZoneDetailLabel;

@end

@implementation UserInformationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self presentUserInformation];
}

- (void)presentUserInformation {
    [self.userNameDetailLabel setText:[[TuyaSmartUser sharedInstance] userName]];
    [self.phoneNumberDetailLabel setText:[[TuyaSmartUser sharedInstance] phoneNumber]];
    [self.emailAddressDetailLabel setText:[[TuyaSmartUser sharedInstance] email]];
    [self.countryCodeDetailLabel setText:[[TuyaSmartUser sharedInstance] countryCode]];
    [self.timeZoneDetailLabel setText:[[TuyaSmartUser sharedInstance] timezoneId]];
}

@end
