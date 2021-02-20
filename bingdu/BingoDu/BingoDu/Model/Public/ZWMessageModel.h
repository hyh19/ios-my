#import <Foundation/Foundation.h>

/**消息类型*/
typedef enum {
    
    MessageTypeMe = 0, /** 自己发的*/
    MessageTypeOther = 1 /**别人发得*/
    
} MessageType;


/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 消息model
 */
@interface ZWMessageModel : NSObject

/**用户头像地址url*/
@property (nonatomic, copy) NSString *icon;
/**消息的发出时间*/
@property (nonatomic, copy) NSString *time;
/**消息内容*/
@property (nonatomic, copy) NSString *content;
/**消息ID号*/
@property (nonatomic, copy) NSString *reply_id;
/**消息类型*/
@property (nonatomic, assign) MessageType type;
/**整条消息的所有信息内容存放在这个dict中*/
@property (nonatomic, copy) NSDictionary *dict;

@end
