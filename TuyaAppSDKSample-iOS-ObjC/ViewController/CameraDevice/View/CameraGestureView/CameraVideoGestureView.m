//
//  CameraVideoGestureView.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "CameraVideoGestureView.h"

@interface CameraVideoGestureView()<UIGestureRecognizerDelegate>

@end

@implementation CameraVideoGestureView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addGestures];
    }
    return self;
}

- (void)addGestures {
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    pinch.delegate = self;
    [self addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.delegate = self;
    [tap requireGestureRecognizerToFail:doubleTap];
    [self addGestureRecognizer:doubleTap];
    [tap requireGestureRecognizerToFail:doubleTap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.minimumNumberOfTouches = 1;
    pan.maximumNumberOfTouches = 1;
    pan.delegate = self;
    [self addGestureRecognizer:pan];
}


#pragma mark - gestures action

- (void)pinchAction:(UIPinchGestureRecognizer *)recognizer {
    static CGPoint centerPoint;
    if (recognizer.numberOfTouches < 2) {
        return;
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint p1 = [recognizer locationOfTouch:0 inView:self];
        CGPoint p2 = [recognizer locationOfTouch:1 inView:self];
        centerPoint = CGPointMake((p1.x + p2.x)/2, (p1.y + p2.y)/2);
    }
    if ([self.delegate respondsToSelector:@selector(gestureView:didRecognizedPinchGesture:scaled:centerPoint:)]) {
        [self.delegate gestureView:self didRecognizedPinchGesture:recognizer scaled:recognizer.scale centerPoint:centerPoint];
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        centerPoint = CGPointZero;
    }
}

- (void)tapAction:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(gestureView:didRecognizedTapGesture:)]) {
        [self.delegate gestureView:self didRecognizedTapGesture:recognizer];
    }
}

- (void)doubleTapAction:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(gestureView:didRecognizedDoubleTapGesture:)]) {
        [self.delegate gestureView:self didRecognizedDoubleTapGesture:recognizer];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:self];
    
    if ([self.delegate respondsToSelector:@selector(gestureView:didRecognizedPanGesture:offset:)]) {
        [self.delegate gestureView:self didRecognizedPanGesture:recognizer offset:point];
    }
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}





@end
