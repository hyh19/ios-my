#import <Foundation/Foundation.h>

/**商品交易状态*/
typedef enum
{
    UnknowStatus = -1,    /**未知类型*/
    processingStatus = 0, /**处理中*/
    succedStatus = 1,     /**成功*/
    failStatus = 2,        /**失败*/
    queueStatus = 3        /**队列中*/
}GoodsExchangeStatus;

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 单条商品交易记录数据model
 */
@interface ZWGoodsExchangeInfoModel : NSObject

/**
 *  商品id
 */
@property (nonatomic, copy) NSString *goodsID;
/**
 *  商品名称
 */
@property (nonatomic, copy) NSString *goodsName;
/**
 *  商品价格
 */
@property (nonatomic, copy) NSString *goodsPrice;
/**
 *  商品交易时间
 */
@property (nonatomic, copy) NSString *exchangeTime;
/**
 *  商品图片
 */
@property (nonatomic, copy) NSString *goodsImageUrl;
/**
 *  商品交易状态
 */
@property (nonatomic, assign) GoodsExchangeStatus exchangeStatus;

/**
 *  创建本对象
 */
+(instancetype)goodsExchangeInfoBy:(NSDictionary *)dictionary;

@end

/**
 *  @author 陈新存
 *
 *  总的商品交易记录数据model
 */
@interface ZWGoodsExchangeRecordModel : NSObject
/**
 *  用户消费总数
 */
@property (nonatomic, copy) NSString *hisCash;
/**
 *  商品交易数据列表
 */
@property (nonatomic, strong) NSArray *goodsExchangeRecordList;

/**
 *  创建本对象
 */
+(instancetype)goodsExchangeRecordModelBy:(NSDictionary *)dictionary;

/**
 * 将当前的数据模型添加新的数据
 */
+(instancetype)goodsExchangeRecordModelBy:(NSDictionary *)dictionary
                        withCurrentObject:(ZWGoodsExchangeRecordModel *)recordModel;

@end
