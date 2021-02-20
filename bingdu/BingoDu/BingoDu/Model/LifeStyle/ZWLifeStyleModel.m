
#import "ZWLifeStyleModel.h"

@implementation ZWLifeStyleModel

+(id)loadModelFromDictionary:(NSDictionary *)dictionary
{
    ZWLifeStyleModel *model = [[ZWLifeStyleModel alloc] init];
    
    [model setImageName:dictionary[@"imageName"]];
    
    [model setName:dictionary[@"name"]];
    
    [model setBoyID:@([dictionary[@"boyID"] integerValue])];
    
    [model setGirlID:@([dictionary[@"girlID"] integerValue])];
    
    return model;
}

@end
