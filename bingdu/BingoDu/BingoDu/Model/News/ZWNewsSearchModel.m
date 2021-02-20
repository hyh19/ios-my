#import "ZWNewsSearchModel.h"

@implementation ZWNewsSearchModel

+(id)newsSearchModelFromDictionary:(NSDictionary *)dictionary
                        searchType:(SearchType)searchType
{
    if(dictionary)
    {
        ZWNewsSearchModel *model = [[ZWNewsSearchModel alloc] init];
        
        [model updateSearchModelWithDictionary:dictionary  searchType:searchType];
        
        return model;
    }
    return nil;
}

- (void)updateSearchModelWithDictionary:(NSDictionary *)dictionary
                             searchType:(SearchType)searchType
{
    [self updateNewsCountWithDictionary:dictionary];
    [self updataNewsListWithDictionary:dictionary searchType:searchType];
}

- (void)resetNewsData
{
    [self setNewsSum:@(0)];
    [self setTopicSum:@(0)];
    [self setFavoriteSum:@(0)];
    [self setNewsListArray:nil];
    [self setTopicListArray:nil];
    [self setFavoriteListArray:nil];
}

- (void)updateNewsCountWithDictionary:(NSDictionary *)dictionary
{
    if([[dictionary allKeys] containsObject:@"newsSum"])
    {
        [self setNewsSum:@([dictionary[@"newsSum"] integerValue])];
    }
    
    if([[dictionary allKeys] containsObject:@"topicSum"])
    {
        [self setTopicSum:@([dictionary[@"topicSum"] integerValue])];
    }
    
    if([[dictionary allKeys] containsObject:@"favoriteSum"])
    {
        [self setFavoriteSum:@([dictionary[@"favoriteSum"] integerValue])];
    }
}

- (void)updataNewsListWithDictionary:(NSDictionary *)dictionary
                          searchType:(SearchType)searchType
{
    switch (searchType) {
        case NewsType:
            
            [self setNewsListArray:[self addNewsObjectInArray:self.newsListArray dataSource:dictionary]];
            
            break;
            
        case TopicType:
            
            [self setTopicListArray:[self addNewsObjectInArray:self.topicListArray dataSource:dictionary]];
            
            break;
            
        case FavoriteType:
            
            [self setFavoriteListArray:[self addNewsObjectInArray:self.favoriteListArray dataSource:dictionary]];
            
            break;
            
        default:
            break;
    }
}

- (NSArray *)addNewsObjectInArray:(NSArray *)newsArray
                       dataSource:(NSDictionary *)dictionary
{
    NSMutableArray *tempNewsArray = [[NSMutableArray alloc] initWithArray:newsArray];
    for(NSDictionary *dict in dictionary[@"newsList"])
    {
        ZWNewsModel *newsModel = [ZWNewsModel modelWithData:dict];
        
        [tempNewsArray addObject:newsModel];
    }
    return [tempNewsArray copy];
}

@end
