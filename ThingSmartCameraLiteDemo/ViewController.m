//
//  ViewController.m
//  ThingSmartCameraLiteDemo
//
//  Created by MokZF on 2025/1/14.
//

#import "ViewController.h"
#import "ThingCameraLitePreviewViewController.h"
#import "ThingCameraLiteCloudViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>


@interface ViewController ()

@property (nonatomic, strong) UIButton *previewBtn;
@property (nonatomic, strong) UIButton *cloudBtn;
@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, copy) NSString *visualToken;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"ThingSmartCameraLite";
    self.view.backgroundColor = [UIColor grayColor];

    [self _viewInit];
}

- (void)_viewInit {
    CGFloat sw = CGRectGetWidth(self.view.frame) - 250;
    if (!self.loginBtn) {
        self.loginBtn = [UIButton new];
        [self.loginBtn setTitle:@"Login" forState:UIControlStateNormal];
        [self.loginBtn addTarget:self action:@selector(_loginAction) forControlEvents:UIControlEventTouchUpInside];
        [self.loginBtn setBackgroundColor:[UIColor redColor]];
        [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.loginBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        self.loginBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.loginBtn];
        
        self.loginBtn.frame = CGRectMake(0, 0, sw, 60);
        self.loginBtn.center = CGPointMake(self.view.center.x, self.view.center.y - 160);
    }

    if (!self.previewBtn) {
        self.previewBtn = [UIButton new];
        [self.previewBtn setTitle:@"Preview" forState:UIControlStateNormal];
        [self.previewBtn addTarget:self action:@selector(_previewAction) forControlEvents:UIControlEventTouchUpInside];
        [self.previewBtn setBackgroundColor:[UIColor redColor]];
        [self.previewBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.previewBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        self.previewBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.previewBtn];
        
        self.previewBtn.frame = CGRectMake(0, 0, sw, 60);
        self.previewBtn.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    }
    
    if (!self.cloudBtn) {
        self.cloudBtn = [UIButton new];
        [self.cloudBtn setTitle:@"Cloud" forState:UIControlStateNormal];
        [self.cloudBtn addTarget:self action:@selector(_cloudAction) forControlEvents:UIControlEventTouchUpInside];
        [self.cloudBtn setBackgroundColor:[UIColor redColor]];
        [self.cloudBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.cloudBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.cloudBtn];
        self.cloudBtn.frame = CGRectMake(CGRectGetMinX(self.previewBtn.frame), CGRectGetMaxY(self.previewBtn.frame) + 40, sw, 60);
    }
}

- (void)_loginAction {
    self.visualToken = nil;
    [SVProgressHUD showProgress:1.0 status:@"login..."];
    [self loginUser];
}
- (void)loginUser {
    NSURL *url = [NSURL URLWithString:@"http://8.149.131.137:8081/v1.0/openapi/visual/d/user/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    
    NSDictionary *dic = @{
        @"userName": @"",        // 开发者账户名
        @"password": @"",        // 开发者密码
        @"deviceList": @[                // 需要授权的设备列表
            @{
                @"productKey": testProductKey,    // 设备产品Key
                @"deviceName": testDeviceName            // 设备名称
            }
        ]
    };

    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
    if (error) {
        NSLog(@"Error serializing JSON: %@", error.localizedDescription);
        [SVProgressHUD showErrorWithStatus:@"Login Fail"];
        return;
    }
    
    [request setHTTPBody:bodyData];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [SVProgressHUD showErrorWithStatus:@"Login Fail"];
            return;
        }
        
        if (data) {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                NSLog(@"Error parsing response: %@", error.localizedDescription);
            } else {
                NSLog(@"Response: %@", jsonResponse);
                if ([jsonResponse.allKeys containsObject:@"data"]) {
                    NSDictionary *datas = jsonResponse[@"data"];
                    NSArray *tokenList = datas[@"deviceVisualTokenList"];
                    for (NSDictionary *subDic in tokenList) {
                        if ([subDic.allKeys containsObject:@"deviceName"] && [subDic.allKeys containsObject:@"productKey"] && [subDic.allKeys containsObject:@"visualToken"]) {
                            NSString *deviceName = subDic[@"deviceName"];
                            NSString *productKey = subDic[@"productKey"];
                            NSString *visualToken = subDic[@"visualToken"];
                            
                            if ([deviceName isEqualToString:testDeviceName] && [productKey isEqualToString:testProductKey] && visualToken.length > 0) {
                                self.visualToken = visualToken;
                                break;
                            }
                        }
                    }
                    [SVProgressHUD showSuccessWithStatus:@"Login Success"];
                }
            }
        }else {
            [SVProgressHUD showErrorWithStatus:@"Login Fail"];
        }
    }];
    
    // 启动请求
    [dataTask resume];
}


- (void)_previewAction {
    if (!_visualToken) {
        [SVProgressHUD showErrorWithStatus:@"Place Login first"];
        return;
    }
    ThingCameraLitePreviewViewController *previewVC = [[ThingCameraLitePreviewViewController alloc] initCameraLitePreviewControllerWithToken:self.visualToken];
    [self.navigationController pushViewController:previewVC animated:YES];
}

- (void)_cloudAction {
    if (!_visualToken) {
        [SVProgressHUD showErrorWithStatus:@"Place Login first"];
        return;
    }
    ThingCameraLiteCloudViewController *cloudVC = [[ThingCameraLiteCloudViewController alloc] initCameraLiteCloudViewController:self.visualToken];
    [self.navigationController pushViewController:cloudVC animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
