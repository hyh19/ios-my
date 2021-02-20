
#import "ZWLaunchGuidanceViewController.h"
#import "ZWLifeStyleNetworkManager.h"
#import "ZWLaunchGuidanceTableView.h"
#import "ZWLifeStyleModel.h"

@interface ZWLaunchGuidanceViewController ()<UIScrollViewDelegate, ZWLaunchGuidanceTableViewDelegate>
{
    UIButton *boyButton;
    UIButton *girlButton;
    UILabel *boyLabel;
    UILabel *girlLabel;
    
    UIImageView *secondBgImageView;
}

/**启动引导页滑动视图*/
@property (nonatomic, strong)UIScrollView *scrollView;

@property (nonatomic, strong)UIButton *nextButton;

@property (nonatomic,strong)ZWLaunchGuidanceTableView *lifeStyleTableView;

@property (nonatomic, strong)NSArray *selectedItems;

@end

@implementation ZWLaunchGuidanceViewController

#define Hight [[UIScreen mainScreen] applicationFrame].size.height+20
#define Wight [[UIScreen mainScreen] applicationFrame].size.width

#pragma mark - Init -
+ (instancetype)viewController {

    ZWLaunchGuidanceViewController *viewController = [[ZWLaunchGuidanceViewController alloc] init];
    
    return viewController;
}
#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:[self scrollView]];
    [self.view addSubview:[self nextButton]];
    [self nextButton].hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-( void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Getter & Setter
- (UIScrollView *)scrollView
{
    if(!_scrollView)
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, Wight, SCREEN_HEIGH)];
        [_scrollView  setContentSize:CGSizeMake(Wight, SCREEN_HEIGH*3)];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor lightGrayColor];
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.scrollEnabled = NO;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [_scrollView addSubview:[self firstView]];
        [_scrollView addSubview:[self secondView]];
        [_scrollView addSubview:[self thirthView]];
    }
    return _scrollView;
}

- (void)setSelectedItems:(NSArray *)selectedItems
{
    _selectedItems = selectedItems;
}

- (ZWLaunchGuidanceTableView *)lifeStyleTableView
{
    if(!_lifeStyleTableView)
    {
        _lifeStyleTableView = [[ZWLaunchGuidanceTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH-50) style:UITableViewStylePlain];
        _lifeStyleTableView.tableViewDelegate = self;
    }
    return _lifeStyleTableView;
}

- (UIButton *)nextButton
{
    if(!_nextButton)
    {
        _nextButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH-50, SCREEN_WIDTH, 50)];
        _nextButton.backgroundColor = COLOR_MAIN;
        if(![self selectedItems] || [self selectedItems].count == 0)
        {
            [_nextButton setTitle:@"选择你的生活方式" forState:UIControlStateNormal];
        }
        
        [_nextButton addTarget:self action:@selector(onTouchButtonWithNext:) forControlEvents:UIControlEventTouchUpInside];
    
    }
    return _nextButton;
}

/**启动引导页第一屏*/
- (UIView *)firstView
{
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Wight, SCREEN_HEIGH)];
    firstView.backgroundColor = [UIColor colorWithRed:75./255 green:83./255 blue:164./255 alpha:1.];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Launch%.fx%.f", Wight, Hight]];
    
    bgImageView.userInteractionEnabled = YES;
    
    [firstView addSubview:bgImageView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH - 54, SCREEN_WIDTH, 20)];
    label.text = @"你的生活方式是?";
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.];
    label.textAlignment = NSTextAlignmentCenter;
    
    [firstView addSubview:label];
    
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-9, SCREEN_HEIGH-54-25, 18, 16)];
    
    gifImageView.animationImages = @[[UIImage imageNamed:@"LaunchArrow1"], [UIImage imageNamed:@"LaunchArrow2"]]; //动画图片数组
    gifImageView.animationDuration = 1; //执行一次完整动画所需的时长
    gifImageView.animationRepeatCount = 0;  //动画重复次数
    [gifImageView startAnimating];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipGestureWithSwipeUp)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [bgImageView addGestureRecognizer:recognizer];
    
    [firstView addSubview:gifImageView];
    
    return firstView;
}

/**启动引导页第二屏*/
- (UIView *)secondView
{
    UIView *secondView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH, Wight, SCREEN_HEIGH)];
    secondView.backgroundColor = [UIColor blackColor];
    
    secondBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    secondBgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Launch%.fx%.f", Wight, Hight]];
    [secondView addSubview:secondBgImageView];
    
    [secondView addSubview:[self lifeStyleTableView]];
    
    return secondView;
}
/**启动引导页第三屏*/
- (UIView *)thirthView
{
    UIView *thirthView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH*2-50, Wight, SCREEN_HEIGH-50)];
    thirthView.backgroundColor = [UIColor colorWithHexString:@"#333333"];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    bgImageView.image = [UIImage imageNamed:@"LaunchBackground"];
    
    [thirthView addSubview:bgImageView];
    
    UIImageView *hintImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 25, 89, 50, 20)];
    hintImageView.image = [UIImage imageNamed:@"LaunchText"];
    
    [thirthView addSubview:hintImageView];
    
    NSArray *images = @[@"LaunchBoy", @"LaunchGirl"];
    
    NSArray *sexs = @[@"男", @"女"];
    
    for(int i = 0; i < 2; i++)
    {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(44, 178, (SCREEN_WIDTH-44*2 - 8)/2, (SCREEN_WIDTH-44*2 - 8)/2)];
        [button setBackgroundImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"LaunchSelected"] forState:UIControlStateSelected];
        [button setImage:nil forState:UIControlStateDisabled];
        
        UILabel *sexLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 178 + (SCREEN_WIDTH-44*2 - 8)/2 + 18, (SCREEN_WIDTH-44*2 - 8)/2, 16)];
        
        sexLabel.text = sexs[i];
        
        sexLabel.textAlignment = NSTextAlignmentCenter;
        
        sexLabel.font = [UIFont systemFontOfSize:15.];
        
        if(i == 1)
        {
            button.frame = CGRectMake(44 + (SCREEN_WIDTH-44*2 - 8)/2 + 8, 178, (SCREEN_WIDTH-44*2 - 8)/2, (SCREEN_WIDTH-44*2 - 8)/2);
            sexLabel.frame = CGRectMake(44 + (SCREEN_WIDTH-44*2 - 8)/2 + 8, 178 + (SCREEN_WIDTH-44*2 - 8)/2 + 18 , (SCREEN_WIDTH-44*2 - 8)/2, 16);
            girlButton = button;
            sexLabel.textColor = [UIColor whiteColor];
            girlLabel = sexLabel;
        }
        else
        {
            boyButton = button;
            [button.layer setBorderWidth:0.5];
            [button.layer setBorderColor:[[UIColor colorWithHexString:@"#00baa2"] CGColor]];
            [button setSelected:YES];
            sexLabel.textColor = [UIColor colorWithHexString:@"#00baa2"];
            boyLabel = sexLabel;
        }
        
        [button addTarget:self action:@selector(onTouchButonWithSelectSex:) forControlEvents:UIControlEventTouchUpInside];
        [thirthView addSubview:button];
        [thirthView addSubview:sexLabel];
    }
    
    return thirthView;
}

#pragma mark - Network management
- (void)sendRequestWithSelectedList
{
    NSMutableArray *lifeStyleIDs = [[NSMutableArray alloc] initWithCapacity:0];
    for(ZWLifeStyleModel *model in [self selectedItems])
    {
        if(boyButton.selected == YES)
        {
            [lifeStyleIDs addObject:model.boyID];
        }
        else if(girlButton.selected == YES)
        {
            [lifeStyleIDs addObject:model.girlID];
        }
        else
        {
            [lifeStyleIDs addObject:model.boyID];
        }
    }
    
    __weak typeof(self) weakSelf=self;
    [[ZWLifeStyleNetworkManager sharedInstance] uploadLifeStyleTypeWithStyleID:[lifeStyleIDs copy] successBlock:^(id result) {
        // 广播用户已经选择了感兴趣的生活方式
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSelectLifeStyleCompleted object:nil];
        // 记录用户已经选择了感兴趣的生活方式
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserDefaultsSelectLifeStyleCompleted];
        
        [weakSelf closeViewController];
    } failureBlock:^(NSString *errorString) {
        occasionalHint(errorString);
    }];
}

#pragma mark - Event handler

- (void)onTouchButonWithSelectSex:(UIButton *)sender
{
    if((sender == boyButton && sender.selected == YES) || (sender == girlButton && sender.selected == YES))
    {
        [self updataButtonsStatus];
    }
    else{
        [self updataButtonsStatus];
        [sender setSelected:YES];
        [sender.layer setBorderWidth:0.5];
        [sender.layer setBorderColor:[[UIColor colorWithHexString:@"#00baa2"] CGColor]];
        if(sender == boyButton)
        {
            boyLabel.textColor = [UIColor colorWithHexString:@"#00baa2"];
        }
        else
        {
            girlLabel.textColor = [UIColor colorWithHexString:@"#00baa2"];
        }
    }
}

- (void)updataButtonsStatus
{
    [boyButton setSelected:NO];
    [girlButton setSelected:NO];
    [boyButton.layer setBorderWidth:0];
    [girlButton.layer setBorderWidth:0];
    boyLabel.textColor = [UIColor whiteColor];
    girlLabel.textColor = [UIColor whiteColor];
}

- (void)onTouchButtonWithNext:(UIButton *)sender
{
    if(![self selectedItems] || [self selectedItems].count == 0)
    {
        return;
    }
    else
    {
        if([[self nextButton].currentTitle isEqualToString:@"下一步"])
        {
            [_nextButton setTitle:@"开启全新生活方式" forState:UIControlStateNormal];
            [UIView animateWithDuration:0.6 animations:^{
                [[self scrollView] setContentOffset:CGPointMake(0, SCREEN_HEIGH*2- 50)];
            }];
            
        }
        else if ([[self nextButton].currentTitle isEqualToString:@"开启全新生活方式"])
        {
            [self sendRequestWithSelectedList];
        }
    }
}

/** 关闭启动广告页面 */
- (void)closeViewController
{
    [UIView animateWithDuration:0.5 animations:^{
        self.view.alpha = 0.4;
    }];
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidLoadLaunchGuidance];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //post一条关闭启动广告或启动引导页的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaunchOver object:nil];
        
        [self.navigationController popViewControllerAnimated:NO];
    });
    
}

- (void)onSwipGestureWithSwipeUp
{
    [[self scrollView] setContentOffset:CGPointMake(0, SCREEN_HEIGH) animated:NO];
    [UIView animateWithDuration:0.5 animations:^{
        secondBgImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [secondBgImageView removeFromSuperview];
    }];
    [[self lifeStyleTableView] loadLocalLifeStyleDataSource];
}

#pragma mark - scrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pagewidth = self.scrollView.frame.size.height;
    int page = floor((self.scrollView.contentOffset.y - pagewidth/ 6)/pagewidth)+1;
    if(page == 0)
    {
        [self nextButton].hidden = YES;
    }
    else
    {
        [self nextButton].hidden = NO;
    }
}

- (void)didSelectItemsWithList:(NSArray *)selectItems
{
    [self setSelectedItems:[selectItems copy]];
    if(!selectItems || [selectItems count] == 0)
    {
        [_nextButton setTitle:@"选择你的生活方式" forState:UIControlStateNormal];
    }
    else
    {
        [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    }
}
@end
