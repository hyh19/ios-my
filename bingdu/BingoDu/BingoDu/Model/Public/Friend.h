#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 并友列表数据model
 */
@interface Friend : NSManagedObject
/**
 *  分割一条数据的标记
 */
@property (nonatomic, retain) NSNumber * actionType;
/**
 *  并友对新闻的评论
 */
@property (nonatomic, retain) NSString * comment;
/**
 *  并友的头像url
 */
@property (nonatomic, retain) NSString * headImgUrl;
/**
 *  并友评论的id
 */
@property (nonatomic, retain) NSNumber * id;

/**
 *  新闻详情的url
 */
@property (nonatomic, retain) NSString * newsDetailUrl;
/**
 *  新闻概要的图片url
 */
@property (nonatomic, retain) NSString * newsPicPath;
/**
 *  新闻的标题
 */
@property (nonatomic, retain) NSString * newsTitle;
/**
 *  频道id
 */
@property (nonatomic, retain) NSNumber * channelID;
/**
 *  并友昵称
 */
@property (nonatomic, retain) NSString * nickName;
/**
 *  发布的时间戳
 */
@property (nonatomic, retain) NSNumber * operTime;
/**
 *  发布的时间 YYYY-MM-DD HH-MM-SS格式的
 */
@property (nonatomic, retain) NSString * relativeOperTime;
/**
 *   并友评论的新闻的id
 */
@property (nonatomic, retain) NSNumber * targetId;
/**
 *  点赞数
 */
@property (nonatomic, retain) NSNumber * praiseNum;
/**
 *  评论数
 */
@property (nonatomic, retain) NSNumber * commentCount;
/**
 *  总体新闻类型
 */
@property (nonatomic, retain) NSNumber * newsType;

/**
 *  立即新闻的新闻类型
 */
@property (nonatomic, retain) NSNumber * displayType;
/**
 *  并友的朋友列表
 */
@property (nonatomic, retain) NSSet *friends;
@end

@interface Friend (CoreDataGeneratedAccessors)
/**
 *  添加朋友对象到coredata
 *  @ingroup model
 *  @param value 添加的对象
 */
- (void)addFriendsObject:(NSManagedObject *)value;
/**
 *  从coredata移除对象
 *  @param value 移除的对象
 */
- (void)removeFriendsObject:(NSManagedObject *)value;
/**
 *  添加并友的并友列表
 *  @param values 并友对象
 */
- (void)addFriends:(NSSet *)values;
/**
 *  删除并友到并友列表
 *  @param values 删除并友对象
 */
- (void)removeFriends:(NSSet *)values;

@end
