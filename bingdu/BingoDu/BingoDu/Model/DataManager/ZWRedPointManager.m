#import "ZWRedPointManager.h"
#import "ZWVersionManager.h"
#import "NSDate+NHZW.h"
#import "ZWTabBarController.h"
#import "ZWFriendsNetworkManager.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWGuideManager.h"

@implementation ZWRedPointManager

+ (void)manageRedPointAtFriendsModuleWithStatus:(void (^)(BOOL hidden))status
{
    if(![ZWUserInfoModel login])//未登录取消
    {
        return;
    }
    [[ZWFriendsNetworkManager sharedInstance]
     loadFriendsReplyMyComment:[ZWUserInfoModel userID]
     offset:@"0"
     rows:1
     direction:@"after"
     isCache:NO
     succed:^(id result)
     {
         if ([result count]>0)
         {
             id array_list=[result objectForKey:@"resultList"];
             if ([array_list isKindOfClass:[NSArray class]])
             {
                 
                 NSArray *commentList=(NSArray*)array_list;
                 NSDictionary *dic=(NSDictionary*)commentList[0];
                 NSString *replyTime= dic[@"reviewTime"];
                 NSString* localReplyTime=  [[NSUserDefaults standardUserDefaults] objectForKey:NEWEST_RELPLY_KEY];
                 if (!localReplyTime)
                 {
                     return;
                 }
                 
                 if ([replyTime longLongValue] >[localReplyTime longLongValue])
                 {
                     status(NO);
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:BINGYOU_HAVA_NEWREPLY];
                 }
                 else
                 {
                     status(YES);
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:BINGYOU_HAVA_NEWREPLY];
                 }
             }
         }
         else
         {
         }
     }
     failed:nil];
}

@end
