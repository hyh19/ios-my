#import <UIKit/UIKit.h>

/**
 *  @author 林思敏
 *  @brief  红色圆圈扩散的视图（Code generated using QuartzCode）
 */

@interface FBCustomView : UIView

- (IBAction)startAllAnimations:(id)sender;
- (void)startOvalAnimations:(UIColor *)color;

@end

@protocol AnimationButtonViewDelegate <NSObject>

@required
- (void)clickButtonAction:(id)sender;

@end

@interface AnimationButtonView : UIView
@property (strong, nonatomic) FBCustomView *customView;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) id<AnimationButtonViewDelegate> delegate;


@end
