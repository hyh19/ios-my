#import <Foundation/Foundation.h>

typedef void (^CompletedBlock)(void);

/**
 *  @author 黄玉辉
 *  @brief 自定义UIImageView的拓展
 */
@interface UIImageView (FB)

/** 加载指定尺寸的图片 */
- (void)fb_setImageWithName:(NSString *)imageName size:(CGSize)size placeholderImage:(UIImage *)placeholder completed:(CompletedBlock)completedBlock;

/** 加载礼物图片 */
- (void)fb_setGiftImageWithName:(NSString *)imageName placeholderImage:(UIImage *)placeholder completed:(CompletedBlock)completedBlock;


/** 设置高斯模糊 */
- (void)fb_setGaussianBlurImageWithName:(NSString *)imageName size:(CGSize)size placeholderImage:(UIImage *)placeholder;

/** 设置高斯模糊 */
- (void)fb_setGaussianBlurImageWithName:(NSString *)imageName size:(CGSize)size radius:(NSInteger)radius placeholderImage:(UIImage *)placeholder;

/** 设置高斯模糊 */
- (void)fb_setGaussianBlurImage:(UIImage*)image radius:(NSInteger)radius useScale:(BOOL)useScale placeholderImage:(UIImage *)placeholder;

@end

/**
 *  @author 黄玉辉
 *  @brief 图片序列动画
 */
@interface UIImageView (Animation)

/**
 *  @author 黄玉辉
 *
 *  @brief 加载图片序列动画
 *
 *  @param imageFiles     图片序列包解压出来的图片路径
 */
- (void)fb_startAnimatingWithImageFiles:(NSArray *)imageFiles duration:(NSTimeInterval)duration repeatCount:(NSInteger)repeatCount completed:(CompletedBlock)completedBlock;

@end