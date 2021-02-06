//
//  DeviceDetailTableViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "DeviceDetailTableViewController.h"
#import "Alert.h"

@interface DeviceDetailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *IPAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *MACAddressLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeDeviceButton;
@end

@implementation DeviceDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.deviceIDLabel.text = self.device.deviceModel.devId;
    self.IPAddressLabel.text = self.device.deviceModel.ip;
    self.MACAddressLabel.text = self.device.deviceModel.mac;
}

- (IBAction)removeDeviceTapped:(id)sender {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Remove the Device?", @"") message:NSLocalizedString(@"If you choose to remove the device, you'll no long hold control over this device.", @"") preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Remove", @"Perform remove device action") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (self.navigationController.viewControllers.count >= 3) {
            [self.device remove:^{
                UIViewController *ctrl = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 3];
                [self.navigationController popToViewController:ctrl animated:YES];
            } failure:^(NSError *error) {
                [Alert showBasicAlertOnVC:[UIApplication sharedApplication].keyWindow.rootViewController withTitle:@"Failed to Remove" message:error.localizedDescription];
            }];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:nil];
    [alertViewController addAction:removeAction];
    [alertViewController addAction:cancelAction];
    self.popoverPresentationController.sourceView = sender;
    
    [self.navigationController presentViewController:alertViewController animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        [self removeDeviceTapped:self.removeDeviceButton];
    }
}
@end
