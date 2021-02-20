#import <Foundation/Foundation.h>

/**
 *  @author 黄玉辉
 *  @brief 自定义UIButton的拓展类
 */
@interface UIButton (FB)

/** 加载指定尺寸的图片 */
- (void)fb_setImageWithName:(NSString *)imageName size:(CGSize)size forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;

/** 加载图片 */
- (void)fb_setImageWithName:(NSString *)imageName forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;

/** 加载指定尺寸的背景图片 */
- (void)fb_setBackgroundImageWithName:(NSString *)imageName size:(CGSize)size forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;

/** 加载指定尺寸的背景图片成功后回调 */
- (void)fb_setBackgroundImageWithName:(NSString *)imageName size:(CGSize)size forState:(UIControlState)state placeholderImage:(UIImage *)placeholder completed:(void(^)(UIImage *image))completed;

/** 加载背景图片 */
- (void)fb_setBackgroundImageWithName:(NSString *)imageName forState:(UIControlState)state placeholderImage:(UIImage *)placeholder;

@end
