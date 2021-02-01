//
//  MainTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "MainTableViewController.h"
#import "Alert.h"
#import "Home.h"

@interface MainTableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *currentHomeLabel;

@property (strong, nonatomic) TuyaSmartHomeManager *homeManager;
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initiateCurrentHome];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([Home getCurrentHome]) {
        self.currentHomeLabel.text = [Home getCurrentHome].name;
    }
}

- (void)initiateCurrentHome {
    [self.homeManager getHomeListWithSuccess:^(NSArray<TuyaSmartHomeModel *> *homes) {
        if (homes && homes.count > 0) {
            [Home setCurrentHome:homes.firstObject];
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - IBAction

- (IBAction)logoutTapped:(UIButton *)sender {
    [[TuyaSmartUser sharedInstance] loginOut:^{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
        [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        [Alert showBasicAlertOnVC:nav withTitle:@"Successfully Logged Out" message:@"Most of the functions will be unusable."];
    } failure:^(NSError *error) {
        [Alert showBasicAlertOnVC:self withTitle:@"Failed to Logout." message:error.localizedDescription];
    }];
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (TuyaSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[TuyaSmartHomeManager alloc] init];
    }
    return _homeManager;
}

@end
