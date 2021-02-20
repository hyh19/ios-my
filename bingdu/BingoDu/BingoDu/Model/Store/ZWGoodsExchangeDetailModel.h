#import <Foundation/Foundation.h>
#import "ZWGoodsModel.h"

/**商品交易状态*/
typedef enum {
    
    NotCompleteStatus = 0, /** 未完成*/
    SuccessStatus = 1,  /** 成功*/
    FailStatus = 2   /** 失败*/
} GoodsExchangeStatus;

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 商品交易状态数据model
 */
@interface ZWGoodsExchangeStatusModel : NSObject
/**
 *  状态描述
 */
@property (nonatomic, copy) NSString *statusDescription;
/**
 *  状态记录时间
 */
@property (nonatomic, copy) NSString *statusTime;
/**
 *  状态标签
 */
@property (nonatomic, copy) NSString *statusRemark;

/**
 *  交易状态
 */
@property (nonatomic, assign)GoodsExchangeStatus exchangeStatus;

/**
 *  创建本对象
 */
+(instancetype)goodsExchangeStatusBy:(NSDictionary *)dictionary;

@end

/**
 *  @author 陈新存
 *
 *  商品交易详情数据model
 */
@interface ZWGoodsExchangeDetailModel : NSObject
/**
 *  商品名称
 */
@property (nonatomic, copy) NSString *goodsName;
/**
 *  联系电话
 */
@property (nonatomic, copy) NSString *phoneNum;
/**
 *  联系地址
 */
@property (nonatomic, copy) NSString *address;
/**
 *  客户名字
 */
@property (nonatomic, copy) NSString *customerName;
/**
 *  流水号
 */
@property (nonatomic, copy) NSString *serialNo;
/**
 *  交易状态列表
 */
@property (nonatomic, strong) NSArray *statusDetails;
/**
 *  商品类型
 */
@property (nonatomic, assign)GoodsType goodsType;
/**
 *  是否已分享
 */
@property (nonatomic, assign)BOOL isShare;
/**
 *  商品图片
 */
@property (nonatomic, strong)NSString *picUrl;
/**
 *  商品ID
 */
@property (nonatomic, strong)NSString *goodsID;
/**
 *  商品价格
 */
@property (nonatomic, strong)NSString *price;

/**
 *  创建本对象
 */
+(instancetype)goodsExchangeDetailBy:(NSDictionary *)dictionary;

@end
