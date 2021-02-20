#import "FBBaseModel.h"

/**
 *  @author 黄玉辉
 *
 *  @brief 礼物动画的配置信息
 */
@interface FBGiftAnimationInfoModel : FBBaseModel

/** 动画类型 */
@property (nonatomic) NSNumber *type;

/** 动画时长 */
@property (nonatomic) NSNumber *time;

@end
