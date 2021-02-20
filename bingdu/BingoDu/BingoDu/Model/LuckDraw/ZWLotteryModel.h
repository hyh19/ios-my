#import <Foundation/Foundation.h>

/** 开奖状态 */
typedef enum {
    
    /** 未开奖 */
    NotLotteryStatus = 0,
    
    /** 未中奖 */
    NotWinningStatus = 1,
    
    /** 已中奖 */
    HasWinningStatus = 2,
    
    /** 已作废 */
    VoidedStatus     = 3,
    
    /** 已退款 */
    RefundStatus     = 4
    
} LotteryStatus;

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 奖券记录数据model
 */

@interface ZWLotteryModel : NSObject

/**
 *  奖券id
 */
@property (nonatomic,strong)NSString *lotteryID;

/**
 *  奖券图片
 */
@property (nonatomic,strong)NSString *lotteryImageUrl;

/**
 *  奖券名字
 */
@property (nonatomic,strong)NSString *lotteryName;

/**
 *  奖券类型
 */
@property (nonatomic,strong)NSString *lotteryType;

/**
 *  奖券信息
 */
@property (nonatomic,strong)NSString *lotteryInfo;

/**
 *  奖券开奖状态
 */
@property (nonatomic,assign)LotteryStatus lotteryStatus;

/**
 *  奖券抽奖剩余信息
 */
@property (nonatomic,strong)NSString *lotterySurplus;

/**
 *  创建本对象
 */
+(instancetype)lotteryModelBy:(NSDictionary *)dictionary;

@end
