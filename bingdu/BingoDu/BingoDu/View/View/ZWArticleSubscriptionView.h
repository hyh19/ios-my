#import <UIKit/UIKit.h>
#import "ZWSubscriptionModel.h"

/**
 *  @author  黄玉辉
 *  @ingroup view
 *  @brief   新闻详情底部订阅控件
 */
@interface ZWArticleSubscriptionView : UIView

/**
 *  @brief  初始化方法
 *
 *  @param frame      位置和宽高
 *  @param model      订阅号数据模型
 *  @param controller 当前视图所在的视图控制器
 */
- (instancetype)initWithFrame:(CGRect)frame
                        model:(ZWSubscriptionModel *)model
           attachedController:(UIViewController *)controller;

@end
