#import "ZWArticleListBaseViewController.h"
// 交接
/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 精选文章列表界面
 */
@interface ZWFeaturedArticlesViewController : ZWArticleListBaseViewController

/** 工厂方法 */
+ (instancetype)viewController;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  新文章加载提示
 *  @ingroup view
 */
@interface ZWTipView : UIView

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  刷新背景
 *  @ingroup view
 */
@interface ZWRefreshBackgroundView : UIView

@end
