#import <UIKit/UIKit.h>
// 转云鹏
/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup protocol
 *  @brief 点击频道名的回调委托
 */
@protocol ZWLoopADCellDelegate <NSObject>

/** 点击广告 */
- (void)tapBanner;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief 精选列表轮播广告
 */
@interface ZWLoopADCell : UITableViewCell

@property (nonatomic, weak) id<ZWLoopADCellDelegate> delegate;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @brief  广告图片
 *  @ingroup view
 */
@interface ZWLoopADView : UIView

/** 所在的Cell */
@property (nonatomic, weak) ZWLoopADCell *parentView;

/** 图片视图 */
@property (nonatomic, strong) UIImageView *imageView;

/** 推广标签 */
@property (nonatomic, strong) UILabel *label;

@end

