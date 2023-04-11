//
//  MainTableViewController.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "MainTableViewController.h"
#import "Alert.h"
#import "Home.h"

@interface MainTableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UILabel *currentHomeLabel;

@property (strong, nonatomic) ThingSmartHomeManager *homeManager;
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
    WEAKSELF_ThingSDK
    [self.homeManager getHomeListWithSuccess:^(NSArray<ThingSmartHomeModel *> *homes) {
        if (homes && homes.count > 0) {
            if (![Home getCurrentHome]) {
                [Home setCurrentHome:homes.firstObject];
                weakSelf_ThingSDK.currentHomeLabel.text = [Home getCurrentHome].name;
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - IBAction

- (IBAction)logoutTapped:(UIButton *)sender {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"You're going to log out this account.", @"User tapped the logout button.") preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[ThingSmartUser sharedInstance] loginOut:^{
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:self withTitle:@"Failed to Logout." message:error.localizedDescription];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
    
    alertViewController.popoverPresentationController.sourceView = sender;
    [alertViewController addAction:logoutAction];
    [alertViewController addAction:cancelAction];
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self logoutTapped:self.logoutButton];
    }
}

- (ThingSmartHomeManager *)homeManager {
    if (!_homeManager) {
        _homeManager = [[ThingSmartHomeManager alloc] init];
    }
    return _homeManager;
}

@end
