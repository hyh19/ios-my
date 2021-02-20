#import "ZWReviewNewsHistoryList.h"

@implementation ZWReviewNewsHistoryList
//已登录用户添加评论过的新闻标示 退出账号不清空 12点清空
+(void)addAlreadyReviewNewsUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewNewsUser"])
    {
        //该账户评论成功过的新闻id集合
        NSMutableArray *newsReviewIds=[[NSMutableArray alloc]init];
        [newsReviewIds safe_addObject:newsId];
        NSMutableDictionary *userDictionary=[[NSMutableDictionary alloc]init];
        [userDictionary safe_setObject:newsReviewIds forKey:[ZWUserInfoModel userID]];
        [userDefaultes setObject:userDictionary forKey:@"alreadyReviewNewsUser"];
        [userDefaultes synchronize];
    }else
    {
        NSMutableDictionary *userDictionary=[NSMutableDictionary dictionaryWithDictionary:[userDefaultes valueForKey:@"alreadyReviewNewsUser"]];
        if ([userDictionary.allKeys containsObject:[ZWUserInfoModel userID]]) {
            NSMutableArray *newsReviewIds=[[NSMutableArray alloc]initWithArray:userDictionary[[ZWUserInfoModel userID]]];
            if ([newsReviewIds containsObject:newsId]) {
                ZWLog(@"该账户已经评论过该新闻并加分");
            }else {
                [newsReviewIds safe_addObject:newsId];
                [userDictionary safe_setObject:newsReviewIds forKey:[ZWUserInfoModel userID]];
                [userDefaultes setObject:userDictionary forKey:@"alreadyReviewNewsUser"];
                [userDefaultes synchronize];
            }
        }else
        {
            //新建该用户评论新闻的本地标示
            NSMutableArray *newsReviewIds=[[NSMutableArray alloc]init];
            [newsReviewIds safe_addObject:newsId];
            [userDictionary safe_setObject:newsReviewIds forKey:[ZWUserInfoModel userID]];
            [userDefaultes setObject:userDictionary forKey:@"alreadyReviewNewsUser"];
            [userDefaultes synchronize];
        }
    }
}
//查询该用户有无评论过该新闻做评论加分提示
+(BOOL)queryAlreadyReviewNewsUser:(NSString *)newsId
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewNewsUser"])
    {
        return NO;
    }else
    {
        NSMutableDictionary *userDictionary=[userDefaultes valueForKey:@"alreadyReviewNewsUser"];
        if ([[userDictionary allKeys] containsObject:[ZWUserInfoModel userID]]) {
            NSMutableArray *newsReviewIds= userDictionary[[ZWUserInfoModel userID]];
            if ([newsReviewIds containsObject:newsId]) {
                return YES;
            }else
                return NO;
        }else
            return NO;
    }
    return NO;
}
//清空用户登录时评论过的新闻标示
+(void)cleanAlreadyReviewNewsUser
{
    NSUserDefaults *userDefaultes= [NSUserDefaults standardUserDefaults];
    if(![userDefaultes valueForKey:@"alreadyReviewNewsUser"])
    {
        [userDefaultes removeObjectForKey:@"alreadyReviewNewsUser"];
    }
}
@end
