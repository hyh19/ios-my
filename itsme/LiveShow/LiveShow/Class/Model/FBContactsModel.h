#import "FBUserInfoModel.h"

/**
 *  @author 李世杰
 *  @brief  列表用户Cell模型
 */

@interface FBContactsModel : FBBaseModel
/** 直播状态 */
@property (nonatomic, assign, getter=isLive) NSInteger live;
/** 关系 */
@property (nonatomic, copy) NSString *relation;
/** 用户资料 */
@property (nonatomic, strong) FBUserInfoModel *user;

@end
