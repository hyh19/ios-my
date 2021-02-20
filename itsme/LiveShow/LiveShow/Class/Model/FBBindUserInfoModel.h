#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @brief 绑定账号信息Model
 */

@interface FBBindUserInfoModel : NSObject

/** 用户绑定信息 */
@property (strong, nonatomic) NSString *openid;
@property (strong, nonatomic) NSString *platform;
@property (strong, nonatomic) NSString *creatTime;
@property (strong, nonatomic) NSString *register_ip;
@property (strong, nonatomic) NSString *infos;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *nick;
@property (strong, nonatomic) NSString *flush_openid;
@property (strong, nonatomic) NSString *appid;

@end
