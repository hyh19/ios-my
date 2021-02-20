#import "FBBaseNetworkManager.h"

/**
 *  @author 黄玉辉
 *  @brief 充值与收益网络请求管理器
 */
@interface FBStoreNetworkManager : FBBaseNetworkManager

/** 加载内购商品列表 */
- (BOOL)loadProductListWithsuccess:(SuccessBlock)success
                           failure:(FailureBlock)failure
                           finally:(FinallyBlock)finally;

/** 充值 */
- (BOOL)depositWithGold:(NSInteger)gold
               platform:(NSString *)platform
               bundleID:(NSString *)bundleID
      receiptBase64Data:(NSString *)receiptBase64Data
                success:(SuccessBlock)success
                failure:(FailureBlock)failure
                finally:(FinallyBlock)finally;

// 越南版
#if TARGET_VERSION_VIETNAM
/** 越南点卡充值 */
- (BOOL)depositWithPlatform:(NSString *)platform
                   bundleID:(NSString *)bundleID
               providerCode:(NSString *)providerCode
                 serialCode:(NSString *)serialCode
                    pinCode:(NSString *)pinCode
                    success:(SuccessBlock)success
                    failure:(FailureBlock)failure
                    finally:(FinallyBlock)finally;



/** 检查是否打开点卡 */
- (BOOL)checkVCardStatusWithSuccess:(SuccessBlock)success
                            failure:(FailureBlock)failure
                            finally:(FinallyBlock)finally;

#endif

// 泰国版和越南版
#if TARGET_VERSION_THAILAND || TARGET_VERSION_VIETNAM
/** 检查是否打开提现 */
- (BOOL)checkWithdrawWithSuccess:(SuccessBlock)success
                         failure:(FailureBlock)failure
                         finally:(FinallyBlock)finally;
#endif

@end
