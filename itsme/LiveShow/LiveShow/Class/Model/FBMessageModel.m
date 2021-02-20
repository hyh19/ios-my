#import "FBMessageModel.h"

@implementation FBMessageModel

- (instancetype)init {
    if (self = [super init]) {
        self.nickColor = COLOR_MAIN;
        self.contentColor = [UIColor hx_colorWithHexString:@"ffffff"];
        self.hitColor = [UIColor whiteColor];
        self.type = kMessageTypeDefault;
        self.messageID = [[NSUUID UUID] UUIDString];
    }
    return self;
}

+ (FBMessageModel *)systemMessageWithContent:(NSString *)content {
    FBUserInfoModel *user = [[FBUserInfoModel alloc] init];
    user.nick = kDefaultSystemNickName;
    FBMessageModel *message = [[FBMessageModel alloc] init];
    message.type = kMessageTypeSystem;
    message.fromUser = user;
    message.contentColor = COLOR_ASSIST;
    message.content = content;
    return message;
}

+ (FBMessageModel *)enterMessageForVIP:(FBUserInfoModel *)user {
    FBMessageModel *message = [[FBMessageModel alloc] init];
    message.type = kMessageTypeVIPEnter;
    message.fromUser = user;
    message.contentColor = COLOR_VIP_ENTER;
    message.content = [NSString stringWithFormat:kLocalizationSuperUserNotice, user.nick];
    return message;
}


+ (FBMessageModel *)assistantMessageWithContent:(NSString *)content {
    FBUserInfoModel *user = [[FBUserInfoModel alloc] init];
    user.nick = kDefaultSystemNickName;
    FBMessageModel *message = [[FBMessageModel alloc] init];
    message.type = kMessageTypeAssistant;
    message.fromUser = user;
    message.contentColor = COLOR_ASSIST_TEXT;
    message.content = content;
    return message;
}

+ (FBMessageModel *)enterMessageForCommonUser:(FBUserInfoModel *)user {
    FBMessageModel *message = [[FBMessageModel alloc] init];
    message.type = kMessageTypeCommonUserEnter;
    message.fromUser = user;
    message.contentColor = COLOR_TEXT_HIGHLIGHT;
    message.content = [NSString stringWithFormat:@"%@ %@", user.nick, kLocalizationLabelComing];
    return message;
}

@end
