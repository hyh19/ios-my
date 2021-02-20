#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉
 *  @since 2.0.0
 *  @brief 渐变色处理
 */
@interface UIImage (Gradient)

/** 生成渐变色图片 */
+ (UIImage *)imageFromGradientColors:(NSArray*)colors withSize:(CGSize)size;

@end
