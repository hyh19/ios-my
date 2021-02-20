#import "ZWHTTPGetRequest.h"

/**
 *  @author 林思敏
 *  @ingroup network
 *  @brief 氪金广告网络请求对象
 */

@interface ZWNetAdxRequest : ZWHTTPGetRequest

/** 初始化 */
- (instancetype)initWithBaseURL:(NSString *)baseURL
                           path:(NSString *)path
                     parameters:(NSMutableDictionary *)parameters
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;


@end
