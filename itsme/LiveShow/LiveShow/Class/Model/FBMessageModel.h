#import "FBBaseModel.h"
#import "FBUserInfoModel.h"

/**
 *  @author 黄玉辉
 *  @brief 直播室和开播室的聊天消息
 */
@interface FBMessageModel : FBBaseModel

/** 消息发送者 */
@property (nonatomic, strong) FBUserInfoModel *fromUser;

/** 消息内容 */
@property (nonatomic, copy) NSString *content;

/** 昵称颜色 */
@property (nonatomic, strong) UIColor *nickColor;

/** 消息颜色 */
@property (nonatomic, strong) UIColor *contentColor;

/** 点亮颜色 */
@property (nonatomic, strong) UIColor *hitColor;

/** 消息类型 */
@property (nonatomic) FBMessageType type;

@property (nonatomic, copy) NSString *messageID;

/** 系统消息 */
+ (FBMessageModel *)systemMessageWithContent:(NSString *)content;

/** 土豪进场消息 */
+ (FBMessageModel *)enterMessageForVIP:(FBUserInfoModel *)user;

/** 普通用户进场消息 */
+ (FBMessageModel *)enterMessageForCommonUser:(FBUserInfoModel *)user;

/** 小助手消息 */
+ (FBMessageModel *)assistantMessageWithContent:(NSString *)content;

@end
