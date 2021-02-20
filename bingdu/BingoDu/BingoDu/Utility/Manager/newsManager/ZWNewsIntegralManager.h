
#import <Foundation/Foundation.h>
#import "ZWNewsModel.h"
/**
 积分类型
 */
typedef NS_ENUM (NSUInteger,ZWNewsIntegralType)
{
    ZWCommentIntegra,  //发表评论获得积分
    ZWReadIntegra,    //阅读文章获得的积分
    ZWShareNewsIntegra,//分享文章获得的积分
};

/**
 *  @author  刘云鹏
 *  @ingroup utility
 *  @brief 新闻积分管理
 */
@interface ZWNewsIntegralManager : NSObject
/**
 *  创建单例
 */
+ (instancetype)sharedInstance;
/**
 *  增加积分
 */
//-(BOOL)addInteraWithType:(ZWNewsIntegralType) integraType  newsId:(NSString*)newsId channelId:(NSString*)channelId newsSourceType:(NSInteger) newsType;

-(BOOL)addInteraWithType:(ZWNewsIntegralType) integraType  model:(ZWNewsModel*)newsModle;
@end
