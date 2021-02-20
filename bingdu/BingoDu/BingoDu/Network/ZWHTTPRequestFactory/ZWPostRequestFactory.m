#import "ZWPostRequestFactory.h"
#import "ZWCryptoPostRequest.h"
#import "ZWNormalPostRequest.h"
#import "ZWHttpsPostRequest.h"

@implementation ZWPostRequestFactory

// 创建普通的网络请求对象
+ (ZWHTTPRequest *)normalRequestWithBaseURLAddress:(NSString *)baseAddress
                                              path:(NSString *)path
                                        parameters:(NSMutableDictionary *)parameters
                                            succed:(void (^)(id result))succed
                                            failed:(void (^)(NSString *errorString))failed {
    ZWHTTPRequest *request = [[ZWNormalPostRequest alloc] initWithBaseURL:baseAddress path:path parameters:parameters succed:succed failed:failed];
    [request startRequest];
    return request;
}

// 创建DES加密的网络请求对象
+ (ZWHTTPRequest *)cryptoRequestWithBaseURLAddress:(NSString *)baseAddress
                                              path:(NSString *)path
                                        parameters:(NSMutableDictionary *)parameters
                                            succed:(void (^)(id result))succed
                                            failed:(void (^)(NSString *errorString))failed {
    // 如果可以加密，则返回加密网络请求对象，否则，返回普通网络请求对象。
    if ([ZWHTTPRequestFactory cryptoEnabled]) {
        
        // DES加密，相关参数类型必须转换为为NSString类型，如NSNumber
        NSMutableDictionary *newParameters = [NSMutableDictionary dictionary];
        
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            
            if (![obj isKindOfClass:[NSString class]] &&
                [obj respondsToSelector:@selector(stringValue)]) {
                [newParameters safe_setObject:[obj stringValue] forKey:key];
            } else {
                [newParameters safe_setObject:obj forKey:key];
            }
        }];
        
        ZWHTTPRequest *request = [[ZWCryptoPostRequest alloc] initWithBaseURL:baseAddress path:path parameters:newParameters succed:succed failed:failed];
        [request startRequest];
        return request;
    }
    
    return [ZWPostRequestFactory normalRequestWithBaseURLAddress:baseAddress path:path parameters:parameters succed:succed failed:failed];
}

+ (ZWHTTPRequest *)httpsRequestWithBaseURLAddress:(NSString *)baseAddress
                                             path:(NSString *)path
                                       parameters:(NSMutableDictionary *)parameters
                                           succed:(void (^)(id result))succed
                                           failed:(void (^)(NSString *errorString))failed {
    ZWHTTPRequest *request = [[ZWHttpsPostRequest alloc] initWithBaseURL:baseAddress path:path parameters:parameters succed:succed failed:failed];
    [request startRequest];
    return request;
}
// 创建普通网盟的网络请求对象
+ (ZWNetUnionRequest *)netUnionNormalRequestWithBaseURLAddress:(NSString *)baseAddress
                                                          path:(NSString *)path
                                                    parameters:(NSMutableDictionary *)parameters
                                                        succed:(void (^)(id result))succed
                                                        failed:(void (^)(NSString *errorString))failed
{
    ZWNetUnionRequest *request = [[ZWNetUnionRequest alloc] initWithBaseURL:baseAddress path:path parameters:parameters succed:succed failed:failed];
    [request startRequest];
    return request;
}
@end
