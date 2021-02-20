#import "ZWBaseWebViewController.h"
#import "ZWActivityModel.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup controller
 *  @brief 活动界面
 */
@interface ZWActivityViewController : ZWBaseWebViewController

/** 初始化方法 */
- (instancetype)initWithModel:(ZWActivityModel *)model;

/** 初始化方法 */
- (instancetype)initWithURLString:(NSString *)URLString;

@end
