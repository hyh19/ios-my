#import "ZWBaseViewController.h"
#import "ZWNewsModel.h"
#import "ZWArticleAdvertiseModel.h"
#import "ZWNewsHotReadModel.h"
#import "ZWSubscriptionNewsModel.h"
#import "ZWNewsCommentManager.h"

#define ARTICLE_MODE_KEY @"article_mode_key"
/**
 *  @author 刘云鹏
 *  @ingroup controller
 *  @brief 新闻详情界面
 */
@interface ZWArticleDetailViewController : ZWBaseViewController
/**
  类初始化
 */
-(id)initWithNewsModel:(ZWNewsModel*)model;
/**
 点击广告
 @param news
 */
-(void)onTouchArticleAdversizeCell:(ZWArticleAdvertiseModel*)advertiseModel;
/**
 点击热读
 @param news
 */
-(void)onTouchHotReadCell:(ZWNewsHotReadModel *)news;

/**
 根据点赞提示加载登录提示框
 */
-(void)loadLoginViewByLikeOrHate;

/**定义对象的类型*/
@property (nonatomic, assign) DetailViewType detailViewType;
/**新闻详情需要返回的viewController*/
@property (nonatomic, strong) UIViewController *willBackViewController;

/**分享新闻的标题*/
@property (nonatomic,strong)NSString *shareTitle;
@end
