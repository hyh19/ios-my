#import "FBLiveRoomViewController.h"
#import "FBLivePlayViewController.h"
#import "FBLiveInfoModel.h"
#import "FBGuideView.h"
#import "FBTipAndGuideManager.h"

@interface FBLiveRoomViewController ()

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) NSArray *lives;

@property (nonatomic, strong) CWStatusBarNotification *notification;

@property (nonatomic) NSInteger currentIndex;

@property (nonatomic, strong) FBLivePlayViewController *prePlayViewController;

@end

@implementation FBLiveRoomViewController

- (instancetype)initWithLives:(NSArray *)lives focusLive:(FBLiveInfoModel *)live {
    if (self = [super init]) {
        self.fromType = kLiveRoomFromTypeHot;
        self.lives = lives;
        self.currentIndex = [self.lives indexOfObject:live];
        
        
        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
        [self.pageViewController setDelegate:self];
        [self.pageViewController setDataSource:self];
        
        FBLivePlayViewController *currentViewController = [[FBLivePlayViewController alloc] initWithModel:live];
        currentViewController.fromType = self.fromType;
        [currentViewController startPlay];
        self.prePlayViewController = currentViewController;
        
        [self.pageViewController setViewControllers:@[currentViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        [self addChildViewController:self.pageViewController];
        [self.pageViewController.view setFrame:self.view.bounds];
        [self.view addSubview:self.pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
        NSUInteger count = [FBTipAndGuideManager countInUserDefaultsWithType:kGuideSwipeLive];
        if (0 == count) {
            [self addGuideView];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

-(void)dealloc
{
    NSArray *controllers = _pageViewController.viewControllers;
    for(UIViewController *vc in controllers)
    {
        if([vc isKindOfClass:[FBLivePlayViewController class]]) {
            [(FBLivePlayViewController *)vc endPlay];
        }
    }
}

- (CWStatusBarNotification *)notification {
    if (!_notification) {
        _notification = [[CWStatusBarNotification alloc] init];
        _notification.notificationLabelBackgroundColor = COLOR_NOTIFICATION_DEFAULT;
        _notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        _notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
        _notification.notificationStyle = CWNotificationStyleStatusBarNotification;
        _notification.notificationLabelFont = FONT_SIZE_14;
        _notification.notificationLabelTextColor = [UIColor whiteColor];
    }
    return _notification;
}

#pragma mark - Event handler -
- (void)showNetworkError {
    if (self.notification.notificationIsShowing) {
        [self.notification dismissNotification];
    }
    [self.notification displayNotificationWithMessage:kLocalizationNetworkErrorStopWatch forDuration:2];
}

#pragma mark - UI Management -
/** 添加引导页 */
- (void)addGuideView {
    
    UIImage *switchImage = [UIImage imageNamed:@"room_icon_guide_switch"];
    FBGuideView *switchGuide = [[FBGuideView alloc] initWithFrame:self.view.bounds text:kLocalizationGuideSwitch image:switchImage
                                                           hide:^{
                                                               [FBTipAndGuideManager addCountInUserDefaultsWithType:kGuideSwipeLive];
                                                           }
                                                     autoLayout:^(UIImageView *imageView, UILabel *label) {
                                                         [label mas_makeConstraints:^(MASConstraintMaker *make) {
                                                             make.centerX.equalTo(imageView);
                                                             make.bottom.equalTo(imageView.mas_top).offset(-20);
                                                         }];
                                                         
                                                         [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                                                             make.size.equalTo(imageView.image.size);
                                                             make.center.equalTo(imageView.superview);
                                                         }];
                                                     }];
    switchGuide.hidden = YES;
    [self.view addSubview:switchGuide];
    
    UIImage *clearImage = [UIImage imageNamed:@"room_icon_guide_clear"];
    FBGuideView *clearGuide = [[FBGuideView alloc] initWithFrame:self.view.bounds text:kLocalizationGuideClear image:clearImage
                                                           hide:^{
                                                               switchGuide.hidden = NO;
                                                           }
                                                     autoLayout:^(UIImageView *imageView, UILabel *label) {
                                                         [label mas_makeConstraints:^(MASConstraintMaker *make) {
                                                             make.centerX.equalTo(imageView);
                                                             make.bottom.equalTo(imageView.mas_top).offset(-40);
                                                         }];
                                                         
                                                         [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                                                             make.size.equalTo(imageView.image.size);
                                                             make.center.equalTo(imageView.superview);
                                                         }];
                                                     }];
    [self.view addSubview:clearGuide];
}

#pragma mark - UIPageViewControllerDataSource -
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if ([self.lives count] <= 0) {
        return nil;
    }
    
    self.currentIndex = [self indexOfCurrentViewController:viewController];
    
    if (self.currentIndex < self.lives.count - 1) {
        self.currentIndex += 1;
    } else {
        self.currentIndex = 0;
    }
    FBLivePlayViewController *currentViewController = [[FBLivePlayViewController alloc] initWithModel:self.lives[self.currentIndex]];
    currentViewController.fromType = self.fromType;
    return currentViewController;
}

- (UIViewController *) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if ([self.lives count] <= 0) {
        return nil;
    }
    
    self.currentIndex = [self indexOfCurrentViewController:viewController];
    
    if (self.currentIndex > 0) {
        self.currentIndex -= 1;
    } else {
        self.currentIndex = self.lives.count - 1;
    }
    FBLivePlayViewController *currentViewController = [[FBLivePlayViewController alloc] initWithModel:self.lives[self.currentIndex]];
    currentViewController.fromType = self.fromType;
    return currentViewController;
}

#pragma mark - UIPageViewControllerDelegate -
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    [self.notification dismissNotification];
    
    if (finished && completed) {
        if(self.prePlayViewController) {
            [self.prePlayViewController endPlay];
        }
        
        FBLivePlayViewController *currentViewController = (FBLivePlayViewController *)[pageViewController.viewControllers firstObject];
        [currentViewController startPlay];
        self.prePlayViewController = currentViewController;
    }
}

#pragma mark - UINavigationController+FDFullscreenPopGesture -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (BOOL)fd_interactivePopDisabled {
    return YES;
}

#pragma mark - Helper -
/** 获取当前直播的索引，因为首页热门列表会定时更新，所以索引可能会改变 */
- (NSUInteger)indexOfCurrentViewController:(UIViewController *)viewController {
    FBLivePlayViewController *liveViewController = (FBLivePlayViewController *)viewController;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"broadcaster.userID = %@", liveViewController.broadcaster.userID];
    NSArray *array = [self.lives filteredArrayUsingPredicate:predicate];
    if ([array count] > 0) {
        FBLiveInfoModel *liveInfo = [array lastObject];
        NSUInteger index = [self.lives indexOfObject:liveInfo];
        return index;
    }
    // 如果当前直播不在首页列表里，要做处理，防止数组越界
    if (self.currentIndex > [self.lives count]-1) {
        self.currentIndex = [self.lives count]-1;
    }
    return self.currentIndex;
}

@end
