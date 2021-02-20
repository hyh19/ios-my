#import <UIKit/UIKit.h>

/**
 *  @author 黄玉辉
 *  @brief 引导页
 */
@interface FBGuideView : UIView

/**
 *  @param frame      位置
 *  @param text       标题
 *  @param image      图片
 *  @param hide       引导页消失后的回调函数
 *  @param autoLayout 控件布局
 */
- (instancetype)initWithFrame:(CGRect)frame
                         text:(NSString *)text
                        image:(UIImage *)image
                         hide:(void (^)(void))hide
                   autoLayout:(void (^)(UIImageView *imageView, UILabel *label))autoLayout;

@end
