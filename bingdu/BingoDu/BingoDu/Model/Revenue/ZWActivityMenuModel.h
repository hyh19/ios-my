#import "ZWMenuModel.h"
#import "ZWActivityModel.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 收入界面活动菜单数据模型
 */
@interface ZWActivityMenuModel : ZWMenuModel

/** 活动数据模型 */
@property (nonatomic, strong) ZWActivityModel *activity;

@end
