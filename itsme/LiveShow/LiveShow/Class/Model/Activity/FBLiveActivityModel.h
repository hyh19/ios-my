#import "FBBaseModel.h"
#import "FBRoomActivityModel.h"

/**
 *  @author 林思敏
 *  @brief  直播间活动入口的模型
 */

@interface FBLiveActivityModel : FBBaseModel

/** 领取后未送出去的礼物数量 */
@property (nonatomic, copy) NSString *num;

@end
