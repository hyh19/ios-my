#import "ZWNewsModel.h"

@implementation ZWNewsModel

+ (instancetype)modelWithData:(NSDictionary *)dict {
    
    ZWNewsModel *model = [[ZWNewsModel alloc] initWithData:dict];
    
    return model;
}

- (instancetype)initWithData:(NSDictionary *)dict {
    
    if (self = [super init]) {
        
        [self setChannel:dict[@"channel"]];
        [self setCNum:dict[@"commentNum"]];
        [self setDetailUrl:dict[@"detailUrl"]?dict[@"detailUrl"]:@""];
        [self setDNum:dict[@"dislikeNum"]];
        
        if ([[dict allKeys] containsObject:@"displayType"]) {
            id obj =dict[@"displayType"];
            if (obj) {
                [self setDisplayType:[dict[@"displayType"] intValue]];
            }else
                [self setDisplayType:0];
        }
        else
            [self setDisplayType:0];
        [self setLNum:dict[@"likeNum"]];
        [self setNewsId:dict[@"newsId"]];
        
        if (dict[@"newsSource"]) {
            [self setNewsSource:dict[@"newsSource"]];
        }else
            [self setNewsSource:@""];
        
        if (dict[@"newsTitle"]) {
            [self setNewsTitle:dict[@"newsTitle"]];
        }else
        {
            [self setNewsTitle:@""];
        }
        [self setZNum:dict[@"praiseNum"]];
        [self setPublishTime:dict[@"publishTime"]];
        [self setReadNum:dict[@"readNum"]];
        [self setSNum:dict[@"shareNum"]];
        if (dict[@"timestamp"]) {
            [self setTimestamp:dict[@"timestamp"]];
        }else
        {
            [self setTimestamp:@""];
        }
        [self setState:ZWNormal];
        [self setLoadFinished:[NSNumber numberWithBool:NO]];
        
        [self setPosition:[NSString stringWithFormat:@"%d",[dict[@"position"] intValue]]];
        
        if([[dict allKeys] containsObject:@"topicTitle"])
        {
            [self setTopicTitle:dict[@"topicTitle"]];
        }
        
        NSArray *picList = (NSArray *)dict[@"picList"];
        NSMutableArray *list =[[NSMutableArray alloc]init];
        if ([picList count]>0) {
            for (int i=0; i<[picList count]; i++) {
                NSDictionary *dict=(NSDictionary*)picList[i];
                ZWPicModel *pic =[ZWPicModel pictureModelFromDictionary:dict];
                [pic setPicIndex:dict[@"picIndex"]];
                [list safe_addObject:pic];
            }
        }
        switch ([picList count]) {
            case 3: {
                self.newsPattern = kNewsPatternTypeMultiImage;
                break;
            }
            case 2:
            case 1: {
                self.newsPattern = kNewsPatternTypeSingleImage;
                break;
            }
            case 0: {
                self.newsPattern = kNewsPatternTypeText;
                break;
            }
            default: {
                self.newsPattern = kNewsPatternTypeText;
                break;
            }
        }
        
        if ([[dict allKeys] containsObject:@"advType"]) {
            
            [self setAdId:dict[@"adId"]];
            [self setAdvType:dict[@"advType"]];
            [self setSpread_state:ZWSpread_State];
            
            // 广告跳转类型
            if (dict[@"redirectType"]) {
                [self setRedirectType:(RedirectType)[dict[@"redirectType"] integerValue]];
            }
            
            // 广告跳转目标
            if (dict[@"redirectTargetId"]) {
                [self setRedirectTargetId:[dict[@"redirectTargetId"] stringValue]];
            }
            
            /** 软文广告 */
            if (![dict[@"advType"] isEqualToString:@"ADVERTORIAL"]) {
                self.newsPattern = kNewsPatternTypeInfoAD;
            }
            
        } else {
            [self setAdvType:@""];
            [self setSpread_state:ZWNoSpread_State];
        }
        
        [self setPicList:list];
        
        if (dict[@"onTop"]) {
            self.onTop = dict[@"onTop"];
        }
        
        if ([[dict allKeys] containsObject:@"newsType"]) {
            self.newsType = [dict[@"newsType"] integerValue];
        }
    }
    return self;
}

@end
