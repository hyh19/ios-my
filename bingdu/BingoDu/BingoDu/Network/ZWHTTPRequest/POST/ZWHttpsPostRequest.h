#import "ZWHTTPPostRequest.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief Https加密的Post网络请求
 */
@interface ZWHttpsPostRequest : ZWHTTPPostRequest
/**
 *  初始化方法
 */
- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed;
@end
