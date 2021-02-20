#import "ZWHTTPRequest.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 普通Get网络请求的基类
 */
@interface ZWHTTPGetRequest : ZWHTTPRequest

/**
 *  初始化方法
 */
- (instancetype)initWithBaseURL:(NSString *)baseURL path:(NSString *)path parameters:(NSMutableDictionary *)parameters succed:(void (^)(id result))succed failed:(void (^)(NSString *errorString))failed;

@end
