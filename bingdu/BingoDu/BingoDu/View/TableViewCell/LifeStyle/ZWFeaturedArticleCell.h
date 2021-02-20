#import "ZWArticleBaseCell.h"

// 转云鹏
/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup protocol
 *  @brief 点击频道名的回调委托
 */
@protocol ZWFeaturedArticleCellDelegate <NSObject>

/** 点击频道名 */
- (void)tapChannelWithModel:(ZWArticleModel *)model;

@end

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 精选文章列表
 */
@interface ZWFeaturedArticleCell : ZWArticleBaseCell

@property (nonatomic, weak) id<ZWFeaturedArticleCellDelegate> delegate;

@end
