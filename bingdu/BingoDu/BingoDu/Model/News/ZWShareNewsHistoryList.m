#import "ZWShareNewsHistoryList.h"

@implementation ZWShareNewsHistoryList

//未登录用户操作获取积分 做该newId的本地标示并保存在data1
//当用户登录时  给该用户加分并需要做该用户分享过未登时的新闻标示 添加在data2 同时data1清空 //每天12点也要清空data1 data2
//已登录用户分享新闻的时候需要查本地 是否分享过 做标示 并缓存在data2 同时判断该账户有无分享过该新闻并加分 是否需要重新加分

//未登录用户添加分享过的新闻标示 12点清空 （暂时么有做，记得加上）
+(void)addAlreadyShareNewsNoUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyShareNewsNoUser"])
    {
        NSMutableArray *userIds=[[NSMutableArray alloc]init];
        [userIds safe_addObject:newsId];
        [userDefaultes setObject:userIds forKey:@"alreadyShareNewsNoUser"];
        [userDefaultes synchronize];
    }else
    {
        NSMutableArray *userIds=[[NSMutableArray alloc]initWithArray:[userDefaultes valueForKey:@"alreadyShareNewsNoUser"] ];
        if ([userIds containsObject:newsId]) {
            ZWLog(@"当前未登录，已经分享过此新闻并加分了");
        }else{
            [userIds safe_addObject:newsId];
            [userDefaultes setObject:userIds forKey:@"alreadyShareNewsNoUser"];
            [userDefaultes synchronize];
        }
    }
}
//清空未登录时分享过的新闻标示
+(void)cleanAlreadyShareNewsNoUser
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyShareNewsNoUser"])
    {
        [userDefaultes removeObjectForKey:@"alreadyShareNewsNoUser"];
    }
}
//查询未登录时有无分享过该新闻做分享加分提示
+(BOOL)queryAlreadyShareNewsNoUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyShareNewsNoUser"])
    {
        return NO;
    }else
    {
        NSMutableArray *userIds=[userDefaultes valueForKey:@"alreadyShareNewsNoUser"];
        if ([userIds containsObject:newsId]) {
            return YES;
        }
    }
    return NO;
}
//当用户登录帐号时导入本地分享过的新闻标示到该账号同时清空本地标示
+(void)importLocalAlreadyShareNewsNoUser
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if([userDefaultes valueForKey:@"alreadyShareNewsNoUser"]) {
        NSMutableArray *userIds=[userDefaultes valueForKey:@"alreadyShareNewsNoUser"];
        if(![userDefaultes valueForKey:@"alreadyShareNewsUser"]) {
            //导入本地分享标示到该用户
            NSMutableDictionary *userDictionary=[[NSMutableDictionary alloc]init];
            [userDictionary safe_setObject:userIds forKey:[ZWUserInfoModel userID]];
            [userDefaultes setObject:userDictionary forKey:@"alreadyShareNewsUser"];
            [userDefaultes synchronize];
        }else {
            NSMutableDictionary *userDictionary=[NSMutableDictionary dictionaryWithDictionary:[userDefaultes valueForKey:@"alreadyShareNewsUser"]];
            //先查询本地有无保存过该用户无则新建 有则添加
            if ([userDictionary.allKeys containsObject:[ZWUserInfoModel userID]]) {
                NSMutableArray *sharedNewsIDs= [[NSMutableArray alloc]initWithArray:userDictionary[[ZWUserInfoModel userID]]];
                for (NSString *newsID in userIds ){
                    [sharedNewsIDs safe_addObject:newsID];
                }
                // 去重
                NSSet *set = [NSSet setWithArray:sharedNewsIDs];
                [userDictionary safe_setObject:[set allObjects] forKey:[ZWUserInfoModel userID]];
                [userDefaultes setObject:userDictionary forKey:@"alreadyShareNewsUser"];
                [userDefaultes synchronize];
            }else {
                //新建该用户分享新闻的本地标示
                NSMutableArray *newsSharedIds=[[NSMutableArray alloc]init];
                [newsSharedIds addObjectsFromArray:userIds];
                [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
                [userDefaultes setObject:userDictionary forKey:@"alreadyShareNewsUser"];
                [userDefaultes synchronize];
            }
        }
    }
}
//已登录用户添加分享过的新闻标示 退出账号不清空 12点清空
+(void)addAlreadyShareNewsUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyShareNewsUser"])
    {
        //该账户分享成功过的新闻id集合
        NSMutableArray *newsSharedIds=[[NSMutableArray alloc]init];
        [newsSharedIds safe_addObject:newsId];
        NSMutableDictionary *userDictionary=[[NSMutableDictionary alloc]init];
        [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
        [userDefaultes setObject:userDictionary forKey:@"alreadyShareNewsUser"];
        [userDefaultes synchronize];
    }else
    {
        NSMutableDictionary *userDictionary=[NSMutableDictionary dictionaryWithDictionary:[userDefaultes valueForKey:@"alreadyShareNewsUser"]];
        if ([userDictionary.allKeys containsObject:[ZWUserInfoModel userID]]) {
            NSMutableArray *newsSharedIds=[[NSMutableArray alloc]initWithArray:userDictionary[[ZWUserInfoModel userID]]];
            if ([newsSharedIds containsObject:newsId]) {
                ZWLog(@"该账户已经分享过该新闻并加分");
            }else {
                [newsSharedIds safe_addObject:newsId];
                [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
                [userDefaultes setObject:userDictionary forKey:@"alreadyShareNewsUser"];
                [userDefaultes synchronize];
            }
        }else
        {
            //新建该用户分享新闻的本地标示
            NSMutableArray *newsSharedIds=[[NSMutableArray alloc]init];
            [newsSharedIds safe_addObject:newsId];
            [userDictionary safe_setObject:newsSharedIds forKey:[ZWUserInfoModel userID]];
            [userDefaultes setObject:userDictionary forKey:@"alreadyShareNewsUser"];
           
        }
    }
}
//查询有用户登录时有无分享过该新闻做分享加分提示
+(BOOL)queryAlreadyShareNewsUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyShareNewsUser"])
    {
        return NO;
    }else
    {
        NSMutableDictionary *userDictionary=[userDefaultes valueForKey:@"alreadyShareNewsUser"];
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
//清空用户登录时分享过的新闻标示
+(void)cleanAlreadyShareNewsUser
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyShareNewsUser"])
    {
        [userDefaultes removeObjectForKey:@"alreadyShareNewsUser"];
    }
}
@end
