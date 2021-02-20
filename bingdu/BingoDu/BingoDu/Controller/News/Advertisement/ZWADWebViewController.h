#import <UIKit/UIKit.h>
#import "ZWBaseWebViewController.h"
#import "ZWBaseViewController.h"

@class ZWArticleAdvertiseModel;

/**
 *  @author 陈新存
 *  @ingroup controller
 *  @brief 启动广告详情页
 */
@interface ZWADWebViewController : ZWBaseWebViewController


/** 初始化方法 */
- (instancetype)initWithModel:(ZWArticleAdvertiseModel *)model;

@end
