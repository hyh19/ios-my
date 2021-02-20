#import "FBBaseModel.h"

/**
 *  @author 黄玉辉
 *  @brief 举报信息
 */
@interface FBReportModel : FBBaseModel

/** 被举报用户的ID */
@property (nonatomic, strong) NSString *userID;

/** 直播ID */
@property (nonatomic, strong) NSString *liveID;

/** 举报类型 */
@property (nonatomic, strong) NSString *type;

/** 举报信息 */
@property (nonatomic, strong) NSString *message;


@end
