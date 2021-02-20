#import <Foundation/Foundation.h>

/**
 *  @author 陈新存
 *  @ingroup utility
 *  @brief 消息推送数据模型
 */
@interface ZWPushMessageManager : NSObject

/**记录是否是否有推送消息需要处理的状态*/
@property (nonatomic, assign) BOOL status;
/**推送消息数据*/
@property (nonatomic, strong) NSDictionary *dataSource;

- (void)handlePushMessage;

/**类实例共享*/
+ (instancetype)sharedInstance;
/**接收到消息推送的数据处理*/
- (void)receiveNotificationWithDictionary:(NSDictionary *)dictionary;
/**清除消息推送数据*/
- (void)cleanNotifition;

/** 注册推送*/
- (void)registerUserNotification;

@end
