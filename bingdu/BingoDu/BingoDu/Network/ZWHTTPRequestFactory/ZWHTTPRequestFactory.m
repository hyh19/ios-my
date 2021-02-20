#import "ZWHTTPRequestFactory.h"

@implementation ZWHTTPRequestFactory

+ (ZWHTTPRequest *)normalRequestWithBaseURLAddress:(NSString *)baseAddress
                                              path:(NSString *)path
                                        parameters:(NSMutableDictionary *)parameters
                                            succed:(void (^)(id result))succed
                                            failed:(void (^)(NSString *errorString))failed {
    return nil;
}

+ (ZWHTTPRequest *)cryptoRequestWithBaseURLAddress:(NSString *)baseAddress
                                              path:(NSString *)path
                                        parameters:(NSMutableDictionary *)parameters
                                            succed:(void (^)(id result))succed
                                            failed:(void (^)(NSString *errorString))failed {
    return nil;
}

+ (ZWHTTPRequest *)httpsRequestWithBaseURLAddress:(NSString *)baseAddress
                                             path:(NSString *)path
                                       parameters:(NSMutableDictionary *)parameters
                                           succed:(void (^)(id result))succed
                                           failed:(void (^)(NSString *errorString))failed {
    return nil;
}

+ (BOOL)cryptoEnabled {
    ZWUserInfoModel *sharedInstance = [ZWUserInfoModel sharedInstance];
    return [sharedInstance userId] && [sharedInstance accessToken] && [sharedInstance deskey];
}

@end
