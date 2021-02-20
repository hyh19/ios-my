#import <Foundation/Foundation.h>
#import "ZWArticleAdvertiseModel.h"

/**
 *  @author 陈新存
 *  @ingroup utility
 *  @brief 广告跳转管理器
 */
@interface ZWAdvertiseSkipManager : NSObject

/**
 * 广告跳转类型处理方法
 * @param controller 从这个controller跳转到广告对应页面
 * @param model      广告模型
 */
+ (void)pushViewController:(UIViewController *)controller
    withAdvertiseDataModel:(ZWArticleAdvertiseModel *)model;

@end
