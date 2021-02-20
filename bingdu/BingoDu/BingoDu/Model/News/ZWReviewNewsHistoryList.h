#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 当日用户评论新闻的操作记录
 */
@interface ZWReviewNewsHistoryList : NSObject
/**
 已登录用户添加评论过的新闻标示 退出账号不清空 12点清空
 */
+(void)addAlreadyReviewNewsUser:(NSString *)newsId;
/**
 查询该用户有无评论过该新闻做评论加分提示
 */
+(BOOL)queryAlreadyReviewNewsUser:(NSString *)newsId;
/**
 清空用户登录时评论过的新闻标示
 */
+(void)cleanAlreadyReviewNewsUser;

@end
