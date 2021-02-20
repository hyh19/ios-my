#import "FBBaseModel.h"
#import "FBUserInfoModel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @brief 直播回放数据模型
 */
@interface FBRecordModel : FBBaseModel

/** 主播信息 */
@property (nonatomic, strong) FBUserInfoModel *user;

/** 点击数 */
@property (nonatomic, strong) NSNumber *clickNumber;

/** 创建时间 */
@property (nonatomic, strong) NSNumber *createTime;

/** 回放ID */
@property (nonatomic, copy) NSString *modelID;

/** 直播标题 */
@property (nonatomic, copy) NSString *title;

/** 消息查询地址 */
@property (nonatomic, copy) NSString *messageURLString;

/** 录制直播地址 */
//@property (nonatomic, copy) NSString *recordURLString;
@property (nonatomic, strong) NSArray *arrayRecordURL;

@end
