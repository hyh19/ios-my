#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 保持登陆者对某条评论的操作信息的对象
 */
@interface TalkInfoList : NSManagedObject
/**
 *  评论者的id
 */
@property (nonatomic, retain) NSNumber * userId;
/**
 *  是否点赞
 */
@property (nonatomic, retain) NSNumber * alreadyApproval;
/**
 *  是否举报
 */
@property (nonatomic, retain) NSNumber * alreadyReport;
/**
 *  评论的id
 */
@property (nonatomic, retain) NSNumber * commentId;

@end
