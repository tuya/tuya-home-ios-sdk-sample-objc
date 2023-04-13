//
//  CameraViewConstants.h
//  TuyaSmartIPCDemo
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

#ifndef TuyaSmart_TPViewConstants_h
#define TuyaSmart_TPViewConstants_h

#define APP_TOP_BAR_HEIGHT ([UIApplication sharedApplication].statusBarFrame.size.height >= 44 ? 88 : 64)

// Color
#define HEXCOLORA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:a]

#define HEXCOLOR(rgbValue) HEXCOLORA(rgbValue, 1.0)

#define IsIphoneX (MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) >= 812)

#define IphoneXSafeBottomMargin 34.0

#endif
