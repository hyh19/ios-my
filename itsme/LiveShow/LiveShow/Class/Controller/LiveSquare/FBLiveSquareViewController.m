#import "FBLiveSquareViewController.h"
#import "FBSearchViewController.h"
#import "FBWebViewController.h"
#import "FBGAIManager.h"
#import "FBLoginInfoModel.h"

@interface FBLiveSquareViewController ()<WMPageControllerDelegate>

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@property (nonatomic, strong) UIImageView *rankListImageView;

@end

@implementation FBLiveSquareViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeAll;

    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS
                                            action:@"首页"
                                             label:@"PV/UUID"
                                             value:@(1)];
    self.delegate = self;
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    
    // 用户是否有关注的人数
    NSArray *replayFollowFansNum = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsReplayFollowFansNumber];
    NSString *followNum = replayFollowFansNum[1];
    // 用户的关注数量不为0
    if ([followNum integerValue] <= 0) {
        for (id subView1 in self.navigationController.navigationBar.subviews) {
            if ([subView1 isKindOfClass:[WMMenuView class]]) {
                for (id subView2 in [(WMMenuView *)subView1 subviews]) {
                    if ([subView2 isKindOfClass:[UIScrollView class]]) {
                        for (id subView3 in [(UIScrollView *)subView2 subviews]) {
                            if ([subView3 isKindOfClass:[WMMenuItem class]]) {
                                if ([[(WMMenuItem *)subView3 text] isEqualToString:kLocalizationTabFocus]) {
                                    UIView *redView = [[UIView alloc] init];
                                    redView.backgroundColor = [UIColor hx_colorWithHexString:@"50e3ce"];
                                    [redView setFrame:CGRectMake([FBUtility calculateWidth:kLocalizationTabFocus]+5, 10, 5, 5)];
                                    redView.layer.cornerRadius = 2.5;
                                    redView.clipsToBounds = YES;
                                    [(WMMenuItem *)subView3 addSubview:redView];
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configUI];
}

#pragma mark - UI Management -
- (void)configUI {
    UIImageView *searchImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_btn_search_nor"]];
    __weak typeof(self) weakSelf = self;
    [searchImageView bk_whenTapped:^{
        [weakSelf pushSearchViewController];
    }];
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchImageView];
    self.navigationItem.rightBarButtonItem = searchItem;
    

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *status = [defaults objectForKey:kUserDefaultsRankListButtonStatus];
    
#ifdef DEBUG
    status = @0;
#endif
    //后台返回0才显示榜单
    if ([status isEqual:@0]) {

        UIBarButtonItem *rankListItem = [[UIBarButtonItem alloc] initWithCustomView:self.rankListImageView];
        self.navigationItem.leftBarButtonItem = rankListItem;
    } else {
        //不是0时再请求一遍
        [self requestRankListButtonStatus];
    }
}

#pragma mark - Getter & Setter -
- (UIImageView *)rankListImageView {
    if (!_rankListImageView) {
        _rankListImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_btn_list_nor"]];
        __weak typeof(self) weakSelf = self;
        [_rankListImageView bk_whenTapped:^{
            [weakSelf pushRankListViewController];
        }];
    }
    return _rankListImageView;
}

#pragma mark - Navigation -
/** 进入搜索界面 */
- (void)pushSearchViewController {
    FBSearchViewController *searchController = [[FBSearchViewController alloc] init];
    searchController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchController animated:YES];

    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS                                         action:@"搜索"
                                          label:[[FBLoginInfoModel sharedInstance] userID]
                                          value:@(1)];
    
    // 每点击主界面右上角的搜索图标进入搜索页面＋1（黄玉辉）
    [self st_reportSearchPageShowEvent];
    
}
/** 进入排行榜界面 */
- (void)pushRankListViewController {
    FBWebViewController *rankListViewController = [[FBWebViewController alloc]initWithTitle:kLocalizationRankingList url:kRankListURL formattedURL:YES];
    rankListViewController.immediateBack = YES;
    [self.navigationController pushViewController:rankListViewController animated:YES];
}

#pragma mark - WMPageControllerDelegate -
- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
    @try {
        NSInteger index =  [info[@"index"] integerValue];
        switch (index) {
            case 0:
                
                for (id subView1 in self.navigationController.navigationBar.subviews) {
                    if ([subView1 isKindOfClass:[WMMenuView class]]) {
                        for (id subView2 in [(WMMenuView *)subView1 subviews]) {
                            if ([subView2 isKindOfClass:[UIScrollView class]]) {
                                for (id subView3 in [(UIScrollView *)subView2 subviews]) {
                                    if ([subView3 isKindOfClass:[WMMenuItem class]]) {
                                        if ([[(WMMenuItem *)subView3 text] isEqualToString:kLocalizationTabFocus]) {
                                            for (UIView *view in [(WMMenuItem *)subView3 subviews]) {
                                                [view removeFromSuperview];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                [[FBGAIManager sharedInstance] ga_sendScreenHit:@"关注"];

                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS                                         action:@"Follow"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
                break;
            case 1:
                [[FBGAIManager sharedInstance] ga_sendScreenHit:@"热门"];

                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS                                         action:@"Popular"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
                break;
            case 2:
                [[FBGAIManager sharedInstance] ga_sendScreenHit:@"达人"];
                
                [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_MAIN_STATITICS                                         action:@"new"
                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                      value:@(1)];
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        
    }
}

#pragma mark - network -
/** 是否显示榜单请求 */
- (void)requestRankListButtonStatus {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[FBLiveSquareNetworkManager sharedInstance] loadRankListButtonStatusSuccess:^(id result) {
        NSNumber *status = result[@"dm_error"];
        [defaults setValue:status forKey:kUserDefaultsRankListButtonStatus];
        [defaults synchronize];
        if ([status isEqual:@0]) {
            UIBarButtonItem *rankListItem = [[UIBarButtonItem alloc] initWithCustomView:self.rankListImageView];
            self.navigationItem.leftBarButtonItem = rankListItem;
        }
    } failure:nil finally:nil];
}

#pragma mark - Statistics -
- (void)st_reportSearchPageShowEvent {
    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"searchepage"  eventParametersArray:@[eventParmeter]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
