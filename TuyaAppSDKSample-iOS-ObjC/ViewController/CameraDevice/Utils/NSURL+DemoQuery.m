//
//  NSURL+DemoQuery.m
//  TuyaAppSDKSample-iOS-ObjC
//
//  Copyright (c) 2014-2024 Tuya Inc. (https://developer.tuya.com/)

#import "NSURL+DemoQuery.h"

@interface NSString (DemoQuery)

- (NSString *)demo_routeUrlEncode;

@end

@implementation NSString (DemoQuery)

- (NSString *)demo_routeUrlEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@end

@implementation NSURL (DemoQuery)

- (NSDictionary *)demo_queryDictionary {
    if (self.scheme) {
        NSString *query = self.query;
        return [self.class _demo_dictionaryFromQuery:query];
    }
    return nil;
}

+ (NSDictionary *)_demo_dictionaryFromQuery:(NSString *)query {
    if (![query isKindOfClass:[NSString class]] || query.length == 0) {
        return nil;
    }
    NSCharacterSet *delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary *pairs = [NSMutableDictionary dictionary];
    NSScanner *scanner = [[NSScanner alloc] initWithString:query];
    while (![scanner isAtEnd]) {
        NSString *pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray *kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString *key = [[kvPair objectAtIndex:0]
                             stringByRemovingPercentEncoding];
            NSString *value = [[kvPair objectAtIndex:1] stringByRemovingPercentEncoding];
            [pairs setObject:value forKey:key];
        }
    }
    
    return [pairs copy];
}

@end
