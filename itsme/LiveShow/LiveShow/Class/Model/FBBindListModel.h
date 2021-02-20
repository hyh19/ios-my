#import <Foundation/Foundation.h>

/**
 *  @author 李世杰
 *  @brief  用户绑定第三方信息
 */

@interface FBBindListModel : NSObject

/** flybird */
@property (nonatomic, copy) NSString *appid;
/** 平台用户ID */
@property (nonatomic, copy) NSString *openid;
/** 平台 */
@property (nonatomic, copy) NSString *platform;
/** userID */
@property (nonatomic, copy) NSString *uid;
/** 是否绑定fb */
@property (nonatomic, assign, getter=isBindFacebook) BOOL bindFacebook;
/** 是否绑定tw */
@property (nonatomic, assign, getter=isBindTwitter) BOOL bindTwitter;

@end
