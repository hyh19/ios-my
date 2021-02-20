#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ZWNewsModel.h"
#import "ZWArticleModel.h"

// 交接
/**
 *  @author 黄玉辉->陈梦杉
 *  @author 林思敏
 *  @brief 生活方式文章列表Table view cell的基类
 */
@interface ZWArticleBaseCell : UITableViewCell

/** 文章图片 */
@property (nonatomic, strong) UIImageView *articleImageView;

/** 文章标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 文章摘要 */
@property (nonatomic, strong) UILabel *summaryLabel;

/** 发布时间 */
@property (nonatomic, strong) UILabel *timeLabel;

/** 评论数 */
@property (nonatomic, strong) UILabel *commentLabel;

/** 文章数据模型 */
@property (nonatomic, strong) ZWArticleModel *model;

@end
