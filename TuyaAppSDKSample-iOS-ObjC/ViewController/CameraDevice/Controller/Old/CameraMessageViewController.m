//
//  CameraMessageViewController.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraMessageViewController.h"
#import <ThingEncryptImage/ThingEncryptImage.h>
#import <ThingSmartCameraKit/ThingSmartCameraKit.h>
#import "UIView+CameraAdditions.h"

@interface MessageTypeViewCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MessageTypeViewCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = UIColor.blackColor;
        self.contentView.backgroundColor = UIColor.whiteColor;
        self.contentView.layer.masksToBounds = YES;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = ({
        CGRect frame = self.contentView.frame;
        frame.origin.y = 10;
        frame.size.height -= 20;
        frame;
    });
    self.contentView.layer.cornerRadius = CGRectGetHeight(self.contentView.frame) * 0.5;
    self.titleLabel.frame = self.contentView.bounds;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentView.backgroundColor = (selected == YES ? UIColor.blueColor : UIColor.whiteColor);
    self.titleLabel.textColor = (selected == YES ? UIColor.redColor : UIColor.blackColor);
}

@end

@interface CameraMessageViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate>
    
@property (nonatomic, strong) ThingSmartCameraMessage *cameraMessage;

@property (nonatomic, strong) NSArray<ThingSmartCameraMessageSchemeModel *> *schemeModels;

@property (nonatomic, strong) UITableView *messageTableView;

@property (nonatomic, strong) NSArray<ThingSmartCameraMessageModel *> *messageModelList;

@property (nonatomic, strong) UICollectionView *messageTypeView;

@end

@implementation CameraMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.messageTableView];
    __weak typeof(self) weakSelf = self;
    [self.cameraMessage getMessageSchemes:^(NSArray<ThingSmartCameraMessageSchemeModel *> *result) {
        weakSelf.schemeModels = result;
        [weakSelf.messageTypeView reloadData];
        if (weakSelf.schemeModels.count > 0) {
            [weakSelf.messageTypeView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
        [weakSelf reloadMessageListWithScheme:result.firstObject];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
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

- (NSString *)titleForCenterItem {
    return NSLocalizedStringFromTable(@"ipc_panel_button_message", @"IPCLocalizable", @"");
}


- (void)reloadMessageListWithScheme:(ThingSmartCameraMessageSchemeModel *)schemeModel {

    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [formatter dateFromString:@"2019-09-17"];
    [self.cameraMessage messagesWithMessageCodes:schemeModel.msgCodes Offset:0 limit:20 startTime:[date timeIntervalSince1970] endTime:[[NSDate new] timeIntervalSince1970] success:^(NSArray<ThingSmartCameraMessageModel *> *result) {
        self.messageModelList = result;
        [self.messageTableView reloadData];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

#pragma mark - message table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageModelList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    ThingSmartCameraMessageModel *messageModel = [self.messageModelList objectAtIndex:indexPath.row];
    NSArray *components = [messageModel.attachPic componentsSeparatedByString:@"@"];
    if (components.count != 2) {
        [cell.imageView thing_setImageWithURL:[NSURL URLWithString:messageModel.attachPic] placeholderImage:[self placeHolder]];
        
    }else {
        [cell.imageView thing_setAESImageWithPath:components.firstObject encryptKey:components.lastObject placeholderImage:[self placeHolder]];
    }
    cell.imageView.frame = CGRectMake(0, 0, 88, 50);
    cell.textLabel.text = messageModel.msgTitle;
    cell.detailTextLabel.text = messageModel.msgContent;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.schemeModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MessageTypeViewCollectionViewCell *cell = (MessageTypeViewCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(MessageTypeViewCollectionViewCell.class) forIndexPath:indexPath];
    if (indexPath.row >= self.schemeModels.count) {
        return cell;
    }
    ThingSmartCameraMessageSchemeModel *schemeModel = [self.schemeModels objectAtIndex:indexPath.row];
    cell.titleLabel.text = schemeModel.describe;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ThingSmartCameraMessageSchemeModel *schemeModel = [self.schemeModels objectAtIndex:indexPath.row];
    [self reloadMessageListWithScheme:schemeModel];
}

- (UIImage *)placeHolder {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContext(CGSizeMake(88, 50));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (ThingSmartCameraMessage *)cameraMessage {
    if (!_cameraMessage) {
        _cameraMessage = [[ThingSmartCameraMessage alloc] initWithDeviceId:self.devId timeZone:[NSTimeZone defaultTimeZone]];
    }
    return _cameraMessage;
}

- (UITableView *)messageTableView {
    if (!_messageTableView) {
        CGFloat top = CGRectGetMaxY(self.navigationController.navigationBar.frame) + 64;
        CGFloat height = self.view.size.height - top;
        _messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, top, self.view.size.width, height) style:UITableViewStylePlain];
        _messageTableView.delegate = self;
        _messageTableView.dataSource = self;
    }
    return _messageTableView;
}

- (UICollectionView *)messageTypeView {
    if (!_messageTypeView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(80, 60);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _messageTypeView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), self.view.frame.size.width, 64) collectionViewLayout:layout];
        [_messageTypeView registerClass:MessageTypeViewCollectionViewCell.class forCellWithReuseIdentifier:NSStringFromClass(MessageTypeViewCollectionViewCell.class)];
        _messageTypeView.backgroundColor = [UIColor clearColor];
        _messageTypeView.showsHorizontalScrollIndicator = NO;
        _messageTypeView.delegate = self;
        _messageTypeView.dataSource = self;
        [self.view addSubview:_messageTypeView];
    }
    return _messageTypeView;
}

@end
