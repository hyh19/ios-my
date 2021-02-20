#import "ZWPicModel.h"

@implementation ZWPicModel
+(id)pictureModelFromDictionary:(NSDictionary *)dic
{
    ZWPicModel *pic=[[ZWPicModel alloc]init];
    [pic setPicId:dic[@"picId"]];
    [pic setNewsId:dic[@"newsId"]];
    if (dic[@"picName"]) {
        [pic setPicName:dic[@"picName"]];
    }else{
        [pic setPicName:@""];
    }
    [pic setPicUrl:dic[@"picUrl"]];
    
    return pic;
}
@end
