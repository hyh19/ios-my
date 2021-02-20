#import "ZWNewsHomeInfo.h"

@implementation ZWNewsHomeInfo
+(id)newsInfoBy:(NSMutableDictionary *)dic
{
    ZWNewsHomeInfo *news=[[ZWNewsHomeInfo alloc]init];
    [news setNewsTitle:dic[@"title"]];
    [news setNewsTime:dic[@"time"]];
    [news setNewsImgUrls:dic[@"imgArray"]];
    [news setNewsLikeNumbers:dic[@"likes"]];
    [news setNewsPlatform:dic[@"platform"]];
    [news setNewsReviewNumbers:dic[@"reviews"]];
    [news setNewsType:[dic[@"type"] intValue]];
    return news;
}
@end
