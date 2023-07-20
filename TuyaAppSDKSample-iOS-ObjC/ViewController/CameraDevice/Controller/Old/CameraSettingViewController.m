//
//  CameraSettingViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraSettingViewController.h"
#import "CameraSwitchCell.h"
#import "CameraSDCardViewController.h"
#import "CameraViewConstants.h"
#import <YYModel/YYModel.h>

#define kTitle  @"title"
#define kValue  @"value"
#define kAction @"action"
#define kArrow  @"arrow"
#define kSwitch @"switch"

static ThingSmartCameraDPKey const kOutOffBoundsDPCode = @"out_off_bounds";
static ThingSmartCameraDPKey const kOutOffBoundsSetDPCode = @"out_off_bounds_set";


@interface CameraSettingViewController ()<ThingSmartCameraDPObserver, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL indicatorOn;

@property (nonatomic, assign) BOOL flipOn;

@property (nonatomic, assign) BOOL osdOn;

@property (nonatomic, assign) BOOL privateOn;

@property (nonatomic, strong) ThingSmartCameraNightvision nightvisionState;

@property (nonatomic, strong) ThingSmartCameraPIR pirState;

@property (nonatomic, assign) BOOL motionDetectOn;

@property (nonatomic, assign) BOOL outOffBoundsOn;

@property (nonatomic, strong) ThingSmartCameraMotion motionSensitivity;

@property (nonatomic, assign) BOOL decibelDetectOn;

@property (nonatomic, strong) ThingSmartCameraDecibel decibelSensitivity;

@property (nonatomic, assign) ThingSmartCameraSDCardStatus sdCardStatus;

@property (nonatomic, assign) BOOL sdRecordOn;

@property (nonatomic, strong) ThingSmartCameraRecordMode recordMode;

@property (nonatomic, assign) BOOL batteryLockOn;

@property (nonatomic, strong) ThingSmartCameraPowerMode powerMode;

@property (nonatomic, assign) NSInteger electricity;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) ThingSmartDevice *device;

@end

@implementation CameraSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xE8E9EF);
    self.title = NSLocalizedStringFromTable(@"ipc_panel_button_settings", @"IPCLocalizable", @"");
    [self.dpManager addObserver:self];
//    [self.tableView registerClass:[CameraSwitchCell class] forCellReuseIdentifier:@"switchCell"];
    [self getDeviceInfo];
    [self setupTableFooter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
}

- (NSString *)titleForCenterItem {
    return NSLocalizedStringFromTable(@"ipc_panel_button_settings", @"IPCLocalizable", @"");
}

- (void)setupTableFooter {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 50)];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:NSLocalizedStringFromTable(@"cancel_connect", @"IPCLocalizable", @"") forState:UIControlStateNormal];
    [footerView addSubview:button];
    self.tableView.tableFooterView = footerView;
    [button addTarget:self action:@selector(removeAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeAction {
    __weak typeof(self) weakSelf = self;
    [self.device remove:^{
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"remove device failed:%@", error.localizedDescription]];
    }];
}

- (void)getDeviceInfo {
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicIndicatorDPName]) {
        self.indicatorOn = [[self.dpManager valueForDP:ThingSmartCameraBasicIndicatorDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicFlipDPName]) {
        self.flipOn = [[self.dpManager valueForDP:ThingSmartCameraBasicFlipDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicOSDDPName]) {
        self.osdOn = [[self.dpManager valueForDP:ThingSmartCameraBasicOSDDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicPrivateDPName]) {
        self.privateOn = [[self.dpManager valueForDP:ThingSmartCameraBasicPrivateDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicNightvisionDPName]) {
        self.nightvisionState = [[self.dpManager valueForDP:ThingSmartCameraBasicNightvisionDPName] thingsdk_toString];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicPIRDPName]) {
        self.pirState = [[self.dpManager valueForDP:ThingSmartCameraBasicPIRDPName] thingsdk_toString];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraMotionDetectDPName]) {
        self.motionDetectOn = [[self.dpManager valueForDP:ThingSmartCameraMotionDetectDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDPCode:kOutOffBoundsDPCode]) {
        self.outOffBoundsOn = [[self.dpManager valueForDPCode:kOutOffBoundsDPCode] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraMotionSensitivityDPName]) {
        self.motionSensitivity = [[self.dpManager valueForDP:ThingSmartCameraMotionSensitivityDPName] thingsdk_toString];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraDecibelDetectDPName]) {
        self.decibelDetectOn = [[self.dpManager valueForDP:ThingSmartCameraDecibelDetectDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraDecibelSensitivityDPName]) {
        self.decibelSensitivity = [[self.dpManager valueForDP:ThingSmartCameraDecibelSensitivityDPName] thingsdk_toString];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraSDCardStatusDPName]) {
        self.sdCardStatus = [[self.dpManager valueForDP:ThingSmartCameraSDCardStatusDPName] thingsdk_toInt];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraSDCardRecordDPName]) {
        self.sdRecordOn = [[self.dpManager valueForDP:ThingSmartCameraSDCardRecordDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraRecordModeDPName]) {
        self.recordMode = [[self.dpManager valueForDP:ThingSmartCameraRecordModeDPName] thingsdk_toString];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraWirelessBatteryLockDPName]) {
        self.batteryLockOn = [[self.dpManager valueForDP:ThingSmartCameraWirelessBatteryLockDPName] thingsdk_toBool];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraWirelessPowerModeDPName]) {
        self.powerMode = [[self.dpManager valueForDP:ThingSmartCameraWirelessPowerModeDPName] thingsdk_toString];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraWirelessElectricityDPName]) {
        self.electricity = [[self.dpManager valueForDP:ThingSmartCameraWirelessElectricityDPName] thingsdk_toInt];
    }
    [self reloadData];
}

- (void)reloadData {
    NSMutableArray *dataSource = [NSMutableArray new];
    NSMutableArray *section0 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicIndicatorDPName]) {
        [section0 addObject:@{kTitle:NSLocalizedStringFromTable(@"ipc_basic_status_indicator", @"IPCLocalizable", @""), kValue: @(self.indicatorOn), kAction: @"indicatorAction:", kSwitch: @"1"}];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicFlipDPName]) {
        [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_basic_picture_flip", @"IPCLocalizable", @""), kValue: @(self.flipOn), kAction: @"flipAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicOSDDPName]) {
        [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_basic_osd_watermark", @"IPCLocalizable", @""), kValue: @(self.osdOn), kAction: @"osdAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicPrivateDPName]) {
        [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_basic_hibernate", @"IPCLocalizable", @""), kValue: @(self.privateOn), kAction: @"privateAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicNightvisionDPName]) {
        NSString *text = [self nightvisionText:self.nightvisionState];
        [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_basic_night_vision", @"IPCLocalizable", @""), kValue: text, kAction: @"nightvisionAction", kArrow: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraBasicPIRDPName]) {
        NSString *text = [self pirText:self.pirState];
        [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_pir_switch", @"IPCLocalizable", @""), kValue: text, kAction: @"pirAction", kArrow: @"1"}];
    }
    
    if (section0.count > 0) {
        [dataSource addObject:@{kTitle:NSLocalizedStringFromTable(@"ipc_settings_page_basic_function_txt", @"IPCLocalizable", @""), kValue: section0.copy}];
    }
    
    NSMutableArray *section1 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:ThingSmartCameraMotionDetectDPName]) {
        [section1 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_live_page_cstorage_motion_detected", @"IPCLocalizable", @""), kValue: @(self.motionDetectOn), kAction: @"motionDetectAction:", kSwitch: @"1"}];
    }
    if ([self.dpManager isSupportDPCode:kOutOffBoundsDPCode] && self.motionDetectOn) {
        [section1 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_live_page_cstorage_out_of_bounds", @"IPCLocalizable", @""), kValue: @(self.outOffBoundsOn), kAction: @"outOffBoundsAction:", kSwitch: @"1"}];
    }
    if ([self.dpManager isSupportDP:ThingSmartCameraMotionSensitivityDPName] && self.motionDetectOn) {
        NSString *text = [self motionSensitivityText:self.motionSensitivity];
        [section1 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_motion_sensitivity_settings", @"IPCLocalizable", @""), kValue: text, kAction: @"motionSensitivityAction", kArrow: @"1"}];
    }
    if (section1.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_live_page_cstorage_motion_detected", @"IPCLocalizable", @""), kValue: section1.copy}];
    }
    
    NSMutableArray *section2 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:ThingSmartCameraDecibelDetectDPName]) {
        [section2 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sound_detect_switch", @"IPCLocalizable", @""), kValue: @(self.decibelDetectOn), kAction: @"decibelDetectAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraDecibelSensitivityDPName] && self.decibelDetectOn) {
        NSString *text = [self decibelSensitivityText:self.decibelSensitivity];
        [section2 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_motion_sensitivity_settings", @"IPCLocalizable", @""), kValue: text, kAction: @"decibelSensitivityAction", kArrow: @"1"}];
    }
    if (section2.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sound_detected_switch_settings", @"IPCLocalizable", @""), kValue: section2.copy}];
    }
    
    NSMutableArray *section3 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:ThingSmartCameraSDCardStatusDPName]) {
        NSString *text = [self sdCardStatusText:self.sdCardStatus];
        [section3 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_settings", @"IPCLocalizable", @""), kValue: text, kAction: @"sdCardAction", kArrow: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraSDCardRecordDPName]) {
        [section3 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_record_switch", @"IPCLocalizable", @""), kValue: @(self.sdRecordOn), kAction: @"sdRecordAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraRecordModeDPName]) {
        NSString *text = [self recordModeText:self.recordMode];
        [section3 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_record_mode_settings", @"IPCLocalizable", @""), kValue: text, kAction: @"recordModeAction", kArrow: @"1"}];
    }
    if (section3.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_settings", @"IPCLocalizable", @""), kValue: section3.copy}];
    }
    
    NSMutableArray *section4 = [NSMutableArray new];
    if ([self.dpManager isSupportDP:ThingSmartCameraWirelessBatteryLockDPName]) {
        [section4 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_basic_batterylock", @"IPCLocalizable", @""), kValue: @(self.batteryLockOn), kAction: @"batteryLockAction:", kSwitch: @"1"}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraWirelessPowerModeDPName]) {
        NSString *text = [self powerModeText:self.powerMode];
        [section4 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_electric_power_source", @"IPCLocalizable", @""), kValue: text}];
    }
    
    if ([self.dpManager isSupportDP:ThingSmartCameraWirelessElectricityDPName]) {
        NSString *text = [self electricityText];
        [section4 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_electric_percentage", @"IPCLocalizable", @""), kValue: text}];
    }
    if (section4.count > 0) {
        [dataSource addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_electric_title", @"IPCLocalizable", @""), kValue: section4.copy}];
    }
    self.dataSource = [dataSource copy];
    [self.tableView reloadData];
}

- (void)indicatorAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraBasicIndicatorDPName success:^(id result) {
        weakSelf.indicatorOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)flipAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraBasicFlipDPName success:^(id result) {
        weakSelf.flipOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)osdAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraBasicOSDDPName success:^(id result) {
        weakSelf.osdOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)privateAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraBasicPrivateDPName success:^(id result) {
        weakSelf.privateOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)nightvisionAction {
    NSArray *options = @[@{kTitle: [self nightvisionText:ThingSmartCameraNightvisionAuto],
                           kValue: ThingSmartCameraNightvisionAuto},
                         @{kTitle: [self nightvisionText:ThingSmartCameraNightvisionOn],
                           kValue: ThingSmartCameraNightvisionOn},
                         @{kTitle: [self nightvisionText:ThingSmartCameraNightvisionOff],
                           kValue: ThingSmartCameraNightvisionOff}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:ThingSmartCameraBasicNightvisionDPName success:^(id result) {
            weakSelf.nightvisionState = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)pirAction {
    NSArray *options = @[@{kTitle: [self pirText:ThingSmartCameraPIRStateHigh],
                           kValue: ThingSmartCameraPIRStateHigh},
                         @{kTitle: [self pirText:ThingSmartCameraPIRStateMedium],
                           kValue: ThingSmartCameraPIRStateMedium},
                         @{kTitle: [self pirText:ThingSmartCameraPIRStateLow],
                           kValue: ThingSmartCameraPIRStateLow},
                         @{kTitle: [self pirText:ThingSmartCameraPIRStateOff],
                           kValue: ThingSmartCameraPIRStateOff}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:ThingSmartCameraBasicPIRDPName success:^(id result) {
            weakSelf.pirState = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)motionDetectAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraMotionDetectDPName success:^(id result) {
        weakSelf.motionDetectOn = switchButton.on;
        [weakSelf reloadData];
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)outOffBoundsAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDPCode:kOutOffBoundsDPCode success:^(id result) {
        weakSelf.outOffBoundsOn = switchButton.on;
        [weakSelf reloadData];
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
    if (!switchButton.isOn) {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //2023-05-19 16:25:38.679 [ThingCameraSDK] ThingAVModule::GetDrawParam Port[1] sei:{"agtx":{"time":1684484736883,"chn":0,"key":1,"iva":{"od":[{"obj":{"id":0,"type":1,"twinkle":1,"rect": [46,129,1152,388,2304,401,1382,648,1382,907,1152,907,921,907,921,648],"vel":[0,0],"cat":"PEDESTRIAN"}}]}}}
    [params setValue:@[@2,@10,@50,@30,@100,@31,@60,@50,@81,@92,@50,@70,@21,@87,@40,@50] forKey:@"points"];
    NSString *jsonString = [@[params] yy_modelToJSONString];
    [self.dpManager setValue:jsonString forDPCode:kOutOffBoundsSetDPCode success:^(id result) {
        NSLog(@"%@", result);
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (void)motionSensitivityAction {
    NSArray *options = @[@{kTitle: [self motionSensitivityText:ThingSmartCameraMotionHigh],
                           kValue: ThingSmartCameraMotionHigh},
                         @{kTitle: [self motionSensitivityText:ThingSmartCameraMotionMedium],
                           kValue: ThingSmartCameraMotionMedium},
                         @{kTitle: [self motionSensitivityText:ThingSmartCameraMotionLow],
                           kValue: ThingSmartCameraMotionLow}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:ThingSmartCameraMotionSensitivityDPName success:^(id result) {
            weakSelf.motionSensitivity = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)decibelDetectAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraDecibelDetectDPName success:^(id result) {
        weakSelf.decibelDetectOn = switchButton.on;
        [weakSelf reloadData];
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)decibelSensitivityAction {
    NSArray *options = @[@{kTitle: [self decibelSensitivityText:ThingSmartCameraDecibelHigh],
                           kValue: ThingSmartCameraDecibelHigh},
                         @{kTitle: [self decibelSensitivityText:ThingSmartCameraDecibelLow],
                           kValue: ThingSmartCameraDecibelLow}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        [self.dpManager setValue:result forDP:ThingSmartCameraDecibelSensitivityDPName success:^(id result) {
            weakSelf.decibelSensitivity = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)sdCardAction {
    CameraSDCardViewController *vc = [CameraSDCardViewController new];
    vc.dpManager = self.dpManager;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)sdRecordAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraSDCardRecordDPName success:^(id result) {
        weakSelf.sdRecordOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (void)recordModeAction {
    NSArray *options = @[@{kTitle: [self recordModeText:ThingSmartCameraRecordModeEvent],
                           kValue: ThingSmartCameraRecordModeEvent},
                         @{kTitle: [self recordModeText:ThingSmartCameraRecordModeAlways],
                           kValue: ThingSmartCameraRecordModeAlways}];
    __weak typeof(self) weakSelf = self;
    [self showActionSheet:options selectedHandler:^(id result) {
        
        [self.dpManager setValue:result forDP:ThingSmartCameraRecordModeDPName success:^(id result) {
            weakSelf.recordMode = result;
            [weakSelf reloadData];
        } failure:^(NSError *error) {
            
        }];
    }];
}

- (void)batteryLockAction:(UISwitch *)switchButton {
    __weak typeof(self) weakSelf = self;
    [self.dpManager setValue:@(switchButton.on) forDP:ThingSmartCameraWirelessBatteryLockDPName success:^(id result) {
        weakSelf.batteryLockOn = switchButton.on;
    } failure:^(NSError *error) {
        [weakSelf reloadData];
    }];
}

- (NSString *)nightvisionText:(ThingSmartCameraNightvision)state {
    if ([state isEqualToString:ThingSmartCameraNightvisionAuto]) {
        return NSLocalizedStringFromTable(@"ipc_basic_night_vision_auto", @"IPCLocalizable", @"");
    }
    if ([state isEqualToString:ThingSmartCameraNightvisionOn]) {
        return NSLocalizedStringFromTable(@"ipc_basic_night_vision_on", @"IPCLocalizable", @"");
    }
    return NSLocalizedStringFromTable(@"ipc_basic_night_vision_off", @"IPCLocalizable", @"");
}

- (NSString *)pirText:(ThingSmartCameraPIR)state {
    if ([state isEqualToString:ThingSmartCameraPIRStateLow]) {
        return NSLocalizedStringFromTable(@"ipc_settings_status_low", @"IPCLocalizable", @"");
    }
    if ([state isEqualToString:ThingSmartCameraPIRStateMedium]) {
        return NSLocalizedStringFromTable(@"ipc_settings_status_mid", @"IPCLocalizable", @"");
    }
    if ([state isEqualToString:ThingSmartCameraPIRStateHigh]) {
        return NSLocalizedStringFromTable(@"ipc_settings_status_high", @"IPCLocalizable", @"");
    }
    return NSLocalizedStringFromTable(@"ipc_settings_status_off", @"IPCLocalizable", @"");
}

- (NSString *)motionSensitivityText:(ThingSmartCameraMotion)sensitivity {
    if ([sensitivity isEqualToString:ThingSmartCameraMotionLow]) {
        return NSLocalizedStringFromTable(@"ipc_motion_sensitivity_low", @"IPCLocalizable", @"");
    }
    if ([sensitivity isEqualToString:ThingSmartCameraMotionMedium]) {
        return NSLocalizedStringFromTable(@"ipc_motion_sensitivity_mid", @"IPCLocalizable", @"");
    }
    if ([sensitivity isEqualToString:ThingSmartCameraMotionHigh]) {
        return NSLocalizedStringFromTable(@"ipc_motion_sensitivity_high", @"IPCLocalizable", @"");
    }
    return @"";
}

- (NSString *)decibelSensitivityText:(ThingSmartCameraDecibel)sensitivity {
    if ([sensitivity isEqualToString:ThingSmartCameraDecibelLow]) {
        return NSLocalizedStringFromTable(@"ipc_sound_sensitivity_low", @"IPCLocalizable", @"");
    }
    if ([sensitivity isEqualToString:ThingSmartCameraDecibelHigh]) {
        return NSLocalizedStringFromTable(@"ipc_sound_sensitivity_high", @"IPCLocalizable", @"");
    }
    return @"";
}

- (NSString *)sdCardStatusText:(ThingSmartCameraSDCardStatus)status {
    switch (status) {
        case ThingSmartCameraSDCardStatusNormal:
            return NSLocalizedStringFromTable(@"Normally", @"IPCLocalizable", @"");
        case ThingSmartCameraSDCardStatusException:
            return NSLocalizedStringFromTable(@"Abnormally", @"IPCLocalizable", @"");
        case ThingSmartCameraSDCardStatusMemoryLow:
            return NSLocalizedStringFromTable(@"Insufficient capacity", @"IPCLocalizable", @"");
        case ThingSmartCameraSDCardStatusFormatting:
            return NSLocalizedStringFromTable(@"ipc_status_sdcard_format", @"IPCLocalizable", @"");
        default:
            return NSLocalizedStringFromTable(@"pps_no_sdcard", @"IPCLocalizable", @"");
    }
}

- (NSString *)recordModeText:(ThingSmartCameraRecordMode)mode {
    if ([mode isEqualToString:ThingSmartCameraRecordModeEvent]) {
        return NSLocalizedStringFromTable(@"ipc_sdcard_record_mode_event", @"IPCLocalizable", @"");
    }
    return NSLocalizedStringFromTable(@"ipc_sdcard_record_mode_ctns", @"IPCLocalizable", @"");
}

- (NSString *)powerModeText:(ThingSmartCameraPowerMode)mode {
    if ([mode isEqualToString:ThingSmartCameraPowerModePlug]) {
        return NSLocalizedStringFromTable(@"ipc_electric_power_source_wire", @"IPCLocalizable", @"");
    }
    return NSLocalizedStringFromTable(@"ipc_electric_power_source_batt", @"IPCLocalizable", @"");
}

- (NSString *)electricityText {
    return [NSString stringWithFormat:@"%@%%", @(self.electricity)];
}

- (void)showActionSheet:(NSArray *)options selectedHandler:(void(^)(id result))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    [options enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[obj objectForKey:kTitle] style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            if (handler) {
                handler([obj objectForKey:kValue]);
            }
        }];
        [alert addAction:action];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - dpmanagerobserver

- (void)cameraDPDidUpdate:(ThingSmartCameraDPManager *)manager dps:(NSDictionary *)dpsData {
    if ([dpsData objectForKey:ThingSmartCameraWirelessElectricityDPName]) {
        self.electricity = [[dpsData objectForKey:ThingSmartCameraWirelessElectricityDPName] integerValue];
        [self reloadData];
    }
}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.dataSource objectAtIndex:section] objectForKey:kTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSource objectAtIndex:section] objectForKey:kValue] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [[[self.dataSource objectAtIndex:indexPath.section] valueForKey:kValue] objectAtIndex:indexPath.row];
    if ([data objectForKey:kSwitch]) {
        NSString *identifier = [NSString stringWithFormat:@"switchCell_%ld_%ld", indexPath.section, indexPath.row];
        CameraSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[CameraSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        BOOL value = [[data objectForKey:kValue] boolValue];
        SEL action = NSSelectorFromString([data objectForKey:kAction]);
        [cell setValueChangedTarget:self selector:action value:value];
        cell.textLabel.text = [data objectForKey:kTitle];
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"defaultCell"];
        }
        cell.textLabel.text = [data objectForKey:kTitle];
        cell.detailTextLabel.text = [data objectForKey:kValue];
        if ([data objectForKey:kArrow]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:kValue] objectAtIndex:indexPath.row];
    if (![data objectForKey:kSwitch]) {
        NSString *action = [data objectForKey:kAction];
        if (action) {
            SEL selector = NSSelectorFromString(action);
            [self performSelector:selector withObject:nil afterDelay:0];
        }
    }
}

- (ThingSmartDevice *)device {
    if (!_device) {
        _device = [ThingSmartDevice deviceWithDeviceId:self.devId];
    }
    return _device;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APP_TOP_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
