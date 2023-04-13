//
//  SweeperMsgControllerViewController.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2022 Tuya Inc. (https://developer.tuya.com/)

#import "SweeperMsgControllerViewController.h"
//#import <TuyaSmartSweeperKit/TuyaSmartSweeperDevice.h>
//#import <TuyaSmartSweeperKit/TuyaSmartSweeperRecordDetail.h>
//#import <TuyaSmartSweeperKit/TuyaSmartSweeperRecordList.h>
#import <ThingFoundationKit/NSData+ThingStringEncoding.h>
#import <ThingFoundationKit/NSString+ThingHex.h>

@interface SweeperMsgControllerViewController ()<ThingSmartHomeDelegate,UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) ThingSmartHome *home;
@property (strong, nonatomic) NSArray *devicelist;///设备列表
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *datalist;///tableview数据源
//@property (strong, nonatomic) TuyaSmartSweeperDevice *sweeperDev;
@property (strong, nonatomic) NSString* subRecordId;
@property (strong, nonatomic) NSString* recordId;

@end

@implementation SweeperMsgControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ///Init view.
    self.title = @"Sweeper";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"swepper-action-cell"];
    
    ///Init data
    self.datalist = @[
        @"[惯导]查询最新一次清扫记录",
        @"[惯导]历史清扫记录列表",
        @"[惯导]清扫记录详情",
        @"[惯导]删除历史清扫记录",
        @"[激光]完善中",
    ];
//    self.sweeperDev = [TuyaSmartSweeperDevice new];
    
    ///Network
    if ([Home getCurrentHome]) {
        self.home = [ThingSmartHome homeWithHomeId:[Home getCurrentHome].homeId];
        self.home.delegate = self;
        self.devicelist = self.home.deviceList;
        NSLog(@">>>: %@", self.devicelist);
        [self updateHomeDetail];
    }
}

- (void)updateHomeDetail {
    [self.home getHomeDataWithSuccess:^(ThingSmartHomeModel *homeModel) {
        self.devicelist = self.home.deviceList;
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark -TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datalist.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"swepper-action-cell" forIndexPath:indexPath];
    cell.textLabel.text = self.datalist[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartDeviceModel *model = [self.devicelist firstObject];
    switch (indexPath.row) {
//        case 0: {
//            //查询最新一次清扫记录
//            [self.sweeperDev queryLatestCleanRecord:model.devId start:@"" size:100 complete:^(TuyaSmartSweeperRecordDetail * _Nonnull model, NSError * _Nonnull error) {
//                NSLog(@">>>: %@", model);
//                self.subRecordId = model.subRecordId;
//            }];
//        }
//            break;
//        case 1:
//        {
//            //历史清扫记录列表
//            [self.sweeperDev getHistoryCleanRecordList:model.devId offset:0 limit:50  startTime:0 endTime:0 complete:^(NSArray<TuyaSmartSweeperRecordList *> * _Nonnull list, NSError * _Nonnull error) {
//                NSLog(@"list: %@,num: %lu", list, (unsigned long)list.count);
//                if(list && list.count > 0) {
//                    self.recordId = list.firstObject.recordId;
//                    NSString *value = list.firstObject.value;
//                    NSData *data = [[NSData alloc]initWithBase64EncodedString:value options:0];
//                    NSString *decodedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@">>>: %s", data.bytes);
//                    NSLog(@"base64解密后字段：%@", decodedString);
//                }
//                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"清扫记录列表 %ld 条", list.count]];
//
//                NSString * subrecordId = [TuyaSmartSweeperRecordList subRecordIdObtainFromValue:@"20210826052504804100145"];
//                NSLog(@"Value策略提取subrecordId：%@", subrecordId);
//            }];
//        }
//            break;
//        case 2:
//        {
//            if([self.subRecordId isEqualToString:@""] || !self.subRecordId){
//                [SVProgressHUD showErrorWithStatus:@"subRecordId 为空，先请求：查询最新一次清扫记录"];
//                return;
//            }
//            //清扫记录详情
//            [self.sweeperDev getCleanRecordDetail:model.devId subRecordId:self.subRecordId.integerValue start:@"" size:50 complete:^(TuyaSmartSweeperRecordDetail * _Nonnull model, NSError * _Nonnull error) {
//                NSLog(@">>>: %@", model);
//            }];
//        }
//            break;
//        case 3:
//        {
//            if([self.recordId isEqualToString:@""] || !self.recordId){
//                [SVProgressHUD showErrorWithStatus:@"recordId 为空，先请求：历史清扫记录列表"];
//                return;
//            }
//            //删除历史清扫记录
//            [self.sweeperDev deleteHistoryCleanRecord:model.devId recordId:self.recordId complete:^(BOOL success, NSError * _Nonnull error) {
//                NSLog(@">>>: %@", @(success));
//                if(success){
//                    [SVProgressHUD showSuccessWithStatus:@"删除历史清扫记录成功"];
//                }else {
//                    [SVProgressHUD showSuccessWithStatus:@"删除历史清扫记录失败"];
//                }
//            }];
//        }
//            break;
//
//        default:
//            break;
    }
}

@end
