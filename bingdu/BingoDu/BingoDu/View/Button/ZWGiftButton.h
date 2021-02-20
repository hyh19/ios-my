#import <UIKit/UIKit.h>
#import "ZWGoodsModel.h"

/**
 *  @author 陈新存
 *  @ingroup view
 *  @brief 礼品按钮
 */
@interface ZWGiftButton : UIButton

/**
 创建一个礼品界面按钮
 @param frame 礼品的frame
 @param title 礼品名称
 @param image 礼品大图
 @param price 礼品价钱
 @param remain 礼品还剩余多少份
 @return 一个新的按钮ZWGiftButton
 */
- (id)initWithFrame:(CGRect)frame
         goodsModel:(ZWGoodsModel *)model;

@end
