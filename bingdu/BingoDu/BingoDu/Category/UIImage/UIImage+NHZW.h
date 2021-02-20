#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup category
 *  @brief UIImage自定义拓展类别
 */
@interface UIImage (NHZW)

/**
 *  将图片缩放后返回
 *  @param image 需要被缩放的图片
 *  @param size  缩放大小
 *  @return 被缩放后的图片
 */
+ (UIImage *)imageByScalingImage:(UIImage *)image toSize:(CGSize)size;

/**
 *  通过颜色来生成图片
 *  @param color 颜色
 *  @param size  图片大小
 *  @return 返回图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end
