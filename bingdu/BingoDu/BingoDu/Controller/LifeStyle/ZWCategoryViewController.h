#import "ZWBaseViewController.h"

/**
 *  @author 林思敏
 *  @brief 分类频道页面
 */

@interface ZWCategoryViewController : ZWBaseViewController

/** 工厂方法 */
+ (instancetype)viewController;

/** 频道名称 */
@property (nonatomic, strong) NSString *channelTitle;

/** 分类频道ID */
@property (nonatomic, assign) NSNumber *channelId;

/** 频道封面 */
@property (nonatomic, strong) NSString *channelImage;

@end
