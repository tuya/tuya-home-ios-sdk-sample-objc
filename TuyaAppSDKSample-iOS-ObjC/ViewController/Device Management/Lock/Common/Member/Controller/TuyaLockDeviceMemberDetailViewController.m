//
//  TuyaLockDeviceMemberDetailViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "TuyaLockDeviceMemberDetailViewController.h"
#import "TuyaLockDeviceMemberDetailView.h"
#import "TuyaLockDeviceMemberUpdateTimeViewController.h"
#import "TuyaLockDeviceUnlockModeListViewController.h"
#import "Alert.h"

@interface TuyaLockDeviceMemberDetailViewController ()<TuyaLockDeviceMemberDetailViewDelegate>

@property (nonatomic, strong) TuyaLockDeviceMemberDetailView *detailView;

@end

@implementation TuyaLockDeviceMemberDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailView = [[TuyaLockDeviceMemberDetailView alloc] initWithFrame:self.view.bounds];
    self.detailView.delegate = self;
    [self.view addSubview:self.detailView];
    [self.detailView reloadData:self.dataSource];
    
    [self reloadData];
}

- (void)reloadData{
    WEAKSELF_ThingSDK
    if ([self isBLEDevice]){
        [self.bleDevice getProBoundUnlockOpModeListWithDevId:self.bleDevice.deviceModel.devId
                                                      userId:[self.dataSource[@"userId"] stringValue]
                                                     success:^(id result) {
            int cardCount = 0,msgCount = 0,fingerCount = 0;
            NSArray *unlockDetail = result[@"unlockDetail"];
            for (int i = 0; i < unlockDetail.count; i++) {
                NSDictionary *dic = [unlockDetail objectAtIndex:i];
                int dpId = [dic[@"dpId"] intValue];
                NSArray *unlockList = (NSArray *)dic[@"unlockList"];
                //指纹开锁
                if (dpId == 12){
                    fingerCount = (int)unlockList.count;
                }
                //密码开锁
                else if (dpId == 13){
                    msgCount = (int)unlockList.count;
                }
                //门卡开锁
                else if (dpId == 15){
                    cardCount = (int)unlockList.count;
                }
            }
            
            [weakSelf_ThingSDK.detailView reloadMsgCount:msgCount cardCount:cardCount fingerCount:fingerCount];
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"获取成员已绑定的解锁方式列表失败" message:error.localizedDescription];
        }];
    }
    
    if ([self isZigbeeDevice]){
        [self.zigbeeDevice getMemberOpmodeListWithDevId:self.devId userId:[self.dataSource[@"userId"] stringValue] success:^(NSArray<ThingSmartZigbeeLockOpmodeModel *> * _Nonnull models) {
            int cardCount = 0,msgCount = 0,fingerCount = 0;
            for (ThingSmartZigbeeLockOpmodeModel *model in models) {
                if ([model.opmode isEqualToString:@"1"]){
                    fingerCount ++;
                }
                else if ([model.opmode isEqualToString:@"2"]){
                    msgCount++;
                }
                else if ([model.opmode isEqualToString:@"5"]){
                    cardCount++;
                }
                
                [weakSelf_ThingSDK.detailView reloadMsgCount:msgCount cardCount:cardCount fingerCount:fingerCount];
            }
        } failure:^(NSError *error) {
            [Alert showBasicAlertOnVC:weakSelf_ThingSDK withTitle:@"解锁方式列表(Zigbee)失败" message:error.localizedDescription];
        }];
    }
}

#pragma mark - TuyaLockDeviceMemberDetailViewDelegate

- (void)addUnlockMode:(int)type{
    TuyaLockDeviceUnlockModeListViewController *listVC = [[TuyaLockDeviceUnlockModeListViewController alloc] init];
    listVC.devId = self.devId;
    listVC.unlockModeType = type;
    listVC.memberId = [self.dataSource[@"userId"] stringValue];
    listVC.userType = [self.dataSource[@"userType"] intValue];
    listVC.lockUserId = [self.dataSource[@"lockUserId"] intValue];
    [self.navigationController pushViewController:listVC animated:YES];
}

- (void)gotoUpdateVC:(NSDictionary *)data{
    if ([self isBLEDevice]){
        TuyaLockDeviceMemberUpdateTimeViewController *vc = [[TuyaLockDeviceMemberUpdateTimeViewController alloc] init];
        vc.dataSource = data;
        vc.devId = self.devId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
