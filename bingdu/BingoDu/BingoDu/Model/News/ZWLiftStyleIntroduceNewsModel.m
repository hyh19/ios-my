

#import "ZWLiftStyleIntroduceNewsModel.h"
#import "ZWNewsHotReadModel.h"

@implementation ZWLiftStyleIntroduceNewsModel
+(id)talkModelFromDictionary:(NSDictionary *)dic
{
    ZWLiftStyleIntroduceNewsModel *lifeModel=[[ZWLiftStyleIntroduceNewsModel alloc] init];
    lifeModel.title=dic[@"name"];
    NSArray *subArray=dic[@"options"];
    for (NSDictionary *d in subArray)
    {
        ZWNewsHotReadModel *readModel=[ZWNewsHotReadModel readModelFromDictionary:d];
        [lifeModel.subModelArray safe_addObject:readModel];
    }

    return lifeModel;
}
-(id)init
{
    self=[super init];
    if (self)
    {
        _subModelArray=[[NSMutableArray alloc] init];
    }
    return self;
}
@end
