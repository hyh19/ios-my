//
//  XXProfileNetWorkManager.m
//  LiveShow
//
//  Created by lgh on 16/2/25.
//  Copyright © 2016年 XX. All rights reserved.
//

#import "FBProfileNetWorkManager.h"
#import "FBLoginInfoModel.h"

@interface FBProfileNetWorkManager()<UIAlertViewDelegate>

@end

@implementation FBProfileNetWorkManager

- (BOOL)loadUserInfoWithUserID:(NSString *)userID
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }

    GET_REQUEST(kRequestURLUserInfo);

    return YES;
}


- (BOOL)loadFollowingListWithUserID:(NSString *)userID
                           startRow:(NSUInteger)start
                              count:(NSUInteger)count
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"]    = userID;
        parameters[@"start"] = @(start);
        parameters[@"count"] = @(count);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLFollowingList
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
    
}


- (BOOL)loadFollowerListWithUserID:(NSString *)userID
                          startRow:(NSUInteger)start
                             count:(NSUInteger)count
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"]    = userID;
        parameters[@"start"] = @(start);
        parameters[@"count"] = @(count);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLFollowerList
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
}


- (BOOL)loadFollowNumberWithUserID:(NSString *)userID
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLFollowNumber
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
    
}


- (BOOL)loadContributionRankingWithUserID:(NSString *)userID
                                 startRow:(NSUInteger)start
                                    count:(NSUInteger)count
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure
                                  finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"]    = userID;
        parameters[@"start"] = @(start);
        parameters[@"count"] = @(count);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLContributionRanking
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)loadBlackListWithUserID:(NSString *)userID
                          start:(NSUInteger)start
                          count:(NSUInteger)count
                        success:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally {

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"uid"]   = userID;
        parameters[@"start"] = @(start);
        parameters[@"count"] = @(count);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLBlackList
       parameters:parameters
          success:success
          failure:failure
          finally:finally
     ];
    return YES;
}



- (BOOL)addToBlackListWithUserID:(NSString *)userID
                         success:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLAddBlack
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
    
}


- (BOOL)removeFromBlackListWithUserID:(NSString *)userID
                              success:(SuccessBlock)success
                              failure:(FailureBlock)failure
                              finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLDeleteBlack
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
    
}

- (BOOL)blackListStatusWithUserIDArray:(NSArray *)userIDArray
                               success:(SuccessBlock)success
                               failure:(FailureBlock)failure
                               finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"ids"] = [userIDArray componentsJoinedByString:@","];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLBlackStatus
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)addToFollowingListWithUserID:(NSString *)userID
                             success:(SuccessBlock)success
                             failure:(FailureBlock)failure
                             finally:(FinallyBlock)finally {
    [FBUtility checkCurrentNotifyState];
    [FBUtility askAPNS];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLFollow
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)removeFromFollowingListWithUserID:(NSString *)userID
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure
                                  finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLUnFollow
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

/** 获取推送状态 */
- (BOOL)getNotifyStatusWithUserID:(NSString *)userID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLNotifyStatus
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)switchNotifyStatusWithStat:(NSInteger)stat
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally; {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"stat"] = @(stat);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLSwitchNotifyStatus
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}


- (BOOL)addSomeoneToNotifyBlackWithUserID:(NSString *)userID
                                  success:(SuccessBlock)success
                                  failure:(FailureBlock)failure
                                  finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLAddSomeoneToNotifyBlack
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}


- (BOOL)removeSomeoneToNotifyBlackWithUserID:(NSString *)userID
                                     success:(SuccessBlock)success
                                     failure:(FailureBlock)failure
                                     finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLRemoveSomeoneToNotifyBlack
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}


- (BOOL)loadNotifyStatusListWithUserID:(NSString *)userID
                              startRow:(NSUInteger)start
                                 count:(NSUInteger)count
                               success:(SuccessBlock)success
                               failure:(FailureBlock)failure
                               finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"]    = userID;
        parameters[@"start"] = @(start);
        parameters[@"count"] = @(count);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLNotifyStatusList
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}


- (BOOL)getRelationWithUserID:(NSString *)userID
                      success:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLRelationWithOther
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)searchUsersWithKeyword:(NSString *)keyword
                      startRow:(NSUInteger)start
                         count:(NSUInteger)count
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"keyword"] = keyword;
        parameters[@"start"]   = @(start);
        parameters[@"count"]   = @(count);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLSearchUsers
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)loadProfitInfoSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLProfitInfo
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
    
}


- (BOOL)loadProfitRecordWithUserID:(NSString *)userID
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLProfitRecord
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)loadPaymentInfoWithUserID:(NSString *)userID
                          success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLPaymentInfo
       parameters:parameters
          success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

- (BOOL)loadExchangeInfoSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager GET:kRequestURLConversionRate
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
}


- (BOOL)updateUserInfoWithNick:(NSString *)nick
                   description:(NSString *)description
                      portrait:(NSString *)portrait
                        gender:(NSNumber *)gender
                       success:(SuccessBlock)success
                       failure:(FailureBlock)failure
                       finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"nick"]  = nick;
        parameters[@"description"] = description;
        parameters[@"portrait"] = portrait;
        parameters[@"gender"] = gender;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    
    [manager POST:kRequestURLUpdateUserInfo
       parameters:parameters
          success:success
          failure:failure
          finally:finally
     ];
    return YES;
}

- (BOOL)updateUserPortrait:(NSData *)portrait
          constructingBody:(ConstructingBodyWithBlock)constructingBody
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"portrait"] = portrait;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager POST:kRequestURLUpdatePortrait
       parameters:parameters
     constructing:constructingBody
          success:success
          failure:failure
          finally:finally];
    return YES;
}


- (BOOL)loadSomeoneRecordsWithUserID:(NSString *)userID
                              Offset:(int)offset
                               count:(int)count
                             success:(SuccessBlock)success
                             failure:(FailureBlock)failure
                             finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"]    = userID;
        parameters[@"start"] = @(offset);
        parameters[@"count"] = @(count);
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLSomeoneRecord)
    
    return YES;
}




- (BOOL)uploadFeedbackWithQuession:(NSString *)quession
                           success:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"msg"] = quession;
        
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    POST_REQUEST(kRequestURlFeedBack)
    
    return YES;
}


- (BOOL)getUserLiveStatusWithUserID:(NSString *)userID
                            success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLLiveStatus)
    
    return YES;
}



- (BOOL)deleteReplayLiveID:(NSString *)liveID
                   success:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"id"] = liveID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    //发一条广播去刷新个人中心的关注粉丝数量
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
    
    
    POST_REQUEST(kRequestURLDeleteReplay)
    
    return YES;
}



/** 获取用户绑定账号列表 */
- (BOOL)getUserBlindWithSuccess:(SuccessBlock)success
                        failure:(FailureBlock)failure
                        finally:(FinallyBlock)finally {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLBlindList)
    
    return YES;
}

- (BOOL)loadUserBlindWithPlatform:(NSString *)platform
                           openId:(NSString *)openId
                            token:(NSString *)token
                            appId:(NSString *)appId
                           secret:(NSString *)secret
                          Success:(SuccessBlock)success
                          failure:(FailureBlock)failure
                          finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = platform;
        parameters[@"openid"] = openId;
        parameters[@"access_token"] = token;
        parameters[@"appid"] = appId;
        parameters[@"secret"] = secret;
        
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    POST_REQUEST(kRequestURLBlindUser)
    
    return YES;
}

- (BOOL)getUserUNBlindWithPlatform:(NSString *)platform
                            Success:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = platform;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLUNBlindUser)
    
    return YES;
}

- (BOOL)getUserBlindInfosWithSuccess:(SuccessBlock)success
                             failure:(FailureBlock)failure
                             finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLBlindUserInfo)
    
    return YES;
}


- (BOOL)getTagsNameSuccess:(SuccessBlock)success
                   failure:(FailureBlock)failure
                   finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    GET_REQUEST(kRequestURLTagsName)
    
    return YES;
}

- (BOOL)getAllTagsNameSuccess:(SuccessBlock)success
                      failure:(FailureBlock)failure
                      finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    GET_REQUEST(kRequestURLAllTagsName)
    
    return YES;
}


- (BOOL)getBindingListWithUserID:(NSString *)userID
                         success:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"userid"] = userID;
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    GET_REQUEST(kRequestURLBindingList)
    
    return YES;
}

#pragma mark - alertview delegate -
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0)
{
    switch(buttonIndex)
    {
        case 0: //不再提醒
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:kUserDefaultsNotRemindApnsAlert];
            [defaults synchronize];
        }
            break;
        case 1: //马上打开
        {
            [[FBProfileNetWorkManager sharedInstance] switchNotifyStatusWithStat:YES success:^(id result) {
                NSLog(@"改变开关状态%@",result);
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"messageRemindCell"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } failure:^(NSString *errorString) {
                NSLog(@"改变出错开关状态出错%@",errorString);
            } finally:^{
            }];
        }
            break;
        case 2: //稍后再说
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kUserDefaultsApnsRemindLaterTimeStamp];
            [defaults synchronize];
        }
            break;
        default:
            break;
    }
}

@end
