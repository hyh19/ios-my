#import "ZWNewsListViewController.h"
#import "ZWNewsNetworkManager.h"
#import "ZWNewsModel.h"
#import "NewsList.h"
#import "AppDelegate.h"
#import "ZWLoginViewController.h"
#import "ChannelItem.h"
#import "NewsPicList.h"
#import "ZWFailureIndicatorView.h"
#import "ZWHTTPRequestFactory.h"
#import "ZWLocationManager.h"
#import "ZWArticleDetailViewController.h"
#import "ZWSubscriptionViewController.h"
#import "ZWSTADCell.h"
#import "ZWCellLinView.h"
#import "ZWMultiImageCell.h"
#import "ZWSingleImageCell.h"
#import "ZWLiteralCell.h"
#import "ZWNewsInfoADCell.h"
#import "ZWSpecialNewsViewController.h"
#import "ZWMyNetworkManager.h"
#import "ZWPointDataManager.h"
#import "ZWAdvertiseSkipManager.h"
#import "NSObject+BlockBasedSelector.h"
#import "ZWImageLoopView.h"
#import "ZWStockMarketView.h"
#import "ZWRealEstateCell.h"
#import "ZWRealEstateCityViewController.h"
#import "ZWCommonWebViewController.h"
#import "ZWYDADCell.h"
#import "ZWUtility.h"
#import "Reachability.h"

/** 新闻列表数据的键值 */
const NSString *kNewsList = @"newsListData";

/** 新闻列轮播图数据的键值 */
const NSString *kCarrouselList = @"topImgData";

/** 新闻列表每页新闻条数 */
const NSUInteger pageRowsInNewsList = 20;

/** 读财频道ID */
static const NSUInteger financialChannelID = 2;

/** 房产频道ID */
static const NSUInteger realEstateChannelID = 68;

/** 新闻列表分隔线内间距 */
#define kSeparatorInset UIEdgeInsetsMake(0, 10, 0, 0)

/** 最后一次下拉刷新成功的时间 */
#define kUserDefaultsLatestDragRefreshTime @"UserDefaultsLatestDragRefreshTime"

/** 最后一次切换频道刷新成功的时间 */
#define kUserDefaultsLatestSwitchRefreshTime @"UserDefaultsLatestSwitchRefreshTime"

///-----------------------------------------------------------------------------
/// @name Cell Identifie
///-----------------------------------------------------------------------------
/** 文字新闻 */
#define kCellIdentifierText        NSStringFromClass([ZWLiteralCell class])

/** 单图新闻 */
#define kCellIdentifierSingleImage NSStringFromClass([ZWSingleImageCell class])

/** 多图新闻 */
#define kCellIdentifierMultiImage  NSStringFromClass([ZWMultiImageCell class])

/** 信息流广告 */
#define kCellIdentifierInfoAD      NSStringFromClass([ZWNewsInfoADCell class])

/** 时趣广告 */
#define kCellIdentifierSTAD        NSStringFromClass([ZWSTADCell class])

/** 房产频道都惠来 */
#define kCellIdentifierRealEstate  NSStringFromClass([ZWRealEstateCell class])

/** 互锋广告 */
#define kCellIdentifierYDAD        NSStringFromClass([ZWYDADCell class])

/** 新闻列表请求数据的偏移量 */
typedef NS_ENUM(NSUInteger, ZWNewsOffsetType) {
    /** 新闻ID */
    kOffsetTypeNewsID,
    
    /** 新闻发布时间 */
    kOffsetTypeNewsTimestamp
};

/** 列表刷新类型，用于记录刷新时间间隔 */
typedef NS_ENUM(NSUInteger, ZWNewsRefreshType) {
    /** 下拉刷新 */
    kNewsRefreshTypeDrag,
    
    /** 切换频道 */
    kNewsRefreshTypeSwitch
};

@interface ZWNewsListViewController () <UITableViewDelegate, UITableViewDataSource, PullTableViewDelegate, UIScrollViewDelegate, ZWSTADCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, ZWRealEstateCityViewControllerDelegate> {
    /** 统计上拉加载更多次数 */
    NSInteger _loadMoreTime;
    
    /** 列表的高度 */
    CGFloat _tableViewHeight;
}

/** 轮播图数据 */
@property (nonatomic, strong) NSMutableArray *carrouselList;

/** 新闻列表数据 */
@property (nonatomic, strong) NSMutableArray *newsList;

/** 记录Table view cell的高度 */
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

/** 轮播图 */
@property (strong, nonatomic) ZWImageLoopView *carouselView;

/** 财经频道股票走势图 */
@property (nonatomic, strong) ZWStockMarketView *stockMarketView;

/** Table header view */
@property (nonatomic, strong) UIView *headView;

/** 房产频道都惠来UI控件 */
@property (nonatomic, strong) UICollectionView *realEstateView;

/** 房产频道都惠来菜单数据 */
@property (nonatomic, strong) NSArray *realEstateMenuData;

@end

@implementation ZWNewsListViewController

#pragma mark - Getter & Setter
- (NSArray *)realEstateMenuData {
    if (!_realEstateMenuData) {
        _realEstateMenuData = @[@{@"icon" : @"icon_privilege",
                                  @"title": @"特惠",
                                  @"url"  : @"http://douhuilai.gzlinker.cn/index.php?g=Wap&m=House&a=house_list_th&token=xzgvaf1432781189&wecha_id=0"},
                                
                                @{@"icon" : @"icon_rebate",
                                  @"title": @"返利",
                                  @"url"  : @"http://douhuilai.gzlinker.cn/index.php?g=Wap&m=House&a=house_list_fh&token=xzgvaf1432781189&wecha_id=0"},
                                
                                @{@"icon" : @"icon_bargain",
                                  @"title": @"砍价",
                                  @"url"  : @"http://douhuilai.gzlinker.cn/index.php?g=Wap&m=House&a=house_kanjia&token=xzgvaf1432781189&wecha_id=0"},
                                
                                @{@"icon" : @"icon_search_realestate",
                                  @"title": @"找房",
                                  @"url"  : @"http://douhuilai.gzlinker.cn/index.php?g=Wap&m=House&a=house_list&token=xzgvaf1432781189&wecha_id=0"}];
    }
    return _realEstateMenuData;
}

- (UICollectionView *)realEstateView {
    if (!_realEstateView) {
        _realEstateView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 73+28) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _realEstateView.delegate = self;
        _realEstateView.dataSource = self;
        _realEstateView.scrollEnabled = NO;
        _realEstateView.scrollsToTop = NO;
        _realEstateView.showsHorizontalScrollIndicator = NO;
        _realEstateView.showsVerticalScrollIndicator = NO;
        _realEstateView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [_realEstateView registerClass:[ZWRealEstateCell class] forCellWithReuseIdentifier:kCellIdentifierRealEstate];
        [_realEstateView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _realEstateView;
}

- (UIView *)headView {
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
        _headView.backgroundColor = [UIColor clearColor];
    }
    return _headView;
}

- (ZWStockMarketView *)stockMarketView {
    if (!_stockMarketView) {
        _stockMarketView = [[ZWStockMarketView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    }
    return _stockMarketView;
}

- (ZWImageLoopView *)carouselView {
    if (!_carouselView) {
        _carouselView = [[ZWImageLoopView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/2)];
        _carouselView.placeHodlerImage = [UIImage imageNamed:@"icon_banner_ad"];
        _carouselView.loopTime = 3.0f;
        _carouselView.themainview = self;
        _carouselView.channelName = self.title;
    }
    return  _carouselView;
}

- (NSMutableDictionary *)offscreenCells {
    if (!_offscreenCells) {
        _offscreenCells = [NSMutableDictionary dictionary];
    }
    return _offscreenCells;
}

- (PullTableView *)tableView {
    if (!_tableView) {
        _tableViewHeight = SCREEN_HEIGH-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT-NAV_TAB_BAR_HEIGHT-TAB_BAR_HEIGHT;
        _tableView = [[PullTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _tableViewHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.pullDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = COLOR_E7E7E7;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

- (NSMutableArray *)carrouselList {
    if (!_carrouselList) {
        _carrouselList = [NSMutableArray array];
    }
    return _carrouselList;
}

- (NSMutableArray *)newsList {
    if (!_newsList) {
        _newsList = [NSMutableArray array];
    }
    return _newsList;
}

- (void)setActionType:(ZWNewsListActionType)actionType {
    _actionType = actionType;
    if (kNewsListActionTypeRefresh == _actionType ||
        kNewsListActionTypeLoadMore == _actionType) {
        [self reloadData];
    }
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self resetRefreshTimeInterval];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationNewsLoadFnished:) name:kNotificationNewsLoadFinished object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationWillShowTabBar)
                                                 name:kNotificationWillShowTabBar
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationWillHideTabBar)
                                                 name:kNotificationWillHideTabBar
                                               object:nil];
    
    [self sendRequestForAdxAdvertisement];
}

/** 响应显示TabBar的广播 */
- (void)onNotificationWillShowTabBar {
    self.tableView.dop_height = _tableViewHeight;
}

/** 响应隐藏TabBar的广播 */
- (void)onNotificationWillHideTabBar {
    self.tableView.dop_height = _tableViewHeight+TAB_BAR_HEIGHT;
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    // 解决在 iOS 7 和 iOS 8 下分隔线左右边距无法设置为0的问题的方法
    // iOS 7
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:kSeparatorInset];
    }
    
    // iOS 8
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:kSeparatorInset];
    }
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    
    [self.tableView registerClass:[ZWLiteralCell class] forCellReuseIdentifier:kCellIdentifierText];
    [self.tableView registerClass:[ZWSingleImageCell class] forCellReuseIdentifier:kCellIdentifierSingleImage];
    [self.tableView registerClass:[ZWMultiImageCell class] forCellReuseIdentifier:kCellIdentifierMultiImage];
    [self.tableView registerClass:[ZWNewsInfoADCell class] forCellReuseIdentifier:kCellIdentifierInfoAD];
    [self.tableView registerClass:[ZWSTADCell class] forCellReuseIdentifier:kCellIdentifierSTAD];
    [self.tableView registerClass:[ZWYDADCell class] forCellReuseIdentifier:kCellIdentifierYDAD];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:self.tableView];
}

/** 更新UI */
- (void)updateUserInterface
{
    [self updateCarrouselView];
    [self updateTableView];
    [self dismissLoadHud];
    [self dismissFailureView];
    [self stopRefreshAndLoadMore];
    if (![self.newsList count]>0) {
        [self showFailureView];
    }
}

/** 刷新轮播图 */
- (void)updateCarrouselView {
    
    if ([self.carrouselList count] > 0) {
        
        [self.carouselView removeFromSuperview];
        [self.headView addSubview:self.carouselView];
        
        CGFloat headerHeight = SCREEN_WIDTH/2;
        // 读财频道股票指数
        if (financialChannelID == self.channelId) {
            [self.stockMarketView removeFromSuperview];
            self.stockMarketView.dop_y = SCREEN_WIDTH/2;
            [self.stockMarketView reloadPointData];
            [self.headView addSubview:self.stockMarketView];
            headerHeight += 70;
        // 房产频道都惠来
        } else if (realEstateChannelID == self.channelId) {
            [self.realEstateView removeFromSuperview];
            self.realEstateView.dop_y = SCREEN_WIDTH/2;
            [self.headView addSubview:self.realEstateView];
            headerHeight += 101;
        }
        
        self.headView.dop_height = headerHeight;
        self.tableView.tableHeaderView = self.headView;
        [self.carouselView setImgData:self.carrouselList];
    } else {
        // 在轮播图为空的条件下，新闻列表为空或读财频道和房产频道以外的频道，都不显示Table header view
        if ((financialChannelID != self.channelId && realEstateChannelID != self.channelId) ||
            self.newsList.count == 0) {
            
            self.tableView.tableHeaderView = nil;
            
        } else {
            
            [self.carouselView removeFromSuperview];
            
            CGFloat headerHeight = 0;
            // 读财频道股票指数
            if (financialChannelID == self.channelId) {
                [self.stockMarketView removeFromSuperview];
                [self.stockMarketView reloadPointData];
                [self.headView addSubview:self.stockMarketView];
                headerHeight += 70;
            // 房产频道都惠来
            } else if (realEstateChannelID == self.channelId) {
                [self.realEstateView removeFromSuperview];
                [self.headView addSubview:self.realEstateView];
                headerHeight += 101;
            }
            self.headView.dop_height = headerHeight;
            [self.tableView setTableHeaderView:self.headView];
        }
    }
}

/** 刷新列表 */
- (void)updateTableView {
    [self.tableView reloadData];
}

/** 停止刷新和加载更多 */
- (void)stopRefreshAndLoadMore {
    [self.tableView setPullTableIsRefreshing:NO];
    [self.tableView setPullTableIsLoadingMore:NO];
}

/** 显示错误提示界面 */
- (void)showFailureView {
    
    __weak typeof(self) weakSelf = self;
    // !!!: 暂不开放订阅频道
    if ([self.channelMapping isEqualToString:kSubscribeChannelMapping] &&
        [ZWUtility networkAvailable]) {
        
        ZWFailViewBlock buttonBlock = nil;
        
        if ([ZWUserInfoModel login]) {
            buttonBlock = ^(void) {
                // 如果用户没有订阅频道，进入订阅界面
                [weakSelf pushSubscriptionViewController];
            };
            
            [ZWFailureIndicatorView showSubscribeViewInView:self.view withButtonBlock:buttonBlock];
            
        } else {
            buttonBlock = ^(void) {
                // 如果用户未登录，进入登录界面
                ZWLoginViewController *nextViewController = [ZWLoginViewController viewControllerWithSuccessBlock:nil failureBlock:nil finallyBlock:nil];
                [weakSelf.navigationController pushViewController:nextViewController animated:YES];
            };
            
            [ZWFailureIndicatorView showSubscribeViewInView:self.view withButtonBlock:buttonBlock];
        }
    } else {
        
        [ZWFailureIndicatorView showInView:self.view
                               withMessage:kNetworkErrorString
                                     image:[UIImage imageNamed:@"news_loadFailed"]
                               buttonTitle:@"点击重试"
                               buttonBlock:^{
                                   // TODO: 后面要重构，暂时为了解决禅道上的问题
//                                   [self sendRequestForLoadingNewsList];
                                   [weakSelf dismissFailureView];
                                   [weakSelf reloadData];
                               }
                           completionBlock:^{
                               [weakSelf.tableView setContentOffset:CGPointZero animated:NO];
                               // 显示错误页时不允许上拉加载更多
                               [weakSelf.tableView hidesLoadMoreView:YES];
                               }];
    }
}

/** 移除错误提示页面 */
- (void)dismissFailureView {
    __weak typeof(self) weakSelf = self;
    [ZWFailureIndicatorView dismissInView:self.view
                      withCompletionBlock:^{
                          // 移除错误页时恢复上拉加载更多
                          [weakSelf.tableView hidesLoadMoreView:NO];
                      }];
}

/** 显示加载提示界面 */
- (void)showLoadHud {
    __weak typeof(self) weakSelf = self;
    [self.view addLoadingViewWithCompletionBlock:^{
        [weakSelf.tableView setContentOffset:CGPointZero animated:NO];
        weakSelf.tableView.scrollEnabled = NO;
        weakSelf.loading = YES;
    }];
    [self.tableView hidesRefreshView:YES];
    [self.tableView hidesLoadMoreView:YES];
}

/** 移除加载提示界面 */
- (void)dismissLoadHud {
    __weak typeof(self) weakSelf = self;
    [self.view removeLoadingViewWithCompletionBlock:^{
        weakSelf.tableView.scrollEnabled = YES;
        weakSelf.loading = NO;
    }];
    
    [self.tableView hidesRefreshView:NO];
    [self.tableView hidesLoadMoreView:NO];
}

#pragma mark - Event handler
- (void)reloadData {
    // 加载失败时不管任何条件下都允许重新发送请求
    if ([ZWFailureIndicatorView hasFailureViewInView:self.view]) {
        [self sendRequestForLoadingNewsList];
        return;
    }
    
    if (kNewsListActionTypeChannelSwitch == self.actionType) {
        if ([self canRefreshAgainWithType:kNewsRefreshTypeSwitch]) {
            [self sendRequestForLoadingNewsList];
        } else {
            // 如果时间间隔不允许刷新，必须将状态重置为Idle
            self.actionType = kNewsListActionTypeIdle;
            // TODO: 暂时这样处理，先解决问题，后面进行重构
            if (1 == self.channelId) {
                [self sendRequestForLoadingNewsList];
            }
        }
    } else {
        if (kNewsListActionTypeEnterForeground == self.actionType) {
            [self.tableView setContentOffset:CGPointZero animated:NO];
        }
        [self sendRequestForLoadingNewsList];
    }
}

- (void)onNotificationNewsLoadFnished:(NSNotification*)notification {
    NSString *newsId=[notification object];
    for (ZWNewsModel *model in self.newsList) {
        if ([model.newsId isEqualToString:newsId]) {
            model.loadFinished = [NSNumber numberWithBool:YES];
            // 标记新闻为已读
            [self markNewsLoadFinished:model.newsId];
            [self updateUserInterface];
        }
    }
}

- (void)tapRefresh {
    if (self.tableView.pullTableIsRefreshing) { return; }
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.tableView.pullTableIsRefreshing = YES;
    __weak typeof(self) weakSelf = self;
    [self performBlock:^{
        [weakSelf pullTableViewDidTriggerRefresh:weakSelf.tableView];
    } afterDelay:0.25];
}
#pragma mark - Network management
/** 发送网络请求加载新闻列表数据 */
- (void)sendRequestForLoadingNewsList {
    // 在切换状态下才允许加载进度条
    if (self.actionType == kNewsListActionTypeChannelSwitch) {
        [self showLoadHud];
    }
    
    NSString *channelID = [NSString stringWithFormat:@"%ld", self.channelId];
    NSString *offset    = (kNewsListActionTypeLoadMore == self.actionType? [self newsOffsetWithType:kOffsetTypeNewsID]:@"0");
    NSString *timestamp = (kNewsListActionTypeLoadMore == self.actionType? [self newsOffsetWithType:kOffsetTypeNewsTimestamp]:@"0");
    NSString *rows      = [NSString stringWithFormat:@"%ld",pageRowsInNewsList];
    NSString *province  = [[ZWLocationManager province] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *city      = [[ZWLocationManager city] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *lon       = [ZWLocationManager longitude];
    NSString *lat       = [ZWLocationManager latitude];
    NSString *uid       = [ZWUserInfoModel userID];
    
    [[ZWNewsNetworkManager sharedInstance] loadNewsListWithChannelID:channelID
                                                      channelMapping:self.channelMapping
                                                              offset:offset
                                                                rows:rows
                                                           timestamp:timestamp
                                                            province:province
                                                                city:city
                                                                 lon:lon
                                                                 lat:lat
                                                                 uid:uid
                                                             isCache:NO
                                                              succed:^(id result) {
                                                                  [self configureData:result];
                                                                  if (kNewsListActionTypeRefresh == self.actionType) {
                                                                      self.tableView.pullLastRefreshDate = [NSDate date];
                                                                      [self saveRefreshTimeWithType:kNewsRefreshTypeDrag
                                                                       ];
                                                                  }
                                                                  
                                                                  if (kNewsListActionTypeChannelSwitch == self.actionType) {
                                                                      [self saveRefreshTimeWithType:kNewsRefreshTypeSwitch];
                                                                  }
                                                              } failed:^(NSString *errorString) {
                                                                  [self loadCacheData];
                                                                  occasionalHint(errorString);
                                                              } finallyBlock:^{
                                                                  self.actionType = kNewsListActionTypeIdle;
                                                                  [self performSelectorOnMainThread:@selector(updateUserInterface) withObject:nil waitUntilDone:YES];
                                                              }];
}

/** 发送网络请求通知后端添加浏览广告积分 */
- (void)sendRequestForAddingPointWithAdvertisement:(ZWNewsModel *)model {
    
    [[ZWMyNetworkManager sharedInstance] clickADWithUserID:[ZWUserInfoModel userID]
                                                      city:[ZWLocationManager city]
                                                  province:[ZWLocationManager province]
                                                  latitude:[ZWLocationManager latitude]
                                                 longitude:[ZWLocationManager longitude]
                                                      adID:model.adId
                                                  position:model.position
                                                    adType:model.advType
                                                 channelID:model.channel
                                                   isCache:NO succed:^(id result) {
                                                       //
                                                   }
                                                    failed:^(NSString *errorString) {
                                                        //
                                                        
                                                    }];
}

/** 获取ip地址,只能获取到局域网内的 */
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        
        while (temp_addr != NULL)
        {
            if( temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

/** 氪金广告 */
- (void)sendRequestForAdxAdvertisement {
    
    NSDate *dateNow = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[dateNow timeIntervalSince1970]];
    long now = [timeStamp longLongValue];
    
    NSString *appid = @"";
    NSString *idfa = [[UIDevice currentDevice] idfaString];
    NSString *os = @"2";
    NSString *pack = @"com.southZW.BD";
    NSString *appkey = @"apikeyfortest";
    
    NSString *token = [NSString stringWithFormat:@"%@%@%@%@%ld%@", appid, idfa, os, pack,now,appkey];
    NSString *tokenMD5 = [NSString stringWithFormat:@"%@", [ZWUtility md5:token]];
    
    NetworkStatus status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    int nt = 0;
    switch (status) {
        case NotReachable:
        {
            nt = 0;
            break;
        }
        case ReachableViaWiFi:
        {
            nt = 1;
            break;
        }
        case ReachableViaWWAN:
        {
            nt = 4;
            break;
        }
        default:
            break;
    }
    
    [[ZWNewsNetworkManager sharedInstance] getNetworkAdxAdvertiseWithAffId:@"affbingduios"
                                                                   affType:1
                                                                posterType:0
                                                                   adWidth:320
                                                                  adHeigth:50
                                                                        os:2
                                                                       osv:[[UIDevice currentDevice] systemVersion]
                                                                      dvid:idfa
                                                                deviceType:1
                                                                      idfa:idfa
                                                                       mac:[[UIDevice currentDevice] macaddress]
                                                               deviceWidth:SCREEN_WIDTH
                                                              deviceHeigth:SCREEN_HEIGH
                                                               orientation:0
                                                                        ip:[self getIPAddress]
                                                                        nt:nt
                                                                      pack:@"com.southZW.BD"
                                                                 timestamp:now
                                                                     token:tokenMD5
                                                                    succed:^(id result) {
                                                                        NSLog(@"the adx request is %@",result);
                                                                    }
                                                                    failed:^(NSString *errorString) {
                                                                        //
                                                                    }];
}

#pragma mark - Request data management -
/** 配置服务器返回的数据 */
- (void)configureData:(id)result {
    NSArray *newsList = result[@"newsList"];
    NSArray *carrouselList = result[@"carouselList"];
    
    if ([newsList count] > 0) {
        // 首次进入加载数据成功
        if (!self.firstLoadFinished) {self.firstLoadFinished = YES;}
        
        [self configureNewsList:newsList carrouselList:carrouselList];
    }
    
    if (kNewsListActionTypeLoadMore == self.actionType) {
        // 检查是否需要显示“下拉加载更多”控件
        if ([newsList count] > 0) {
            [self.tableView hidesLoadMoreView:NO];
        } else {
            [self.tableView hidesLoadMoreView:YES];
            occasionalHint(@"没有新闻了");
        }
    }
}

#pragma mark - News data management -
/** 配置列表新闻和轮播图新闻数据 */
- (void)configureNewsList:(NSArray *)newsList carrouselList:(NSArray *)carrouselList {
    
    if (kNewsListActionTypeLoadMore == self.actionType) {
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in newsList) {
            ZWNewsModel *newsModel = [ZWNewsModel modelWithData:dict];
            newsModel.markType = @(2);
            // 2.0.2版本开始屏蔽互锋广告 // 转云鹏
            if (![newsModel.adId isEqualToString:kYDADIdentifier]) {
                [array safe_addObject:newsModel];
            }
        }
        // 缓存新增的新闻列表数据
        [self addCacheData:array withIndexOffset:self.newsList.count];
        [self.newsList safe_addObjectsFromArray:array];
        
    } else {
        
        [self loadCacheData];
        
        if (self.newsList.count > 0) {
            newsList = [self updateNewsLoadFinishedStatus:newsList];
        }
        
        [self.newsList removeAllObjects];
        [self.carrouselList removeAllObjects];
        [self deleteCacheData];
        
        // 列表新闻
        for (NSDictionary *dict in newsList) {
            ZWNewsModel *model = [ZWNewsModel modelWithData:dict];
            model.loadFinished = dict[@"loadFinished"];
            model.markType = @(2);
            // 2.0.2版本开始屏蔽互锋广告 // 转云鹏
            if (![model.adId isEqualToString:kYDADIdentifier]) {
                [self.newsList safe_addObject:model];
            }
        }
        [self addCacheData:self.newsList withIndexOffset:0];
        
        // 轮播图新闻
        for (NSDictionary *dict in carrouselList) {
            ZWNewsModel *model = [ZWNewsModel modelWithData:dict];
            model.markType = @(1);
            model.timestamp = @"";
            [self.carrouselList safe_addObject:model];
        }
        // 下拉刷新时缓存轮播图数据
        [self addCacheData:self.carrouselList withIndexOffset:0];
    }
}

#pragma mark - Cache data management -
/** 加载缓存数据 */
- (void)loadCacheData {
    
    [self.newsList removeAllObjects];
    
    [self.carrouselList removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
    
    [fetchRequest setEntity:newsEntity];
    
    // 查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel==%d", self.channelId];
    
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"newsIndex" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    
    NSMutableArray *fetchResult = [[[AppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if (!fetchResult) {
        ZWLog(@"Error:%@",error);
    }
    
    // 配置数据库查询结果
    for (NewsList *news in fetchResult) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict safe_setObject:(news.newsId? news.newsId : @"") forKey:@"newsId"];
        
        [dict safe_setObject:news.lNum forKey:@"likeNum"];
        
        [dict safe_setObject:news.detailUrl forKey:@"detailUrl"];
        
        [dict safe_setObject:news.newsTitle forKey:@"newsTitle"];
        
        [dict safe_setObject:news.dNum forKey:@"dislikeNum"];
        
        [dict safe_setObject:news.publishTime forKey:@"publishTime"];
        
        [dict safe_setObject:news.sNum forKey:@"shareNum"];
        
        [dict safe_setObject:news.cNum  forKey:@"commentNum"];
        
        [dict safe_setObject:news.channel  forKey:@"channel"];
        
        [dict safe_setObject:(news.timestamp? news.timestamp:@"") forKey:@"timestamp"];
        
        [dict setObject:news.spreadstate forKeyedSubscript:@"promotion"];
        
        [dict safe_setObject:(news.readNum? news.readNum:@"0") forKey:@"readNum"];
        
        if (news.newsSource) { [dict safe_setObject:news.newsSource forKey:@"newsSource"]; }
        
        if (news.topicTitle) { [dict safe_setObject:news.topicTitle forKey:@"topicTitle"]; }
        
        NSMutableArray *picArray = [NSMutableArray array];
        
        // 读取图片
        for (NewsPicList *pic in [news.newsPic allObjects]) {
            NSMutableDictionary *picDict = [NSMutableDictionary dictionary];
            [picDict safe_setObject:pic.picUrl forKey:@"picUrl"];
            [picDict safe_setObject:pic.picName forKey:@"picName"];
            [picDict safe_setObject:pic.newsId forKey:@"newsId"];
            [picDict safe_setObject:pic.picId forKey:@"picId"];
            if (pic.picIndex) { [picDict safe_setObject:pic.picIndex forKey:@"picIndex"]; }
            [picArray safe_addObject:picDict];
        }
        
        // 图片排序
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"picIndex" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
        if ([picArray count] > 0) {
            picArray = [NSMutableArray arrayWithArray:[picArray sortedArrayUsingDescriptors:sortDescriptors]];
        }
        
        // 配置新闻数据
        [dict safe_setObject:picArray forKey:@"picList"];
        
        [dict safe_setObject:(news.position?news.position:@"") forKey:@"position"];
        
        [dict safe_setObject:news.zNum forKey:@"praiseNum"];
        
        [dict safe_setObject:(news.adId? news.adId:@"0") forKey:@"adId"];
        
        [dict safe_setObject:(news.displayType? news.displayType:@"0") forKey:@"displayType"];
        
        if (news.advType&&![news.advType isEqualToString:@""]) { [dict safe_setObject:news.advType forKey:@"advType"]; }
        
        if (news.redirectType) { [dict safe_setObject:news.redirectType forKey:@"redirectType"]; }
        
        if (news.redirectTargetId) { [dict safe_setObject:news.redirectTargetId forKey:@"redirectTargetId"]; }
        
        ZWNewsModel *model = [ZWNewsModel modelWithData:dict];
        [model setNewsIndex:news.newsIndex];
        [model setMarkType:news.markType];
        [model setLoadFinished:news.loadFinished];
        
        if (2 == [news.markType intValue]) {
            // 新闻
            [self.newsList safe_addObject:model];
            
        } else if (1 == [news.markType intValue]) {
            // 轮播图
            [self.carrouselList safe_addObject:model];
        }
    }
}
/** 删除缓存数据 */
- (void)deleteCacheData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
    
    [fetchRequest setEntity:newsEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel==%d",self.channelId];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    
    NSMutableArray *fetchResult = [[[AppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (error) { ZWLog(@"Error:%@",error); }
    
    for (NewsList* news in fetchResult) {
        [[AppDelegate sharedInstance].managedObjectContext deleteObject:news];
    }
    
    if (![[AppDelegate sharedInstance].managedObjectContext save:&error]) {
        if (error) { ZWLog(@"Error:%@",error); }
    }
}
/**
 *  @brief  缓存新闻数据
 *
 *  @param data   新闻数据
 *  @param offset 新闻索引的偏移量，如果是缓存轮播图新闻则传轮播图新闻的数量，列表新闻类似
 */
- (void)addCacheData:(NSArray *)data withIndexOffset:(NSUInteger)offset {
    for (int i =0; i<data.count; i++) {
        
        ZWNewsModel *newsModel = (ZWNewsModel *)data[i];
        
        NewsList *news = (NewsList *)[NSEntityDescription insertNewObjectForEntityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
        
        [news setNewsId:newsModel.newsId];
        [news setLNum:newsModel.lNum];
        [news setDetailUrl:newsModel.detailUrl];
        [news setNewsTitle:newsModel.newsTitle];
        [news setDNum:newsModel.dNum];
        [news setPublishTime:newsModel.publishTime];
        [news setSNum:newsModel.sNum];
        [news setCNum:newsModel.cNum];
        [news setChannel:newsModel.channel];
        [news setAdvType:newsModel.advType];
        [news setPosition:newsModel.position?newsModel.position:@""];
        [news setTimestamp:newsModel.timestamp];
        [news setReadNum:newsModel.readNum];
        [news setSpreadstate:[NSNumber numberWithInt:newsModel.spread_state ]];
        [news setTopicTitle:newsModel.topicTitle];
        [news setAdId:(newsModel.adId? newsModel.adId:@"0")];
        if (newsModel.newsSource) { [news setNewsSource:newsModel.newsSource]; }
        if (newsModel.redirectTargetId) { [news setRedirectTargetId:@([newsModel.redirectTargetId integerValue])]; }
        if (newsModel.redirectType > 0) { [news setRedirectType:@(newsModel.redirectType)]; }
        if (newsModel.onTop) { news.onTop = newsModel.onTop; }
        
        NSMutableArray *array = [NSMutableArray array];
        for (int j=0; j<[newsModel.picList count]; ++j) {
            
            ZWPicModel *pic = [newsModel.picList safe_objectAtIndex:j];
            
            NewsPicList *newsPic = (NewsPicList *)[NSEntityDescription insertNewObjectForEntityForName:@"NewsPicList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
            [newsPic setPicId:[NSNumber numberWithInt:[pic.picId intValue]]];
            [newsPic setNewsId:[NSNumber numberWithInt:[pic.newsId intValue]]];
            [newsPic setPicName:pic.picName];
            [newsPic setPicUrl:pic.picUrl];
            [newsPic setPicIndex:[NSNumber numberWithInt:j]];
            [array safe_addObject:newsPic];
        }
        
        [news setNewsPic:[NSSet setWithArray:array]];
        [news setZNum:newsModel.zNum];
        [news setDisplayType:[NSString stringWithFormat:@"%ld",newsModel.displayType]];
        [news setMarkType:newsModel.markType];
        [news setState:[NSNumber numberWithInt:newsModel.state]];
        [news setLoadFinished:newsModel.loadFinished];
        [news setNewsIndex:[NSNumber numberWithLongLong:offset+i]];
    }
    
    NSError *error;
    if (![[AppDelegate sharedInstance].managedObjectContext save:&error]) {
        if (error) { ZWLog(@"Error:%@",error); }
    }
}

#pragma mark - PullTableView delegate
- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView {
    // 新闻列表页：下拉刷新
    [MobClick event:@"pull_down_to_refresh"];
    // 恢复上拉加载更多统计次数
    _loadMoreTime = 0;
    if (![self canRefreshAgainWithType:kNewsRefreshTypeDrag]) {
        if (self.newsList.count > 0) {
            [self performSelector:@selector(stopRefreshAndLoadMore) withObject:nil afterDelay:0.5];
            return;
        }
    }
    self.actionType = kNewsListActionTypeRefresh;
    
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView {
    // 发送上拉加载更多统计次数
    ++_loadMoreTime;
    if (_loadMoreTime == 1) {
        [MobClick event:@"load_more_once"];
    } else if(_loadMoreTime == 2) {
        [MobClick event:@"load_more_twice"];
    } else if(_loadMoreTime == 3) {
        [MobClick event:@"load_more_3times"];
    } else if(_loadMoreTime == 4) {
        [MobClick event:@"load_more_4times"];
    } else if(_loadMoreTime == 5) {
        [MobClick event:@"load_more_5times"];
    }
    
    self.actionType = kNewsListActionTypeLoadMore;
    [[ZWNewsNetworkManager sharedInstance] sendChannelUseing:[@(self.channelId) stringValue]];
}

#pragma mark - Navigation -
/** 进入自媒体订阅界面 */
- (void)pushSubscriptionViewController {
    ZWSubscriptionViewController *nextViewController = [ZWSubscriptionViewController viewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZWNewsModel *model = self.newsList[indexPath.row];
    ZWNewsPatternType newsPattern = model.newsPattern;
    
    if (newsPattern == kNewsPatternTypeInfoAD && [model.adId isEqualToString:kSTADIdentifier]) {
        ZWSTADCell *cell = (ZWSTADCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifierSTAD];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        cell.model = model;
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        return cell;
    }
    
    if (newsPattern == kNewsPatternTypeInfoAD && [model.adId isEqualToString:kYDADIdentifier]) {
        ZWYDADCell *cell = (ZWYDADCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifierYDAD];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = model;
        cell.presentingViewController = self;
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        return cell;
    }
    
    NSString *cellIdentifier = nil;
    
    switch (newsPattern) {
        case kNewsPatternTypeInfoAD: { cellIdentifier = kCellIdentifierInfoAD; break; }
        case kNewsPatternTypeMultiImage: { cellIdentifier = kCellIdentifierMultiImage; break; }
        case kNewsPatternTypeSingleImage: { cellIdentifier = kCellIdentifierSingleImage; break; }
        case kNewsPatternTypeText: { cellIdentifier = kCellIdentifierText; break; }
        default: break;
    }
    
    ZWNewsBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.newsList[indexPath.row];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWNewsModel *model = self.newsList[indexPath.row];
    NSUInteger newsPattern = model.newsPattern;
    // 时趣广告
    if (newsPattern == kNewsPatternTypeInfoAD && [model.adId isEqualToString:kSTADIdentifier]) {
        return [ZWSTADCell height];
    }
    
    // 互锋广告
    if (newsPattern == kNewsPatternTypeInfoAD && [model.adId isEqualToString:kYDADIdentifier]) {
        return [ZWYDADCell height];
    }
    
    NSString *cellIdentifier = nil;
    
    switch (newsPattern) {
        case kNewsPatternTypeInfoAD: { cellIdentifier = kCellIdentifierInfoAD; break; }
        case kNewsPatternTypeMultiImage: { cellIdentifier = kCellIdentifierMultiImage; break; }
        case kNewsPatternTypeSingleImage: { cellIdentifier = kCellIdentifierSingleImage; break; }
        case kNewsPatternTypeText: { cellIdentifier = kCellIdentifierText; break; }
        default: break;
    }
    
    ZWNewsBaseCell *cell = [self.offscreenCells objectForKey:cellIdentifier];
    if (!cell) {
        cell = [[NSClassFromString(cellIdentifier) alloc] init];
        [self.offscreenCells setObject:cell forKey:cellIdentifier];
    }
    cell.model = model;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;
    return height;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 新闻列表页：点击列表新闻链接
    [MobClick event:@"click_information_list"];

    ZWNewsModel *model = self.newsList[indexPath.row];
    
    if (model.displayType == kNewsDisplayTypeSpecialReport || model.displayType == kNewsDisplayTypeSpecialFeature) {
        [self pushSpecialNewsReportViewController:model];
        return;
    } else if (model.spread_state == ZWSpread_State) {
        // 时趣移动广告
        if ([model.adId isEqualToString:kSTADIdentifier]) {
            ZWSTADCell *cell = (ZWSTADCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            STObject *stObj = cell.STObj;
            if (stObj) { [self presentSTADViewControllerWithModel:model andSTObject:stObj]; }
            return;
        }
        
        // 互锋移动广告
        if ([model.adId isEqualToString:kYDADIdentifier]) {
            ZWYDADCell *cell = (ZWYDADCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            YDNativeAd *nativeAD = cell.nativeAd;
            [nativeAD displayContentWithCompletion:^(BOOL success, NSError *error) {
                if (success) {
                    [self sendRequestForAddingPointWithAdvertisement:model];
                    NSString *ADURL = [nativeAD.defaultActionURL absoluteString];
                    [ZWPointDataManager addPointForAdvertisementWithURL:ADURL];
                } else {
                    //
                }
            }];
            return;
        }
        
        if (![model.advType isEqualToString:@"ADVERTORIAL"]) {
            [self pushAdvertisementViewController:model];
            return;
        }
    }
    [self pushArticleDetailViewController:model];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // iOS 7
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:kSeparatorInset];
    }
    
    // iOS 8
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:kSeparatorInset];
    }
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!scrollView.bounces) {
        scrollView.bounces=YES;
    }
}

#pragma mark - ZWSTADCellDelegate -
- (void)STADCell:(ZWSTADCell *)cell displayed:(BOOL)displayed {
    if (!displayed) {
        [self.newsList safe_removeObject:cell.model];
        [self.tableView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    }
    return [self.realEstateMenuData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)
collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (0 == indexPath.section) {
        UICollectionViewCell *cell = [collectionView
                                      dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])
                                      forIndexPath:indexPath];
        NSString *cityText = nil;
        // 读取选定的城市缓存
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kRealEstateSelectedCity];
        if (dict) {
            cityText = dict[@"region_name"];
        }
        
        // 没有缓存则定位城市或者使用默认的广州市
        if (!cityText) {
            // 默认的城市是广州市
            cityText = @"广州市";
        }
        
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
        
        NSString *fullText = [NSString stringWithFormat:@"%@ 购房优惠", cityText];
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
        NSRange hilightedRange = [fullText rangeOfString:cityText];
        [attributedText addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN range:hilightedRange];
        
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.textColor = COLOR_333333;
        label.font = [UIFont systemFontOfSize:13];
        label.attributedText = attributedText;
        [label sizeToFit];
        label.center = CGPointMake(SCREEN_WIDTH/2, 14);
        [cell.contentView addSubview:label];
        
        cell.backgroundColor = [UIColor colorWithHexString:@"#e8e8e8"];
        return cell;
    }
    
    ZWRealEstateCell* cell = [collectionView
                              dequeueReusableCellWithReuseIdentifier:kCellIdentifierRealEstate
                              forIndexPath:indexPath];
    cell.data = self.realEstateMenuData[indexPath.item];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        [self pushRealEstateCityViewController];
    } else if (1 == indexPath.section) {
        NSDictionary *dict = self.realEstateMenuData[indexPath.item];
        NSMutableString *URLString = [NSMutableString stringWithString:dict[@"url"]];
        
        // 默认城市是广州市，ID是1
        NSInteger cityID = 1;
        // 优化读取缓存的选定城市数据
        NSDictionary *selectedCity = [[NSUserDefaults standardUserDefaults] objectForKey:kRealEstateSelectedCity];
        if (selectedCity) {
            cityID = [selectedCity[@"id"] integerValue];
        }
        [URLString appendFormat:@"&cityid=%ld", cityID];
        NSURL *URL = [NSURL URLWithString:URLString];
        [self pushRealEstateWebViewControllerWithURLString:URL andTitle:dict[@"title"]];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.section) {
        return CGSizeMake(SCREEN_WIDTH, 28);
    }
    return CGSizeMake(SCREEN_WIDTH/[self.realEstateMenuData count], 73);
}

- (UIEdgeInsets)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView * _Nonnull)collectionView layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark - ZWRealEstateCityViewControllerDelegate -
- (void)realEstateViewController:(ZWRealEstateCityViewController *)viewController didSelectCity:(NSDictionary *)dict {
    [self.realEstateView reloadData];
}

#pragma mark - Navigation -
/** 进入专题新闻 */
- (void)pushSpecialNewsReportViewController:(ZWNewsModel *)model {
    ZWSpecialNewsViewController *nextViewController = [[ZWSpecialNewsViewController alloc] init];
    nextViewController.newsModel = model;
    nextViewController.channelName = self.title;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入新闻详情 */
- (void)pushArticleDetailViewController:(ZWNewsModel *)model {
    model.newsSourceType = ZWNewsSourceTypeGeneralNews;
    ZWArticleDetailViewController* articleDetail = [[ZWArticleDetailViewController alloc] initWithNewsModel:model];
    articleDetail.willBackViewController=self.navigationController.visibleViewController;
    [self.navigationController pushViewController:articleDetail animated:YES];
}

/** 信息流广告跳转 */
- (void)pushAdvertisementViewController:(ZWNewsModel *)model {
    ZWArticleAdvertiseModel *ariticleMode = [ZWArticleAdvertiseModel ariticleModelByNewsModel:model];
    [ZWAdvertiseSkipManager pushViewController:self withAdvertiseDataModel:ariticleMode];
}

/** 进入都惠来定位界面 */
- (void)pushRealEstateCityViewController {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    ZWRealEstateCityViewController *nextViewController = [[ZWRealEstateCityViewController alloc] initWithCollectionViewLayout:flowLayout];
    nextViewController.delegate = self;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入房产频道都惠来网页 */
- (void)pushRealEstateWebViewControllerWithURLString:(NSURL *)URL andTitle:(NSString *)title {
    ZWCommonWebViewController *nextViewController = [[ZWCommonWebViewController alloc] initWithURLString:URL.absoluteString];
    nextViewController.title = title;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 弹出时趣广告界面 */
- (void)presentSTADViewControllerWithModel:(ZWNewsModel *)model andSTObject:(STObject *)stObj {
    [stObj adClick:^(NSString *result) {
        if ([result isEqualToString:@"LandPage_Success"]) {
            [self sendRequestForAddingPointWithAdvertisement:model];
            NSString *ADURL = [stObj.content_image_url absoluteString];
            [ZWPointDataManager addPointForAdvertisementWithURL:ADURL];
        }
    }];
}

#pragma mark - Helper -
/** 配置新数据的加载状态，和缓存数据中的保持一致 */
- (NSMutableArray *)updateNewsLoadFinishedStatus:(NSArray *)newsList {
    
    NSMutableArray *newArray = [NSMutableArray array];
    
    for (NSDictionary *dict in newsList) {
        
        NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        NSString *newsID = dict[@"newsId"];
        
        [newDict safe_setObject:[NSNumber numberWithBool:NO] forKey:@"loadFinished"];
        
        for (ZWNewsModel *model in self.newsList) {
            if ([model.newsId isEqualToString:newsID]) {
                if ([model.loadFinished isKindOfClass:NSClassFromString(@"NSNumber")]) {
                    [newDict safe_setObject:model.loadFinished forKey:@"loadFinished"];
                    break;
                }
            }
        }
        [newArray safe_addObject:newDict];
    }
    return newArray;
}

/** 标记某一条新闻的已读状态 */
- (void)markNewsLoadFinished:(NSString *)newsID {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *newsEntity = [NSEntityDescription entityForName:@"NewsList" inManagedObjectContext:[AppDelegate sharedInstance].managedObjectContext];
    
    [fetchRequest setEntity:newsEntity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel==%d&&newsId==%@",self.channelId,newsID];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSMutableArray* fetchResult=[[[AppDelegate sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    if (error) { ZWLog(@"Error:%@",error); }
    
    for (NewsList *news in fetchResult) {
        [news setLoadFinished:[NSNumber numberWithBool:YES]];
    }
    if (![[AppDelegate sharedInstance].managedObjectContext save:&error]) {
        if (error) { ZWLog(@"Error:%@",error); }
    }
}

- (BOOL)canRefreshAgainWithType:(ZWNewsRefreshType)type {
    BOOL result = NO;
    NSString *key = nil;
    if (kNewsRefreshTypeDrag == type) {
        key = kUserDefaultsLatestDragRefreshTime;
    } else if (kNewsRefreshTypeSwitch == type) {
        key = kUserDefaultsLatestSwitchRefreshTime;
    }
    NSString *channelID = [NSString stringWithFormat:@"%ld", self.channelId];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *now = [NSDate date];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    // 未保存过任何频道的刷新时间间隔数据
    if(![userDefaults objectForKey:key]) {
        result = YES;
    } else {
        dict = [[userDefaults objectForKey:key] mutableCopy];
        // 判断是否保存过当前频道的刷新时间间隔数据
        if ([[dict allKeys] containsObject:channelID]) {
            NSDate *latest = [dict objectForKey:channelID];
            NSTimeInterval interval = [now timeIntervalSinceDate:latest];
            NSUInteger limit = 0;
            if (kNewsRefreshTypeDrag == type) {
                // 下拉刷新时间间隔要大于1分钟
                limit = kTimeIntervalRefreshNewsListWhenDrag;
            } else if (kNewsRefreshTypeSwitch == type) {
                // 切换频道刷新时间间隔要大于5分钟
                limit = kTimeIntervalRefreshNewsListWhenSwitchChannel;
            }
            if (interval > limit) {
                result = YES;
            }
        } else {
            result = YES;
        }
    }
    return result;
}

/** 保存最后一次刷新时间（下拉刷新和切换频道） */
- (void)saveRefreshTimeWithType:(ZWNewsRefreshType)type {
    NSString *key = nil;
    if (kNewsRefreshTypeDrag == type) {
        key = kUserDefaultsLatestDragRefreshTime;
    } else if (kNewsRefreshTypeSwitch == type) {
        key = kUserDefaultsLatestSwitchRefreshTime;
    }
    NSString *channelID = [NSString stringWithFormat:@"%ld", self.channelId];
    NSDate *now = [NSDate date];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if ([userDefaults objectForKey:key]) {
        // 获取之前保存的数据
        dict = [[userDefaults objectForKey:key] mutableCopy];
    }
    
    [dict safe_setObject:now forKey:channelID];
    [userDefaults setObject:dict forKey:key];
    [userDefaults synchronize];
}

/** 重置刷新时间间隔 */
- (void)resetRefreshTimeInterval {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsLatestDragRefreshTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsLatestSwitchRefreshTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/** 获取请求数据的偏移量 */
- (NSString *)newsOffsetWithType:(ZWNewsOffsetType)type {
    NSEnumerator *enumerator = [self.newsList reverseObjectEnumerator];
    id anObject;
    while (anObject = [enumerator nextObject]) {
        ZWNewsModel *model = (ZWNewsModel *)anObject;
        if (!model.adId || [model.adId isEqualToString:@"0"]) {
            if (kOffsetTypeNewsID == type) {
                return model.newsId;
            } else if (kOffsetTypeNewsTimestamp == type) {
                return model.timestamp;
            }
        }
    }
    return @"0";
}

@end
