#import "UIButton+NHZW.h"

/** 红点的标记 */
const NSInteger TAG_RED_POINT = 1024;

@implementation UIButton (NHZW)

- (void)addRedPointWithFrame:(CGRect)frame {
    [self addRedPointWithFrame:frame borderColor:[UIColor whiteColor] borderWidth:0];
}

- (void)addRedPointWithFrame:(CGRect)frame borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth {
    [self removeRedPoint];
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor redColor];
    label.layer.cornerRadius = CGRectGetWidth(label.frame)/2;
    label.layer.masksToBounds = YES;
    label.layer.borderColor = borderColor.CGColor;
    label.layer.borderWidth = borderWidth;
    label.tag = TAG_RED_POINT;
    [self addSubview:label];
}

- (void)removeRedPoint {
    for (UIView *subView in self.subviews) {
        if (TAG_RED_POINT == subView.tag) {
            [subView removeFromSuperview];
        }
    }
}

@end
