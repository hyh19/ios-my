#import <Foundation/Foundation.h>

/** 提现类型 */
typedef NS_ENUM(NSUInteger, ZWWithdrawWay) {
    /** 银行卡 */
    kWithdrawWayBank = 0,
    /** 支付宝提现 */
    kWithdrawWayAliPay = 1,
    /** 财付通提现 */
    kWithdrawWayTenPay = 2,
    /** 无效提现方式 */
    kWithdrawWayInvalid
};

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 提现方式数据，目前的提现方式有支付宝、财付通和银行卡
 */
@interface ZWWithdrawWayModel : NSObject

/** 提现方式ID */
@property (nonatomic, assign) NSNumber *wwid;

/** 第三方支付平台名称或银行名称 */
@property (nonatomic, copy) NSString *name;

/** 图标地址 */
@property (nonatomic, copy) NSString *icon;

/** 到账时间说明 */
@property (nonatomic, copy) NSString *arrive;

/** 提现的提示信息 */
@property (nonatomic, copy) NSString *tips;

/** 银行卡持卡人姓名 */
@property (nonatomic, copy) NSString *userName;

/** 银行卡账号 */
@property (nonatomic, copy) NSString *account;

/** 提现是否免费 */
@property (nonatomic, assign) BOOL isFree;

/** 提现是否有限额 */
@property (nonatomic, assign) BOOL hasQuota;

/** 提现额度 */
@property (nonatomic, assign) NSInteger quato;

/** 提现类型，银行、支付宝、财付通 */
@property (nonatomic, assign) ZWWithdrawWay type;

/** 提现手续费 */
@property (nonatomic, assign) float fees;

/** 用户的身份证信息 */
@property (nonatomic, copy) NSString *idCardNum;

/** 银行卡归属地 */
@property (nonatomic, copy) NSString *bankArea;

/** 初始化提现方式模型 */
- (instancetype)initWithData:(NSDictionary *)data;

@end
