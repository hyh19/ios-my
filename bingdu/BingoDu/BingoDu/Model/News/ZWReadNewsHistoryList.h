#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 新闻阅读历史本地化管理类
 */
@interface ZWReadNewsHistoryList : NSObject
/**
 添加当日已经阅读过的新闻纪录 （无用户）
 */
+(void)addAlreadyReadNewsNoUser:(NSString *)newsId;
/**
 查询当日已经阅读过的新闻纪录 （无用户）
 */
+(BOOL)queryAlreadyReadNewsNoUser:(NSString *)newsId;
/**
 清空非今日已经阅读过的新闻纪录 （无用户）
 */
+(void)cleanAlreadyReadNewsNoUser;
/**
 当用户登录帐号时导入本地浏览过的新闻标示到该账号同时清空本地标示 （无用户）
 */
+(void)importLocalAlreadyReadNewsNoUser;
/**
 添加今日已经阅读过的新闻纪录 （有用户）
 */
+(void)addAlreadyReadNewsUser:(NSString *)newsId;
/**
 查询今日已经阅读过的新闻纪录 （有用户）
 */
+(BOOL)queryAlreadyReadNewsUser:(NSString *)newsId;
/**
 清空非今日已经阅读过的新闻纪录 （有用户）
 */
+(void)cleanAlreadyReadNewsUser;

@end
