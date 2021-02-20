#import "ZWTabBarController.h"
#import "ZWNavigationController.h"
#import "ZWNewsMainViewController.h"
#import "SCNavTabBarController.h"
#import "ZWBingYouViewController.h"
#import "ZWLifeStyleMainViewController.h"
#import "UIView+Borders.h"

@implementation ZWTabBarItem

- (instancetype)init {
    if (self = [super init]) {
        [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"949494"], NSForegroundColorAttributeName, [UIFont systemFontOfSize:10], NSFontAttributeName, nil] forState:UIControlStateNormal];
        [self setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:COLOR_MAIN, NSForegroundColorAttributeName, [UIFont systemFontOfSize:10], NSFontAttributeName, nil] forState:UIControlStateSelected];
        self.titlePositionAdjustment = UIOffsetMake(0, -3);
    }
    return self;
}

@end

@interface ZWTabBarController () <UITabBarDelegate> {
    CGRect _tabBarFrame;
}

/** 生活方式主界面 */
@property (nonatomic, strong, readwrite) ZWLifeStyleMainViewController *lifeStyleViewController;

/** 即时新闻主界面 */
@property (nonatomic, strong, readwrite) ZWNewsMainViewController *newsViewController;

@end

@implementation ZWTabBarController

- (instancetype)init {
    if (self = [super init]) {
        _tabBarFrame = self.tabBar.frame;
    }
    return self;
}

- (ZWLifeStyleMainViewController *)lifeStyleViewController {
    if (!_lifeStyleViewController) {
        _lifeStyleViewController = [[ZWLifeStyleMainViewController alloc] init];
        _lifeStyleViewController.hidesBottomBarWhenPushed = NO;
    }
    return _lifeStyleViewController;
}

- (ZWNewsMainViewController *)newsViewController {
    if (!_newsViewController) {
        _newsViewController = [[ZWNewsMainViewController alloc] init];
        _newsViewController.hidesBottomBarWhenPushed = NO;
    }
    return _newsViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ZWNavigationController *lifeStyleNavigationController = [[ZWNavigationController alloc] initWithRootViewController:self.lifeStyleViewController];
    ZWTabBarItem *lifeStyleTabBarItem = [[ZWTabBarItem alloc] initWithTitle:@"生活方式" image:[UIImage imageNamed:@"icon_life_style_normal"] selectedImage:[UIImage imageNamed:@"icon_life_style_selected"]];
    lifeStyleNavigationController.tabBarItem = lifeStyleTabBarItem;
    
    ZWNavigationController *newsNavigationController = [[ZWNavigationController alloc] initWithRootViewController:self.newsViewController];
    ZWTabBarItem *newsTabBarItem = [[ZWTabBarItem alloc] initWithTitle:@"即时资讯" image:[UIImage imageNamed:@"icon_news_normal"] selectedImage:[UIImage imageNamed:@"icon_news_selected"]];
    newsNavigationController.tabBarItem = newsTabBarItem;
    
    self.viewControllers = [NSArray arrayWithObjects:
                            lifeStyleNavigationController,
                            newsNavigationController,
                            nil];
    
    self.tabBar.backgroundColor = COLOR_BAR_BACKGROUND;
    self.tabBar.tintColor = COLOR_MAIN;
    self.tabBar.clipsToBounds = YES;
    [self.tabBar addTopBorderWithHeight:0.5 andColor:COLOR_E0E0E0];
    
    NSNumber *defaultIndex = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaultsSelectedTab];
    if (defaultIndex) {
        self.selectedIndex = [defaultIndex integerValue];
    }
    [self addRedPointAtIndex:0];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger index = [tabBar.items indexOfObject:item];
    switch (index) {
        // 生活方式
        case 0: {
            // 点击刷新
            if (0 == self.selectedIndex) {
                NSNotification *notification = [NSNotification notificationWithName:kNotificationTapLifeStyle object:nil];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
            self.selectedIndex = 0;
            [MobClick event:@"click_news_tab"];
            
            break;
        }
        // 即时新闻
        case 1: {
            // 从其它标签切换过来不需要刷新
            if (1 == self.selectedIndex) {
                [self.newsViewController tapRefresh];
            }
            self.selectedIndex = 1;
            break;
        }
        default: {
            break;
        }
    }
    [self removeRedPointAtIndex:index];
}

- (void)showTabBar {
    [self showTabBarAnimated:NO WithDuration:0];
}

- (void)showTabBarAnimated:(BOOL)animated WithDuration:(NSTimeInterval)duration {
    NSNotification *notification = [NSNotification notificationWithName:kNotificationWillShowTabBar object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            self.tabBar.frame = _tabBarFrame;
        }];
    } else {
        self.tabBar.frame = _tabBarFrame;
    }
}

- (void)hideTabBar {
    [self hideTabBarAnimated:NO WithDuration:0];
}

- (void)hideTabBarAnimated:(BOOL)animated WithDuration:(NSTimeInterval)duration {
    NSNotification *notification = [NSNotification notificationWithName:kNotificationWillHideTabBar object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    if (animated) {
        [UIView animateWithDuration:duration animations:^{
            self.tabBar.frame = CGRectOffset(_tabBarFrame, 0, CGRectGetHeight(_tabBarFrame));
        }];
    } else {
        self.tabBar.frame = CGRectOffset(_tabBarFrame, 0, CGRectGetHeight(_tabBarFrame));
    }
}

/** 添加红点 */
- (void)addRedPointAtIndex:(NSInteger)index {
    [self removeRedPointAtIndex:index];
    NSInteger count = [self.viewControllers count];
    CGFloat side = 4;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/count*index + SCREEN_WIDTH/count/2+15, 5, side, side)];
    label.layer.cornerRadius = side/2;
    label.clipsToBounds = YES;
    label.backgroundColor = [UIColor redColor];
    label.tag = index;
    [self.tabBar addSubview:label];
}

/** 隐藏红点 */
- (void)removeRedPointAtIndex:(NSInteger)index {
    for (UIView *view in self.tabBar.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            if (view.tag == index) {
                [view removeFromSuperview];
            }
        }
    }
}

@end
