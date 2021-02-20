#import "ZWNewsIntegralManager.h"
#import "ZWReviewNewsHistoryList.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWNewsNetworkManager.h"
#import "ZWReadNewsHistoryList.h"
#import "ZWShareNewsHistoryList.h"
#import "ZWMyNetworkManager.h"
#import "ZWLocationManager.h"
#import "ZWPointDataManager.h"

@implementation ZWNewsIntegralManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZWNewsIntegralManager *_integraManager;
    dispatch_once(&onceToken, ^{
        _integraManager = [[ZWNewsIntegralManager alloc] init];
        
    });
    return _integraManager;
}
-(BOOL)addInteraWithType:(ZWNewsIntegralType) integraType  model:(ZWNewsModel*)newsModle
{
    switch (integraType)
    {
        case ZWCommentIntegra:
        {
            //先查询本地并判断 需不需要加分  评论某条新闻可以加分但一天只能加一次
            if (![ZWReviewNewsHistoryList queryAlreadyReviewNewsUser:newsModle.newsId])
            {
                [ZWReviewNewsHistoryList addAlreadyReviewNewsUser:newsModle.newsId];
                [self reviewJoy:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReview]];
                return YES;
            }
            else
            {
                return NO;
            }
        }
            break;
        case ZWReadIntegra:
        {
            /**软文广告加5分*/
            if ([newsModle.advType isEqualToString:@"ADVERTORIAL"])
            {
                [self requestClickNormolAD:newsModle];
            }
            else
            {
              [self sendReadIntegralToServer:newsModle.newsId channelId:newsModle.channel newsType:newsModle.newsSourceType];
            }
        }
            break;
        case ZWShareNewsIntegra:
        {

            [self logSuccessOperate:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareRead] newsId:newsModle.newsId];
        }
            break;
        default:
            break;
    }
    return NO;
}
-(void)reviewJoy:(ZWIntegralRuleModel *)itemRule
{
    if ([ZWUserInfoModel userID]) {
        ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
        if (obj) {
            float review=[obj.review floatValue];
            if (review==[itemRule.pointMax floatValue]) {
                occasionalHint(@"评论发表成功");
                return ;
            }else
            {
                [obj setReview:[NSNumber numberWithFloat:review+[itemRule.pointValue floatValue]]];
                NSString *str=[NSString stringWithFormat:@"评论发表成功，获得%.1f分",[itemRule.pointValue floatValue]];
                occasionalHint(str);
            }
            [ZWIntegralStatisticsModel saveCustomObject:obj];
        }
    }
}

/**
 *  5秒后发送阅读积分到后台
 */
-(void)sendReadIntegralToServer:(NSString*)newsId channelId:(NSString*)channelId  newsType:(NSInteger)newsType
{
    typeof(self) __weak weakSelf = self;
    [[ZWNewsNetworkManager sharedInstance] sendUserReadIntegralWithUserId:[ZWUserInfoModel userID] channerID:channelId newsID:newsId newsType:[NSString stringWithFormat:@"%ld",newsType] succed:^(id result)
     
     {
         //增加本地阅读积分
         [weakSelf readNewsExtrapoints:newsId];
         
     }
     failed:^(NSString *errorString)
     {
         NSString *str=[NSString stringWithFormat:@"阅读积分发送失败：%@",errorString];
         ZWLog(@"%@",str);
     }];
}
/**
*  5秒后发送积分成功后增加本地阅读新闻积分
*/
-(void)readNewsExtrapoints:(NSString*)newsId
{
    [ZWUtility saveReadNewsNum];
    
    if ([ZWUserInfoModel userID])
    {
        if (![ZWReadNewsHistoryList queryAlreadyReadNewsUser:newsId])
        {
            [ZWReadNewsHistoryList addAlreadyReadNewsUser:newsId];
            [self readNewsAndExtrapoints:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReadNews]];
        }
    }
    else
    {
        if (![ZWReadNewsHistoryList queryAlreadyReadNewsNoUser:newsId])
        {
            [ZWReadNewsHistoryList addAlreadyReadNewsNoUser:newsId];
            [self readNewsAndExtrapoints:[ZWIntegralStatisticsModel saveIntergralItemData:IntegralReadNews]];
        }
    }
}
/**
 *  浏览新闻加积分 然后存储本地
 *  @param itemRule
 */
-(void)readNewsAndExtrapoints:(ZWIntegralRuleModel *)itemRule
{
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj)
    {
        if ([obj.readNews floatValue]>=[itemRule.pointMax floatValue])
        {
            return ;
        }
        else
        {
            [obj setReadNews:[NSNumber numberWithFloat:[obj.readNews floatValue]+[itemRule.pointValue floatValue]]];
            [ZWIntegralStatisticsModel saveCustomObject:obj];
            NSString *totalIncome=[NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
            [[NSNotificationCenter defaultCenter] postNotificationName:IntegralTotalIncome object:totalIncome];
        }
    }
}
#pragma mark -  social share
-(void)logSuccessOperate:(ZWIntegralRuleModel *)itemRule newsId:(NSString*)newsId
{
    [ZWIntegralStatisticsModel saveIntergralItemData:IntegralShareRead];
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    if (obj)
    {
        if ([obj.shareRead intValue]==[itemRule.pointMax intValue])
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                occasionalHint(@"分享新闻成功");
            });
        }
        else
        {
            if (![ZWUserInfoModel userID])
            {
                if (![ZWShareNewsHistoryList queryAlreadyShareNewsNoUser:newsId]) {
                    [ZWShareNewsHistoryList addAlreadyShareNewsNoUser:newsId];
                    [obj setShareRead:[NSNumber numberWithFloat:([obj.shareRead floatValue]+[[itemRule pointValue] floatValue])]];
                    [ZWIntegralStatisticsModel saveCustomObject:obj];
                    NSString*str=[NSString stringWithFormat:@"分享新闻成功,获得%.1f分",[itemRule.pointValue floatValue]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        occasionalHint(str);
                    });
                }else
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        occasionalHint(@"分享新闻成功");
                    });
                    
                }
            }
            else
            {
                if (![ZWShareNewsHistoryList queryAlreadyShareNewsUser:newsId])
                {
                    [ZWShareNewsHistoryList addAlreadyShareNewsUser:newsId];
                    [obj setShareRead:[NSNumber numberWithFloat:([obj.shareRead floatValue]+[itemRule.pointValue floatValue])]];
                    [ZWIntegralStatisticsModel saveCustomObject:obj];
                    NSString*str=[NSString stringWithFormat:@"分享新闻成功,获得%.1f分",[itemRule.pointValue floatValue]];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             occasionalHint(str);
                    });
               
                    
                }
                else
                {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        occasionalHint(@"分享新闻成功");
                    });
                }
            }
            NSString *totalIncome=[NSString stringWithFormat:@"%.2f",[ZWIntegralStatisticsModel sumIntegrationBy:obj]];
            [[NSNotificationCenter defaultCenter] postNotificationName:IntegralTotalIncome object:totalIncome];
        }
    }
    ZWLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
}

- (void)requestClickNormolAD:(ZWNewsModel*)newModle
{
    [[ZWMyNetworkManager sharedInstance] clickADWithUserID:[ZWUserInfoModel userID]
                                                      city:[ZWLocationManager city]
                                                  province:[ZWLocationManager province]
                                                  latitude:[ZWLocationManager latitude]
                                                 longitude:[ZWLocationManager longitude]
                                                      adID:newModle.adId
                                                  position:newModle.position
                                                    adType:newModle.advType
                                                 channelID:newModle.channel
                                                   isCache:NO succed:^(id result)
     {
           [ZWPointDataManager addPointForAdvertisementWithURL:newModle.detailUrl];
     }
     failed:^(NSString *errorString)
     {
     }];
}
@end
