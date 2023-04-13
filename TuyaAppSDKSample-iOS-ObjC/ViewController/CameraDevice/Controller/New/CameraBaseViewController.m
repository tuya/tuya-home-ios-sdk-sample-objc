//
//  CameraBaseViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraBaseViewController.h"

@interface CameraBaseViewController ()

@end

@implementation CameraBaseViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showAlertWithMessage:(NSString *)msg {
    [self showAlertWithMessage:msg complete:NULL];
}

- (void)showAlertWithMessage:(NSString *)msg complete:(void(^)(void))complete {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"ipc_settings_ok", @"IPCLocalizable", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !complete?:complete();
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showAlertWithMessage:(NSString *)msg cancelHandler:(void(^)(void))cancelHandler confirmHandler:(void(^)(void))confirmHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"cancel", @"IPCLocalizable", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !cancelHandler?:cancelHandler();
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"confirm", @"IPCLocalizable", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        !confirmHandler?:confirmHandler();
    }];
    [alert addAction:confirmAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showTip:(NSString *)tip {
    [SVProgressHUD showInfoWithStatus:tip];
}

- (void)showSuccessTip:(NSString *)tip {
    [SVProgressHUD showSuccessWithStatus:tip];
}

- (void)showErrorTip:(NSString *)tip {
    [SVProgressHUD showErrorWithStatus:tip];
}

- (void)showProgress:(float)progress tip:(NSString *)tip {
    [SVProgressHUD showProgress:progress status:tip];
}

- (void)dismissTip {
    [SVProgressHUD dismiss];
}

@end
