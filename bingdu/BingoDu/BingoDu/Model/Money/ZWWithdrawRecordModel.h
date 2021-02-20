#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 提现记录数据模型
 */
@interface ZWWithdrawRecordModel : NSObject

/** 提现记录ID */
@property (nonatomic, assign) long recordID;

/** 提现金额 */
@property (nonatomic, assign) NSInteger amount;

/** 提现手续费 */
@property (nonatomic, assign) NSInteger fee;

/** 提现账号 */
@property (nonatomic, copy) NSString *account;

/** 提现状态：处理中、提现成功、提现失败 */
@property (nonatomic, copy) NSString *statusString;

/** 提现时间 */
@property (nonatomic, copy) NSString *time;

/** 提现平台图标 */
@property (nonatomic, copy) NSString *logo;

/** 提现状态文字的颜色 */
@property (nonatomic, copy) NSString *colorString;

/** 初始化方法 */
- (instancetype)initWithData:(id)data;

@end
