#import "ZWBaseViewController.h"

/**
 *  @author 林思敏
 *  @brief 分类文章列表
 */

@interface ZWCategoryArticlesViewController : ZWBaseViewController

/** 工厂方法 */
+ (instancetype)viewController;

/** 频道名称 */
@property (nonatomic, strong) NSString *channelName;

/** 分类频道ID */
@property (nonatomic, assign) NSNumber *channelId;

@end
