#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 频道托管对象
 */
@interface ChannelItem : NSManagedObject

/**频道ID*/
@property (nonatomic, retain) NSNumber * channelId;
/**频道名*/
@property (nonatomic, retain) NSString * channelName;
/**属否被选中*/
@property (nonatomic, retain) NSNumber * isSelect;
/**频道序号*/
@property (nonatomic, retain) NSNumber * sort;
/**创建时间*/
@property (nonatomic, retain) NSString * createTime;
/**跟新时间*/
@property (nonatomic, retain) NSString * updateTime;
/**是否已经加载了该频道的新闻数据*/
@property (nonatomic, retain) NSNumber * loadFinished;
/**频道的唯一标示*/
@property (nonatomic, retain) NSString *mapping;

@end
