#import "ZWMessageModel.h"

@implementation ZWMessageModel

- (void)setDict:(NSDictionary *)dict{
    
    _dict = dict;
    
    NSTimeInterval intel = [dict[@"created_at"] longLongValue];
    
    NSDate *data = [NSDate dateWithTimeIntervalSince1970:intel/1000];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString *destDateString = [dateFormatter stringFromDate:data];
    
    self.time = destDateString;
    
    self.content = dict[@"content"];
    
    self.reply_id = dict[@"reply_id"];
    
    if([dict[@"type"] isEqualToString:@"dev_reply"])
    {
        self.type = MessageTypeOther;
        self.icon = @"icon_logo";
    }
    else
    {
        self.type = MessageTypeMe;
        self.icon = [[ZWUserInfoModel sharedInstance] headImgUrl];
    }
}

@end
