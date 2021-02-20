#import "ZWHTTPGetRequest.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 加密的Get网络请求
 */
@interface ZWCryptoGetRequest : ZWHTTPGetRequest
- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed;
@end
