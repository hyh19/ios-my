#import "NSString+Base64.h"

@implementation NSString (Base64)

- (NSString *)base64String {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *base64Encoded = [data base64EncodedStringWithOptions:0];
    
    return base64Encoded;
}

+ (NSString *)stringFromBase64String:(NSString *)base64String {
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
    
    NSString *base64Decoded = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return base64Decoded;
}



@end
