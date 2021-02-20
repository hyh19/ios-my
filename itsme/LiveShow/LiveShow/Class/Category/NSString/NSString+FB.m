#import "NSString+FB.h"

@implementation NSString (FB)

+ (NSString *)stringByEncodingURLString:(NSString *)URLString {
    NSString *encodeString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(nil,
                                                                                                  (CFStringRef)URLString, nil,
                                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    return encodeString;
}

@end
