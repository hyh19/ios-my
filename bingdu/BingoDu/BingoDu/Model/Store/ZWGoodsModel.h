#import <Foundation/Foundation.h>
/**商品属性*/
typedef enum{
    /**实物类型*/
    EntityType = 1,
    /**虚拟类型*/
    virtualType = 2
}GoodsType;

/**
 *  @author 陈新存
 *  @ingroup model
 *  @brief 商品数据模型
 */
@interface ZWGoodsModel : NSObject

/**商品ID*/
@property (nonatomic, strong)NSNumber *goodsID;
/**商品名称*/
@property (nonatomic, copy)NSString *name;
/**商品价格*/
@property (nonatomic, strong)NSNumber *price;
/**商品序号*/
@property (nonatomic, strong)NSNumber *number;
/**商品海报名称*/
@property (nonatomic, copy)NSString *pictureName;
/**海报地址*/
@property (nonatomic, copy)NSString *pictureUrl;
/**商品详情*/
@property (nonatomic, copy)NSString *goodsDetail;
/**商品兑换规则*/
@property (nonatomic, copy)NSString *goodsRule;
/**商品图组*/
@property (nonatomic, strong)NSArray *imageArray;

/**是否预上线*/
@property (nonatomic, assign)BOOL isOnline;

/**物品属性*/
@property (nonatomic, assign)GoodsType goodsType;

/**根据商品信息实例化一个对象*/
+(id)goodsInfoByDictionary:(NSDictionary *)dictionary;
/**根据商品详情实例化一个对象*/
+(id)goodsDetailByDictionary:(NSDictionary *)dictionary;

@end
