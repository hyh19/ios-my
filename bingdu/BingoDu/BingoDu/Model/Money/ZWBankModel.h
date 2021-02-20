#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 选择开户银行界面数据模型
 */
@interface ZWBankModel : NSObject

/** 银行ID */
@property (nonatomic, copy) NSString *bankId;

/** 银行名称 */
@property (nonatomic, copy) NSString *name;

/** 银行Logo下载地址 */
@property (nonatomic, copy) NSString *logoURL;

/** 用服务器返回的数据初始化银行数据模型 */
- (instancetype)initWithData:(NSDictionary *)data;

@end
