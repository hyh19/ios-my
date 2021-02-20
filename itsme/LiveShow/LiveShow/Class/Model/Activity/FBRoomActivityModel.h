#import "FBBaseModel.h"

/**
 *  @author 林思敏
 *  @brief  首页活动入口的模型
 */

@interface FBRoomActivityModel : FBBaseModel

/** 活动id */
@property (nonatomic, copy) NSString *aid;

/** 活动名称 */
@property (nonatomic, copy) NSString *name;

/** 活动标题 */
@property (nonatomic, copy) NSString *title;

/** 活动主页动态图、弹框图、多语言包 */
@property (nonatomic, copy) NSString *img_bag;

/** 活动直播礼物图 */
@property (nonatomic, copy) NSString *img_bag_live;

/** 活动创建时间 */
@property (nonatomic, copy) NSString *create_time;

/** 活动开始时间 */
@property (nonatomic, copy) NSString *start_time;

/** 活动结束时间 */
@property (nonatomic, copy) NSString *end_time;

/** 礼物id */
@property (nonatomic, strong) NSNumber *gid;

/** 礼物金额 */
@property (nonatomic, copy) NSString *gold;

/** url */
@property (nonatomic, copy) NSString *url;

@end
