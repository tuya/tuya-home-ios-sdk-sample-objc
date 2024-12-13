//
//  DemoVideoLocalizerView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "DemoVideoLocalizerView.h"

#import "DemoSplitVideoLocalizerTimer.h"
#import "DemoSplitVideoUtil.h"

static NSInteger const kLocalizerInnerLineViewWidth = 1;
static NSInteger const kLocalizerInnerLineViewHeight = 5;
static NSInteger const kInnerLocalizerImageViewWidth = 11;

@interface DemoVideoInnerLocalizerView : UIView {
    UIColor *_selectedColor;
    UIColor *_normalColor;
}

@property (nonatomic, strong) UIButton *centerImageButton;
@property (nonatomic, strong) UIView *innerTopLineView;
@property (nonatomic, strong) UIView *innerBottomLineView;
@property (nonatomic, strong) UIView *innerLeftLineView;
@property (nonatomic, strong) UIView *innerRightLineView;

@end

@implementation DemoVideoInnerLocalizerView

- (instancetype)initWithFrame:(CGRect)frame normalColor:(UIColor *)normalColor selectedColor:(UIColor *)selectedColor {
    self = [super initWithFrame:frame];
    if (self) {
        _normalColor = normalColor;
        _selectedColor = selectedColor;
        self.backgroundColor = UIColor.clearColor;
        self.layer.cornerRadius = CGRectGetWidth(frame) * 0.5;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = _normalColor.CGColor;
        self.layer.masksToBounds = YES;
        [self subviewsInit];
    }
    return self;
}

- (void)subviewsInit {
    UIButton *centerImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [centerImageButton setImage:[UIImage imageNamed:@"demo_localizer_normal"] forState:UIControlStateNormal];
    [centerImageButton setImage:[UIImage imageNamed:@"demo_localizer_selected"] forState:UIControlStateSelected];
    centerImageButton.adjustsImageWhenHighlighted = NO;
    centerImageButton.userInteractionEnabled = NO;
    [self addSubview:centerImageButton];
    self.centerImageButton = centerImageButton;
    
    self.innerTopLineView = [self generateNormalInnerLineView];
    self.innerBottomLineView = [self generateNormalInnerLineView];
    self.innerLeftLineView = [self generateNormalInnerLineView];
    self.innerRightLineView = [self generateNormalInnerLineView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.centerImageButton.frame = CGRectMake((self.width - kInnerLocalizerImageViewWidth) * 0.5, (self.height - kInnerLocalizerImageViewWidth) * 0.5, kInnerLocalizerImageViewWidth, kInnerLocalizerImageViewWidth);
    
    self.innerTopLineView.frame = CGRectMake((self.width - kLocalizerInnerLineViewWidth) * 0.5, 0, kLocalizerInnerLineViewWidth, kLocalizerInnerLineViewHeight);

    self.innerBottomLineView.frame = CGRectMake((self.width - kLocalizerInnerLineViewWidth) * 0.5, self.height - kLocalizerInnerLineViewHeight, kLocalizerInnerLineViewWidth, kLocalizerInnerLineViewHeight);
    
    self.innerLeftLineView.frame = CGRectMake(0, (self.height - kLocalizerInnerLineViewWidth) * 0.5, kLocalizerInnerLineViewHeight, kLocalizerInnerLineViewWidth);

    self.innerRightLineView.frame = CGRectMake(self.width - kLocalizerInnerLineViewHeight, (self.height - kLocalizerInnerLineViewWidth) * 0.5, kLocalizerInnerLineViewHeight, kLocalizerInnerLineViewWidth);
}

- (UIView *)generateNormalInnerLineView {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = _normalColor;
    [self addSubview:lineView];
    return lineView;
}


- (void)refreshUIAppearanceWithSelected:(BOOL)selected {
    self.centerImageButton.selected = selected;
    UIColor *currentColor = selected ? _selectedColor : _normalColor;
    self.innerTopLineView.backgroundColor = currentColor;
    self.innerBottomLineView.backgroundColor = currentColor;
    self.innerLeftLineView.backgroundColor = currentColor;
    self.innerRightLineView.backgroundColor = currentColor;
    self.layer.borderColor = currentColor.CGColor;
}


@end

static NSInteger const kLocalizerOuterLineViewWidth = 1;
static NSInteger const kLocalizerOuterLineViewMargin = 4;

@interface DemoVideoLocalizerView() <UIGestureRecognizerDelegate> {
    UIColor *_selectedColor;
    UIColor *_normalColor;
}


@property (nonatomic, strong) DemoVideoInnerLocalizerView *innerLocalizerView;

/// 定位器辅助线
@property (nonatomic, strong) UIView *outerTopLineView;
@property (nonatomic, strong) UIView *outerBottomLineView;
@property (nonatomic, strong) UIView *outerLeftLineView;
@property (nonatomic, strong) UIView *outerRightLineView;

@property (nonatomic, strong) DemoSplitVideoLocalizerTimer *localizerTimer;

@property (nonatomic, assign, readwrite) BOOL isLocalizerShown;

@property (nonatomic, assign) BOOL isFirstIn;

@end


@implementation DemoVideoLocalizerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isFirstIn = YES;
        _selectedColor = [UIColor demo_colorWithHex:0xFF592A];
        _normalColor = UIColor.whiteColor;
        [self subviewsInit];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(localizerViewPanAction:)];
        panGesture.delegate = self;
        [self.innerLocalizerView addGestureRecognizer:panGesture];
                
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(localizerViewTapAction:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGestureRecognizer];
        [self safeSetLocalizerShown:NO];
    }
    return self;
}

- (void)showLocalizerView:(BOOL)isShown {
    if (isShown) {
        [self showLocalizerAnimated];
    } else {
        [self hideLocalizerAnimated];
    }
}

- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        [self.innerLocalizerView refreshUIAppearanceWithSelected:_selected];
        
        UIColor *currentColor = _selected ? _selectedColor : _normalColor;
        self.outerTopLineView.backgroundColor = currentColor;
        self.outerBottomLineView.backgroundColor = currentColor;
        self.outerLeftLineView.backgroundColor = currentColor;
        self.outerRightLineView.backgroundColor = currentColor;
    }
}


- (void)localizerViewPanAction:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    
    // 更新瞄准器位置
    CGPoint center = self.innerLocalizerView.center;
    center.x += translation.x;
    center.y += translation.y;
    
    [self realtimeReloadOuterLineViewsFrame];

    //结束手势时，开启timer
    [self _updateLocalizerViewTimerWhenGestureRecorgerStateChange:gesture];
    
    [gesture setTranslation:CGPointZero inView:self];
    
    CGPoint newCenter = CGPointMake(center.x, center.y);
    //超出虚线区域范围不可操作
    if (center.x <= 0) {
        newCenter.x = 0;
    }
    if (center.x >= self.width) {
        newCenter.x = self.width;
    }
    if (center.y <= 0) {
        newCenter.y = 0;
    }
    if (center.y >= self.height) {
        newCenter.y = self.height;
    }
    self.innerLocalizerView.center = newCenter;
}

- (void)localizerViewTapAction:(UIPanGestureRecognizer *)gesture {
    CGPoint tapCenter = [gesture locationInView:gesture.view];
    //虚线范围外的区域不可点击
    if (tapCenter.x < 0 ||
        tapCenter.x > self.width ||
        tapCenter.y < 0 ||
        tapCenter.y > self.height) {
        return;
    }
    //定位器展示过程中再次触发点击手势，修改定位器中点
    if ([self safeLocalizerShown]) {
        self.innerLocalizerView.center = tapCenter;
        [self realtimeReloadOuterLineViewsFrame];
        //结束手势时，开启timer
        [self _updateLocalizerViewTimerWhenGestureRecorgerStateChange:gesture];
        return;
    }

    [self showLocalizerView:YES];
}

- (void)showLocalizerAnimated {
    if (self.width == 0 || self.height == 0) {
        return;
    }
    if ([self safeLocalizerShown]) {
        return;
    }
    //每次展示前都要以中心位置进行展示
    self.innerLocalizerView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
    
    [self realtimeReloadOuterLineViewsFrame];
    
    self.selected = NO;
    
    [self.localizerTimer invalidate];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self safeSetLocalizerShown:YES];
    } completion:^(BOOL finished) {
    }];
    [self.localizerTimer fire];
}


- (void)hideLocalizerAnimated {
    [UIView animateWithDuration:0.25 animations:^{
        [self safeSetLocalizerShown:NO];
    } completion:^(BOOL finished) {
        [self.localizerTimer invalidate];
    }];
}

- (void)hideLocalizerViewImmediately {
    [self safeSetLocalizerShown:NO];
    [self.localizerTimer invalidate];
}

- (void)_updateLocalizerViewTimerWhenGestureRecorgerStateChange:(UIGestureRecognizer *)recognizer {
    CGPoint center = self.innerLocalizerView.center;
    CGFloat x = center.x/self.width;
    CGFloat y = center.y/self.height;

    NSString *dpInfo = [NSString stringWithFormat:@"%.0f,%.0f",x*100,y*100];

    //结束手势时，开启timer
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.localizerTimer fire];
        !self.movedCompletion ?: self.movedCompletion(dpInfo);
    }
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.localizerTimer invalidate];
    }
    self.selected = YES;
}

#pragma mark - Actions

- (void)localizerTimerAction:(DemoSplitVideoLocalizerTimer *)timer {
    [self hideLocalizerAnimated];
}

#pragma mark - Views

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.width && self.height) {
        if (self.isFirstIn) {
            self.isFirstIn = NO;
            self.innerLocalizerView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
        }
    }
    [self realtimeReloadOuterLineViewsFrame];
}

- (void)subviewsInit {
    DemoVideoInnerLocalizerView *innerLocalizerView = [[DemoVideoInnerLocalizerView alloc] initWithFrame:CGRectMake(0, 0, 23, 23) normalColor:_normalColor selectedColor:_selectedColor];
    [self addSubview:innerLocalizerView];
    self.innerLocalizerView = innerLocalizerView;
    
    self.outerTopLineView = [self generateNormalOuterLineView];
    self.outerBottomLineView = [self generateNormalOuterLineView];
    self.outerLeftLineView = [self generateNormalOuterLineView];
    self.outerRightLineView = [self generateNormalOuterLineView];
}

- (UIView *)generateNormalOuterLineView {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
    lineView.backgroundColor = UIColor.whiteColor;
    [self addSubview:lineView];
    return lineView;
}

- (void)realtimeReloadOuterLineViewsFrame {
    self.outerTopLineView.frame = [self outerTopLineViewFrame];
    self.outerBottomLineView.frame = [self outerBottomLineViewFrame];
    self.outerLeftLineView.frame = [self outerLeftLineViewFrame];
    self.outerRightLineView.frame = [self outerRightLineViewFrame];
}

- (void)safeSetLocalizerShown:(BOOL)localizerShown {
    @synchronized (self) {
        self.hidden = !localizerShown;
        self.isLocalizerShown = localizerShown;
    }
}

- (BOOL)safeLocalizerShown {
    BOOL localizerShown = NO;
    @synchronized (self) {
        localizerShown = self.isLocalizerShown;
    }
    return localizerShown;
}

#pragma mark - Frames

- (CGRect)outerTopLineViewFrame {
    return CGRectMake(self.innerLocalizerView.centerX - kLocalizerOuterLineViewWidth * 0.5 ,0, kLocalizerOuterLineViewWidth, self.innerLocalizerView.top-kLocalizerOuterLineViewMargin);
}

- (CGRect)outerBottomLineViewFrame {
    CGFloat originY = self.innerLocalizerView.bottom + kLocalizerOuterLineViewMargin;
    return CGRectMake(self.innerLocalizerView.centerX - kLocalizerOuterLineViewWidth * 0.5, originY, kLocalizerOuterLineViewWidth, self.height - originY);
}

- (CGRect)outerLeftLineViewFrame {
    return CGRectMake(0, self.innerLocalizerView.centerY - kLocalizerOuterLineViewWidth * 0.5, self.innerLocalizerView.left - kLocalizerOuterLineViewMargin, kLocalizerOuterLineViewWidth);
}

- (CGRect)outerRightLineViewFrame {
    CGFloat originX = self.innerLocalizerView.right + kLocalizerOuterLineViewMargin;
    return CGRectMake(originX, self.innerLocalizerView.centerY - kLocalizerOuterLineViewWidth * 0.5, self.width - originX, kLocalizerOuterLineViewWidth);
}

- (DemoSplitVideoLocalizerTimer *)localizerTimer {
    if (!_localizerTimer) {
        _localizerTimer = [DemoSplitVideoLocalizerTimer timerWithTimeInterval:3 target:self selector:@selector(localizerTimerAction:) userInfo:nil];
    }
    return _localizerTimer;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer.view == self) {
        return YES;
    }
    if ([self.gestureRecognizers containsObject:gestureRecognizer] && [self.gestureRecognizers containsObject:otherGestureRecognizer]) {
        return YES;
    } else {
        return NO;
    }
}

@end
