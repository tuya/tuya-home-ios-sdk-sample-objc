//
//  EditHomeTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "EditHomeTableViewController.h"
#import "Alert.h"

@interface EditHomeTableViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *homeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;

@property(strong, nonatomic) CLLocationManager *locationManager;
@property(assign, nonatomic) double longitude;
@property(assign, nonatomic) double latitude;
@end

@implementation EditHomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.locationManager requestWhenInUseAuthorization];
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingHeading];
    } else {
        [Alert showBasicAlertOnVC:self withTitle:@"Cannot Access Location" message:@"Please make sure if the location access is enabled for the app."];
    }
    
    if (!self.home) {
        return;
    }
    
    self.homeNameTextField.text = self.home.homeModel.name;
    self.cityTextField.text = self.home.homeModel.geoName;
}

- (IBAction)doneTapped:(id)sender {
    NSString *homeName = self.homeNameTextField.text;
    NSString *geoName = self.cityTextField.text;
    
    [self.home updateHomeInfoWithName:homeName geoName:geoName latitude:self.latitude longitude:self.longitude success:^{
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Update Home" message:error.localizedDescription];
    }];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = manager.location;
    if (!location) {
        return;
    }
    
    self.longitude = location.coordinate.longitude;
    self.latitude = location.coordinate.latitude;
}


- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}

@end
