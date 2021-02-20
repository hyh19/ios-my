#import "FBBaseModel.h"
@class FBUserInfoModel;

/**
 *  @author 李世杰
 *  @brief  粉丝榜用户资料模型
 */

@interface FBContributionModel : FBBaseModel
@property (nonatomic, copy) NSString *contribution;
@property (nonatomic, strong) FBUserInfoModel *user;

@end
