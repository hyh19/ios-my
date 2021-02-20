#import <UIKit/UIKit.h>

/** 滑动方向 */
typedef NS_ENUM(NSUInteger, FBSlideDirection) {
    /** 没有滑动 */
    kSlideDirectionNone,
    /** 往左边滑动 */
    kSlideDirectionLeft,
    /** 往右边滑动 */
    kSlideDirectionRight
};

/**
 *  @author 黄玉辉
 *  @brief 轮播图控件，根据AutoSlideScrollView（https://github.com/iOSNerd/PagedScrollView）修改，用于切换评论模式
 *
 *  修改了以下几点：
 *  - 移除指示控件
 *  - 移除自动切换
 *  - 移除点击事件
 *  - 增加滑动方向
 */
@interface FBSlideScrollView : UIView

@property (nonatomic , readonly) UIScrollView *scrollView;

/**
 数据源：获取总的page个数，如果少于2个，不自动滚动
 **/
@property (nonatomic , copy) NSInteger (^totalPagesCount)(void);

/**
 数据源：获取第pageIndex个位置的contentView
 **/
@property (nonatomic , copy) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);

/** 最后一次的滑动方向 */
@property (nonatomic) FBSlideDirection latestSlideDirection;

@end
