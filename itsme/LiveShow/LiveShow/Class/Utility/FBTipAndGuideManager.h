#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉
 *  @since 2.0.0
 *  @brief 记录应用周期和本地缓存中，提示或引导出现的次数
 */
@interface FBTipAndGuideManager : NSObject

/** 单例 */
+ (instancetype)sharedInstance;

/** 应用生命周期内的计数加一 */
- (void)addCountInLiftCycleWithType:(FBTipAndGuideType)type;

/** 获取应用周期内的计数 */
- (NSUInteger)countInLiftCycleWithType:(FBTipAndGuideType)type;

/** 本地缓存的计数加一 */
+ (void)addCountInUserDefaultsWithType:(FBTipAndGuideType)type;

/** 获取本地缓存的计数 */
+ (NSUInteger)countInUserDefaultsWithType:(FBTipAndGuideType)type;

@end
