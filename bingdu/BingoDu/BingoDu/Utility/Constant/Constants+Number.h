#ifndef Constants_Number_h
#define Constants_Number_h

///-----------------------------------------------------------------------------
/// @name 即时新闻
///-----------------------------------------------------------------------------
#pragma mark - 即时新闻 -
/** 从后台重新进入前台时新闻列表刷新的时间间隔，300秒 */
#define kTimeIntervalRefreshNewsListWhenEnterForeground 300

/** 下拉新闻列表刷新的时间间隔，60秒 */
#define kTimeIntervalRefreshNewsListWhenDrag 60

/** 切换频道刷新闻列表的时间间隔，300秒 */
#define kTimeIntervalRefreshNewsListWhenSwitchChannel 300

/** 阅读一定数量的新闻后提醒用户给好评 */
#define kNumberReviewThreshold 20

/** 新闻收藏每页的文章数 */
#define kPageRowFavoriteArticles 10

///-----------------------------------------------------------------------------
/// @name 生活方式
///-----------------------------------------------------------------------------
#pragma mark - 生活方式 -
/** 精选文章每页的文章数 */
#define kPageRowFeaturedArticles 20

/** 分类文章每页的文章数 */
#define kPageRowCategoryArticles 20

#endif
