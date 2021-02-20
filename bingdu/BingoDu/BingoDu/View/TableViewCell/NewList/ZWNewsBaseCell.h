#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
#import "ZWNewsModel.h"
#import "PureLayout.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 新闻列表Table view cell的基类
 */
@interface ZWNewsBaseCell : UITableViewCell

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 字体大小 */
@property (nonatomic, assign) CGFloat fontSize;

/** 新闻标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 阅读图标 */
@property (nonatomic, strong) UIImageView *readIcon;

/** 阅读数 */
@property (nonatomic, strong) UILabel *readLabel;

/** 评论图标 */
@property (nonatomic, strong) UIImageView *commentIcon;

/** 评论数 */
@property (nonatomic, strong) UILabel *commentLabel;

/** 单图模式下的新闻图片 */
@property (nonatomic, strong) UIImageView *newsImageView;

/** 新闻标签 */
@property (nonatomic, strong) UIImageView *tagImageView;

/** 新闻数据源 */
@property (nonatomic, strong) ZWNewsModel *model;

/** 单图片模式下图片尺寸 */
+ (CGSize)imageSize;

@end
