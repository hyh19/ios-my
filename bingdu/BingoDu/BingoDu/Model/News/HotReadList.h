#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 热读缓存对象，已没用（热度没做本地缓存）暂时不删
 */
@interface HotReadList : NSManagedObject

@property (nonatomic, retain) NSNumber * newsId;
@property (nonatomic, retain) NSString * newsTitle;
@property (nonatomic, retain) NSString * newsSource;
@property (nonatomic, retain) NSNumber * displayType;
@property (nonatomic, retain) NSNumber * promotion;
@property (nonatomic, retain) NSString * detailUrl;
@property (nonatomic, retain) NSNumber * channel;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * publishTime;
@property (nonatomic, retain) NSNumber * zNum;
@property (nonatomic, retain) NSNumber * cNum;
@property (nonatomic, retain) NSNumber * rNum;
@property (nonatomic, retain) NSNumber * sNum;
@property (nonatomic, retain) NSNumber * dNum;
@property (nonatomic, retain) NSNumber * lNum;

@end
