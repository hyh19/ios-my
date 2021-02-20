#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 热议modle对象
 */
@interface HotTalkList : NSManagedObject
/**
 *  评论内容
 */
@property (nonatomic, retain) NSString * comment;
/**
 *  评论时间
 */
@property (nonatomic, retain) NSString * reviewTime;
/**
 *  评论举报次数
 */
@property (nonatomic, retain) NSNumber * reportCount;
/**
 *  评论点赞数目
 */
@property (nonatomic, retain) NSNumber * praiseCount;
/**
 *  评论者昵称
 */
@property (nonatomic, retain) NSString * nickName;
/**
 *  评论id
 */
@property (nonatomic, retain) NSNumber * commentId;
/**
 *  评论者头像url
 */
@property (nonatomic, retain) NSString * uIcon;

@end
