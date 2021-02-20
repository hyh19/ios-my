#import "ZWCryptoGetRequest.h"

@implementation ZWCryptoGetRequest

- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed {
    
    if (self = [super initWithBaseURL:baseURL path:path parameters:parameters succed:succed failed:failed]) {
        
        parameters[@"uid"] = [ZWUserInfoModel userID];
        
        // 请求参数组成的字符串
        NSMutableString *parameterString = [NSMutableString string];
        
        // 拼装请求参数
        for (NSString *key in [parameters allKeys]) {
            [parameterString appendString:[NSString stringWithFormat:@"%@=%@&", key, parameters[key]]];
        }
        
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", baseURL, path];
        
        [urlString appendString:[NSString stringWithFormat:[path rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", parameterString]];
        
        // 对"api/"后面的地址要进行加密
        NSRange theRange = [urlString rangeOfString:@"api/"];
        
        NSString *plainText = [urlString substringFromIndex:theRange.location+theRange.length];
        
        NSString *ciphertext = [plainText stringByDESEncryptingWithKey:[[ZWUserInfoModel sharedInstance] deskey]];
        
        NSURL *url = [NSURL URLWithString:urlString.replace(plainText, ciphertext)];
        
        [self.request setURL:url];
        
        NSMutableDictionary *headers = [self headersWithParameters:parameters andRequestType:ZWHTTPRequestTypeCrypto];
        
        [self.request setRequestHeaders:headers];
    }
    
    return self;
    
}
@end
