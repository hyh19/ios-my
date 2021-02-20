#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 每条新闻的点赞model 由数据库生成
 */
@interface NewsLike : NSManagedObject
/**
 新闻是否点赞 0/1
 */
@property (nonatomic, retain) NSNumber * alreadyApproval;
/**
 新闻id
 */
@property (nonatomic, retain) NSNumber * newsId;
/**
 新闻所属频道
 */
@property (nonatomic, retain) NSNumber * channel;

@end
