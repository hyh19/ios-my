#import <UIKit/UIKit.h>
#import "FBBannerModel.h"

/**
 *  @author 黄玉辉
 *  @brief Banner广告
 */
@interface FBBannerView : UIView

/** 初始化 */
- (instancetype)initWithBanner:(FBBannerModel *)banner;

/** 图片加载完成后的回调 */
@property (nonatomic, copy) void (^doCompleteAction)(CGSize imageSize);

@end



@interface FBBannerViewsContainer : UIView

@property (nonatomic , readonly) UIScrollView *scrollView;

/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;

/**
 数据源：获取总的page个数，如果少于2个，不自动滚动
 **/
@property (nonatomic , copy) NSInteger (^totalPagesCount)(void);

/**
 数据源：获取第pageIndex个位置的contentView
 **/
@property (nonatomic , copy) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);

/**
 当点击的时候，执行的block
 **/
@property (nonatomic , copy) void (^TapActionBlock)(NSInteger pageIndex);

@end
