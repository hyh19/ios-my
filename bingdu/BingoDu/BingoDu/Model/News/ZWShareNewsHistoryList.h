#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 用户分享新闻时的操作记录
 */
@interface ZWShareNewsHistoryList : NSObject
/**
 //TODO:未登录用户添加分享过的新闻标示 12点清空 （暂时么有做，记得加上）
 */
+(void)addAlreadyShareNewsNoUser:(NSString *)newsId;
/**
 查询未登录时有无分享过该新闻做分享加分提示
 */
+(BOOL)queryAlreadyShareNewsNoUser:(NSString *)newsId;
/**
 清空未登录时分享过的新闻标示
 */
+(void)cleanAlreadyShareNewsNoUser;
/**
 当用户登录帐号时导入本地分享过的新闻标示到该账号同时清空本地标示
 */
+(void)importLocalAlreadyShareNewsNoUser;
/**
 已登录用户添加分享过的新闻标示 退出账号不清空 12点清空
 */
+(void)addAlreadyShareNewsUser:(NSString *)newsId;
/**
 已登录用户添加分享过的新闻标示 退出账号不清空 12点清空
 */
+(BOOL)queryAlreadyShareNewsUser:(NSString *)newsId;
/**
 清空用户登录时分享过的新闻标示
 */
+(void)cleanAlreadyShareNewsUser;

@end
