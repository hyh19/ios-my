#import "ZWArticleAdvertiseModel.h"
#import "ZWNewsModel.h"

@implementation ZWArticleAdvertiseModel
+(instancetype)ariticleModelBy:(NSDictionary *)dic
{
    ZWArticleAdvertiseModel *adversizeModel=[[ZWArticleAdvertiseModel alloc]init];
    [adversizeModel setAdversizeID:[NSString stringWithFormat:@"%@", dic[@"id"]]];
    [adversizeModel setAdversizePositionID:[NSString stringWithFormat:@"%@",dic[@"position"]]];
    [adversizeModel setAdversizeChannerID:[NSString stringWithFormat:@"%@",dic[@"channel"]]];
    [adversizeModel setAdversizeType:dic[@"advType"]];
    [adversizeModel setAdversizeTitle:dic[@"title"]];
    [adversizeModel setAdversizeImgUrl:dic[@"img"]];
    [adversizeModel setIsAdAllianceAd:[dic[@"isAdAllianceAd"] boolValue]];
    //跳转类型
    [adversizeModel setRedirectType:(RedirectType)[dic[@"redirectType"] integerValue]];
    //广告id
    if(dic[@"redirectTargetId"])
    {
        [adversizeModel setRedirectTargetId:[dic[@"redirectTargetId"] stringValue]];
    }
    //广告url
    if (dic[@"url"])
    {
        [adversizeModel setAdversizeDetailUrl:dic[@"url"]];
    }
    //是否有联盟广告url
    if (dic[@"allianceRequestUrl"])
    {
        [adversizeModel setUnionAdvertiseUrl:dic[@"allianceRequestUrl"]];
    }
    return adversizeModel;
}
+(instancetype)ariticleModelByNewsModel:(ZWNewsModel *)newsModel
{
    ZWArticleAdvertiseModel *adversizeModel=[[ZWArticleAdvertiseModel alloc]init];
    [adversizeModel setAdversizeID:[NSString stringWithFormat:@"%@",newsModel.adId]];
    [adversizeModel setAdversizePositionID:[NSString stringWithFormat:@"%@",newsModel.position]];
    [adversizeModel setAdversizeChannerID:[NSString stringWithFormat:@"%@",newsModel.channel]];
    [adversizeModel setAdversizeType:newsModel.advType];
    [adversizeModel setAdversizeTitle:newsModel.newsTitle];
    if (newsModel.picList.count > 0) {
        [adversizeModel setAdversizeImgUrl:((ZWPicModel*)(newsModel.picList[0])).picUrl];
    }else{
        [adversizeModel setAdversizeImgUrl:@""];
    }
    [adversizeModel setRedirectType:newsModel.redirectType];
    [adversizeModel setRedirectTargetId:newsModel.redirectTargetId];
    [adversizeModel setAdversizeDetailUrl:newsModel.detailUrl];
    return adversizeModel;
}
@end
