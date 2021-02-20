#import "ZWNewsHotReadModel.h"

@implementation ZWNewsHotReadModel
+(id)readModelFromDictionary:(NSDictionary *)dic
{
    ZWNewsHotReadModel *read=[[ZWNewsHotReadModel alloc]init];
    
    //生活方式推荐的列表
    if (dic[@"priority"] && dic[@"classifyId"])
    {
        [read setNewsTitle:dic[@"title"]];
        [read setDetailUrl:dic[@"url"]];
        [read setNewsImageUrl:dic[@"icon"]];
        return read;
    }
    [read setNewsId:[NSNumber numberWithInt:[dic[@"newsId"] intValue]]];
    [read setNewsTitle:dic[@"newsTitle"]];
    [read setPublishTime:dic[@"publishTime"]];
    [read setNewsSource:dic[@"newsSource"]];
    if (dic[@"author"]) {
        [read setAuthor:dic[@"author"]];
    }else
        [read setAuthor:@""];
    [read setPromotion:[NSNumber numberWithInt:[dic[@"promotion"] intValue]]];
    [read setChannel:[NSNumber numberWithInt:[dic[@"channel"] intValue]]];
    [read setDisplayType:[NSNumber numberWithInt:[dic[@"displayType"] intValue]]];
    [read setDetailUrl:dic[@"detailUrl"]];
    [read setRNum:[NSNumber numberWithInt:[dic[@"readNum"] intValue]]];
    [read setCNum:[NSNumber numberWithInt:[dic[@"commentNum"] intValue]]];
    [read setZNum:[NSNumber numberWithInt:[dic[@"praiseNum"] intValue]]];
    [read setLNum:[NSNumber numberWithInt:[dic[@"likeNum"] intValue]]];
    [read setDNum:[NSNumber numberWithInt:[dic[@"dislikeNum"] intValue]]];
    [read setSNum:[NSNumber numberWithInt:[dic[@"shareNum"] intValue]]];
    //取图片
    NSArray *picArray=dic[@"picList"];
    if (picArray && picArray.count>0)
    {
        [read setNewsImageUrl:[[picArray objectAtIndex:0] objectForKey:@"picUrl"]];
    }
    return read;
}
@end
