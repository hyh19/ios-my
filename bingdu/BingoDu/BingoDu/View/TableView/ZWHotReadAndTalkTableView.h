#import <UIKit/UIKit.h>
#import "LoadMoreTableFooterView.h"
#import "ZWNewsNetworkManager.h"
#import "AppDelegate.h"
#import "ZWNewsTalkModel.h"
#import "ZWCommentPopView.h"
#import "ZWNewsModel.h"

/**
 * 对象类型
 */
typedef NS_ENUM (NSUInteger,DetailViewType)
{
    ZWDetailDefaultNews=0,  //新闻详情（默认）
    ZWDetailComment,  //最新评论
    ZWDetailVideo,  //视频
};

@class ZWHotReadAndTalkTableView;

/**
 *  评论的talbeview
 */
@protocol ZWHotReadAndTalkTabDelegate <NSObject>
/**
 *  加载更多的代理
 */
- (void)pullTableViewDidTriggerLoadMore:(ZWHotReadAndTalkTableView*)pullTableView;
/**
 *  点击评论的代理
 */
- (void)onTouchCelPopView:(ZWClickType) touchPopType model:(ZWNewsTalkModel*)data;
/**
 *  talbelview scroll的代理
 */
 @optional
  - (void)commentScrollviewDidScroll:(UIScrollView *)scrollView;
@end

/**
 *  @author 刘云鹏
 *  @ingroup view
 *  @brief 新闻详情底部 热度与热议模块
 */
@interface ZWHotReadAndTalkTableView : UITableView<LoadMoreTableFooterDelegate,UITableViewDelegate>
{
    /**
     *  下载更多标记
     */
    BOOL pullTableIsLoadingMore;
}

/**
 *  是否停止加载
 */
@property (nonatomic, assign) BOOL stopLoad;
/**
 *  是否是点击了评论按钮跳转到评论的
 */
@property (nonatomic, assign) BOOL isClickCommentBtn;
/**
 *  代理对象
 */
@property (nonatomic, strong)AppDelegate *myDelegate;
/**
 *  加载更多的view
 */
@property (nonatomic, strong) LoadMoreTableFooterView *loadMoreView;

/**
 *  加载更多的代理
 */
@property (nonatomic, assign) id<ZWHotReadAndTalkTabDelegate> loadMoreDelegate;

/**
 *  加载更多的view
 */
@property (nonatomic, assign) BOOL pullTableIsLoadingMore;
/**
 *  广告图片的比例
 */
@property (nonatomic, assign) CGFloat advertiseImageRate;
/**
 *  热议的secton headview
 */
@property (nonatomic, strong) UIView *talkHeaderView;
/**
 *  最新热议的secton headview
 */
@property (nonatomic, strong) UIView *newTalkHeaderView;
/**
 *  数据源
 */
@property (nonatomic ,strong) NSMutableDictionary *allDictionary;
/**
 *  新闻id
 */
@property (nonatomic, strong) NSString *newsId;
/**
 *  频道id
 */
@property (nonatomic, strong) NSString *channelId;

/**
 *  频道id
 */
@property (nonatomic, assign) ZWNewsSourceType newsSourceType;
/**
 *  点击评论时弹出的view
 */
@property (nonatomic, strong) ZWCommentPopView  *popView;
/**
 *  talbeview 的父viewController
 */
@property (nonatomic, weak) UIViewController *baseViewController;

/**
 *定义对象的类型
 */
@property (nonatomic, assign) DetailViewType detailViewType;
/**
 *  点击赞响应
 */
-(void)chickLikeTalk:(int)likeAction from:(ZWNewsTalkModel *)from index:(int)index isFromHot:(BOOL)isFromHot;
/**
 *  点击举报
 */
-(void)chickReportTalk:(NSNumber *)commentId index:(int)index isHotComment:(BOOL)isHotComment;
/**
 *  发送用户浏览了热议接口
 */
-(void)sendHotTalkIsGetRequest;
@end
