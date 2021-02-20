#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup utility
 *  积分管理器，管理所有模块的积分获取
 */
@interface ZWPointDataManager : NSObject

/**
 *  浏览广告获取积分
 *
 *  @param URL 广告的地址
 */
+ (void)addPointForAdvertisementWithURL:(NSString *)URL;

@end
