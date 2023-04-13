//
//  CameraCloudNewViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraCloudNewViewController.h"
#import "CameraCloudDayCollectionViewCell.h"
#import "CameraPermissionUtil.h"
#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import <ThingEncryptImage/ThingEncryptImage.h>
#import <ThingCameraUIKit/ThingCameraUIKit.h>
#import "CloudTimePieceModel+Timeline.h"
#import "CameraViewConstants.h"
#import "UIView+CameraAdditions.h"

#define TopBarHeight 88
#define VideoViewWidth [UIScreen mainScreen].bounds.size.width
#define VideoViewHeight ([UIScreen mainScreen].bounds.size.width / 16 * 9)

#define kControlRecord      @"record"
#define kControlPhoto       @"photo"

@interface CameraCloudNewViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource,ThingTimelineViewDelegate,ThingSmartCloudManagerDelegate>

@property (nonatomic, strong) ThingSmartDevice *device;

@property (nonatomic, strong) ThingSmartCloudManager *cloudManager;

@property (nonatomic, strong) ThingSmartCloudDayModel *selectedDay;

@property (nonatomic, strong) NSArray *timePieces;

@property (nonatomic, strong) NSArray *eventModels;

@property (nonatomic, strong) ThingTimelineView *timeLineView;

@property (nonatomic, strong) UITableView *eventTable;

@property (nonatomic, strong) UICollectionView *dayCollectionView;

@property (nonatomic, strong) UIButton *photoButton;

@property (nonatomic, strong) UIButton *recordButton;

@property (nonatomic, strong) UIButton *pauseButton;

@property (nonatomic, strong) UIButton *soundButton;

@property (nonatomic, strong) UIView *controlBar;

@property (nonatomic, assign) BOOL isRecording;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL isPaused;

@end

@implementation CameraCloudNewViewController

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self.cloudManager stopPlayCloudVideo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = HEXCOLOR(0xE8E9EF);
    self.title = [self titleForCenterItem];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"tp_top_bar_goBack"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    leftBtn.frame = CGRectMake(0, 0, 44, 44);
    [leftBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItems = @[leftItem];
    
    self.device = [ThingSmartDevice deviceWithDeviceId:self.devId];
    self.cloudManager = [[ThingSmartCloudManager alloc] initWithDeviceId:self.devId];
    self.cloudManager.delegate = self;
    self.cloudManager.enableEncryptedImage = YES;
    __weak typeof(self) weakSelf = self;
    [self.cloudManager loadCloudData:^(ThingSmartCloudState state) {
        [weakSelf.dayCollectionView reloadData];
        [weakSelf checkCloudState:state];
    }];

    [self.view addSubview:self.cloudManager.videoView];
    [self.cloudManager.videoView thing_clear];
    
    self.cloudManager.videoView.frame = CGRectMake(0, APP_TOP_BAR_HEIGHT, VideoViewWidth, VideoViewHeight);
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(80, 50);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.dayCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.cloudManager.videoView.bottom, [UIScreen mainScreen].bounds.size.width, 50) collectionViewLayout:layout];
    [self.view addSubview:self.dayCollectionView];
    self.dayCollectionView.delegate = self;
    self.dayCollectionView.dataSource = self;
    self.dayCollectionView.backgroundColor = [UIColor whiteColor];
    [self.dayCollectionView registerClass:[CameraCloudDayCollectionViewCell class] forCellWithReuseIdentifier:@"cloudDay"];
    
    self.timeLineView = [[ThingTimelineView alloc] initWithFrame:CGRectMake(0, self.dayCollectionView.bottom, [UIScreen mainScreen].bounds.size.width, 74)];
    self.timeLineView.delegate = self;
    self.timeLineView.timeHeaderHeight = 24;
    self.timeLineView.showShortMark = YES;
    self.timeLineView.timeTextTop = 6;
    self.timeLineView.spacePerUnit = 90;
    self.timeLineView.selectionTimeBackgroundColor = [UIColor blackColor];
    self.timeLineView.selectionTimeTextColor = [UIColor whiteColor];
    self.timeLineView.backgroundColor = [UIColor whiteColor];
    self.timeLineView.backgroundGradientColors = @[];
    self.timeLineView.contentGradientColors = @[(__bridge id)HEXCOLORA(0x4f67ee, 0.62).CGColor, (__bridge id)HEXCOLORA(0x4d67ff, 0.09).CGColor];
    self.timeLineView.contentGradientLocations = @[@(0.0), @(1.0)];
    self.timeLineView.timeStringAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize:9], NSForegroundColorAttributeName : HEXCOLOR(0x333300)};
    self.timeLineView.tickMarkColor = HEXCOLORA(0x000000, 0.1);
    [self.view addSubview:self.timeLineView];
    
    self.eventTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.timeLineView.bottom, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (self.timeLineView.bottom + 50))];
    self.eventTable.delegate = self;
    self.eventTable.dataSource = self;
    [self.view addSubview:self.eventTable];
    
    [self.view addSubview:self.soundButton];
    [self.view addSubview:self.controlBar];
    
    [self.soundButton addTarget:self action:@selector(soundAction) forControlEvents:UIControlEventTouchUpInside];
    [self.photoButton addTarget:self action:@selector(photoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.pauseButton addTarget:self action:@selector(pauseAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)soundAction {
    BOOL isMuted = [self.cloudManager isMuted];
    __weak typeof(self) weakSelf = self;
    [self.cloudManager enableMute:!isMuted success:^{
        NSString *imageName = @"ty_camera_soundOn_icon";
        if (weakSelf.cloudManager.isMuted) {
            imageName = @"ty_camera_soundOff_icon";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.soundButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        });
        NSLog(@"enable mute success");
    } failure:^(NSError *error) {
        [weakSelf showErrorTip:NSLocalizedStringFromTable(@"enable mute failed", @"IPCLocalizable", @"")];
    }];
}

- (void)recordAction {
    [self checkPhotoPermision:^(BOOL result) {
        if (result) {
            if (self.isRecording) {
                self.isRecording = NO;
                self.recordButton.tintColor = [UIColor blackColor];
                if ([self.cloudManager stopRecord] != 0) {
                    [self showErrorTip:NSLocalizedStringFromTable(@"record failed", @"IPCLocalizable", @"")];
                }else {
                    [self showTip:NSLocalizedStringFromTable(@"ipc_multi_view_video_saved", @"IPCLocalizable", @"")];
                }
            }else {
                [self.cloudManager startRecord];
                self.isRecording = YES;
                self.recordButton.tintColor = [UIColor redColor];
            }
        }
    }];
}

- (void)pauseAction {
    if (self.isPlaying && self.isPaused) {
        if ([self.cloudManager resumePlayCloudVideo]) {
            [self showErrorTip:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"")];
        }else {
            UIImage *image = [[UIImage imageNamed:@"ty_camera_tool_pause_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.pauseButton setImage:image forState:UIControlStateNormal];
            self.isPaused = NO;
        }
    }else if (self.isPlaying) {
        if ([self.cloudManager pausePlayCloudVideo]) {
            [self showErrorTip:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"")];
        }else {
            UIImage *image = [[UIImage imageNamed:@"ty_camera_tool_play_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.pauseButton setImage:image forState:UIControlStateNormal];
            self.isPaused = YES;
        }
    }
}

- (void)photoAction {
    [self checkPhotoPermision:^(BOOL result) {
        if (result) {
            if ([self.cloudManager snapShoot]) {
                [self showTip:NSLocalizedStringFromTable(@"ipc_multi_view_photo_saved", @"IPCLocalizable", @"")];
            }else {
                [self showErrorTip:NSLocalizedStringFromTable(@"fail", @"IPCLocalizable", @"")];
            }
        }
    }];
}


- (NSString *)titleForCenterItem {
    return NSLocalizedStringFromTable(@"ipc_panel_button_cstorage", @"IPCLocalizable", @"");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
    }
}

- (void)checkCloudState:(ThingSmartCloudState)state {
    [self enableFeatureButtons:YES];
    switch (state) {
        case ThingSmartCloudStateNoService:
            [self enableFeatureButtons:NO];
            [self gotoCloudServicePanel];
            [self showTip:NSLocalizedStringFromTable(@"ipc_cloudstorage_status_off", @"IPCLocalizable", @"")];
            break;
        case ThingSmartCloudStateNoData:
        case ThingSmartCloudStateExpiredNoData:
            [self enableFeatureButtons:NO];
            [self showTip:NSLocalizedStringFromTable(@"ipc_cloudstorage_noDataTips", @"IPCLocalizable", @"")];
            break;
        case ThingSmartCloudStateLoadFailed:
            [self enableFeatureButtons:NO];
            [self showErrorTip:NSLocalizedStringFromTable(@"ty_network_error", @"IPCLocalizable", @"")];
            break;
        case ThingSmartCloudStateValidData:
        case ThingSmartCloudStateExpiredData:
            [self.dayCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.cloudManager.cloudDays.count-1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionLeft];
            [self loadTimePieceForDay:self.cloudManager.cloudDays.lastObject];
        default:
            break;
    }
}

- (void)loadTimePieceForDay:(ThingSmartCloudDayModel *)dayModel {
    self.selectedDay = dayModel;
    __weak typeof(self) weakSelf = self;
    [self.cloudManager timeLineWithCloudDay:dayModel success:^(NSArray<ThingSmartCloudTimePieceModel *> *timePieces) {
        weakSelf.timePieces = timePieces;
        weakSelf.timeLineView.sourceModels = timePieces;
        [weakSelf playCloudTimePiece:weakSelf.timePieces.firstObject playTime:0];
    } failure:^(NSError *error) {
        [weakSelf showErrorTip:NSLocalizedStringFromTable(@"ipc_errormsg_data_load_failed", @"IPCLocalizable", @"")];
    }];
    [self.cloudManager timeEventsWithCloudDay:dayModel offset:0 limit:-1 success:^(NSArray<ThingSmartCloudTimeEventModel *> *timeEvents) {
        weakSelf.eventModels = timeEvents;
        [weakSelf.eventTable reloadData];
    } failure:^(NSError *error) {
        [weakSelf showErrorTip:NSLocalizedStringFromTable(@"ipc_errormsg_data_load_failed", @"IPCLocalizable", @"")];
    }];
}

- (void)gotoCloudServicePanel {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"please import ThingSmartCloudServiceBizBundle", @"IPCLocalizable", @"")];
    });
//    id<ThingCameraCloudServiceProtocol> cloudService = [[ThingSmartBizCore sharedInstance] serviceOfProtocol:@protocol(ThingCameraCloudServiceProtocol)];
//    [cloudService requestCloudServicePageWithDevice:self.device.deviceModel completionBlock:^(__kindof UIViewController *page, NSError *error) {
//        if (page) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self.navigationController pushViewController:page animated:YES];
//            });
//        }
//    }];
}

- (void)playCloudTimePiece:(ThingSmartCloudTimePieceModel *)pieceModel playTime:(NSInteger)playTime {
    if (!pieceModel) return;
    if (![pieceModel containsTime:playTime]) {
        playTime = pieceModel.startTime;
    }
    __weak typeof(self) weakSelf = self;
    [self.cloudManager playCloudVideoWithStartTime:playTime endTime:self.selectedDay.endTime isEvent:NO onResponse:^(int errCode) {
        if (errCode) {
            [weakSelf showErrorTip:NSLocalizedStringFromTable(@"ipc_status_stream_failed", @"IPCLocalizable", @"")];
        }else {
            weakSelf.isPlaying = YES;
            weakSelf.isPaused = NO;
        }
    } onFinished:^(int errCode) {
        [weakSelf showTip:NSLocalizedStringFromTable(@"ipc_video_end", @"IPCLocalizable", @"")];
    }];
}

- (void)playCloudEvent:(ThingSmartCloudTimeEventModel *)eventModel {
    __weak typeof(self) weakSelf = self;
    [self.cloudManager playCloudVideoWithStartTime:eventModel.startTime endTime:self.selectedDay.endTime isEvent:YES onResponse:^(int errCode) {
        if (errCode) {
            [weakSelf showErrorTip:NSLocalizedStringFromTable(@"ipc_status_stream_failed", @"IPCLocalizable", @"")];
        }else {
            weakSelf.isPlaying = YES;
            weakSelf.isPaused = NO;
            
            UIImage *image = [[UIImage imageNamed:@"ty_camera_tool_pause_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [weakSelf.pauseButton setImage:image forState:UIControlStateNormal];
        }
    } onFinished:^(int errCode) {
        [weakSelf showTip:NSLocalizedStringFromTable(@"ipc_video_end", @"IPCLocalizable", @"")];
    }];
}

#pragma mark - table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.eventModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm:ss";
    });
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"event"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"event"];
    }
    ThingSmartCloudTimeEventModel *eventModel = [self.eventModels objectAtIndex:indexPath.row];
    [cell.imageView thing_setAESImageWithPath:eventModel.snapshotUrl encryptKey:self.cloudManager.encryptKey placeholderImage:[self placeholder]];
    cell.textLabel.text = eventModel.describe;
    cell.detailTextLabel.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:eventModel.startTime]];
    return cell;
}

- (UIImage *)placeholder {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContext(CGSizeMake(88, 50));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartCloudTimeEventModel *eventModel = [self.eventModels objectAtIndex:indexPath.row];
    [self playCloudEvent:eventModel];
}

#pragma mark - ThingSmartCloudManagerDelegate

- (void)cloudManager:(ThingSmartCloudManager *)cloudManager didReceivedFrame:(CMSampleBufferRef)frameBuffer videoFrameInfo:(ThingSmartVideoFrameInfo)frameInfo {
    if (frameInfo.nTimeStamp != self.timeLineView.currentTime) {
        self.timeLineView.currentTime = frameInfo.nTimeStamp;
    }
}

#pragma mark - ThingTimelineViewDelegate

- (void)timelineViewWillBeginDragging:(ThingTimelineView *)timeLineView {
    
}

- (void)timelineViewDidEndDragging:(ThingTimelineView *)timeLineView willDecelerate:(BOOL)decelerate {
    
}

- (void)timelineViewDidScroll:(ThingTimelineView *)timeLineView time:(NSTimeInterval)timeInterval isDragging:(BOOL)isDragging {
    
}

- (void)timelineView:(ThingTimelineView *)timeLineView didEndScrollingAtTime:(NSTimeInterval)timeInterval inSource:(id<ThingTimelineViewSource>)source {
    if (source) {
        [self playCloudTimePiece:source playTime:timeInterval];
    }
}

#pragma mark - collection view

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cloudManager.cloudDays.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CameraCloudDayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cloudDay" forIndexPath:indexPath];
    ThingSmartCloudDayModel *dayModel = [self.cloudManager.cloudDays objectAtIndex:indexPath.item];
    cell.textLabel.text = dayModel.uploadDay;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartCloudDayModel *dayModel = [self.cloudManager.cloudDays objectAtIndex:indexPath.row];
    [self loadTimePieceForDay:dayModel];
}

- (UIButton *)soundButton {
    if (!_soundButton) {
        _soundButton = [[UIButton alloc] initWithFrame:CGRectMake(8, APP_TOP_BAR_HEIGHT + VideoViewHeight - 50, 44, 44)];
        [_soundButton setImage:[UIImage imageNamed:@"ty_camera_soundOff_icon"] forState:UIControlStateNormal];
    }
    return _soundButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        UIImage *image = [[UIImage imageNamed:@"ty_camera_photo_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_photoButton setImage:image forState:UIControlStateNormal];
        [_photoButton setTintColor:[UIColor blackColor]];
    }
    return _photoButton;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        UIImage *image = [[UIImage imageNamed:@"ty_camera_rec_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_recordButton setImage:image forState:UIControlStateNormal];
        [_recordButton setTintColor:[UIColor blackColor]];
    }
    return _recordButton;
}

- (UIButton *)pauseButton {
    if (!_pauseButton) {
        _pauseButton = [[UIButton alloc] init];
        UIImage *image = [[UIImage imageNamed:@"ty_camera_tool_pause_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_pauseButton setImage:image forState:UIControlStateNormal];
        [_pauseButton setTintColor:[UIColor blackColor]];
    }
    return _pauseButton;
}

- (UIView *)controlBar {
    if (!_controlBar) {
        _controlBar = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 50, VideoViewWidth, 50)];
        [_controlBar addSubview:self.photoButton];
        [_controlBar addSubview:self.pauseButton];
        [_controlBar addSubview:self.recordButton];
        CGFloat width = VideoViewWidth / 3;
        [_controlBar.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            obj.frame = CGRectMake(width * idx, 0, width, 50);
        }];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 49.5, VideoViewWidth, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_controlBar addSubview:line];
    }
    return _controlBar;
}

- (void)checkPhotoPermision:(void(^)(BOOL result))complete {
    if ([CameraPermissionUtil isPhotoLibraryNotDetermined]) {
        [CameraPermissionUtil requestPhotoPermission:complete];
    }else if ([CameraPermissionUtil isPhotoLibraryDenied]) {
        [self showAlertWithMessage:NSLocalizedStringFromTable(@"Photo library permission denied", @"IPCLocalizable", @"")];
        !complete?:complete(NO);
    }else {
        !complete?:complete(YES);
    }
}

- (void)enableFeatureButtons:(BOOL)enabled {
    self.soundButton.enabled = enabled;
    self.photoButton.enabled = enabled;
    self.recordButton.enabled = enabled;
    self.pauseButton.enabled = enabled;
}

@end
