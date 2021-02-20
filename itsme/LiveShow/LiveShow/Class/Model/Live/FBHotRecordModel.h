#import "FBBaseModel.h"
#import "FBRecordModel.h"

/**
 *  @author 林思敏
 *  @brief 热门回放数据模型
 */

@interface FBHotRecordModel : FBBaseModel

/** 热门回放模块ID */
@property (nonatomic, strong) NSString *modelId;

/** 热门回放模块名称 */
@property (nonatomic, strong) NSString *modelName;

/** 热门回放模块分类 */
@property (nonatomic, copy) NSString *modelSort;

/** 热门回放模块创建时间 */
@property (nonatomic, copy) NSString *modelCreatTime;

/** 热门回放模块地区 */
@property (nonatomic, copy) NSString *modelCountry;

/** 热门回放model */
@property (nonatomic, strong) NSArray *records;

@end
