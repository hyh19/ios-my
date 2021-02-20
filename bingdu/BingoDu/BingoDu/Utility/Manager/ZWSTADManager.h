#import <Foundation/Foundation.h>
#import "STObject.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  @brief 时趣移动广告管理器
 */
@interface ZWSTADManager : NSObject

/** 请求时趣移动广告数据 */
+ (void)startUpdatingSTADWithSuccessBlock:(void(^)(STObject *stad))success
                             failureBlock:(void(^)())failure;

@end
