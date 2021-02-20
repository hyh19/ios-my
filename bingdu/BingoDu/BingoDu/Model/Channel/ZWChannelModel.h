#import <Foundation/Foundation.h>

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 频道模型
 */
@interface ZWChannelModel : NSObject

/**频道ID*/
@property (nonatomic,strong) NSNumber *channelID;

/**频道名称*/
@property (nonatomic,strong) NSString *channelName;

/**是否被选中*/
@property (nonatomic,strong) NSNumber *isSelected;

/**频道序号*/
@property (nonatomic,strong) NSNumber *sort;

/**创建时间*/
@property (nonatomic,strong) NSString *createTime;

/**更新时间*/
@property (nonatomic,strong) NSString *updateTime;

/**频道的唯一标示*/
@property (nonatomic, strong) NSString *mapping;

/**实例化频道模型*/
+(id)channelModelFromDictionary:(NSDictionary *)dic;

@end

