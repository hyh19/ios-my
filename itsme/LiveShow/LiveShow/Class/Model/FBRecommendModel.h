#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @brief 推荐主播数据模型
 */

@interface FBRecommendModel : NSObject

/** 主播头像 */
@property (strong, nonatomic) NSString *image;

/** 主播名称 */
@property (strong, nonatomic) NSString *name;

/** 主播粉丝人数 */
@property (strong, nonatomic) NSString *followedNum;

/** 主播收到钻石数量 */
@property (strong, nonatomic) NSString *diamondNum;

/** 主播ID */
@property (strong, nonatomic) NSString *uid;

/** 主播开播状态 */
@property (strong, nonatomic) NSString *status;

/** 主播等级 */
@property (strong, nonatomic) NSString *level;

/** 主播签名 */
@property (strong, nonatomic) NSString *subscription;

@end
