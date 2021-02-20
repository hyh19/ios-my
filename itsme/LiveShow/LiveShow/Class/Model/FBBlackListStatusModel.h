#import "FBBaseModel.h"

/**
 *  @author 李世杰
 *  @brief  黑名单模型
 */

@interface FBBlackListStatusModel : FBBaseModel
/** 黑名单状态 blacklist为已拉黑*/
@property (nonatomic, copy) NSString *stat;
/** 用户uid */
@property (nonatomic, copy) NSString *uid;
@end
