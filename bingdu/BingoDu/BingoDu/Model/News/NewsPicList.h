#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 图片缩略图model 用于存储
 */
@interface NewsPicList : NSManagedObject
/**
 图片id
 */
@property (nonatomic, retain) NSNumber * picId;
/**
 新闻id
 */
@property (nonatomic, retain) NSNumber * newsId;
/**
 图片名称
 */
@property (nonatomic, retain) NSString * picName;
/**
 图片地址
 */
@property (nonatomic, retain) NSString * picUrl;
/**
 图片存储索引
 */
@property (nonatomic, retain) NSNumber * picIndex;

@end
