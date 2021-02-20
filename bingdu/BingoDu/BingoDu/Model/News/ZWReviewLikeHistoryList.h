#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 热议点赞历史本地化管理类
 */
@interface ZWReviewLikeHistoryList : NSObject
/**
 添加当日已经点赞过的评论纪录 （无用户）
 */
+(void)addAlreadyReviewLikeNoUser:(NSString *)newsId;
/**
 查询当日已经点赞过的评论纪录 （无用户）
 */
+(BOOL)queryAlreadyReviewLikeNoUser:(NSString *)newsId;
/**
 清空当日已经点赞过的评论纪录 （无用户）
 */
+(void)cleanAlreadyReviewLikeNoUser;
/**
 当用户登录帐号时导入本地点赞过的新闻标示到该账号同时清空本地标示
 */
+(void)importLocalAlreadyReviewLikeNoUser;
/**
 添加当日已经点赞过的评论纪录 （有用户）
 */
+(void)addAlreadyReviewLikeUser:(NSString *)newsId;
/**
 查询当日已经点赞过的评论纪录 （有用户）
 */
+(BOOL)queryAlreadyReviewLikeUser:(NSString *)newsId;
/**
 清空当日已经点赞过的评论纪录 （有用户）
 */
+(void)cleanAlreadyReviewLikeUser;

@end
