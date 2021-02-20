#import <Foundation/Foundation.h>

/**
 *  @author 刘云鹏
 *  @ingroup model
 *  @brief 奖品model
 */
@interface ZWPrizeModel : NSObject
/**
 *  奖品id
 */
@property(nonatomic,assign) NSInteger prizeId;
/**
 *  奖品图片
 */
@property(nonatomic,strong) NSString *prizeImageUrl;
/**
 *  奖品信息
 */
@property(nonatomic,strong) NSString  *prizeInfo;
/**
 *  奖品名称
 */
@property(nonatomic,strong) NSString  *prizeName;
/**
 *  奖品类型
 */
@property(nonatomic,assign) NSInteger prizeType;
/**根据奖品信息实例化一个对象*/
+(id)prizeOBJByDictionary:(NSDictionary *)dictionary;
@end
