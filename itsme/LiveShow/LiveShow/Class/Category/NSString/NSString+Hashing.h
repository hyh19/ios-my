#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

enum {
    NJHashTypeMD5 = 0,
    NJHashTypeSHA1,
    NJHashTypeSHA256,
}; typedef NSUInteger NJHashType;


@interface NSString (Hashing)

- (NSString*)md5;
- (NSString*)sha1;
- (NSString*)sha256;
- (NSString*)hashWithType:(NJHashType)type;
- (NSString*)hmacWithKey:(NSString*)key;

@end
