#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @author 程光东
 *  @ingroup model
 *  @brief 积分规则model
 */
@interface ZWIntegralRuleModel : NSObject

/** 是否在列表显示 */
@property (nonatomic, assign) BOOL display;

/** 积分最大数 */
@property (nonatomic,strong)NSNumber *pointMax;

/** 积分名称 */
@property (nonatomic,strong)NSString *pointName;

/** 积分类型 */
@property (nonatomic,strong)NSNumber *pointType;

/** 单个积分数值 */
@property (nonatomic,strong)NSNumber *pointValue;

/**
 初始化函数
 */
-(instancetype)initRuleData:(NSDictionary *)dic;

@end
