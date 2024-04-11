//
//  AppDelegate.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import "AppDelegate.h"
#import "AppKey.h"
#import "SVProgressHUD.h"

#import "CameraDoorbellManager.h"

#import <UserNotifications/UserNotifications.h>

#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import <ThingSmartCallChannelKit/ThingSmartCallChannelKit.h>

#import "NSURL+DemoQuery.h"

#if __has_include(<ThingSmartLogger/ThingLogSDK.h>)
#import <ThingSmartLogger/ThingLogSDK.h>
#define kOfflineLogEnable 1
#else
#define kOfflineLogEnable 0
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#if kOfflineLogEnable
    [ThingLogSDK startLog];
       // print log path
    NSLog(@"[logPath]=%@", [ThingLogSDK logPath]);
#endif
    
    // Initialize ThingSmartSDK
    [[ThingSmartSDK sharedInstance] startWithAppKey:APP_KEY secretKey:APP_SECRET_KEY];
    
    // Doorbell Observer. If you have a doorbell device
    [[CameraDoorbellManager sharedInstance] addDoorbellObserver];

    // Enable debug mode, which allows you to see logs.
    #ifdef DEBUG
    [[ThingSmartSDK sharedInstance] setDebugMode:YES];
    [[ThingSmartCameraSDK sharedInstance] setDebugMode:YES];
    #else
    #endif
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:2];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (@available(iOS 13, *)) {
        // Will go into scene delegate
    } else {
        if ([ThingSmartUser sharedInstance].isLogin) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"ThingSmartMain" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            self.window.rootViewController = nav;
        } else {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *nav = [mainStoryboard instantiateInitialViewController];
            self.window.rootViewController = nav;
        }
    }
    
    [[UIApplication sharedApplication] delegate].window = self.window;
    [self.window makeKeyAndVisible];
        
    return YES;
}


- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSDictionary *userInfo = response.notification.request.content.userInfo;
        if (userInfo) {
            [self handleRemoteNotificationWithHigherVersion:userInfo];
        }
    }else {
        //本地通知处理
        
    }
    completionHandler();
}

- (void)handleRemoteNotificationWithHigherVersion:(NSDictionary *)userInfo {
    NSString *link = [userInfo objectForKey:@"link"];
    NSNumber *ts = [userInfo objectForKey:@"ts"];
    NSNumber *voipEnable = [userInfo objectForKey:@"voipEnable"];
    if ([link isKindOfClass:NSString.class] && link.length > 0) {
        NSURL *url = [NSURL URLWithString:link];
        NSDictionary *info = [url demo_queryDictionary];
        if (info) {
            if ([link containsString:@"://rtcCall"]) {
                if ([url.host isEqualToString:@"rtcCall"]) {
                    //解析url中的参数
                    NSString *param = info[@"param"];
                    if (![param isKindOfClass:NSString.class]) {
                        return;
                    }
                    NSError *error;
                    NSData *jsonData = [param dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
                    if (error == nil) {
                        return;
                    }
                    
                    if (dic == nil && ![dic isKindOfClass:NSDictionary.class]) {
                        return;
                    }
                    
                    NSMutableDictionary *map = [dic mutableCopy];
                    if (voipEnable) [map setObject:voipEnable forKey:@"voipEnable"];

                    [ThingSmartCallChannel.sharedInstance handlePushMessage:map];

                    return;
                }

            } else if (ts && [link containsString:@"videoCall"]) {
                NSMutableDictionary *tempInfo = [NSMutableDictionary dictionaryWithDictionary:info];
                if (voipEnable) [tempInfo setObject:voipEnable forKey:@"voipEnable"];
                NSInteger time = [ts integerValue] / 1000;
                [tempInfo setObject:@(time) forKey:@"time"];
                [ThingSmartDoorBellManager.sharedInstance generateCall:tempInfo.copy];
            }
        }
    }
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
