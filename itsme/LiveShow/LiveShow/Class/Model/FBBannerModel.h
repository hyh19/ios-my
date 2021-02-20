#import "FBBaseModel.h"

/**
 *  @author 黄玉辉
 *  @brief Banner广告
 */
@interface FBBannerModel : FBBaseModel

/** 活动名称 */
@property (nonatomic, copy) NSString *activityName;

/** 广告图片 */
@property (nonatomic, copy) NSString *imageURL;

/** 活动地址 */
@property (nonatomic, copy) NSString *activityURL;

/** 主播UID */
@property (nonatomic, copy) NSString *broadcasterID;

/** 活动类型 */
@property (nonatomic, copy) NSString *activityType;

@end
