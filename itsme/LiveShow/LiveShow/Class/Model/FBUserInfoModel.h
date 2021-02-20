#import "FBBaseModel.h"
#import <Foundation/Foundation.h>

/**
 *  @author 李世杰
 *          黄玉辉
 *  @brief  用户资料模型
 */

@interface FBUserInfoModel : FBBaseModel

/** 个性签名 */
@property (nonatomic, copy) NSString *Description;
/** 位置 */
@property (nonatomic, copy) NSString *location;
/** 昵称 */
@property (nonatomic, copy) NSString *nick;
/** 头像 */
@property (nonatomic, copy) NSString *portrait;
/** 等级 */
@property (nonatomic, strong) NSNumber *ulevel;
/** 性别 */
@property (nonatomic, strong) NSNumber *gender;
/** 用户ID */
@property (nonatomic, strong) NSString *userID;
/** 性别图片 */
@property (nonatomic, strong) UIImage *genderImage;
/** 用户头像 */
@property (nonatomic, strong) UIImage *avatarImage;

/** 主播签约标识 */
@property (nonatomic, strong) NSNumber *verified;

/** 是否签约主播 */
@property (nonatomic, getter=isVerifiedBroadcastor) BOOL verifiedBroadcastor;

/** 是否为禁言管理员，默认为NO */
@property (nonatomic) BOOL isTalkManager;

/** 是否被禁言，默认为NO */
@property (nonatomic) BOOL isTalkBanned;

/** Description的高度 */
@property (nonatomic, assign) CGFloat DescriptionHeight;

/** 是否是登录用户自己 */
- (BOOL)isLoginUser;

/** 登录用户是否关注了该用户，如果该用户是登录用户自己，则认为已经关注了 */
- (void)checkFollowingStatus:(void (^)(BOOL result))block;

@end
