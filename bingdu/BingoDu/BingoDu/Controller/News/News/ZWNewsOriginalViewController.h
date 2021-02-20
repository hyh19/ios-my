#import "ZWBaseViewController.h"

/**
 *  @author 刘云鹏
 *  @ingroup controller
 *  @brief 新闻详情里查看原文模块  （有内存难以释放的问题）
 */
@interface ZWNewsOriginalViewController : ZWBaseViewController

/**
 原文链接地址
 */
@property (nonatomic, strong) NSString *originalUrl;


@end
