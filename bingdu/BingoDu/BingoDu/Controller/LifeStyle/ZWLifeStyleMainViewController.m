#import "ZWLifeStyleMainViewController.h"
#import "ZWSegmentedViewController.h"
#import "ZWLifestyleCategoryCollectionViewController.h"
#import "ZWPushMessageManager.h"
#import "ZWFeaturedArticlesViewController.h"
#import "UIButton+Block.h"

@interface ZWLifeStyleMainViewController ()

@property (nonatomic, strong) ZWSegmentedViewController *segmentedViewController;

@end

@implementation ZWLifeStyleMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self initSubViewControllers];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNotificationLockScroll:)
                                                 name:kNotificationLockLifeStyleMainViewController
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [[ZWPushMessageManager sharedInstance] handlePushMessage];
        
    });
}

#pragma mark - Event handler -
/** 切换标签 */
- (void)onSegmentValueChanged:(NSInteger)index {
    // 避免因为轮播广告导致无法滚动
    self.segmentedViewController.scrollEnabled = YES;
}

- (void)onNotificationLockScroll:(NSNotification *)notification {
    self.segmentedViewController.scrollEnabled = [notification.object boolValue];
}

#pragma mark - UI management
/** 配置界面 */
- (void)configureUserInterface {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"并读" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [button addAction:^(UIButton *btn) {
        NSNotification *notification = [NSNotification notificationWithName:kNotificationTapNavTitle object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }];
    self.navigationItem.titleView = button;
}

/** 初始化子界面 */
- (void)initSubViewControllers {
    ZWFeaturedArticlesViewController *oneViewController = [ZWFeaturedArticlesViewController viewController];
    oneViewController.title = @"精选";
    
    ZWLifeStyleCategoryCollectionViewController *categoryCollectionVC = [ZWLifeStyleCategoryCollectionViewController viewController];
    categoryCollectionVC.title = @"分类";
    
    ZWSegmentedViewController *segmentedViewController = [[ZWSegmentedViewController alloc] init];
    segmentedViewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-TAB_BAR_HEIGHT);
    segmentedViewController.subViewControllers = @[oneViewController, categoryCollectionVC];
    segmentedViewController.scrollEnabled = YES;
    segmentedViewController.titleTextAttributes = @{NSForegroundColorAttributeName : COLOR_848484,
                                                    NSFontAttributeName            : [UIFont systemFontOfSize:14]};
    segmentedViewController.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : COLOR_MAIN,
                                                            NSFontAttributeName            : [UIFont systemFontOfSize:14]};
    __weak typeof(self)weakSelf = self;
    segmentedViewController.indexChangeBlock = ^(NSInteger index) {
        [weakSelf onSegmentValueChanged:index];
    };
    [segmentedViewController addParentController:self];
    self.segmentedViewController = segmentedViewController;
}

@end
