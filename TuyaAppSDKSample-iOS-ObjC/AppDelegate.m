//
//  AppDelegate.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "AppDelegate.h"
#import "AppKey.h"
#import "SVProgressHUD.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Initialize TuyaSmartSDK
    [[TuyaSmartSDK sharedInstance] startWithAppKey:APP_KEY secretKey:APP_SECRET_KEY];
    
    // Enable debug mode, which allows you to see logs.
    #ifdef DEBUG
    [[TuyaSmartSDK sharedInstance] setDebugMode:YES];
    #else
    #endif
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if (@available(iOS 13, *)) {
        // Will go into scene delegate
    } else {
        if ([TuyaSmartUser sharedInstance].isLogin) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TuyaSmartMain" bundle:nil];
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
