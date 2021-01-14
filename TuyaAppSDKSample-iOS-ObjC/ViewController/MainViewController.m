//
//  MainViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "MainViewController.h"
#import "UIButton+Extensions.h"

@interface MainViewController ()
// MARK: - IBOutlet
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureView];
}

- (void)configureView {
    [self.loginButton roundCorner];
    [self.registerButton roundCorner];
}

@end
