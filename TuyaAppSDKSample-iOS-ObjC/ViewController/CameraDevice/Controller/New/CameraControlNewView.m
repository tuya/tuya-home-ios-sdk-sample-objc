//
//  CameraControlNewView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2023 Tuya Inc. (https://developer.tuya.com/)

#import "CameraControlNewView.h"

#import "CameraControlButton.h"

@interface CameraControlNewView ()

@property (nonatomic, strong) NSHashTable *subButtons;

@property (nonatomic, strong) UIScrollView *mainScrollView;

@end

@implementation CameraControlNewView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        _subButtons = NSHashTable.weakObjectsHashTable;
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _mainScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addSubview:_mainScrollView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.mainScrollView.frame = self.bounds;
    CGFloat buttonWith = self.frame.size.width / 3;
    CGFloat buttonHeight = buttonWith;
    
    CGFloat subbuttonWith = buttonWith;
    CGFloat subbuttonHeight = buttonHeight / 2;
    
    NSArray <CameraControlButton *> *items = self.mainScrollView.subviews;
    
    NSInteger columnNum = items.count / 3 + (items.count % 3 == 0 ? 0 : 1);
    self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width, buttonHeight * columnNum);
    CGFloat buttonImageToTitleMargin = self.isSmallSize ? 0 : 8;
    [items enumerateObjectsUsingBlock:^(CameraControlButton *button, NSUInteger idx, BOOL *stop) {
        button.imageToTitleMargin = buttonImageToTitleMargin;
        button.frame = CGRectMake((idx % 3) * (buttonWith - 0.5), idx / 3 * (buttonHeight - 0.5), buttonWith, buttonHeight);
        if (!button.identifier) {
            [button.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
                obj.frame = CGRectMake(0, idx * subbuttonHeight, subbuttonWith, subbuttonHeight);
            }];
        }
    }];
}

- (void)setButtonItems:(NSArray<NSArray<id<CameraControlButtonItem>> *> *)buttonItems {
    _buttonItems = buttonItems;
    [self removeAllSubviews];
   
    self.mainScrollView.contentOffset = CGPointZero;
    for (NSArray<id<CameraControlButtonItem>> *subButtonItems in buttonItems) {
        NSMutableArray *tmepSubButtonItems = NSMutableArray.array;
        for (id<CameraControlButtonItem>subButtonItem in subButtonItems) {
            if (subButtonItem && subButtonItem.hidden == NO) {
                [tmepSubButtonItems addObject:subButtonItem];
            }
        }
        if (tmepSubButtonItems.count > 0) {
            CameraControlButton *controlButton = [self generateParentButtonWithButtonItems:tmepSubButtonItems.copy];
            [self.mainScrollView addSubview:controlButton];
        }
    }
    [self triggerLayoutImmediately];
}

- (CameraControlButton *)generateParentButtonWithButtonItems:(NSArray<id<CameraControlButtonItem>>*)buttonItems {
    if (2 == buttonItems.count) {
        CameraControlButton *parentButton = [CameraControlButton new];
        CameraControlButton *firstButton = [self generateChildButtonWithButtonItem:buttonItems.firstObject];
        [parentButton addSubview:firstButton];
        
        CameraControlButton *lastButton = [self generateChildButtonWithButtonItem:buttonItems.lastObject];
        [parentButton addSubview:lastButton];
        return parentButton;
    }
    return [self generateChildButtonWithButtonItem:buttonItems.firstObject];
}

- (CameraControlButton *)generateChildButtonWithButtonItem:(id<CameraControlButtonItem>)buttonItem {
    CameraControlButton *controlButton = [CameraControlButton new];
    controlButton.identifier = buttonItem.identifier;
    controlButton.imageView.image = [[UIImage imageNamed:buttonItem.imagePath] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    controlButton.titleLabel.text = NSLocalizedStringFromTable(buttonItem.title, @"IPCLocalizable", @"");
    [controlButton addTarget:self action:@selector(controlAction:)];
    [self.subButtons addObject:controlButton];
    return controlButton;
}

- (void)enableControl:(NSString *)identifier {
    for (CameraControlButton *controlButton in self.subButtons) {
        if ([controlButton.identifier isEqualToString:identifier]) {
            controlButton.disabled = NO;
            return;
        }
    }
}

- (void)disableControl:(NSString *)identifier {
    for (CameraControlButton *controlButton in self.subButtons) {
        if ([controlButton.identifier isEqualToString:identifier]) {
            controlButton.disabled = YES;
            return;
        }
    }
}

- (void)selectedControl:(NSString *)identifier {
    for (CameraControlButton *controlButton in self.subButtons) {
        if ([controlButton.identifier isEqualToString:identifier]) {
            controlButton.highLighted = YES;
            return;
        }
    }
}

- (void)deselectedControl:(NSString *)identifier {
    for (CameraControlButton *controlButton in self.subButtons) {
        if ([controlButton.identifier isEqualToString:identifier]) {
            controlButton.highLighted = NO;
            return;
        }
    }
}

- (void)enableAllControl {
    [self.subButtons.allObjects setValue:@NO forKeyPath:@"disabled"];
}

- (void)disableAllControl {
    [self.subButtons.allObjects setValue:@YES forKeyPath:@"disabled"];
}

- (void)controlAction:(UITapGestureRecognizer *)recognizer {
    CameraControlButton *controlButton = (CameraControlButton *)recognizer.view;
    if (!controlButton.disabled) {
        [self.delegate controlView:self didSelectedControl:controlButton.identifier];
    }
}

- (void)removeAllSubviews {
    [self.subButtons removeAllObjects];
    [self.mainScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

- (void)triggerLayoutImmediately {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
