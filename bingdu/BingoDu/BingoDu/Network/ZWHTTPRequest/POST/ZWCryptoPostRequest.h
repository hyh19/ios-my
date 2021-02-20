#import "ZWHTTPPostRequest.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 加密的Post网络请求
 */
@interface ZWCryptoPostRequest : ZWHTTPPostRequest

/**
 *  初始化方法
 */
- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed;

@end
