#import "ZWGetFriendsSingleton.h"
#import "ZWMyNetworkManager.h"
#import <ShareSDK/SSDKFriendsPaging.h>

@interface ZWGetFriendsSingleton ()

@property (nonatomic, strong)NSMutableArray *friendsArray;
@property (nonatomic, assign)NSInteger _page;

@end


@implementation ZWGetFriendsSingleton

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZWGetFriendsSingleton *_userInfo;
    dispatch_once(&onceToken, ^{
        _userInfo = [[ZWGetFriendsSingleton alloc] init];
    });
    
    if(_userInfo)
    {
        _userInfo._page = 0;
    }
    
    return _userInfo;
}

- (NSMutableArray *)friendsArray
{
    if(!_friendsArray)
        _friendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    return _friendsArray;
}

- (void)uploadFriends
{
    [ShareSDK getFriends:SSDKPlatformTypeSinaWeibo
                  cursor:self._page
                    size:50
          onStateChanged:^(SSDKResponseState state, SSDKFriendsPaging *paging, NSError *error) {
              
              if (state == SSDKResponseStateSuccess)
              {
                  for (int i = 0; i < [paging.users count]; i++)
                  {
                      SSDKUser *userInfo = [paging.users objectAtIndex:i];
                      NSDictionary *dict = @{@"source" : @"WEIBO",
                                             @"openId" : [userInfo rawData][@"idstr"],
                                            @"nickName": [userInfo rawData][@"screen_name"],
                                                @"sex" : [[userInfo rawData][@"gender"] isEqualToString:@"m"] ? @"M" : @"F"};
                      [[self friendsArray] safe_addObject:dict];
                  }
                  if(paging.hasNext == YES)
                  {
                      self._page = paging.nextCursor;
                      [self uploadFriends];
                  }
                  else
                  {
                      [[ZWMyNetworkManager sharedInstance] updataFriendsWithUserID:[ZWUserInfoModel userID] friends:[self friendsArray] isCache:NO succed:^(id result) {
                      } failed:^(NSString *errorString) {
                      }];
                  }
              }

          }];
}

@end
