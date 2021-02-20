#import "UIView+NHZW.h"
#import "ZWLoadingView.h"

@implementation UIView (NHZW)

@end

@implementation UIView (Debug)

- (void)debug {
    [self debugWithBorderColor:[UIColor redColor] andBorderWidth:0.5];
}

- (void)debugWithBorderColor:(UIColor *)color {
    [self debugWithBorderColor:color andBorderWidth:0.5];
}

- (void)debugWithBorderColor:(UIColor *)color andBorderWidth:(CGFloat)width {
#if SERVER_TYPE == 3
    self.layer.borderWidth = width;
    self.layer.borderColor = [color CGColor];
#endif
}

@end

@implementation UIView (Loading)

- (BOOL)hasLoadingView {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZWLoadingView class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)addLoadingView {
    [self addLoadingViewWithCompletionBlock:nil];
}

- (void)addLoadingViewWithCompletionBlock:(void (^)(void))block {
    [self addLoadingViewWithCompletionBlock:block andType:kLoadingParentTypeDefault];
}

- (void)addLoadingViewWithCompletionBlock:(void (^)(void))block andType:(ZWLoadingParentType)type {
    [self addLoadingViewWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))  type:type andCompletionBlock:block];
}

- (void)addLoadingViewWithFrame:(CGRect)frame {
    [self addLoadingViewWithFrame:frame andType:kLoadingParentTypeDefault];
}

- (void)addLoadingViewWithFrame:(CGRect)frame andType:(ZWLoadingParentType)type {
    [self addLoadingViewWithFrame:frame type:type andCompletionBlock:nil];
}

- (void)addLoadingViewWithFrame:(CGRect)frame andCompletionBlock:(void (^)(void))block {
    [self addLoadingViewWithFrame:frame type:kLoadingParentTypeDefault andCompletionBlock:block];
}

/**
 *  @brief  添加正在加载提示
 *  @param frame 位置
 *  @param block 添加完成后的回调操作
 */
- (void)addLoadingViewWithFrame:(CGRect)frame type:(ZWLoadingParentType)type andCompletionBlock:(void (^)(void))block {
    // 移除旧的正在加载提示
    [self removeLoadingView];
    
    // 添加新的正在加载提示
    ZWLoadingView *loadingView = [[ZWLoadingView alloc] initWithFrame:frame andType:type];
    loadingView.backgroundColor = [UIColor whiteColor];
    [self addSubview:loadingView];
    [loadingView setNeedsUpdateConstraints];
    [loadingView updateConstraintsIfNeeded];
    if (block) {
        block();
    }
}

- (void)removeLoadingView {
    [self removeLoadingViewWithCompletionBlock:nil];
}

- (void)removeLoadingViewWithCompletionBlock:(void (^)(void))block {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[ZWLoadingView class]]) {
            [view removeFromSuperview];
        }
    }
    if (block) {
        block();
    }
}

@end