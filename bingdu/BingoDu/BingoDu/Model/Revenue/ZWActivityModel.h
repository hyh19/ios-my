#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 活动数据模型
 */
@interface ZWActivityModel : NSObject

/** 活动ID */
@property (nonatomic, assign) long activityID;

/** 活动标题 */
@property (nonatomic, copy) NSString *title;

/** 活动副标题 */
@property (nonatomic, copy) NSString *subtitle;

/** 活动地址 */
@property (nonatomic, copy) NSString *url;

/** 初始化 */
- (instancetype)initWithActivityID:(long)activityID
                             title:(NSString *)title
                          subtitle:(NSString *)subtitle
                               url:(NSString *)url;

@end
