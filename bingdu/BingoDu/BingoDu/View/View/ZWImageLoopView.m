#import "ZWImageLoopView.h"
#import "UIImageView+WebCache.h"
#import "ZWNewsModel.h"
#import "ZWSMPageControl.h"
#import "ZWNewsNetworkManager.h"
#import "ZWSpecialNewsViewController.h"
#import "ZWADWebViewController.h"
#import "ZWArticleAdvertiseModel.h"
#import "ZWAdvertiseSkipManager.h"
#import "ZWArticleDetailViewController.h"

#define TitleLabelHeight 28
#define PageControlWidth 64

@interface ZWImageLoopView ()<UIGestureRecognizerDelegate>
{
    int _currentPage;
    int _scrollPageIndex;
    NSTimer *_scrollTimer;
    NSTimeInterval _loopTime;
    CGPoint oldPoint;
}
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) ZWSMPageControl *pageControl;
@property (strong, nonatomic) NSArray *newsModelArr;
@property (assign, nonatomic) CGSize  tableOldContentSize; //保持talbeview以前的contentsize
@end

@implementation ZWImageLoopView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}
- (void)setup
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop=NO;
    self.scrollView.bounces=NO;
    self.scrollView.directionalLockEnabled=YES;
    self.scrollView.tag = 110;
    [self addSubview:self.scrollView];

    oldPoint.x=-1;
    _scrollPageIndex = 1;
    
    UITableView *tableView = (UITableView *)self.nextResponder.nextResponder;
    tableView.contentInset=UIEdgeInsetsMake(100, 0, 0, 0);
}

- (UIView *)bottomViewAtIndex:(NSInteger)index
{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - TitleLabelHeight, self.frame.size.width, TitleLabelHeight)];
    
    // 原代码借用
    UILabel*titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(6, 0, bottomView.frame.size.width, bottomView.frame.size.height)];
    [titleLbl setTextColor:COLOR_FFFFFF];
    [titleLbl setFont:[UIFont systemFontOfSize:13]];
    
    ZWNewsModel *news = self.newsModelArr[index];
    [titleLbl setText:news.newsTitle];
    
    //做推广与否的判断 改变样式
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(6, (bottomView.frame.size.height - 12) / 2, 21, 12)];
    if (news.spread_state == ZWNoSpread_State) {
        if (news.displayType == ZWNewsDisplayText ||
            news.displayType == kNewsDisplayTypeImageAndText ) {
            [imgView setHidden:YES];
        } else {
            [imgView setHidden:NO];
        }
        switch (news.displayType) {
            case kNewsDisplayTypeImageSet:
                [imgView setImage:[UIImage imageNamed:@"icon_pictrue"]];
                break;
            case kNewsDisplayTypeVideo:
                [imgView setImage:[UIImage imageNamed:@"icon_video"]];
                break;
            case kNewsDisplayTypeOriginal:
                [imgView setImage:[UIImage imageNamed:@"icon_original"]];
                break;
            case kNewsDisplayTypeSpecialReport:
            case kNewsDisplayTypeSpecialFeature:
                [imgView setImage:[UIImage imageNamed:@"icon_special"]];
                break;
            case kNewsDisplayTypeActivity:
            {
                [imgView setImage:[UIImage imageNamed:@"icon_activity"]];
                break;
            }
            case kNewsDisplayTypeLive:
            {
                [imgView setImage:[UIImage imageNamed:@"icon_live"]];
                break;
            }
            default: {
                [imgView setHidden:YES];
                break;
            }
        }
    } else if (news.spread_state == ZWSpread_State) {
        [imgView setImage:[UIImage imageNamed:@"icon_ad"]];
     
        if (news.redirectType!=AdvertiseType) {
            [imgView setHidden:YES];
        } else {
            [imgView setHidden:NO];
        }
    }
    [titleLbl setFrame:CGRectMake(imgView.hidden? 6 : imgView.frame.origin.x + imgView.frame.size.width+6, 0, bottomView.frame.size.width-10-21, bottomView.frame.size.height)];
    [bottomView addSubview:imgView];
    [bottomView addSubview:titleLbl];
    return bottomView;
}

- (void)reloadData
{
    if ( !_imageURLArr)
        return;
    
    if (_scrollTimer)
    {
        [self releaseTimer];
    }
    
    // 清除原先添加的所有子视图
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    // 为scrollView添加每一页的内容
    int i = 0;
    CGFloat width = self.frame.size.width;
    self.pageControl.numberOfPages=_imageURLArr.count-2;
    for (NSURL *url in _imageURLArr)
    {
        CGRect frame = CGRectMake(i * width, 0, width, self.frame.size.height);
        UIButton *picBtn = [self picBtnWithFrame:frame ImageURL:url Index:i];
        [self.scrollView addSubview:picBtn];
        i++;
    }
    // 默认显示第一张图片
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * _imageURLArr.count,0)];
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:NO];
    if (self.imageURLArr.count-2<=1)
    {
        self.scrollView.scrollEnabled=NO;
        self.pageControl.hidden=YES;
        if (_scrollTimer)
        {
            [_scrollTimer invalidate];
            _scrollTimer=nil;
        }
    }
    else
    {
        self.scrollView.scrollEnabled=YES;
        // 默认开启定时器
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.loopTime target:self selector:@selector(scrollTimerAction:) userInfo:nil repeats:YES];
    }
}

- (UIButton *)picBtnWithFrame:(CGRect)frame ImageURL:(NSURL *)imageURL Index:(NSInteger)index
{
    UIButton *picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    picBtn.frame = frame;
    [picBtn setTag:index];
    picBtn.adjustsImageWhenHighlighted = NO;
    [picBtn addTarget:self action:@selector(picBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:picBtn.bounds];
    [imageView sd_setImageWithURL:imageURL placeholderImage:self.placeHodlerImage];
    [picBtn addSubview:imageView];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - TitleLabelHeight, self.frame.size.width, TitleLabelHeight)];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    [backgroundView setAlpha:0.6];
    [picBtn addSubview:backgroundView];
    
    UIView *bottomView = [self bottomViewAtIndex:index];
    [picBtn addSubview:bottomView];
    return picBtn;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView!=_scrollView)
    {
        return;
    }
    if (_scrollTimer) {
        
        [self releaseTimer];
    }
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView!=_scrollView)
        return;
    _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.loopTime target:self selector:@selector(scrollTimerAction:) userInfo:nil repeats:YES];
    
    [self lockChannelScrollView:NO];
    self.scrollView.scrollEnabled=YES;
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView!=_scrollView)
    {
        return;
    }
    // ZWLog(@"ZWImageLoopView-scrollViewDidScroll");
    CGFloat width = self.frame.size.width;
    // 显示scrollView的第一张图片(最后一张图片)时, 偏移到scrollView的倒数第二张图片(最后一张图片)
    if (scrollView.contentOffset.x <= 0) {
        [self.scrollView setContentOffset: CGPointMake(width * (_imageURLArr.count - 2), 0) animated:NO];
    }
    
    // 显示scrollView的最后一张图片(第一张图片)时, 偏移到scrollView的第二张图片(第一张图片)
    if (scrollView.contentOffset.x >= width * (_imageURLArr.count - 1)) {
        [self.scrollView setContentOffset:CGPointMake(width, 0) animated:NO];
    }
    
    _currentPage = self.scrollView.contentOffset.x / width - 1;    // 索引从0开始, 要-1
    // _currentPage为0时(索引为1的图片), 定时器播放_currentPage为1(索引为2的图片)
    _scrollPageIndex = _currentPage == 0 ? 2 : _currentPage + 2;
    
    if (self.imageURLArr) {
        self.pageControl.currentPage = _currentPage;
    }
    
    
}

- (void)releaseTimer
{
    [_scrollTimer invalidate];
    _scrollTimer = nil;
}

/** 定时器执行方法 */
- (void)scrollTimerAction:(NSTimer*)timer
{
    
    // 定时器播放时只需要 first, second, ...... last, first, 从1开始
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * _scrollPageIndex, 0) animated:YES];
    if (_scrollPageIndex > self.imageURLArr.count - 1) {
        _scrollPageIndex = 1;
    } else {
        _scrollPageIndex++;
    }
}

#pragma mark - 图片点击响应逻辑

- (void)picBtnAction:(UIButton *)sender
{
    // 原代码借用
    ZWNewsModel *news = self.newsModelArr[sender.tag];
    /**详情url为nil的时候，返回，有可能是抽奖的点击*/
    if (!news.picList.count  || !news.detailUrl)
    {
       return;
    }
     //做专题 活动 广告 新闻 判断跳转不同页面
    if(news.displayType == kNewsDisplayTypeSpecialReport || news.displayType == kNewsDisplayTypeSpecialFeature)
    {
        ZWSpecialNewsViewController *speialNewsView = [[ZWSpecialNewsViewController alloc] init];
        speialNewsView.newsModel = news;
        speialNewsView.channelName = self.channelName;
        [self.themainview.navigationController pushViewController:speialNewsView animated:YES];
        return;
    }else if (news.spread_state == ZWSpread_State)
    {
       
        ZWArticleAdvertiseModel *ariticleMode=[ZWArticleAdvertiseModel ariticleModelByNewsModel:news];
        [ZWAdvertiseSkipManager pushViewController:self.themainview withAdvertiseDataModel:ariticleMode];
         return;
    }
    /**
     设置新闻详情模块所需的参数
     */
    news.newsSourceType=ZWNewsSourceTypeCarousel;
    ZWArticleDetailViewController* articleDetail=[[ZWArticleDetailViewController alloc] initWithNewsModel:news];
    articleDetail.willBackViewController=self.themainview.navigationController.visibleViewController;
    // 新闻列表页：点击轮播图
    [MobClick event:@"click_banner"];
    [self.themainview.navigationController pushViewController:articleDetail animated:YES];
    
}

#pragma mark - Getter & Setter UI

- (ZWSMPageControl *)pageControl {
    if ( !_pageControl) {
        _pageControl = [[ZWSMPageControl alloc] initWithFrame:CGRectMake(self.frame.size.width - PageControlWidth, self.frame.size.height - TitleLabelHeight, PageControlWidth, TitleLabelHeight)];
        _pageControl.numberOfPages = self.imageURLArr.count - 2;
        _pageControl.indicatorMargin = 5.0f;
        _pageControl.indicatorDiameter = 5.0f;
        [_pageControl setPageIndicatorImage:[UIImage imageNamed:@"carouselPointNom"]];
        [_pageControl setCurrentPageIndicatorImage:[UIImage imageNamed:@"carouselPoint"]];
        
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

- (void)setImageURLArr:(NSArray *)imageURLArr {
    if (!imageURLArr) {
        _imageURLArr = imageURLArr;
        return;
    }
    
    // 更新图片数组, 添加最后一张图与第一张图
    NSMutableArray *tempImageArr = [NSMutableArray array];
    if (imageURLArr.count > 0) {
        [tempImageArr safe_addObject:[imageURLArr lastObject]];
        [tempImageArr addObjectsFromArray:imageURLArr];
        [tempImageArr safe_addObject:[imageURLArr firstObject]];
        _imageURLArr = tempImageArr;
    }
    [self reloadData];
}

- (void)setNewsModelArr:(NSArray *)newsModelArr {
    if ( !newsModelArr) {
        _newsModelArr = newsModelArr;
        return;
    }
    
    // 添加第一与最后的数据
    NSMutableArray *tempImageArr = [NSMutableArray array];
    if(newsModelArr.count > 0)
    {
        [tempImageArr safe_addObject:[newsModelArr lastObject]];
        [tempImageArr addObjectsFromArray:newsModelArr];
        [tempImageArr safe_addObject:[newsModelArr firstObject]];
        _newsModelArr = tempImageArr;
    }
}

- (NSTimeInterval)loopTime {
    if (_loopTime == 0) {
        return 3;
    }
    return _loopTime;
}

- (void)setLoopTime:(NSTimeInterval)loopTime {
    _loopTime = loopTime;
    [self reloadData];
}

- (void)setImgData:(NSMutableArray *)imgData
{
    if (imgData.count <= 1) {
        self.scrollView.scrollEnabled = NO;
        for (UIGestureRecognizer *pan in self.gestureRecognizers) {
            if ([pan isKindOfClass:[UIPanGestureRecognizer class]]) {
                pan.enabled=NO;
                break;
            }
        }
    }
    _imgData = imgData;
    
    NSMutableArray *imgURLArr = [NSMutableArray array];
    NSMutableArray *newsArrM = [NSMutableArray array];
    for (int i = 0; i < _imgData.count; i++) {
        ZWNewsModel *news=(ZWNewsModel *)imgData[i];
        [newsArrM safe_addObject:news];
        
        if (news.picList.count) {
            ZWPicModel *picModel=news.picList[0];
            [imgURLArr safe_addObject:[NSURL URLWithString:picModel.picUrl]];
        }
    }
    self.newsModelArr = [NSArray arrayWithArray:newsArrM];
    self.imageURLArr = imgURLArr;
}
// 锁定/解锁频道滚动列表
- (void)lockChannelScrollView:(BOOL) lock
{
    ZWNewsModel *news = self.newsModelArr[0];
    if (!news.detailUrl)//抽奖详情
    {
        return;
    }
    if ([[[[[self nextResponder] nextResponder] nextResponder] nextResponder] isMemberOfClass:[UIScrollView class]]) {
        
        UIScrollView *scrollView = (UIScrollView *)[[[[self nextResponder] nextResponder] nextResponder] nextResponder];
        // ZWLog(@"%d",scrollView.tag);
        scrollView.scrollEnabled = !lock;
    }
}
-(UITableView*)getTableView
{
    ZWNewsModel *news = self.newsModelArr[0];
    UITableView *tableView=nil;
    if (!news.detailUrl)//抽奖详情
    {
        tableView = (UITableView *)self.nextResponder;
    }
    else
        tableView = (UITableView *)self.nextResponder.nextResponder;
    
    return tableView;
}
@end
