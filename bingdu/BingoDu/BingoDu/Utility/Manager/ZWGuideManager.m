#import "ZWGuideManager.h"
#import "UIButton+Block.h"

/** 当前唯一引导页 */
static ZWGuideView *currentPage = nil;

@implementation ZWGuideManager

+ (void)showGuidePage:(NSString *)name {

    if (![[NSUserDefaults standardUserDefaults] boolForKey:name]) {
    
        [ZWGuideManager dismissGuidePage];
        
        currentPage = [[ZWGuideView alloc] initWithName:name];
        
        [[UIApplication sharedApplication].delegate.window addSubview:currentPage];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:name];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)dismissGuidePage {
    if (currentPage) {
        [currentPage removeFromSuperview];
        currentPage = nil;
    }
}

+ (BOOL)hasGuidePage {
    return (currentPage != nil) &&
    [currentPage isDescendantOfView:[UIApplication sharedApplication].delegate.window];
}

@end

@implementation ZWGuideView

- (instancetype)initWithName:(NSString *)name {
    
    if (self = [super initWithFrame:[[UIApplication sharedApplication].delegate window].frame]) {
        
        self.backgroundColor = [UIColor colorWithHexString:@"#000000" alpha:0.5];
        
        self.userInteractionEnabled = YES;
        
        self.tag = 500;
        
        [self configureGuidePage:name];
    }
    return self;
}

/** 配置引导页 */
- (void)configureGuidePage:(NSString *)name {
    
    // 提现方式界面引导页
    if ([name isEqualToString:kGuidePageWithdraw]) {
        [self layoutImage:@"bg_guide4" centerOffset:CGPointMake(0, 0)];
        return;
    }
    
    // 新闻详情的引导页
    if ([name isEqualToString:kGuidePageNeswDetail])
    {
        UIImage *image=[UIImage imageNamed:@"bg_guide_newdetail"];
        CGFloat centerY=(SCREEN_HEIGH-image.size.height/2)/2;
        [self layoutImage:@"bg_guide_newdetail" centerOffset:CGPointMake(0, -(centerY-277/2))];
        return;
    }
    // 图片详情的引导页
    if ([name isEqualToString:kGuidePageImageDetail])
    {
        [self layoutImage:@"bg_guide_imageDetail" centerOffset:CGPointMake(0, -20)];
        return;
    }
    // 用户中心界面引导页
    if ([name isEqualToString:kGuidePageUser]) {
        [self layoutImage:@"bg_guide2" centerOffset:CGPointMake(0, 0)];
        return;
    }
}

/**
 *  布局引导页图片
 *
 *  @param image  图片名称
 *  @param offset 屏幕中心偏移位置
 */
- (void)layoutImage:(NSString *)image centerOffset:(CGPoint)offset {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    
    CGRect frame = imageView.frame;
    
    imageView.frame = CGRectMake((SCREEN_WIDTH-CGRectGetWidth(frame))/2+offset.x,
                                 (SCREEN_HEIGH-CGRectGetHeight(frame))/2+offset.y,
                                 CGRectGetWidth(frame),
                                 CGRectGetHeight(frame));
    
    [self addSubview:imageView];
    
    CGRect newFrame = imageView.frame;
    
    [self addSubview:[self dismissButtonWithOriginY:CGRectGetMinY(newFrame) + CGRectGetHeight(newFrame) + 20]];
}

/** 创建关闭按钮 */
- (UIButton *)dismissButtonWithOriginY:(CGFloat)originY {
    
    UIImage *image = [UIImage imageNamed:@"btn_yes"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake((SCREEN_WIDTH-image.size.width)/2,
                              originY,
                              image.size.width,
                              image.size.height);
    
    [button setImage:image forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor clearColor];
    
    __weak typeof(self) weakSelf = self;
    
    [button addAction:^(UIButton *btn) {
        [weakSelf removeFromSuperview];
    }];
    
    return button;
}

@end
