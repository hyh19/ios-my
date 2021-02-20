#import "GVUserDefaults.h"

@interface GVUserDefaults (Properties)

/** 用户ID */
@property (nonatomic, weak) NSString *userID;

/** 登录Token */
@property (nonatomic, weak) NSString *tokenString;

/** 登录类型 */
@property (nonatomic, weak) NSString *loginType;

/** 用户头像 */
@property (nonatomic, weak) NSData *avatarData;

/** 礼物列表 */
@property (nonatomic, weak) NSArray *giftList;

/** 弹幕信息 */
@property (nonatomic, weak) NSDictionary *danmuInfo;

/** 全部网络请求接口数据 */
@property (nonatomic, weak) NSDictionary *URLData;

/** 登录用户的资料，序列化成NSData保存在NSUserDefaults，避免因为某些Key为NULL导致崩溃 */
@property (nonatomic, weak) NSData *userData;

/** 缓存内购商品数据 */
@property (nonatomic, weak) NSData *productData;

/** 内购商品ID列表 */
@property (nonatomic, weak) NSArray *productIdentifiers;

/**
 *  @since 2.0.0
 *  @brief 服务器类型：正式服、测试服
 */
@property (nonatomic, weak) NSNumber *serverType;

@end
