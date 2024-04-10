//
//  CameraCallInterfaceManager.m
//  ThingCallModule
//
//  Created by thing on 2023/3/6.
//

#import "CameraCallInterfaceManager.h"

#import "CameraCallViewController.h"
#import "UIView+CameraAdditions.h"

@interface CameraCallInterfaceManager ()
@property (nonatomic, strong) UIViewController<ThingSmartCallInterface> *currentVc;
@end

@implementation CameraCallInterfaceManager

@synthesize identifier;


#pragma mark - ThingCallInterfaceManager

- (void)presentInterface:(id<ThingSmartCallInterface>)interface completion:(ThingCallInterfaceManagerCompletion)completion {
    if (interface == nil) {
        !completion ?: completion();
        return;
    }
    UIViewController<ThingSmartCallInterface> *tempInterface = (UIViewController<ThingSmartCallInterface> *)interface;
    dispatch_async(dispatch_get_main_queue(), ^{
        tempInterface.modalPresentationStyle = UIModalPresentationFullScreen;

        if (self.currentVc) {
            [self.currentVc dismissViewControllerAnimated:NO completion:nil];
            [tp_topMostViewController() presentViewController:tempInterface animated:NO completion:completion];
        }else{
            [tp_topMostViewController() presentViewController:tempInterface animated:YES completion:completion];
        }
        self.currentVc = tempInterface;
    });
}

- (void)dismissInterface:(id<ThingSmartCallInterface>)interface completion:(ThingCallInterfaceManagerCompletion)completion {
    UIViewController<ThingSmartCallInterface> *tempInterface = (UIViewController<ThingSmartCallInterface> *)interface;
    if (tempInterface != self.currentVc) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentVc dismissViewControllerAnimated:YES completion:completion];
        self.currentVc = nil;
    });
}

- (id<ThingSmartCallInterface>)generateCallInterfaceWithCall:(id<ThingSmartCallProtocol>)call {
    CameraCallViewController *callViewController = [[CameraCallViewController alloc] initWithCall:call];
    return callViewController;
}

@end
