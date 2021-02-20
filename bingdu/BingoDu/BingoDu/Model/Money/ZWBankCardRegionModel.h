#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @ingroup model
 *  @brief 银行卡归属地区界面数据模型
 */
@interface ZWBankCardRegionModel : NSObject

/** 银行卡归属地区名称 */
@property (nonatomic, copy) NSString *regionName;
@property (nonatomic, copy) NSString *regionId;

/** 用服务器返回的数据初始化银行数据模型 */
- (instancetype)initWithData:(NSDictionary *)data;

@end
