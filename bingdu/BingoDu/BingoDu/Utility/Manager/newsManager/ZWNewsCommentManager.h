
#import <Foundation/Foundation.h>
#import "ZWNewsModel.h"
#import "ZWNewsTalkModel.h"
#import "ZWHotReadAndTalkTableView.h"
#import "ZWSubscriptionNewsModel.h"
#import "ZWSubscriptionModel.h"


/**
 订阅键
 */
#define  SUBSCRIPTIONKEY    @"subscription_key"
/**
 广告键
 */
#define  ADVERTISEKEY    @"article_mode_key"
/**
 热议键
 */
#define  HOTTALKKEY    @"hotReview"
/**
 热读键
 */
#define  HOTREADKEY    @"hotRead"
/**
 最新评论键
 */
#define  NEWCOMMENTKEY    @"newsReview"
/**
 是否需要加载更多
 */
#define  LOADMORE    @"loadMore"
/**
 block回调类型
 */
typedef NS_ENUM (NSUInteger,ZWCommentResultType)
{
    ZWCommentLoad,  //下载评论
    ZWCommentUpload,  //上传评论
    ZWCommentLoadFinish,  //所有的数据都加载完毕
};
typedef NS_ENUM (NSUInteger,ZWCommentType)
{
    ZWCommentHot=1097,  //并友热议
    ZWCommentNew,  //最新评论
};

/**
 加载完成的回调
 */
typedef void (^commentLoadResultCallBack)(ZWCommentResultType commentResultType,id newsTalkModel, BOOL isSuccess);

/**
 *  @author  刘云鹏
 *  @ingroup utility
 *  @brief 新闻评论管理
 */
@interface ZWNewsCommentManager : NSObject
/**
 * 类初始化函数
 * @param mode 数据model
 * @param commentTalbeView 显示评论的talbeview
 * @param commentLoadResultCallBack 结果回调
 */
-(id)initWithNewsModel:(ZWNewsModel*) model  commentTalbeView:(ZWHotReadAndTalkTableView*)commentTalbeView loadResultBlock:(commentLoadResultCallBack) commentLoadResultCallBack;
/**
 * 加载热议评论
 * @param isLoadMore 是否加载更多的请求
 */
-(void)loadNewsComment:(DetailViewType) detailViewType loadMore:(BOOL)isLoadMore;

/**
 * 加载所有最新评论
 * @param isLoadMore 是否加载更多的请求
 */
-(void)loadAllNewsComment:(BOOL)isLoadMore;
/**
 * 上传发表的评论
 * @param newsTalkModel 评论model
 * @param commentContent 评论内容
 * @param isImageComment 是否是图评
 * @param isPinlunReply 是否是回复某条评论
 */
-(void)upLoadNewsComment:(ZWNewsTalkModel*)newsTalkModel commentContent:(NSString*)commentContent isImageComment:(BOOL)isImageComment isPinlunReply:(BOOL)isPinlunReply;
/**
 新闻详情是否有广告
 */
-(BOOL)isHaveAdvertise;

@end
