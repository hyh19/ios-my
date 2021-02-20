
#import "ZWLifeStyleCategoryCollectionViewController.h"
#import "ZWLifestyleCategoryCollectionViewCell.h"
#import "PullCollectionView.h"
#import "ZWLifeStyleNetworkManager.h"
#import "ZWLifeStyleChannelItemModel.h"
#import "UIImageView+WebCache.h"
#import "ZWCategoryArticlesViewController.h"
#import "ZWFailureIndicatorView.h"
#import "ZWSegmentedViewController.h"
#import "ZWCategoryViewController.h"

@interface ZWLifeStyleCategoryCollectionViewController ()<PullCollectionViewDelegate>

@property (nonatomic, strong)NSArray *channelList;

@end

@implementation ZWLifeStyleCategoryCollectionViewController

static NSString * const reuseIdentifier = @"ZWLifestyleCategoryCollectionViewCell";

#pragma mark - Init -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle:nil];
    ZWLifeStyleCategoryCollectionViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ZWLifeStyleCategoryCollectionViewController class])];
    return viewController;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"classification_page_show"];
    
    PullCollectionView *collectionView = (PullCollectionView *)self.collectionView;
    
    collectionView.pullDelegate = self;
    
    [collectionView hidesLoadMoreView:YES];
    
    // 加载加载页
    [self.collectionView addLoadingView];
    
    [self sendRequestWithLifeStyleChannelList];
    
    self.collectionView.scrollsToTop = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kNotificationTapLifeStyle object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:kNotificationTapNavTitle object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationTapLifeStyle object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationTapNavTitle object:nil];
}

#pragma mark - Getter & Setter
- (void)setChannelList:(NSArray *)channelList
{
    if(_channelList != channelList)
    {
        _channelList = channelList;
    }
}

#pragma mark - Private method

- (void)refreshData
{
    ZWSegmentedViewController *parentViewController = (ZWSegmentedViewController *)[self parentViewController];
    if (parentViewController.selectedViewController == self) {
        [self.collectionView setContentOffset:CGPointZero animated:NO];
        [ZWFailureIndicatorView dismissInView:self.view];
        [self.collectionView setPullTableIsRefreshing:YES];
        [self sendRequestWithLifeStyleChannelList];
    }
}

- (void)showDefaultView
{
    __weak typeof(self) weakSelf = self;
    
    [[ZWFailureIndicatorView alloc]
     initWithContent:kNetworkErrorString
     image:[UIImage imageNamed:@"news_loadFailed"]
     buttonTitle:@"点击重试"
     showInView:self.view
     event:^{
         [weakSelf.collectionView setPullTableIsRefreshing:YES];
         [weakSelf sendRequestWithLifeStyleChannelList];
     }];
}

#pragma mark - Network Requests
- (void)sendRequestWithLifeStyleChannelList
{
    __weak typeof(self) weakSelf = self;
    
    [[ZWLifeStyleNetworkManager sharedInstance] loadLifeStyleChannelListWithSucced:^(id result) {
        
        [weakSelf.collectionView removeLoadingView];
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.collectionView setPullTableIsRefreshing:NO];
        });
        
        NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSDictionary *dict in result[@"channelList"])
        {
            ZWLifeStyleChannelItemModel *model = [ZWLifeStyleChannelItemModel channelModelFromDictionary:dict];
            [list addObject:model];
        }
        [weakSelf setChannelList:[list copy]];
        [weakSelf.collectionView reloadData];
        
    } failed:^(NSString *errorString) {
        occasionalHint(errorString);
        [weakSelf.collectionView removeLoadingView];
        
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf.collectionView setPullTableIsRefreshing:NO];
        });
        
        [weakSelf showDefaultView];
    }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if([self channelList])
        return [self channelList].count;
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWLifestyleCategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if([self channelList] && [self channelList].count > 0)
    {
        ZWLifeStyleChannelItemModel *model = [self channelList][indexPath.row];
        [cell.channelImageView sd_setImageWithURL:[NSURL URLWithString:model.channelImageUrl] placeholderImage:[UIImage imageNamed:@"icon_banner_ad"]];
        cell.channelNameLabel.text = model.channelName;
        
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZWLifeStyleChannelItemModel *model = [self channelList][indexPath.row];
    [self pushTagNewsListViewController:model];
}

- (void)pushTagNewsListViewController:(ZWLifeStyleChannelItemModel *)model{
//    ZWCategoryArticlesViewController *nextViewController = [ZWCategoryArticlesViewController viewController];
//    nextViewController.channelName = model.channelName;
//    nextViewController.channelId = model.channelID;
//    [self.navigationController pushViewController:nextViewController animated:YES];
    
    ZWCategoryViewController *nextViewController = [ZWCategoryViewController viewController];
    nextViewController.channelTitle = model.channelName;
    nextViewController.channelId = model.channelID;
    nextViewController.channelImage = model.channelImageUrl;
    [self.navigationController pushViewController:nextViewController animated:YES];

}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((SCREEN_WIDTH-24-5)/2, 124. * (SCREEN_WIDTH-24-5)/2 / 145);
}

#pragma mark - PullCollectionViewDelegate
- (void)pullCollectionViewDidTriggerRefresh:(PullCollectionView*)pullTableView
{
    [self sendRequestWithLifeStyleChannelList];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
