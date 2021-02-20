#import "FBStoreNetworkManager.h"

@implementation FBStoreNetworkManager

/** 加载内购商品列表 */
- (BOOL)loadProductListWithsuccess:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = @"App Store";
        parameters[@"app"] = [FBUtility bundleID];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLProductList
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    
    return YES;
}

- (BOOL)depositWithGold:(NSInteger)gold
               platform:(NSString *)platform
               bundleID:(NSString *)bundleID
      receiptBase64Data:(NSString *)receiptBase64Data
                success:(SuccessBlock)success
                failure:(FailureBlock)failure
                finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        if (gold > 0) {
            parameters[@"gold"] = @(gold);
        }
        
        if ([platform isValid]) {
            parameters[@"platform"] = platform;
        }
        
        if ([bundleID isValid]) {
            parameters[@"app"] = bundleID;
        }
        
        if ([receiptBase64Data isValid]) {
            parameters[@"receiptBase64Data"] = receiptBase64Data;
        }
#if DEBUG
        // 沙盒环境
        parameters[@"sandbox"] = @(1);
#else
        // 正式环境
        parameters[@"sandbox"] = @(0);
#endif
        
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager POST:kRequestURLDeposit
       parameters:parameters
          success:success
          failure:failure
          finally:finally
     ];
    
    return YES;
    
}

// 越南版
#if TARGET_VERSION_VIETNAM
- (BOOL)depositWithPlatform:(NSString *)platform
                   bundleID:(NSString *)bundleID
               providerCode:(NSString *)providerCode
                 serialCode:(NSString *)serialCode
                    pinCode:(NSString *)pinCode
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure
                    finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        if ([platform isValid]) {
            parameters[@"platform"] = platform;
        }
        
        if ([bundleID isValid]) {
            parameters[@"app"] = bundleID;
        }
        
        if ([providerCode isValid]) {
            parameters[@"provider"] = providerCode;
        }
        
        if ([serialCode isValid]) {
            parameters[@"serial"] = serialCode;
        }
        
        if ([pinCode isValid]) {
            parameters[@"pin"] = pinCode;
        }
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager POST:kRequestURLDeposit
       parameters:parameters
          success:success
          failure:failure
          finally:finally
     ];
    
    return YES;
}

- (BOOL)checkVCardStatusWithSuccess:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = @"ios";
        parameters[@"app"] = [FBUtility bundleID];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLStoreVCardStatus
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
}

#endif

// 泰国版和越南版
#if TARGET_VERSION_THAILAND || TARGET_VERSION_VIETNAM
- (BOOL)checkWithdrawWithSuccess:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    @try
    {
        parameters[@"platform"] = @"ios";
        parameters[@"app"] = [FBUtility bundleID];
    }
    @catch (NSException *exception)
    {
        return NO;
    }
    
    FBHTTPSessionManager *manager = [FBHTTPSessionManager sharedInstance];
    [manager GET:kRequestURLCheckWithdraw
      parameters:parameters
         success:success
         failure:failure
         finally:finally
     ];
    return YES;
}
#endif

@end
