//
//  NewHomeTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "NewHomeTableViewController.h"
#import "Alert.h"

@interface NewHomeTableViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *homeNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;


@property(strong, nonatomic) TuyaSmartHomeManager *homeManager;
@property(strong, nonatomic) CLLocationManager *locationManager;
@property(assign, nonatomic) double longitude;
@property(assign, nonatomic) double latitude;
@end

@implementation NewHomeTableViewController

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
}
- (IBAction)createTapped:(id)sender {
    NSString *homeName = self.homeNameTextField.text;
    NSString *geoName = self.cityTextField.text;
    
    [self.homeManager addHomeWithName:homeName geoName:geoName rooms:@[@""] latitude:self.latitude longitude:self.longitude success:^(long long result) {
        [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"Success" message:@"Successfully added new home."];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"Failed to Add New Home" message:error.localizedDescription];
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

- (TuyaSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[TuyaSmartHomeManager alloc] init];
    }
    return _homeManager;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}
@end
