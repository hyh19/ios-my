#import <Foundation/Foundation.h>

/**
 *  @author 林思敏
 *  @author 黄玉辉->陈梦杉
 *  @ingroup model
 *  @brief 提现进度数据模型
 */
@interface ZWWithdrawProcessModel : NSObject

/** 进度描述 */
@property (nonatomic, copy) NSString *statusString;

/** 提现进度，0-未完成，1-成功，2-失败 */
@property (nonatomic, assign) NSInteger status;

/** 进度时间 */
@property (nonatomic, copy) NSString *time;

/** 进度备注 */
@property (nonatomic, copy) NSString *remark;

/** 进度颜色值，用于实心大圆点 */
@property (nonatomic, copy) NSString *color;

/** 初始化方法 */
- (instancetype)initWithData:(id)data;

@end
