#import "ZWReviewLikeHistoryList.h"

@implementation ZWReviewLikeHistoryList
//未登录用户操作获取积分 做该newId的本地标示并保存在data1
//当用户登录时  给该用户加分并需要做该用户浏览过未登时的新闻评论点赞标示 添加在data2 同时data1清空 //每天12点也要清空data1 data2
//已登录用户新闻评论点赞的时候需要查本地 是否浏览过 做标示 并缓存在data2 同时判断该账户有无点赞该新闻评论并加分 是否需要重新加分

//未登录用户添加评论点赞过的新闻标示 12点清空 （暂时么有做，记得加上）
+(void)addAlreadyReviewLikeNoUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewLikeNoUser"])
    {
        NSMutableArray *userIds=[[NSMutableArray alloc]init];
        [userIds safe_addObject:newsId];
        [userDefaultes setObject:userIds forKey:@"alreadyReviewLikeNoUser"];
        [userDefaultes synchronize];
    }else
    {
        NSMutableArray *userIds=[[NSMutableArray alloc]initWithArray:[userDefaultes valueForKey:@"alreadyReviewLikeNoUser"] ];
        if ([userIds containsObject:newsId]) {
            ZWLog(@"当前未登录，已经为此新闻评论点赞并加分了");
        }else{
            [userIds safe_addObject:newsId];
            [userDefaultes setObject:userIds forKey:@"alreadyReviewLikeNoUser"];
            [userDefaultes synchronize];
        }
    }
}
//清空未登录时点赞过的新闻标示
+(void)cleanAlreadyReviewLikeNoUser
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewLikeNoUser"])
    {
        [userDefaultes removeObjectForKey:@"alreadyReviewLikeNoUser"];
    }
}
//查询未登录时有无点赞过该新闻做分享加分提示
+(BOOL)queryAlreadyReviewLikeNoUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewLikeNoUser"])
    {
        return NO;
    }else
    {
        NSMutableArray *userIds=[userDefaultes valueForKey:@"alreadyReviewLikeNoUser"];
        if ([userIds containsObject:newsId]) {
            return YES;
        }
    }
    return NO;
}
//当用户登录帐号时导入本地点赞过的新闻标示到该账号同时清空本地标示
+(void)importLocalAlreadyReviewLikeNoUser
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if([userDefaultes valueForKey:@"alreadyReviewLikeNoUser"]) {
        NSMutableArray *userIds=[userDefaultes valueForKey:@"alreadyReviewLikeNoUser"];
        if(![userDefaultes valueForKey:@"alreadyReviewLikeUser"]) {
            //导入本地分享标示到该用户
            NSMutableDictionary *userDictionary=[[NSMutableDictionary alloc]init];
            [userDictionary safe_setObject:userIds forKey:[ZWUserInfoModel userID]];
            [userDefaultes setObject:userDictionary forKey:@"alreadyReviewLikeUser"];
            [userDefaultes synchronize];
        }else {
            NSMutableDictionary *userDictionary=[NSMutableDictionary dictionaryWithDictionary:[userDefaultes valueForKey:@"alreadyReviewLikeUser"]];
            //先查询本地有无保存过该用户无则新建 有则添加
            if ([userDictionary.allKeys containsObject:[ZWUserInfoModel userID]]) {
                NSMutableArray *newsSharedIds= [[NSMutableArray alloc]initWithArray:userDictionary[[ZWUserInfoModel userID]]];
                for (NSString *useId in userIds ){
                    [newsSharedIds safe_addObject:useId];
                }
                //去重
                NSSet *set = [NSSet setWithArray:newsSharedIds];
                NSArray *sortSetArray=[set allObjects];
//                NSArray *sortDesc = @[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]];
//                NSArray *sortSetArray = [set sortedArrayUsingDescriptors:sortDesc];
                [userDictionary safe_setObject:sortSetArray forKey:[ZWUserInfoModel userID]];
                [userDefaultes setObject:userDictionary forKey:@"alreadyReviewLikeUser"];
                [userDefaultes synchronize];
            }else {
                //新建该用户点赞新闻的本地标示
                NSMutableArray *newsSharedIds=[[NSMutableArray alloc]init];
                [newsSharedIds addObjectsFromArray:userIds];
                [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
                [userDefaultes setObject:userDictionary forKey:@"alreadyReviewLikeUser"];
                [userDefaultes synchronize];
            }
        }
    }
}
//已登录用户添加点赞过的新闻标示 退出账号不清空 12点清空
+(void)addAlreadyReviewLikeUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewLikeUser"])
    {
        //该账户点赞成功过的新闻id集合
        NSMutableArray *newsSharedIds=[[NSMutableArray alloc]init];
        [newsSharedIds safe_addObject:newsId];
        NSMutableDictionary *userDictionary=[[NSMutableDictionary alloc]init];
        [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
        [userDefaultes setObject:userDictionary forKey:@"alreadyReviewLikeUser"];
        [userDefaultes synchronize];
    }else
    {
        NSMutableDictionary *userDictionary=[NSMutableDictionary dictionaryWithDictionary:[userDefaultes valueForKey:@"alreadyReviewLikeUser"]];
        if ([userDictionary.allKeys containsObject:[ZWUserInfoModel userID]]) {
            NSMutableArray *newsSharedIds=[[NSMutableArray alloc]initWithArray:userDictionary[[ZWUserInfoModel userID]]];
            if ([newsSharedIds containsObject:newsId]) {
                ZWLog(@"该账户已经点赞过该新闻并加分");
            }else {
                [newsSharedIds safe_addObject:newsId];
                [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
                [userDefaultes setObject:userDictionary forKey:@"alreadyReviewLikeUser"];
                [userDefaultes synchronize];
            }
        }else
        {
            //新建该用户点赞新闻的本地标示
            NSMutableArray *newsSharedIds=[[NSMutableArray alloc]init];
            [newsSharedIds safe_addObject:newsId];
            [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
            [userDefaultes setObject:userDictionary forKey:@"alreadyReviewLikeUser"];
            
        }
    }
}
//查询有用户登录时有无点赞过该新闻做分享加分提示
+(BOOL)queryAlreadyReviewLikeUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewLikeUser"])
    {
        return NO;
    }else
    {
        NSMutableDictionary *userDictionary=[userDefaultes valueForKey:@"alreadyReviewLikeUser"];
        if ([[userDictionary allKeys] containsObject:[ZWUserInfoModel userID]]) {
            NSMutableArray *newsSharedIds= userDictionary[[ZWUserInfoModel userID]];
            if ([newsSharedIds containsObject:newsId]) {
                return YES;
            }else
                return NO;
        }else
            return NO;
    }
    return NO;
}
//清空用户登录时点赞过的新闻标示
+(void)cleanAlreadyReviewLikeUser
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewLikeUser"])
    {
        [userDefaultes removeObjectForKey:@"alreadyReviewLikeUser"];
    }
}

@end
