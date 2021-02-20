//
//  SCNavTabBarController.m
//  SCNavTabBarController
//
//  Created by ShiCang on 14/11/17.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#import "SCNavTabBarController.h"
#import "SCNavTabBar.h"
#import "ZWNewsListViewController.h"
#import "AppDelegate.h"
#import "ZWNewsNetworkManager.h"
#import "UIView+Borders.h"

@interface SCNavTabBarController () <UIScrollViewDelegate, SCNavTabBarDelegate>
{
    NSInteger       _currentIndex;              // current page index
    UIScrollView    *_mainView;                 // content view
}
@property (nonatomic, strong)NSMutableArray  *titles;
@property (nonatomic, strong)UIScrollView  *mainView;                 // content view
@property (nonatomic, strong) AppDelegate         *myAppDelegate;     // 应用程序委托
@end

@implementation SCNavTabBarController

#pragma mark - Life Cycle
#pragma mark -

- (id)initWithShowArrowButton:(BOOL)show
{
    self = [super init];
    if (self)
    {
        _showArrowButton = show;
    }
    return self;
}

- (id)initWithSubViewControllers:(NSMutableArray *)subViewControllers
{
    self = [super init];
    if (self)
    {
        _subViewControllers = subViewControllers;
    }
    return self;
}

- (id)initWithParentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        [self addParentController:viewController];
    }
    return self;
}

- (id)initWithSubViewControllers:(NSMutableArray *)subControllers andParentViewController:(UIViewController *)viewController showArrowButton:(BOOL)show;
{
    self = [self initWithSubViewControllers:subControllers];
    
    _showArrowButton = show;
    [self addParentController:viewController];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _myAppDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
#pragma mark -

- (void)setSubViewControllers:(NSMutableArray *)subViewControllers
{
    if(_subViewControllers != subViewControllers)
    {
        _subViewControllers = subViewControllers;
        [self initConfig];
        [self viewConfig];
    }
}

- (NSMutableArray *)titles
{
    if(!_titles)
    {
        _titles = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _titles;
}
- (SCNavTabBar *)navTabBar
{
    if(!_navTabBar)
    {
        _navTabBar = [[SCNavTabBar alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, SCREEN_WIDTH, NAV_TAB_BAR_HEIGHT) showArrowButton:_showArrowButton];
        _navTabBar.delegate = self;
        
        _navTabBar.backgroundColor = COLOR_FFFFFF;
        _navTabBar.lineColor = COLOR_MAIN;
        _navTabBar.selectedColor = COLOR_MAIN;
        [_navTabBar addBottomBorderWithHeight:0.5 andColor:COLOR_E7E7E7];
    }
    return _navTabBar;
}

- (UIScrollView *)mainView
{
    if(!_mainView)
    {
        _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, [self navTabBar].frame.origin.y + [self navTabBar].frame.size.height, SCREEN_WIDTH, SCREEN_HEIGH - [self navTabBar].frame.origin.y - [self navTabBar].frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT*2 - 5+49)];
        _mainView.delegate = self;
        _mainView.pagingEnabled = YES;
        _mainView.bounces = NO;
        _mainView.showsHorizontalScrollIndicator = NO;
        _mainView.alwaysBounceHorizontal = NO;
        _mainView.alwaysBounceVertical = NO;
        _mainView.directionalLockEnabled = YES;
        _mainView.scrollsToTop = NO;
        _mainView.contentSize = CGSizeMake(SCREEN_WIDTH * [self subViewControllers].count, DOT_COORDINATE);
    }
    return _mainView;
}

#pragma mark -
- (void)initConfig
{
    // Iinitialize value
    _currentIndex = 0;
    [[self titles] removeAllObjects];
    for (UIViewController *viewController in [self subViewControllers])
    {
        [[self titles] addObject:viewController.title];
    }
}

- (void)viewInit{
    // Load NavTabBar and content view to show on window
    [[self mainView] removeFromSuperview];
    [[self navTabBar] removeFromSuperview];
    [self navTabBar].itemTitles = [self titles];
    [self navTabBar].arrowImage = _navTabBarArrowImage;
    [[self navTabBar] updateData];
    [[self navTabBar] itemPressedWithIndex:_currentIndex];
    
    [self.view addSubview:[self mainView]];
    [self.view addSubview:[self navTabBar]];
}

- (void)viewConfig{
    [self viewInit];
    NSArray *viewArray = [[NSArray alloc] initWithArray:self.childViewControllers];
    for(UIViewController *view in viewArray)
    {
        [view removeFromParentViewController];
        [view.view removeFromSuperview];
    }
    // Load children view controllers and add to content view
    [self mainView].contentSize = CGSizeMake(SCREEN_WIDTH * [self subViewControllers].count, DOT_COORDINATE);
    [self mainView].contentOffset = CGPointMake(0, 0);
    
    [[self subViewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        UIViewController *viewController = (UIViewController *)[self subViewControllers][idx];
        viewController.view.frame = CGRectMake(idx * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, [self mainView].frame.size.height);
        [[self mainView] addSubview:viewController.view];
        [self mainView].contentSize = CGSizeMake(SCREEN_WIDTH * [self subViewControllers].count, DOT_COORDINATE);
        [self mainView].contentOffset = CGPointMake(0, 0);
        [self addChildViewController:viewController];
    }];
    [self changeScrollToTopState:_currentIndex];
    
}

- (void)channelChangeAtIndex:(NSInteger)index
{
    _currentIndex = index;
    [self mainView].contentOffset = CGPointMake(index*SCREEN_HEIGH, 0);
    [[self navTabBar] itemPressedWithIndex:index];
}

- (void)insertViewController:(UIViewController *)viewController
{
    [[self subViewControllers] addObject: viewController];
    [[self titles] addObject:viewController.title];
    [[self navTabBar] updateData:[self titles]];
    [self mainView].frame = CGRectMake(DOT_COORDINATE, [self navTabBar].frame.origin.y + [self navTabBar].frame.size.height, SCREEN_WIDTH, SCREEN_HEIGH - [self navTabBar].frame.origin.y - [self navTabBar].frame.size.height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT*2 - 5);
    [self mainView].contentSize = CGSizeMake(SCREEN_WIDTH * [self subViewControllers].count, DOT_COORDINATE);
    
    viewController.view.frame = CGRectMake(([self subViewControllers].count-1) * SCREEN_WIDTH, DOT_COORDINATE, SCREEN_WIDTH, [self mainView].frame.size.height);
    [[self mainView] addSubview:viewController.view];
    [self mainView].contentSize = CGSizeMake(SCREEN_WIDTH * [self subViewControllers].count, DOT_COORDINATE);
    [self addChildViewController:viewController];
}


#pragma mark - Public Methods
#pragma mark -

- (void)addParentController:(UIViewController *)viewController
{
    // !!!: 以下代码会导致TabBar隐藏后，TabBar原来所在的区域无法点击，所以注释掉
    /**
     if ([viewController respondsToSelector:@selector(edgesForExtendedLayout)])
     {
     viewController.edgesForExtendedLayout = UIRectEdgeNone;
     }
     */
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    
    [viewController addChildViewController:self];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [viewController.view addSubview:self.view];
}

#pragma mark - Scroll View Delegate Methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    for (ZWNewsListViewController *thecon in [self subViewControllers]) {
        if (thecon.loading) {
            thecon.tableView.scrollEnabled = NO;
        } else {
            thecon.tableView.scrollEnabled = YES;
        }
    }
    NSInteger index = scrollView.contentOffset.x / SCREEN_WIDTH;
    if (_currentIndex != index) {
        _currentIndex = index;
        [[self navTabBar] itemPressedWithIndex:_currentIndex];
    }else
    {
        ZWNewsListViewController *curNewsListView=(ZWNewsListViewController *)[self subViewControllers][_currentIndex];
        if (curNewsListView.loading) {
            curNewsListView.tableView.scrollEnabled = NO;
        } else {
            curNewsListView.tableView.scrollEnabled = curNewsListView.firstLoadFinished;
        }
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    for (ZWNewsListViewController *thecon in [self subViewControllers]) {
        if (thecon.loading) {
            thecon.tableView.scrollEnabled = NO;
        } else {
            thecon.tableView.scrollEnabled = YES;
        }
    }
    NSInteger index = scrollView.contentOffset.x / SCREEN_WIDTH;
    if (_currentIndex == index)
    {
        ZWNewsListViewController *curNewsListView=(ZWNewsListViewController *)[self subViewControllers][_currentIndex];
        if (curNewsListView.loading) {
            curNewsListView.tableView.scrollEnabled = NO;
        } else {
            curNewsListView.tableView.scrollEnabled = curNewsListView.firstLoadFinished;
        }
    }
}
- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    for (ZWNewsListViewController *thecon in [self subViewControllers]) {
        thecon.tableView.scrollEnabled = NO;
    }
}

#pragma mark - SCNavTabBarDelegate Methods
- (void)itemDidSelectedWithIndex:(NSInteger)index
{
    [[self mainView] setContentOffset:CGPointMake(index * SCREEN_WIDTH, DOT_COORDINATE) animated:_scrollAnimation];
    
    _currentIndex = index;
    [self navTabBar].currentItemIndex = _currentIndex;
    
    ZWNewsListViewController *viewController = (ZWNewsListViewController *)[self currentViewController];
    viewController.actionType = kNewsListActionTypeChannelSwitch;
    [viewController reloadData];
    // 发送频道使用统计
    [[ZWNewsNetworkManager sharedInstance] sendChannelUseing:[@(viewController.channelId) stringValue]];
    
    [self changeScrollToTopState:index];
}

-(void)changeScrollToTopState:(NSInteger )index
{
    int i=0;
    for (ZWNewsListViewController *infoTab in [self subViewControllers]) {
        if (i!=(int)index) {
            infoTab.tableView.scrollsToTop=NO;
        }else
        {
            infoTab.tableView.scrollsToTop=YES;
        }
        i++;
    }
}

#pragma mark - Helper -
- (UIViewController *)currentViewController {
    if (_subViewControllers && [_subViewControllers count]>0) {
        return _subViewControllers[_currentIndex];
    }
    return nil;
}

@end

