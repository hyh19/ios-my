#import "ZWPrizeModel.h"

@implementation ZWPrizeModel
+(id)prizeOBJByDictionary:(NSDictionary *)dictionary
{
    ZWPrizeModel *przeMode=[[ZWPrizeModel alloc] init];
    [przeMode setPrizeId:[[dictionary objectForKey:@"id"] integerValue]];
    [przeMode setPrizeImageUrl:[dictionary objectForKey:@"image"]];
    [przeMode setPrizeInfo:[dictionary objectForKey:@"info"]];
    [przeMode setPrizeName:[dictionary objectForKey:@"name"]];
    [przeMode setPrizeType:[[dictionary objectForKey:@"type"] integerValue]];
    return przeMode;
}
@end
