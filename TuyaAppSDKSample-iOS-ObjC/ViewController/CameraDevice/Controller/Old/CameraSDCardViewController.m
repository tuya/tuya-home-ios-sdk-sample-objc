//
//  CameraSDCardViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraSDCardViewController.h"

#import "CameraViewConstants.h"

#define kTitle  @"title"
#define kValue  @"value"

@interface CameraSDCardViewController ()<ThingSmartCameraDPObserver, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger used;
@property (nonatomic, assign) NSInteger left;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) UIButton *formatButton;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation CameraSDCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xE8E9EF);
    __weak typeof(self) weakSelf = self;
    [self.dpManager valueForDP:ThingSmartCameraSDCardStorageDPName success:^(id result) {
        NSArray *components = [result componentsSeparatedByString:@"|"];
        if (components.count < 3) {
            return;
        }
        weakSelf.total = [[components firstObject] integerValue];
        weakSelf.used = [[components objectAtIndex:1] integerValue];
        weakSelf.left = [[components lastObject] integerValue];
        [weakSelf reloadData];
    } failure:^(NSError *error) {
        
    }];
    
    UIButton *formatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [formatButton addTarget:self action:@selector(formatAction) forControlEvents:UIControlEventTouchUpInside];
    [formatButton setTitle:NSLocalizedStringFromTable(@"ipc_sdcard_format", @"IPCLocalizable", @"") forState:UIControlStateNormal];
    [formatButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.tableView.tableFooterView = formatButton;
    self.formatButton = formatButton;
    
    [self.dpManager addObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
}

- (NSString *)titleForCenterItem {
    return @"SD Card";
}

- (void)formatAction {
    self.formatButton.enabled = NO;
    [self.dpManager setValue:@(YES) forDP:ThingSmartCameraSDCardFormatDPName success:^(id result) {
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)reloadData {
    NSMutableArray *dataSource = [NSMutableArray new];
    NSMutableArray *section0 = [NSMutableArray new];
    NSString *totalText = [NSString stringWithFormat:@"%.1fG", self.total / 1024.0 / 1024.0];
    NSString *usedText = [NSString stringWithFormat:@"%.1fG", self.used / 1024.0 / 1024.0];
    NSString *leftText = [NSString stringWithFormat:@"%.1fG", self.left / 1024.0 / 1024.0];
    [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_capacity_total", @"IPCLocalizable", @""), kValue: totalText}];
    [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_capacity_used", @"IPCLocalizable", @""), kValue: usedText}];
    [section0 addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_capacity_residue", @"IPCLocalizable", @""), kValue: leftText}];
    
    [dataSource addObject:@{kTitle: NSLocalizedStringFromTable(@"ipc_sdcard_capacity", @"IPCLocalizable", @""), kValue: section0.copy}];
    self.dataSource = [dataSource copy];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.dataSource objectAtIndex:section] objectForKey:kValue] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [[[self.dataSource objectAtIndex:indexPath.section] objectForKey:kValue] objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [data objectForKey:kTitle];
    cell.detailTextLabel.text = [data objectForKey:kValue];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.dataSource objectAtIndex:section] objectForKey:kTitle];
}

- (void)cameraDPDidUpdate:(ThingSmartCameraDPManager *)manager dps:(NSDictionary *)dpsData {
    if ([dpsData objectForKey:ThingSmartCameraSDCardFormatStateDPName]) {
        NSInteger progress = [[dpsData objectForKey:ThingSmartCameraSDCardFormatStateDPName] intValue];
        if (progress == 100) {
            self.formatButton.enabled = YES;
            [SVProgressHUD dismiss];
        } else if (progress < 0) {
            self.formatButton.enabled = YES;
            [SVProgressHUD dismiss];
        } else {
            [SVProgressHUD showProgress:progress/100. status:NSLocalizedStringFromTable(@"SD card format progress", @"IPCLocalizable", @"")];
        }
        NSLog(@"[progress]%@", @(progress));
    }
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, APP_TOP_BAR_HEIGHT, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - APP_TOP_BAR_HEIGHT) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
