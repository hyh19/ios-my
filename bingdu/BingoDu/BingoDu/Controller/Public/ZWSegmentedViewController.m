#import "ZWSegmentedViewController.h"
#import "HMSegmentedControl.h"
#import "PureLayout.h"

@interface ZWSegmentedViewController () <UIScrollViewDelegate> {
    NSInteger _selectedSegmentIndex;
    NSMutableArray *_sectionTitles;
    NSArray *_subViewControllers;
}

/** 标记是否已完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

/** 标签栏 */
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;

/** 分隔线 */
@property (nonatomic, strong) UIView *separator;

/** 子界面容器 */
@property (nonatomic, strong) UIScrollView *containerView;

/** 标题 */
@property (nonatomic, strong) NSMutableArray *sectionTitles;

@end

@implementation ZWSegmentedViewController

#pragma mark - Init -
- (id)initWithSubViewControllers:(NSArray *)subViewControllers {
    if (self = [super init]) {
        self.subViewControllers = subViewControllers;
    }
    return self;
}

- (id)initWithParentViewController:(UIViewController *)viewController {
    if (self = [super init]) {
        [self addParentController:viewController];
    }
    return self;
}

- (id)initWithSubViewControllers:(NSArray *)subControllers andParentViewController:(UIViewController *)viewController {
    self = [self initWithSubViewControllers:subControllers];
    [self addParentController:viewController];
    return self;
}

#pragma mark - Getter & Setter -
- (NSMutableArray *)sectionTitles {
    if (!_sectionTitles) {
        _sectionTitles = [[NSMutableArray alloc] init];
    }
    return _sectionTitles;
}

- (NSArray *)subViewControllers {
    if (!_subViewControllers) {
        _subViewControllers = [[NSArray alloc] init];
    }
    return _subViewControllers;
}

- (void)setSectionTitles:(NSMutableArray *)sectionTitles {
    _sectionTitles = sectionTitles;
    self.segmentedControl.sectionTitles = _sectionTitles;
}

- (void)setSubViewControllers:(NSArray *)subViewControllers {
    
    _subViewControllers = subViewControllers;
    
    self.containerView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * _subViewControllers.count, 0);
    
    [_subViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        
        UIViewController *viewController = (UIViewController *)_subViewControllers[idx];
        viewController.view.frame = CGRectMake(idx * CGRectGetWidth(self.view.frame), 0, CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
        [self.containerView addSubview:viewController.view];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }];
    
    NSMutableArray *sectionTitles = [NSMutableArray array];
    for (UIViewController *viewController in _subViewControllers) {
        [sectionTitles addObject:viewController.title];
    }
    self.sectionTitles = sectionTitles;
}

- (HMSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [HMSegmentedControl newAutoLayoutView];
        _segmentedControl.backgroundColor = [UIColor whiteColor];
        _segmentedControl.selectionIndicatorColor = COLOR_MAIN;
        _segmentedControl.selectionIndicatorHeight = 2;
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : COLOR_848484,
                                                  NSFontAttributeName            : [UIFont systemFontOfSize:13]};
        _segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : COLOR_MAIN,
                                                          NSFontAttributeName            : [UIFont systemFontOfSize:13]};
        __weak typeof(self) weakSelf = self;
        _segmentedControl.indexChangeBlock = ^(NSInteger index) {
            [weakSelf.containerView setContentOffset:CGPointMake(index * CGRectGetWidth(weakSelf.containerView.frame), 0) animated:NO];
            if (weakSelf.indexChangeBlock) {
                weakSelf.indexChangeBlock(index);
            }
        };
    }
    return _segmentedControl;
}

- (UIScrollView *)containerView {
    if (!_containerView) {
        _containerView = [UIScrollView newAutoLayoutView];
        _containerView.delegate = self;
        _containerView.pagingEnabled = YES;
        _containerView.bounces = NO;
        _containerView.showsHorizontalScrollIndicator = NO;
        _containerView.scrollsToTop = NO;
    }
    return _containerView;
}

- (UIView *)separator {
    if (!_separator) {
        _separator = [UIView newAutoLayoutView];
        _separator.backgroundColor = COLOR_E7E7E7;
    }
    return _separator;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.containerView.scrollEnabled = _scrollEnabled;
}

- (void)setTitleTextAttributes:(NSDictionary *)titleTextAttributes {
    _titleTextAttributes = titleTextAttributes;
    self.segmentedControl.titleTextAttributes = _titleTextAttributes;
}

- (void)setSelectedTitleTextAttributes:(NSDictionary *)selectedTitleTextAttributes {
    _selectedTitleTextAttributes = selectedTitleTextAttributes;
    self.segmentedControl.selectedTitleTextAttributes = _selectedTitleTextAttributes;
}

- (UIViewController *)selectedViewController {
    return _subViewControllers[_selectedSegmentIndex];
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadView {
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.segmentedControl];
    [self.view addSubview:self.separator];
    [self.view addSubview:self.containerView];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.segmentedControl autoSetDimension:ALDimensionHeight toSize:SEGMENT_BAR_HEIGHT];
        
        [self.separator autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.segmentedControl];
        [self.separator autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.separator autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.separator autoSetDimension:ALDimensionHeight toSize:0.5];
        
        [self.containerView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.separator];
        [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.containerView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        self.didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}


- (void)addParentController:(UIViewController *)viewController {
    [viewController.view addSubview:self.view];
    [viewController addChildViewController:self];
    [self didMoveToParentViewController:viewController];
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _selectedSegmentIndex = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
    [self.segmentedControl setSelectedSegmentIndex:_selectedSegmentIndex animated:YES];
}

- (void)addRedPointAtIndex:(NSUInteger)index {
    if (index < [self.subViewControllers count]) {
         [self.segmentedControl addRedPointAtIndex:index];
    }
}

- (void)removeRedPointAtIndex:(NSUInteger)index {
    if (index < [self.subViewControllers count]) {
        [self.segmentedControl removeRedPointAtIndex:index];
    }
}

@end
