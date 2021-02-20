#import "ZWImageCommentModel.h"

@implementation ZWImageCommentModel
+(id)imageCommentModelFromDictionary:(NSDictionary *)dic
{
    ZWImageCommentModel *model=[[ZWImageCommentModel alloc]init];
    [model setCommmentImageId:dic[@"picCommentId"]];
    [model setCommentImageUrl:dic[@"picUrl"]];
    [model setCommentImageComment:dic[@"content"]];
     model.xPercent=[dic[@"xData"] floatValue];
     model.yPercent=[dic[@"yData"] floatValue];
     model.userId=[NSString stringWithFormat:@"%d",[dic[@"uid"] intValue]];
    model.newsId=[NSString stringWithFormat:@"%ld",[dic[@"newsId"] integerValue]];
    return model;
}
@end
