#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup network
 *  @brief NSMutableURLRequest的子类，主要用于添加自定义的请求头
 */
@interface ZWURLRequest : NSMutableURLRequest

/** 创建ZWURLRequest实例的初始化方法 */
- (instancetype)initWithURL:(NSURL *)theURL;

/** 创建ZWURLRequest实例的工厂方法 */
+ (instancetype)requestWithURL:(NSURL *)theURL;

/** 创建ZWURLRequest实例的初始化方法 */
- (instancetype)initWithURL:(NSURL *)theURL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

/** 创建ZWURLRequest实例的工厂方法 */
+ (instancetype)requestWithURL:(NSURL *)theURL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval;

@end
