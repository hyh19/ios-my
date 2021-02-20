#import "ZWHTTPPostRequest.h"

/**
 *  @author 刘云鹏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief 网盟广告网络请求对象
 */

@interface ZWNetUnionRequest : ZWHTTPPostRequest

/** 初始化 */
- (instancetype)initWithBaseURL:(NSString *)baseURL
                           path:(NSString *)path
                     parameters:(NSMutableDictionary *)parameters
                         succed:(void (^)(id result))succed
                         failed:(void (^)(NSString *errorString))failed;

@end
