#import <Foundation/Foundation.h>

/**交易状态*/
typedef enum
{
    /**未知类型*/
    UnknowStatus = -1,
    /**处理中*/
    processingStatus = 0,
    /**成功*/
    succedStatus = 1,
    /**失败*/
    failStatus = 2
}ExchangeStatus;

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 单件商品兑换记录
 */
@interface ZWExchangeModel : NSObject
/**
 图片链接
 */
@property (nonatomic, copy)NSString *goodsUrl;
/**
 兑换时间
 */
@property (nonatomic, copy)NSString *time;
/**
 商品名字
 */
@property (nonatomic, copy)NSString *goodsName;
/**
 商品价格
 */
@property (nonatomic, copy)NSString *goodsPrice;
/**
 (0处理中，1已发货，2失败,金额已返还)
 */
@property (nonatomic, assign)ExchangeStatus exchangeStatus;

/**
 *  实例对象
 */
+(id)exchangeByDictionary:(NSDictionary *)dictionary;
/**
 *  实例对象
 */
@end

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 商品兑换记录
 */
@interface ZWExchangeRecordModel : NSObject
/**
 头像链接
 */
@property (nonatomic, copy)NSString *headImageUrl;
/**
 已消费
 */
@property (nonatomic, strong)NSNumber *hadExchangeMoney;
/**
 余额
 */
@property (nonatomic, copy)NSString *totolMoney;
/**
 总记录
 */
@property (nonatomic, strong)NSArray *exchangeList;

/**
 *  实例对象
 */
+(id)exchangeRecordByDictionary:(NSDictionary *)dictionary;
@end
