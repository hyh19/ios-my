#import <UIKit/UIKit.h>
#import "ZWNewsTalkModel.h"

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 弹幕的单条评论界面
 */

@interface ZWBarrageItemView : UIView

/**记录该评论的排序*/
@property (nonatomic, assign)NSInteger itemIndex;

/**评论数据模型*/
@property (nonatomic, strong) ZWNewsTalkModel *model;

@end
