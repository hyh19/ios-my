#import "ZWLaunchAdvertisemenViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "ZWNavigationController.h"
#import "ZWNewsNetworkManager.h"
#import "ZWArticleAdvertiseModel.h"
#import "ZWLocationManager.h"
#import "ZWAdvertiseSkipManager.h"
#import "ZWMyNetworkManager.h"
#import "ZWLaunchGuidanceViewController.h"

@interface ZWLaunchAdvertisemenViewController ()

/**启动广告图*/
@property (nonatomic, strong)UIImageView *ADImageView;

/**启动广告定时器*/
@property (nonatomic, strong)NSTimer *timer;

/**记录是否点击了广告*/
@property (nonatomic, assign)BOOL isClickAD;

/**启动广告数据model*/
@property (nonatomic, strong)ZWArticleAdvertiseModel *adModel;

/**跳过按钮*/
@property (nonatomic, strong)UIButton *skipButton;

@end

@implementation ZWLaunchAdvertisemenViewController

#define Hight [[UIScreen mainScreen] applicationFrame].size.height+20
#define Wight [[UIScreen mainScreen] applicationFrame].size.width

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isClickAD == YES) {
        [self dismissADView];
    }
}

-( void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:[self ADImageView]];
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"IOS%.fx%.f", Wight, Hight]];

    [[self ADImageView] setImage:image];
    [self.view addSubview:[self skipButton]];
    [[self skipButton] setHidden:YES];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kDidLoadLaunchGuidance])
    {
        [self.view addSubview:[self coverImageView]];
        _timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                  target:self
                                                selector:@selector(dismissADView)
                                                userInfo:nil
                                                 repeats:NO];
        
        [self requestLaunchADMessage];
        [self loadLocalAdvertise];
        
        __weak typeof(self) weakSelf = self;
        
        [ZWLocationManager updateLocationWithSuccess:^{ [weakSelf requestLaunchADMessage]; }
                                             failure:nil];
    } else {
        [self requestLaunchADMessage];
        [self dismissADView];
    }
    
    self.view.backgroundColor = COLOR_F8F8F8;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network management
//获取启动广告信息
- (void)requestLaunchADMessage
{
    NSString *resolution  = [[UIScreen mainScreen] isiPhone6] ?
    [NSString stringWithFormat:@"%.fx%.f",  SCREEN_WIDTH*3, SCREEN_HEIGH*3] :
    [NSString stringWithFormat:@"%.fx%.f",  SCREEN_WIDTH*2, SCREEN_HEIGH*2];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"channel"] = @"-1";
    param[@"width"] = [resolution componentsSeparatedByString:@"x"][0];
    param[@"height"] = [resolution componentsSeparatedByString:@"x"][1];
    NSString * encodingProvinceString = [[ZWLocationManager province] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    param[@"province"] = (encodingProvinceString? encodingProvinceString : @"");
    NSString * encodingCityString = [[ZWLocationManager city] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    param[@"city"] = (encodingCityString? encodingCityString : @"");
    
    param[@"lon"] = ([ZWLocationManager longitude]? [ZWLocationManager longitude] : @"");
    
    param[@"lat"] = ([ZWLocationManager latitude]? [ZWLocationManager latitude] : @"");
    
    param[@"uid"] = [ZWUserInfoModel login] ? [ZWUserInfoModel userID] : @"";
    param[@"advType"] = @"STARTUP";
    
    [[ZWNewsNetworkManager sharedInstance] loadAdvertiseWithType:ZWADVERSTARTUP
                                                      parameters:param
                                                          succed:^(id result)
    {
        [[NSUserDefaults standardUserDefaults] setValue:result forKey:kLaunchAdvertiseKey];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failed:^(NSString *errorString) {
    }];
}

#pragma mark - Event handler
/**点击启动广告上的图片的单点手势响应方法*/
- (void)pressGestureOnADView:(UITapGestureRecognizer *)sender
{
    if(self.adModel)
    {
        if([_timer isValid])
            [_timer invalidate];
        self.isClickAD = YES;
        [ZWAdvertiseSkipManager pushViewController:self withAdvertiseDataModel:self.adModel];
    }
}
/**执行启动页面关闭逻辑处理*/
- (void)dismissADView
{
    [[self skipButton] removeFromSuperview];
    if([_timer isValid])
        [_timer invalidate];
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kDidLoadLaunchGuidance])
    {
        [[ZWMyNetworkManager sharedInstance] noticeGuide];
        UIViewController *viewController = [ZWLaunchGuidanceViewController viewController];
        [[self ADImageView] removeFromSuperview];
        [self addChildViewController:viewController];
        [self.view addSubview:viewController.view];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
    }
    else
    {
        if(self.isClickAD == YES)
            return;
        if(![self.navigationController viewControllers])
        {
            [self performSelector:@selector(closeViewController) withObject:nil afterDelay:0.3];
        }
        else
        {
            [self closeViewController];
        }
    }
}

#pragma mark - Getter & Setter
- (UIImageView *)ADImageView
{
    if(!_ADImageView)
    {
        _ADImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Wight, Hight)];
        _ADImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressGestureOnADView:)];
        [_ADImageView addGestureRecognizer:singleTap1];
    }
    return _ADImageView;
}

- (UIImageView *)coverImageView
{
    UIImage *coverImage = [UIImage imageNamed:[NSString stringWithFormat:@"cover_%.f", SCREEN_WIDTH]];
    
    UIImageView *coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH-coverImage.size.height, SCREEN_WIDTH, coverImage.size.height)];
    
    coverImageView.image = coverImage;
    
    return coverImageView;
}

- (UIButton *)skipButton
{
    if(!_skipButton)
    {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.frame = CGRectMake(SCREEN_WIDTH-16-38, 38, 38, 38);
        [_skipButton setImage:[UIImage imageNamed:@"icon_skip"] forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(dismissADView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipButton;
}


#pragma mark - Private method
//加载本地缓存广告数据
-(void)loadLocalAdvertise
{
    if([[NSUserDefaults standardUserDefaults] valueForKey:kLaunchAdvertiseKey] && [[[NSUserDefaults standardUserDefaults] valueForKey:kLaunchAdvertiseKey] allKeys].count > 0)
    {
        self.adModel = [ZWArticleAdvertiseModel ariticleModelBy:[[NSUserDefaults standardUserDefaults] valueForKey:kLaunchAdvertiseKey]];
        
        [[self ADImageView] sd_setImageWithURL:[NSURL URLWithString:self.adModel.adversizeImgUrl]
                              placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"IOS%.fx%.f", Wight, Hight]]
                                     completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             
             if(image)
             {
                 [self skipButton].hidden = NO;
             }}];
    }
    else
    {
        [self dismissADView];
    }
}

/** 关闭启动广告页面 */
- (void)closeViewController
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDidLoadLaunchGuidance];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if([_timer isValid])
        [_timer invalidate];
//post一条关闭启动广告或启动引导页的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLaunchOver object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - FDFullscreenPopGesture -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

#pragma mark - FDFullscreenPopGesture -
- (BOOL)fd_interactivePopDisabled {
    return YES;
}

@end
