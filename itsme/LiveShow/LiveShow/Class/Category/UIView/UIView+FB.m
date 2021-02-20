#import "UIView+FB.h"

@implementation UIView (Debug)

- (void)debug {
    [self debugWithBorderColor:[UIColor redColor] andBorderWidth:0.5];
}

- (void)debugWithBorderColor:(UIColor *)color {
    [self debugWithBorderColor:color andBorderWidth:0.5];
}

- (void)debugWithBorderColor:(UIColor *)color andBorderWidth:(CGFloat)width {
#if DEBUG
    if (NO) {
        self.layer.borderWidth = width;
        self.layer.borderColor = [color CGColor];
    }
#endif
}

@end

@implementation UIView (Failure)

- (FBFailureView *)addFailureViewWithFrame:(CGRect)frame image:(NSString *)image message:(NSString *)message {
    [self removeFailureView];
    FBFailureView *view = [[FBFailureView alloc] initWithFrame:frame image:image message:message];
    [self addSubview:view];
    return view;
}

- (void)removeFailureView {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[FBFailureView class]]) {
            [view removeFromSuperview];
        }
    }
}


@end
