#import "FBBaseModel.h"
#import "FBUserInfoModel.h"

/**
 *  @author 黄玉辉
 *  @brief 礼物信息
 */
@interface FBGiftModel : FBBaseModel

/** 礼物ID */
@property (nonatomic, strong) NSNumber *giftID;

/** 礼物名字 */
@property (nonatomic, copy) NSString *name;

/** 礼物类型 */
@property (nonatomic, strong) NSNumber *type;

/** 礼物价格 */
@property (nonatomic, strong) NSNumber *gold;

/** 礼物列表小图 */
@property (nonatomic, copy) NSString *icon;

/** 礼物动画大图 */
@property (nonatomic, copy) NSString *image;

/** 送出用户 */
@property (nonatomic, strong) FBUserInfoModel *fromUser;

/** 接收用户 */
@property (nonatomic, strong) FBUserInfoModel *toUser;

@property (nonatomic, strong) NSNumber *exp;

/** 礼物动画图片序列包 */
@property (nonatomic, copy) NSString *imageZip;

@end
