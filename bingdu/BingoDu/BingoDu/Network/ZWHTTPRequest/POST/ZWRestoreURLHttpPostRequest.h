
#import "ZWHTTPPostRequest.h"

/**
 *  @author 陈新存
 *  @ingroup network
 *  @brief 百度短链还原长链数据请求
 */
@interface ZWRestoreURLHttpPostRequest : ZWHTTPPostRequest

/**
 *  初始化方法
 */
- (instancetype)initRestoreURLWithURL:(NSString *)restoreURL
                               succed:(void (^)(id result))succed
                               failed:(void (^)(NSString *errorString))failed;

@end
