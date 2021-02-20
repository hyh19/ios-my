#import "ZWBindingView.h"
#import "UILabel+HYBAttributedCategory.h"

@interface ZWBindingView ()

/**中间白色弹出框的view*/
@property (strong, nonatomic) UIView *contentView;

@end

@implementation ZWBindingView

#define WIDTH    [UIScreen mainScreen].bounds.size.width - 40
#define HIGHT    180

#pragma mark - initView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setBackgroundColor:[UIColor colorWithHexString:@"#000000" alpha:0.5]];
        
        [self addSubview:[self contentView]];
        
        [self addLoginButton];
        
        [self show];
    }
    return self;
}

#pragma mark - Properties

/**弹出视图*/
- (void)show{
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self contentView].layer addAnimation:popAnimation forKey:nil];
}

#pragma mark - Getter & Setter
- (UIView *)contentView
{
    if(!_contentView)
    {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HIGHT)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 5;
        _contentView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGH/2);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, WIDTH - 20, 40)];
        label.textColor = COLOR_333333;
        label.font = [UIFont systemFontOfSize:15];
        [label hyb_setAttributedText:@"每成功绑定一个社交账号即获得<font color=\"#00baa2\">+20</font>积分奖励，请选择需要绑定的帐号"];
        label.numberOfLines = 2;
        [_contentView addSubview:label];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, HIGHT-41, WIDTH, 1)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_contentView addSubview:line];
        [_contentView addSubview:[self closeButton]];
    }
    return _contentView;
}

- (void)addLoginButton
{
    NSArray *loginIcon = @[@"login_weibo", @"login_weixin",@"login_QQ" ];
    NSArray *loginIcon_hightlight = @[@"login_weibo_hightlight", @"login_weixin_hightlight", @"login_QQ_hightlight"];
    
    float buttonWith = [UIImage imageNamed:@"login_QQ"].size.width;
    
    for(int i = 1; i < 4; i ++)
    {
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [loginButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", loginIcon[i-1]]] forState:UIControlStateNormal];
        
        [loginButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", loginIcon_hightlight[i-1]]] forState:UIControlStateHighlighted];
        
        loginButton.backgroundColor = [UIColor clearColor];
        
        loginButton.tag = i+1000-1;
        
        [loginButton addTarget:self action:@selector(onTouchButtonBingdingPlatform:) forControlEvents:UIControlEventTouchUpInside];
        
        loginButton.frame = CGRectMake((WIDTH-buttonWith*3)/4*i + buttonWith*i-buttonWith, 60, buttonWith, buttonWith);
        
        [[self contentView] addSubview:loginButton];
    }
}

- (UIButton *)closeButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:@"取消" forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, HIGHT-40, WIDTH, 40);
    
    button.layer.cornerRadius = 5;
    
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(onTouchButtonCloseView) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - UI EventHandler

/**点击社交账号按钮触发方法*/
- (void)onTouchButtonBingdingPlatform:(UIButton *)sender
{
    if([[self bingdingDelegate] respondsToSelector:@selector(bingdingPlatformWithType:)])
    {
        [[self bingdingDelegate] bingdingPlatformWithType:(BindingType)sender.tag - 1000];
    }
    [self onTouchButtonCloseView];
}

/**关闭视图*/
- (void)onTouchButtonCloseView
{
    [self removeFromSuperview];
}

@end
