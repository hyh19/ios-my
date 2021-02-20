
#import <Foundation/Foundation.h>
#import "ZWNewsTalkModel.h"
#import "ZWBarrageItemView.h"

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 记录弹幕对象的位置以及数据信息model
 */
@interface ZWBarrageInfoModel : NSObject

/**X坐标起点*/
@property (nonatomic, assign)CGFloat originX;

/**Y坐标起点*/
@property (nonatomic, assign)CGFloat originY;

/**对象的标示*/
@property (nonatomic, assign)NSInteger tag;

/**对象的数据源*/
@property (nonatomic, strong)ZWNewsTalkModel *model;

/**初始化对象*/
+(id)initModelFromBarrageItem:(ZWBarrageItemView *)barrageItem;

@end
