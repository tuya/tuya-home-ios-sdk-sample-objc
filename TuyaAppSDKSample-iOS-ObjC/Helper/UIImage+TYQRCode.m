//
//  UIImage+TYQRCode.m
//  TYUIKit
//
//  Created by TuyaInc on 2019/5/11.
//

#import "UIImage+TYQRCode.h"

@implementation UIImage (TYQRCode)

+ (UIImage *)ty_qrCodeWithString:(NSString *)str width:(CGFloat)width {
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKey:@"inputMessage"];
    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
    CIImage *outPutImage = [filter outputImage];
    return [self _ty_createNonInterpolatedImageFromCIImage:outPutImage withSize:width];
}

+ (UIImage *)_ty_createNonInterpolatedImageFromCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;      //宽度像素
    size_t height = CGRectGetHeight(extent) * scale;    //高度像素
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();//DeviceGray颜色空间
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];//创建CoreGraphics image
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    UIImage *resultImage = [UIImage imageWithCGImage:scaledImage];
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    CGImageRelease(scaledImage);
    return resultImage;
}

@end
