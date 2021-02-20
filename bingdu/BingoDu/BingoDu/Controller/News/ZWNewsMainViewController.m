#import "ZWNewsMainViewController.h"
#import "ZWNewsListViewController.h"
#import "SCNavTabBarController.h"
#import "ZWNewsNetworkManager.h"
#import "RTLabel.h"
#import "SCNavTabBar.h"
#import "ZWTabBarController.h"
#import "AppDelegate.h"
#import "ChannelItem.h"
#import "ZWIntegralStatisticsModel.h"
#import "UIView+WhenTappedBlocks.h"
#import "ZWLoginViewController.h"
#import "ZWChannelDataManager.h"
#import "ZWChannelScrollView.h"
#import "ZWRedPointManager.h"
#import "ZWReviewManager.h"
#import "ZWNewsSearchViewController.h"
#import "ZWLocationManager.h"
#import "UIAlertView+Blocks.h"
#import "ZWSubscriptionViewController.h"
#import "PureLayout.h"
#import "UIButton+Block.h"
#import "ZWFailureIndicatorView.h"
#import "ZWPushMessageManager.h"

#define UNSELECTCHANNELLIST [[ZWChannelDataManager sharedInstance] unSelectedChannelList]
#define SELECTCHANNELLIST [[ZWChannelDataManager sharedInstance] selectedChannelList]

@interface ZWNewsMainViewController ()

@property (nonatomic, strong) SCNavTabBarController *navTabBarController;
@property (nonatomic, strong) ZWChannelScrollView *channelMenuView;

/** 顶部登录提示控件 */
@property (nonatomic, strong) ZWLoginPromptView *loginPromptView;

@end

@implementation ZWNewsMainViewController

- (instancetype)init {
    if (self = [super init]) {
        self.hidesBottomBarWhenPushed = NO;
        [self addObservers];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (ZWLoginPromptView *)loginPromptView
{
    if (!_loginPromptView) {
        _loginPromptView = [[ZWLoginPromptView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        _loginPromptView.userInteractionEnabled = YES;
        _loginPromptView.clipsToBounds = NO;
        _loginPromptView.alpha = 0.0;
        _loginPromptView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
        __weak typeof(self) weakSelf = self;
        [_loginPromptView whenTapped:^{
            [weakSelf pushLoginViewController];
        }];
        [_loginPromptView setNeedsUpdateConstraints];
        [_loginPromptView updateConstraintsIfNeeded];
    }
    return _loginPromptView;
}

#pragma mark - Life cycle -
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 新闻列表页：页面显示
    [MobClick event:@"information_list_page_show"];
    [self loadLocalChannel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 提示用户给好评
    [ZWReviewManager showReviewAlert];
    
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [[ZWPushMessageManager sharedInstance] handlePushMessage];
        
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSNotification *notification = [NSNotification notificationWithName:kNotificationHideChannelMenu object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isShowBarTitleRefresh = YES;
    self.backIsshow = NO;
    [self configureUserInterface];
    [self loadChannelData];
}

//跳转到对应的频道
- (void)changeChannel:(NSNotification *)info
{
    if(info){
        NSDictionary *dict = [info userInfo];
        if(SELECTCHANNELLIST.count > 0 && [SELECTCHANNELLIST containsObject:dict[@"channelTitle"]])
        {
            [[self navTabBarController] channelChangeAtIndex:[SELECTCHANNELLIST indexOfObject:dict[@"channelTitle"]]];
        }
    }
}

#pragma mark - Channel
/** 加载频道数据*/
- (void)loadChannelData {
    // 获取缓存频道ID列表
    NSArray *tmpArray = [[ZWChannelDataManager sharedInstance] queryChannelData];
    // 有缓存的时候，先加在缓存数据
    if (tmpArray.count > 0) {
        
        [[ZWChannelDataManager sharedInstance] filterChannelData:tmpArray];
        [[ZWChannelDataManager sharedInstance] addLocalChannel];
        [self updataNewsViewControllers:SELECTCHANNELLIST];
        if ([self navTabBarController].subViewControllers.count > 0) {
            [[self navTabBarController].subViewControllers[0] reloadData];
        }
    }
    __weak typeof(self) weakSelf = self;
    [[ZWChannelDataManager sharedInstance] checkVersion:^(BOOL success) {
        if (!success) {
            if (![tmpArray count]>0) {
                [weakSelf showFailureView];
            }
        } else {
            [ZWFailureIndicatorView dismissInView:self.view];
            [weakSelf updataNewsViewControllers:SELECTCHANNELLIST];
            if ([weakSelf navTabBarController].subViewControllers.count > 0) {
                [[weakSelf navTabBarController].subViewControllers[0] reloadData];
            }
        }
    }];
}

/**
 *  获取本地频道
 */
- (void)loadLocalChannel
{
    [[ZWChannelDataManager sharedInstance] refreshLocalChannelWithSuccess:^ {
        ChannelItem *tmpmod = [[ZWChannelDataManager sharedInstance] queryChannelDataWithChannelName:[SELECTCHANNELLIST lastObject]];
        ZWNewsListViewController *infoVC = [[ZWNewsListViewController alloc]init];
        infoVC.title = [SELECTCHANNELLIST lastObject];
        infoVC.channelId = [tmpmod.channelId integerValue];
        infoVC.channelMapping = tmpmod.mapping;
        infoVC.view.tag = [SELECTCHANNELLIST count]-1;
        infoVC.actionType=kNewsListActionTypeChannelSwitch;
        [[self navTabBarController] insertViewController:infoVC];
    }];
}
#pragma mark - Init ChannelBar
-(void)updataNewsViewControllers:(NSArray *)channleList{
    NSMutableArray *viewControllersArray = [NSMutableArray array];
    NSInteger i = 0;
    for (NSString *itemname in channleList) {
        ChannelItem *tmpmod = [[ZWChannelDataManager sharedInstance] queryChannelDataWithChannelName:itemname];
        ZWNewsListViewController *infoVC = [[ZWNewsListViewController alloc]init];
        infoVC.title = itemname;
        infoVC.channelId = [tmpmod.channelId integerValue];
        infoVC.channelMapping = tmpmod.mapping;
        infoVC.view.tag = i;
        infoVC.actionType=kNewsListActionTypeChannelSwitch;
        [viewControllersArray safe_addObject:infoVC];
        i ++;
    }
    [[self navTabBarController] setSubViewControllers:viewControllersArray];
    [[self navTabBarController] addParentController:self];
}

-(void)initChannelSelector{
    //箭头按钮
    UIButton *channelbtn = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - ARROW_BUTTON_WIDTH - 5, 0, ARROW_BUTTON_WIDTH + 10, ARROW_BUTTON_WIDTH)];
    channelbtn.backgroundColor = [UIColor clearColor];
    [channelbtn setImage:[UIImage imageNamed:@"common_channelbar"] forState:UIControlStateNormal];
    [channelbtn addTarget:self action:@selector(showChannel) forControlEvents:UIControlEventTouchUpInside];
    [[self navTabBarController].navTabBar addSubview:channelbtn];
}
- (void)showChannel
{
    [[self navTabBarController].view addSubview:[self channelMenuView]];
    [[self channelMenuView] onTouchButtonShowChannelMenu];
}

-(void)hideLoginVew
{
    if (![ZWUserInfoModel login]) {
        [self addTopLoginModalView];
    }
    
    if ([self navTabBarController].subViewControllers.count>0) {
        [[self navTabBarController].subViewControllers[0] reloadData];
    }
}

- (void)addTopLoginModalView {
    [[self navTabBarController].navTabBar changeItemUserInteractionEnabled:1];
    [self showLoginPromptView];
}

- (void)showLoginPromptView {
    [UIView beginAnimations:@"ShowArrow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(showArrowDidStop)];
    self.loginPromptView.alpha = 1.0;
    [UIView commitAnimations];
}
-(void)showArrowDidStop
{
    [NSTimer scheduledTimerWithTimeInterval:3
                                     target:self
                                   selector:@selector(hideArrow)
                                   userInfo:nil
                                    repeats:YES];
}
- (void)hideArrow
{
    [UIView beginAnimations:@"HideArrow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:0.0];
    [self loginPromptView].alpha = 0.0;
    [[self navTabBarController].navTabBar changeItemUserInteractionEnabled:2];
    [UIView commitAnimations];
}

#pragma mark -Properties
- (SCNavTabBarController *)navTabBarController
{
    if(!_navTabBarController)
    {
        _navTabBarController = [[SCNavTabBarController alloc] init];
        [self initChannelSelector];
    }
    return _navTabBarController;
}

- (ZWChannelScrollView *)channelMenuView
{
    if(!_channelMenuView)
    {
        _channelMenuView = [[ZWChannelScrollView alloc] initWithFrame:CGRectMake(0, -SCREEN_HEIGH, SCREEN_WIDTH, SCREEN_HEIGH)];
        _channelMenuView.backgroundColor = [UIColor whiteColor];
        _channelMenuView.bounces = NO;
        _channelMenuView.contentSize = CGSizeMake(0, UNSELECTCHANNELLIST.count/3 * 70 + SCREEN_HEIGH/2);
        [_channelMenuView setMainSuperView:[self navTabBarController]];
        [_channelMenuView setMainViewController:self];
    }
    return _channelMenuView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)refreshNewsListWhenEnterForeground {
    ZWNewsListViewController *viewController = (ZWNewsListViewController *)[self.navTabBarController currentViewController];
    viewController.actionType = kNewsListActionTypeEnterForeground;
    [viewController reloadData];
}

- (void)tapRefresh {
    ZWNewsListViewController *viewController = (ZWNewsListViewController *)[self.navTabBarController currentViewController];
    [viewController tapRefresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLaunchOver object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IntegralTotalIncome object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadChannel" object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushMessage" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeChannel" object:nil];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    [self setupTitle];
    [self.navTabBarController.navTabBar addSubview:self.loginPromptView];
}

/** 配置标题 */
- (void)setupTitle {
    __weak typeof(self) weakSelf = self;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"并读" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:17]];
    [button addAction:^(UIButton *btn) {
        // 新闻列表页：点击顶部刷新
        [MobClick event:@"back_to_top"];
        // 没有任何频道数据时要重新加载频道数据
        if (SELECTCHANNELLIST.count == 0) {
            [weakSelf loadChannelData];
        } {
            [weakSelf tapRefresh];
        }
    }];
    self.navigationItem.titleView = button;
}

/** 显示错误页 */
- (void)showFailureView {
    __weak typeof(self) weakSelf = self;
    [ZWFailureIndicatorView showInView:self.view
                           withMessage:kNetworkErrorString
                                 image:[UIImage imageNamed:@"news_loadFailed"]
                           buttonTitle:@"点击重试"
                           buttonBlock:^{
                               [weakSelf loadChannelData];
                           }
                       completionBlock:^{
                           //
                       }];
}

#pragma mark - Event handler -
/** 添加监听器 */
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLoginVew)
                                                 name:kNotificationLaunchOver
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadChannelData)
                                                 name:@"reloadChannel"
                                               object: nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(pushMessage:)
//                                                 name:@"pushMessage"
//                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeChannel:)
                                                 name:@"changeChannel"
                                               object: nil];
}

#pragma mark - Navigation -
/** 进入登录界面 */
- (void)pushLoginViewController {
    // 新闻列表页：点击快捷登录
    [MobClick event:@"login_quickly"];
    ZWLoginViewController *nextViewController = [[ZWLoginViewController alloc] init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end



@interface ZWLoginPromptView ()

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 标题 */
@property (nonatomic, strong) UILabel *titleLabel;

/** 图标 */
@property (nonatomic, strong) UIImageView *icon;

@end

@implementation ZWLoginPromptView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.icon];
    }
    return self;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        [UIView autoSetPriority:UILayoutPriorityRequired forConstraints:^{
            [self.titleLabel autoSetContentCompressionResistancePriorityForAxis:ALAxisHorizontal];
        }];
        [self.titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        [self.titleLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self withOffset:15];
        
        [self.icon autoSetDimensionsToSize:CGSizeMake(20, 20)];
        [self.icon autoPinEdge:ALEdgeRight toEdge:ALEdgeLeft ofView:self.titleLabel withOffset:-10];
        [self.icon autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.titleLabel];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel newAutoLayoutView];
        _titleLabel.text = @"快捷登录，找到你感兴趣的内容";
        _titleLabel.textColor = COLOR_666666;
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (UIImageView *)icon
{
    if (!_icon)
    {
        _icon = [UIImageView newAutoLayoutView];
        _icon.image = [UIImage imageNamed:@"btn_avatar_nav"];
    }
    return _icon;
}

@end
