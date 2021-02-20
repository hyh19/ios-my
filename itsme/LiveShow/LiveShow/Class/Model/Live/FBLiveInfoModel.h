#import "FBBaseModel.h"
#import "FBUserInfoModel.h"
#import "FBHotRecordModel.h"

/**
 *  @author 林思敏
 *  @author 黄玉辉
 *  @brief 直播信息数据模型
 */
@interface FBLiveInfoModel : NSObject

/** 主播信息 */
@property (nonatomic, strong) FBUserInfoModel *broadcaster;

/** 所在城市 */
@property (nonatomic, copy) NSString *city;

/** 封面图片 */
@property (nonatomic, copy) NSString *imageURLString;

/** 观众人数 */
@property (nonatomic, strong) NSNumber *spectatorNumber;

/** 直播ID */
@property (nonatomic, copy) NSString* live_id;

/** 房间ID */
@property (nonatomic, copy) NSString *roomID;

/** 直播所在的分组 */
@property (nonatomic, strong) NSNumber* group;

@property (nonatomic, copy) NSString *name;

/** 直播的tag */
@property (nonatomic, copy) NSString *tagName;

@property (nonatomic, copy) NSString *distance;

/** 热门列表中的直播需要插入的回放数组 */
@property (nonatomic, strong) NSMutableArray *hotRecords;

@end
