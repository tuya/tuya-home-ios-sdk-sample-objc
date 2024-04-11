//
//  UIButton+Extensions.m
//  ThingAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2021 Thing Inc. (https://developer.tuya.com/)

#import <UIKit/UIKit.h>
#import "UIButton+Extensions.h"

@interface UIImage (DemoColor)

+ (UIImage *)demo_imageWithColor:(UIColor *)color;
+ (UIImage *)demo_imageWithColor:(UIColor *)color size:(CGSize)size;

@end

@implementation UIImage (DemoColor)

+ (UIImage *)demo_imageWithColor:(UIColor *)color {
    return [self demo_imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)demo_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (size.width <= 0 || size.height <= 0) return nil;
    
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

@implementation UIButton (Extensions)
- (void)roundCorner {
    self.layer.cornerRadius = 5.0;
    self.clipsToBounds = true;
}

- (void)demo_setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    UIImage *colorImage = [UIImage demo_imageWithColor:color];
    [self setBackgroundImage:colorImage forState:state];
}

@end

