//
//  HomeDetailTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "HomeDetailTableViewController.h"
#import "EditHomeTableViewController.h"
#import "Alert.h"
#import "Home.h"

@interface HomeDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *homeIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherConditionLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation HomeDetailTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    TuyaSmartHomeModel *model = self.homeModel;
    self.home = [TuyaSmartHome homeWithHomeId:model.homeId];
    
    self.homeIDLabel.text = [NSString stringWithFormat:@"%lld", model.homeId];
    self.homeNameLabel.text = model.name;
    self.cityLabel.text = model.geoName;
    
    [self.home getHomeWeatherSketchWithSuccess:^(TuyaSmartWeatherSketchModel *weatherModel) {
        self.weatherConditionLabel.text = weatherModel.condition;
        self.temperatureLabel.text = weatherModel.temp;
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"Failed to Fetch Weather" message:error.localizedDescription];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)dismiss:(UIButton *)sender {
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Dismiss This Home", @"") message:NSLocalizedString(@"You're going to dismiss this home.", @"") preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", @"Dismiss a home.") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.home dismissHomeWithSuccess:^{
            [Home setCurrentHome:[TuyaSmartHomeModel new]];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"Failed to Dismiss" message:error.localizedDescription];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    alertViewController.popoverPresentationController.sourceView = sender;
    [alertViewController addAction:action];
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 0) {
        [self dismiss:self.dismissButton];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (![segue.identifier isEqualToString:@"edit-home"]) {
        return;
    }
    
    if ([segue.destinationViewController isKindOfClass:[EditHomeTableViewController class]]) {
        ((EditHomeTableViewController*)(segue.destinationViewController)).home = self.home;
    }
}
@end
