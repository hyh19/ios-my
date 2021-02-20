#import <Foundation/Foundation.h>
#import "ZWLotteryModel.h"

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 奖券号码数据model
 */
@interface ZWLotteryTicketInfoModel : NSObject
/**
 *  奖券编码
 */
@property (nonatomic, copy)NSString *ticketsCode;
/**
 *  奖券ID
 */
@property (nonatomic, copy)NSString *ticketsID;
/**
 *  奖券状态
 */
@property (nonatomic, assign)LotteryStatus lotteryStatus;

/**
 *  创建本对象
 */
+(instancetype)lotteryTicketInfoModelBy:(NSDictionary *)dictionary;

@end

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 奖券记录详情数据model
 */
@interface ZWLotteryDetailModel : NSObject
/**
 *  奖券id
 */
@property (nonatomic,strong)NSString *lotteryID;
/**
 *  奖券图片url
 */
@property (nonatomic,copy)NSString *lotteryImageUrl;

/**
 *  奖券名字
 */
@property (nonatomic,copy)NSString *lotteryName;

/**
 *  奖券信息
 */
@property (nonatomic,strong)NSString *lotteryInfo;

/**
 *  奖券是否属于虚拟物品
 */
@property (nonatomic,assign)BOOL isVirtual;

/**
 *  奖券编码信息
 */
@property (nonatomic,strong)NSArray *lotteryTickets;

/**
 *  地址
 */
@property (nonatomic, copy)NSString *address;
/**
 *  货运方式
 */
@property (nonatomic, copy)NSString *delivery;
/**
 *  联系手机号
 */
@property (nonatomic, copy)NSString *mobile;
/**
 *  客户名字
 */
@property (nonatomic, copy)NSString *customerName;
/**
 *  货运状态
 */
@property (nonatomic, copy)NSString *deliveryState;
/**
 *  货运单号
 */
@property (nonatomic, copy)NSString *deliveryTicket;

/**
 *  获奖信息
 */
@property (nonatomic, strong) NSArray *prizeInfo;
/**
 *  获奖描述
 */
@property (nonatomic, copy)NSString *prizeDescription;

/**
 *  是否有中奖纪录
 */
@property (nonatomic, assign)BOOL isGetPrize;

/**
 *  创建本对象
 */
+(instancetype)lotteryDetailModelBy:(NSDictionary *)dictionary;

@end
