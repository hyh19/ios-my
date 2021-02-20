#import "ZWBaseViewController.h"
#import "ZWNewsHotReadModel.h"
#import "ZWNewsModel.h"
#import "ZWArticleAdvertiseModel.h"

/**
 打开当前新闻的来源
 */
typedef enum
{
    UnknowNewsSourceType = 0, //未知类型
    GeneralNewsSourceType = 1,//普通新闻
    SpecialNewsSourceType = 2,//专题新闻
    FriendsNewsSourceType = 3,//并友圈新闻
    PushNewsSourceType = 4,   //推送新闻
    SearchNewsType = 5,       //搜索新闻
    FavoriteNewsType = 6      //收藏新闻
}NewsSourceType;

#define ARTICLE_MODE_KEY @"article_mode_key"

/**
 *  @author 刘云鹏
 *  @ingroup controller
 *  @brief 新闻详情界面
 */
@interface ZWNewsDetailViewController : ZWBaseViewController

/**
 主界面Controller
*/
@property (nonatomic, weak) UIViewController* themainview;
/**
 主界面Controller
 */
@property (nonatomic, strong) NSMutableDictionary *params;
/**
 是否加载完成
 */
@property (nonatomic, assign) BOOL loadFinish;
/**
 新闻类型
 */
@property (nonatomic, assign) NewsSourceType newsSourceType;

/**
 点击广告
 @param news
 */
-(void)onTouchArticleAdversizeCell:(ZWArticleAdvertiseModel*)advertiseModel;

/**
 点击热读新闻的回调
 @param news
 */
-(void)onTouchHotReadCell:(ZWNewsHotReadModel *)news;

/**
 根据热度后的按钮返回对应频道
 */
-(void)onTouchButtonBackChannel;

/**
 加载登录提示框
 */
-(void)loadLoginView;

/**
 根据点赞提示加载登录提示框
 */
-(void)loadLoginViewByLikeOrHate;

/**
 根据tabView的滑动位置 来响应js 保证网页内的图片加载
 */
-(void)scrollByDisplacementY:(CGFloat)displacementY translation:(CGFloat)translationY;

@end
