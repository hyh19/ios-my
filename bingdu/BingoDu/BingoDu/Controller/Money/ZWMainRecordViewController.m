#import "ZWMainRecordViewController.h"
#import "ZWWithdrawRecordViewController.h"
#import "ZWGoodsExchangeRecordViewController.h"
#import "ZWLotteryRecordViewController.h"
#import "ZWRecordTipsManager.h"
#import "ZWPublicNetworkManager.h"
#import "HMSegmentedControl.h"
#import "UIView+Borders.h"

@interface ZWMainRecordViewController ()

/** 奖券兑换记录页面 */
@property (nonatomic, strong) ZWLotteryRecordViewController *lotteryRecordViewController;

/** 商品兑换记录页面 */
@property (nonatomic, strong) ZWGoodsExchangeRecordViewController *goodsRecordViewController;

/** 余额提现记录页面 */
@property (nonatomic, strong) ZWWithdrawRecordViewController *withdrawRecordViewController;

/** 标签栏 */
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

/** 标签栏标题 */
@property (nonatomic, strong) NSArray *sectionTitles;

/** 用于放置奖券兑换记录、商品兑换记录和余额提现记录页面的容器 */
@property (nonatomic, strong) UIView *containerView;

@end

@implementation ZWMainRecordViewController {
    /** 当前页面 */
    UIViewController *_fromViewController;
    
    /** 目标页面 */
    UIViewController *_toViewController;
}

#pragma mark - Init -
- (instancetype)initWithDefaultViewController:(NSString *)className {
    if (self = [super init]) {
        [self configureDefaultViewController:className];
    }
    return self;
}

#pragma mark - Getter & Setter
- (NSArray *)sectionTitles {
    NSInteger lotteryNumber = [ZWRecordTipsManager lotteryNumber];
    NSString *lotteryText = ( lotteryNumber > 0 ? [NSString stringWithFormat:@"奖券（%ld）", (long)lotteryNumber] : @"奖券" );
    
    NSInteger goodsNumber = [ZWRecordTipsManager goodsNumber];
    NSString *goodsText = ( goodsNumber > 0 ? [NSString stringWithFormat:@"商品（%ld）", (long)goodsNumber] : @"商品" );
    
    NSInteger withdrawNumber = [ZWRecordTipsManager withdrawNumber];
    NSString *withdrawText = ( withdrawNumber > 0 ? [NSString stringWithFormat:@"提现（%ld）", (long)withdrawNumber] : @"提现" );
    
    return @[lotteryText, goodsText, withdrawText];
}

- (HMSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:self.sectionTitles];
        _segmentedControl.frame = CGRectMake(0, 0, SCREEN_WIDTH, SEGMENT_BAR_HEIGHT);
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.selectionIndicatorHeight = 3;
        _segmentedControl.selectionIndicatorColor = COLOR_MAIN;
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : COLOR_848484,
                                                   NSFontAttributeName            : [UIFont systemFontOfSize:13]};
        _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : COLOR_MAIN,
                                                          NSFontAttributeName            : [UIFont systemFontOfSize:13]};
        [_segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
        [_segmentedControl addBottomBorderWithHeight:0.5 andColor:COLOR_E7E7E7];
    }
    return _segmentedControl;
}

- (UIView *)containerView {
    
    if (!_containerView) {
        CGRect frame = CGRectMake(0, SEGMENT_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGH-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-SEGMENT_BAR_HEIGHT);
        _containerView = [[UIView alloc] initWithFrame:frame];
        _containerView.backgroundColor = [UIColor redColor];
    }
    return _containerView;
}

- (ZWLotteryRecordViewController *)lotteryRecordViewController {
    if (!_lotteryRecordViewController) {
        _lotteryRecordViewController = [[ZWLotteryRecordViewController alloc] init];
    }
    return _lotteryRecordViewController;
}

- (ZWGoodsExchangeRecordViewController *)goodsRecordViewController {
    if (!_goodsRecordViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Exchange" bundle:nil];
        _goodsRecordViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWGoodsExchangeRecordViewController class])];
    }
    return _goodsRecordViewController;
}

- (ZWWithdrawRecordViewController *)withdrawRecordViewController {
    if (!_withdrawRecordViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
        _withdrawRecordViewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWWithdrawRecordViewController class])];
    }
    return _withdrawRecordViewController;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTipsNumber) name:kNotificationUpdateRecordTipsNumber object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self readPage:self.segmentedControl.selectedSegmentIndex sender:self];
}

#pragma mark - UI management
/** 配置界面外观 */
- (void)configureUserInterface {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"兑换记录";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.containerView];
}

/** 配置默认显示页面 */
- (void)configureDefaultViewController:(NSString *)className {
    
    UIViewController *childViewController = nil;
    
    if ([className isEqualToString:NSStringFromClass([ZWLotteryRecordViewController class])]) {
        
        // 默认显示奖券兑换记录页面
        childViewController = self.lotteryRecordViewController;
        
        self.segmentedControl.selectedSegmentIndex = 0;
        
    } else if ([className isEqualToString:NSStringFromClass([ZWGoodsExchangeRecordViewController class])]) {
        
        // 默认显示奖券兑换记录页面
        childViewController = self.goodsRecordViewController;
        
        self.segmentedControl.selectedSegmentIndex = 1;
        
    } else if ([className isEqualToString:NSStringFromClass([ZWWithdrawRecordViewController class])]) {
        
        // 默认余额提现记录页面
        childViewController = self.withdrawRecordViewController;
        
        self.segmentedControl.selectedSegmentIndex = 2;
    }
    
    childViewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:childViewController.view];
    [self addChildViewController:childViewController];
    [childViewController didMoveToParentViewController:self];
    _fromViewController = childViewController;
}

#pragma mark - Network management
/** 发送网络请求标记当前页面为已读状态，用于清除标签数字提示 */
- (void)sendRequestForRemovingTipWithPageName:(NSString *)pageName {
    [[ZWPublicNetworkManager sharedInstance] deleteTipsNumberWithUserId:[ZWUserInfoModel userID]
                                                                   type:pageName
                                                                 succed:^(id result) {
                                                                     [ZWRecordTipsManager updateTipsNumberForLottery:result[@"lottery"]
                                                                                                               goods:result[@"goods"]
                                                                                                            withdraw:result[@"withdraw"]];
                                                                 }
                                                                 failed:^(NSString *errorString) {}];
}

#pragma mark - Event handler
/** 切换页面 */
- (void)switchPageWithIndex:(NSUInteger)index {
    switch (index) {
            
        case 0:// 切换到奖券兑换记录界面
        {
            _toViewController = self.lotteryRecordViewController;
            // 兑换记录页：奖券标签页面显示
            [MobClick event:@"conversion_record_lottery_page_show"];
            break;
        }
        case 1:// 切换到商品兑换记录界面
        {
            _toViewController = self.goodsRecordViewController;
            // 兑换记录页：商品标签页面显示
            [MobClick event:@"conversion_record_gift_page_show"];
            break;
        }
        case 2:// 切换到余额提现记录界面
        {
            _toViewController = self.withdrawRecordViewController;
            // 兑换记录页：提现标签页面显示
            [MobClick event:@"conversion_record_encashment_page_show"];
            break;
        }
    }
    
    [self addChildViewController:_toViewController];
    
    [self transitionFromViewController:_fromViewController
                      toViewController:_toViewController
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                [_fromViewController.view removeFromSuperview];
                                _toViewController.view.frame = self.containerView.bounds;
                                [self.containerView addSubview:_toViewController.view];
                            }
                            completion:^(BOOL finished) {
                                [_toViewController didMoveToParentViewController:self];
                                [_fromViewController removeFromParentViewController];
                                _fromViewController = _toViewController;
                            }];
}

/** 发送请求通知服务器当前页面的数字提示已读 */
- (void)readPage:(NSUInteger)index sender:(id)sender {
    
    switch (index) {
            
        case 0:
        {
            if ([sender isEqual:self]) {
                [self sendRequestForRemovingTipWithPageName:@"LOTTERY"];
            } else {
                if ([ZWRecordTipsManager lotteryNumber] > 0) { [self sendRequestForRemovingTipWithPageName:@"LOTTERY"]; }
            }
            break;
        }
        case 1:
        {
            if ([sender isEqual:self]) {
                [self sendRequestForRemovingTipWithPageName:@"GOODS"];
            } else {
                if ([ZWRecordTipsManager goodsNumber] > 0) { [self sendRequestForRemovingTipWithPageName:@"GOODS"]; }
            }
            break;
        }
        case 2:
        {
            if ([sender isEqual:self]) {
                [self sendRequestForRemovingTipWithPageName:@"WITHDRAW"];
            } else {
                if ([ZWRecordTipsManager withdrawNumber] > 0) { [self sendRequestForRemovingTipWithPageName:@"WITHDRAW"]; }
            }
            break;
        }
    }
}

/** 更新标签提示数字 */
- (void)updateTipsNumber {
    self.segmentedControl.sectionTitles = self.sectionTitles;
    // 触发标题变更事件
    self.segmentedControl.selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
}

/** 切换标签栏 */
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self switchPageWithIndex:segmentedControl.selectedSegmentIndex];
    [self readPage:segmentedControl.selectedSegmentIndex sender:segmentedControl];
}

@end
