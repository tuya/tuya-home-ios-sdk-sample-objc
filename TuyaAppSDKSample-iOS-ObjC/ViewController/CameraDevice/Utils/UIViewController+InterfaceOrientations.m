//
//  UIViewController+InterfaceOrientations.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "UIViewController+InterfaceOrientations.h"

@implementation UIViewController (InterfaceOrientations)

- (void)demo_rotateWindowIfNeed {
    UIInterfaceOrientation windowOri = [UIApplication sharedApplication].statusBarOrientation;
    
    if ([UIApplication sharedApplication].keyWindow.rootViewController == nil // rootVC还没加载出来
        || windowOri == UIInterfaceOrientationUnknown // 未知方向
        || ([self respondsToSelector:@selector(shouldAutorotate)] && ![self shouldAutorotate]) // 明确禁止自转
        || ![[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)] // 无此方法
        ) {
        return;
    }

    UIInterfaceOrientation targetOri = (int)[self demo_preferredOrientationForWindowRotation];
    if (targetOri == UIInterfaceOrientationUnknown || targetOri == windowOri) {
        return;
    }
 
    if (@available(iOS 16.0, *)) {
        @try {
            [self setNeedsUpdateOfSupportedInterfaceOrientations];
         
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            UIWindowScene *windowScene = (UIWindowScene *)array.firstObject;
            
            UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc]initWithInterfaceOrientations:[self supportedInterfaceOrientations]];
            [windowScene requestGeometryUpdateWithPreferences:geometryPreferences errorHandler:^(NSError * _Nonnull error) {
                NSLog(@"error=%@",error);
            }];
        } @catch (NSException *exception) {
            //异常处理
        } @finally {
            //异常处理
        }
    } else {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int ori = (int)targetOri;
        [invocation setArgument:&ori atIndex:2];
        [invocation invoke];
    }
}

- (UIInterfaceOrientation)demo_preferredOrientationForWindowRotation {
    UIInterfaceOrientationMask oriMask = self.supportedInterfaceOrientations;
    if (oriMask & UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait;
    } else if (oriMask & UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft;
    } else if (oriMask & UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight;
    } else if (oriMask & UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown;
    }
    return UIInterfaceOrientationUnknown;
}

@end
