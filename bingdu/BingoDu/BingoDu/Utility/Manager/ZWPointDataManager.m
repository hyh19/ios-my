#import "ZWPointDataManager.h"
#import "ZWIntegralRuleModel.h"
#import "ZWIntegralStatisticsModel.h"
#import "NSDate+NHZW.h"

@implementation ZWPointDataManager

+ (void)addPointForAdvertisementWithURL:(NSString *)URL {
    
    // 存储的key命名为：ClickAD＋用户ID，目的是让登录的每个用户都能加到点击广告的积分
    NSString *userID = ([ZWUserInfoModel login] ? [ZWUserInfoModel userID] : @"");
    
    id ADValue = [NSUserDefaults loadValueForKey:[NSString stringWithFormat:@"ClickAD%@", userID]];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    NSString *today = [NSDate todayString];
    
    NSMutableArray *urlArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    if ([ADValue isKindOfClass:[NSDictionary class]]) {
        
        dict = [ADValue mutableCopy];
        
        urlArray = [dict[@"ADUrl"] mutableCopy];
        
        if (urlArray.count > 0) {
            
            if ([today isEqualToString:dict[@"date"]] && [dict[@"ADUrl"] containsObject:URL]) {
                return;
            }
        }
        
        if (![today isEqualToString:dict[@"date"]]) {
            [urlArray removeAllObjects];
        }
    }
    
    [urlArray safe_addObject:URL];
    
    [dict setValue:[NSDate todayString] forKey:@"date"];
    
    [dict setValue:urlArray forKey:@"ADUrl"];
    
    [NSUserDefaults saveValue:dict ForKey:[NSString stringWithFormat:@"ClickAD%@", userID]];
    
    // 增加点击广告积分
    ZWIntegralRuleModel *itemRule = (ZWIntegralRuleModel *)[ZWIntegralStatisticsModel saveIntergralItemData:IntegralLookAdvertising];
    
    ZWIntegralStatisticsModel *obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    
    if (obj) {
        
        float lookAdvertising = [obj.lookAdvertising floatValue];
        
        if (lookAdvertising == [itemRule.pointMax floatValue]) {
            
            return ;
            
        } else {
            
            [obj setLookAdvertising:[NSNumber numberWithFloat:(lookAdvertising+[itemRule.pointValue floatValue])]];
            
            [ZWIntegralStatisticsModel saveCustomObject:obj];
            
            NSString *str=[NSString stringWithFormat:@"浏览广告为您带来了%.1f分",[itemRule.pointValue floatValue]];
            
            occasionalHint(str);
        }
    }
}

@end
