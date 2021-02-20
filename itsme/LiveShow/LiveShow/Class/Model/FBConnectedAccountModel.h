#import "FBBaseModel.h"

/**
 *  @author 林思敏
 *  @brief 绑定账号Model
 */

@interface FBConnectedAccountModel : FBBaseModel

/** 用户绑定信息 */
@property (nonatomic, copy) NSString *name;
@property (strong, nonatomic) NSString *platform;
@property (strong, nonatomic) NSString *creatTime;
@property (strong, nonatomic) NSString *register_ip;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *status;

@end
