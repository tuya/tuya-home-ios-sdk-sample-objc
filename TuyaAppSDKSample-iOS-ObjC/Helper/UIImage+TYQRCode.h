//
//  UIImage+TYQRCode.h
//  TYUIKit
//
//  Created by TuyaInc on 2019/5/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (TYQRCode)

/**
 [^zh]将文本内容渲染为二维码[$zh]
 [^en]Create QRCode image with str[$]
 */
+ (UIImage *)ty_qrCodeWithString:(NSString *)str width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
