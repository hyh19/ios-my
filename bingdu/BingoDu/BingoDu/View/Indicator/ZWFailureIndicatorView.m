#import "ZWFailureIndicatorView.h"
#import "UIButton+Block.h"

@interface ZWFailureIndicatorView()

/** 点击重试按钮的回调操作 */
@property (nonatomic, strong) ZWFailViewBlock event;

/** 错误提示页类型 */
@property (nonatomic, assign) ZWFailureIndicatorViewType type;

@end

@implementation ZWFailureIndicatorView

- (void)initWithContent:(NSString *)content
                  image:(UIImage *)image
            buttonTitle:(NSString *)buttonTitle
             showInView:(UIView *)view
                  event:(void (^)(void))event
{
    ZWFailureIndicatorView *failView = [super init];
    if (failView)
    {
        failView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        failView.backgroundColor = [UIColor whiteColor];
        failView.userInteractionEnabled = YES;
        failView.event = event;
        CGRect frame = [NSString heightForString:content fontSize:12 andSize:CGSizeMake(200, MAXFLOAT)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width-frame.size.width-image.size.width-10)/2 + image.size.width+10, 0, frame.size.width, 30)];
        label.numberOfLines = 2;
//        label.center = CGPointMake(label.center.x, view.frame.size.height/2 - 40-(view.frame.origin.y == 0 ? 0 : view.frame.origin.y));
        
        label.center = CGPointMake(label.center.x, view.frame.size.height/2 - 40-(view.frame.origin.y == 0 ));
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = COLOR_848484;
        label.text = content;
        [failView addSubview:label];
        
        UIImageView *expressionImageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width-frame.size.width-image.size.width-10)/2, 0, image.size.width, image.size.height)];
        //暂时不删 同上
//        expressionImageView.center = CGPointMake(expressionImageView.center.x, view.frame.size.height/2-40-(view.frame.origin.y == 0 ? 0 : view.frame.origin.y));
        expressionImageView.center = CGPointMake(expressionImageView.center.x, view.frame.size.height/2-40-(view.frame.origin.y == 0));
        expressionImageView.image = image;
        [failView addSubview:expressionImageView];
        
        if(buttonTitle)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, buttonTitle.length > 4 ? 180 : 90, 32);
            [button setBackgroundColor:COLOR_MAIN];
            [button setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
            [button setTitleColor:COLOR_FFFFFF forState:UIControlStateHighlighted];
            button.layer.cornerRadius = 5;
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setTitle:buttonTitle forState:UIControlStateNormal];
            button.center = CGPointMake(view.frame.size.width/2, expressionImageView.center.y+40);
            [button addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
            [failView addSubview:button];
        }
        failView.tag=kFaildViewTag;
    }
    [view addSubview:failView];
}

+ (void)showInView:(UIView *)view
       withMessage:(NSString *)message
             image:(UIImage *)image
       buttonTitle:(NSString *)buttonTitle
       buttonBlock:(void (^)(void))buttonBlock {
    
    [ZWFailureIndicatorView showInView:view
                           withMessage:message
                                 image:image
                           buttonTitle:buttonTitle
                           buttonBlock:buttonBlock
                       completionBlock:nil];
}

+ (void)showInView:(UIView *)view
       withMessage:(NSString *)message
             image:(UIImage *)image
       buttonTitle:(NSString *)buttonTitle
       buttonBlock:(void (^)(void))block
   completionBlock:(void (^)(void))completionBlock {
    // 确保每一个界面只有一个默认失败页
    [ZWFailureIndicatorView dismissInView:view];
    
    ZWFailureIndicatorView *failureView = [[ZWFailureIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds))];
    failureView.backgroundColor = [UIColor whiteColor];
    failureView.userInteractionEnabled = YES;
    failureView.event = block;
    failureView.tag=kFaildViewTag;
    [view addSubview:failureView];
    
    // 提示信息
    CGRect frame = [NSString heightForString:message fontSize:12 andSize:CGSizeMake(200, MAXFLOAT)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((view.frame.size.width-frame.size.width-image.size.width-10)/2 + image.size.width+10, 0, frame.size.width, 30)];
    label.numberOfLines = 2;
    label.center = CGPointMake(label.center.x, view.frame.size.height/2 - 40-(view.frame.origin.y == 0 ? 0 : view.frame.origin.y));
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = COLOR_848484;
    label.text = message;
    [failureView addSubview:label];
    
    // 提示图片
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((view.frame.size.width-frame.size.width-image.size.width-10)/2, 0, image.size.width, image.size.height)];
    imageView.center = CGPointMake(imageView.center.x, view.frame.size.height/2-40-(view.frame.origin.y == 0 ? 0 : view.frame.origin.y));
    imageView.image = image;
    [failureView addSubview:imageView];
    
    // 提示按钮
    if ([buttonTitle isValid]) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, buttonTitle.length > 4 ? 180 : 90, 32);
        [button setBackgroundColor:COLOR_MAIN];
        [button setTitleColor:COLOR_FFFFFF forState:UIControlStateNormal];
        [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        button.layer.cornerRadius = 5;
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        [button setTitle:buttonTitle forState:UIControlStateNormal];
        button.center = CGPointMake(view.frame.size.width/2, imageView.center.y+40);
        [button addTarget:failureView action:@selector(onTouchButton) forControlEvents:UIControlEventTouchUpInside];
        [failureView addSubview:button];
    }
    
    if (completionBlock) {
        completionBlock();
    }
}

+ (void)showInView:(UIView *)view
          withType:(ZWFailureIndicatorViewType)type
           message:(NSString *)message
             image:(UIImage *)image
       buttonTitle:(NSString *)buttonTitle
       buttonBlock:(void (^)(void))block {
    switch (type) {
        case ZWFailureIndicatorViewTypeDefault: {
            [ZWFailureIndicatorView showInView:view withMessage:message image:image buttonTitle:buttonTitle buttonBlock:block];
            break;
        }
            
        case ZWFailureIndicatorViewTypeSubscription: {
            [ZWFailureIndicatorView showSubscriptionViewInView:view
                                                   withMessage:message
                                                         image:image
                                                   buttonTitle:buttonTitle
                                                   buttonBlock:block];
            break;
        }
        default:
            break;
    }
}

+ (void)showSubscriptionViewInView:(UIView *)view
                       withMessage:(NSString *)message
                             image:(UIImage *)image
                       buttonTitle:(NSString *)buttonTitle
                       buttonBlock:(void (^)(void))block {
    
    ZWFailureIndicatorView *failureView = [[ZWFailureIndicatorView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds))];
    failureView.type = ZWFailureIndicatorViewTypeSubscription;
    failureView.backgroundColor = [UIColor whiteColor];
    failureView.userInteractionEnabled = YES;
    failureView.event = block;
    failureView.tag = kFaildViewTag;
    [view addSubview:failureView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 80);
    button.layer.cornerRadius = 5;
    button.center = CGPointMake(view.frame.size.width/2, 114+CGRectGetWidth(button.frame)/2);
    [button addTarget:failureView action:@selector(onTouchButton) forControlEvents:UIControlEventTouchUpInside];
    [failureView addSubview:button];
    
    // 提示信息
    CGRect frame = [NSString heightForString:message fontSize:12 andSize:CGSizeMake(200, MAXFLOAT)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
    label.numberOfLines = 2;
    label.center = CGPointMake(label.center.x, CGRectGetMaxY(button.frame)+20+CGRectGetHeight(label.frame)/2);
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = COLOR_848484;
    label.text = message;
    [failureView addSubview:label];
}

+ (void)showSubscribeViewInView:(UIView *)view withButtonBlock:(void (^)(void))block {
    
    ZWFailureIndicatorView *failureView = [[ZWFailureIndicatorView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    failureView.backgroundColor = COLOR_F8F8F8;
    [view addSubview:failureView];
    
    // 订阅按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 80, 80);
    button.center = CGPointMake(SCREEN_WIDTH/2, 114+CGRectGetWidth(button.frame)/2);
    [button setImage:[UIImage imageNamed:@"btn_add"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    [button addAction:^(UIButton *btn) {
        if (block) {
            block();
        }
    }];
    [failureView addSubview:button];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"外面正在发生一些很有趣的事情\n世界很大，我们一起去看看";
    label.textColor = COLOR_848484;
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 2;
    [label sizeToFit];
    label.center = CGPointMake(SCREEN_WIDTH/2, CGRectGetMaxY(button.frame)+20+CGRectGetHeight(label.frame)/2);
    [failureView addSubview:label];
}

+ (void)dismissInView:(UIView *)view {
    [ZWFailureIndicatorView dismissInView:view withCompletionBlock:nil];
}

+ (void)dismissInView:(UIView *)view
  withCompletionBlock:(void (^)(void))completionBlock {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[ZWFailureIndicatorView class]]) {
            [subView removeFromSuperview];
        }
    }
    if (completionBlock) {
        completionBlock();
    }
}

+ (BOOL)hasFailureViewInView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:[ZWFailureIndicatorView class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)onTouchButton {
    if (self.event) {
        self.event();
    }
}

- (void)refresh:(id)sender
{
    if (self.event) {
        self.event();
    }
    [self removeFromSuperview];
}

@end
