//
//  CameraCalendarView.m
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#import "CameraCalendarView.h"
#import "CameraCalendarCollectionViewCell.h"

#define CellIdentifier  @"CalendarCell"

@interface CameraCalendarView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *prevButton;

@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSArray<UILabel *> *weekdayLabels;

@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) NSDateComponents *compoments;

@property (nonatomic, assign) NSRange range;

@end

// IB_DESIGNABLE
@implementation CameraCalendarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        self.hidden = YES;
        [self.collectionView registerClass:[CameraCalendarCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        
        [self addSubview:self.maskView];
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.prevButton];
        [self.containerView addSubview:self.titleLabel];
        [self.containerView addSubview:self.nextButton];
        [self.containerView addSubview:self.headerView];
        [self.containerView addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.maskView.frame = self.bounds;
    
    self.containerView.frame = CGRectMake(0, 0, 300, 365);
    self.containerView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    self.prevButton.frame = CGRectMake(45, 9.5, 50, 50);
    self.titleLabel.frame = CGRectMake(100, 26, 100, 17);
    self.nextButton.frame = CGRectMake(205, 9.5, 50, 50);
    self.headerView.frame = CGRectMake(10, 69, 280, 18);
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(40 * idx, 0, 40, 18);
    }];
    self.collectionView.frame = CGRectMake(10, 89, 280, 266);
}

- (void)show:(NSDate *)date {
    if (!date) {
        return;
    }
    self.hidden = NO;
    self.compoments = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    [self reloadData];
}

- (void)hide {
    self.hidden = YES;
}

- (void)reloadData {
    self.titleLabel.text = [NSString stringWithFormat:@"%04d-%02d", (int)_compoments.year, (int)_compoments.month];
    
    NSDate *date = [self.calendar dateFromComponents:_compoments];
    NSDateComponents *componets = [self.calendar components:NSCalendarUnitWeekday fromDate:date];

    _range = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    _range.location = (componets.weekday - _compoments.day + 35) % 7;
    
    [self.collectionView reloadData];
}

- (void)maskViewClicked {
    self.hidden = YES;
}

- (void)prevAction {
    _compoments.month -= 1;
    if (_compoments.month < 1) {
        _compoments.month = 12;
        _compoments.year -= 1;
    }
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectYear:month:)]) {
        [self.delegate calendarView:self didSelectYear:_compoments.year month:_compoments.month];
    }
    [self reloadData];
}

- (void)nextAction {
    _compoments.month += 1;
    if (_compoments.month > 12) {
        _compoments.month = 1;
        _compoments.year += 1;
    }
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectYear:month:)]) {
        [self.delegate calendarView:self didSelectYear:_compoments.year month:_compoments.month];
    }
    [self reloadData];
}

#pragma mark - UICollectionView

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    return _calendar;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _range.location + _range.length;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CameraCalendarCollectionViewCell *cell = (CameraCalendarCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (NSLocationInRange(indexPath.row, _range)) {
        cell.titleLabel.text = NSLocationInRange(indexPath.row, _range) ? [NSString stringWithFormat:@"%d", (int)(indexPath.row - _range.location + 1)] : @"";

        NSDateComponents *compoments = [_compoments copy];
        compoments.day = indexPath.row - _range.location + 1;
        BOOL hasVideo = NO;
        if ([self.dataSource respondsToSelector:@selector(calendarView:hasVideoOnYear:month:day:)]) {
            hasVideo = [self.dataSource calendarView:self hasVideoOnYear:compoments.year month:compoments.month day:compoments.day];
        }
        
        cell.backgroundColor = hasVideo ? [UIColor blueColor] : [UIColor clearColor];
        cell.userInteractionEnabled = hasVideo;
    } else {
        cell.titleLabel.text = @"";
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!NSLocationInRange(indexPath.row, _range)) {
        return;
    }
    self.hidden = YES;
    NSDateComponents *compoments = [_compoments copy];
    compoments.day = indexPath.row - _range.location + 1;
    NSDate *date = [self.calendar dateFromComponents:compoments];

    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectYear:month:day:date:)]) {
        [self.delegate calendarView:self didSelectYear:compoments.year month:compoments.month day:compoments.day date:date];
    }
}

#pragma mark - Accessor

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewClicked)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame: CGRectZero];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 12;
    }
    return _containerView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIButton *)prevButton {
    if (!_prevButton) {
        _prevButton = [[UIButton alloc] init];
        [_prevButton setImage:[UIImage imageNamed:@"pps_left_arrow"] forState:UIControlStateNormal];
        [_prevButton addTarget:self action:@selector(prevAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _prevButton;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [[UIButton alloc] init];
        [_nextButton setImage:[UIImage imageNamed:@"pps_right_arrow"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [UIColor whiteColor];
    }
    return _headerView;
}

- (NSArray<UILabel *> *)weekdayLabels {
    if (!_weekdayLabels) {
        NSMutableArray *temp = [NSMutableArray array];
        NSArray *titles = @[
                           NSLocalizedStringFromTable(@"pps_day_sun", @"IPCLocalizable", @""),
                           NSLocalizedStringFromTable(@"pps_day_mon", @"IPCLocalizable", @""),
                           NSLocalizedStringFromTable(@"pps_day_tue", @"IPCLocalizable", @""),
                           NSLocalizedStringFromTable(@"pps_day_wed", @"IPCLocalizable", @""),
                           NSLocalizedStringFromTable(@"pps_day_thu", @"IPCLocalizable", @""),
                           NSLocalizedStringFromTable(@"pps_day_fri", @"IPCLocalizable", @""),
                           NSLocalizedStringFromTable(@"pps_day_sat", @"IPCLocalizable", @""),
                           ];
        [titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *label = [[UILabel alloc] init];
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:10];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = obj;
            [temp addObject:label];
            [self.headerView addSubview:label];
        }];
        _weekdayLabels = [temp copy];
    }
    return _weekdayLabels;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(40, 40);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 4;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

@end
