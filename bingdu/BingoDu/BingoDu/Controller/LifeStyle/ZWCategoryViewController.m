#import "ZWCategoryViewController.h"
#import "ZWSegmentedViewController.h"
#import "Constants+Device.h"
#import "UIImageView+WebCache.h"
#import "ZWCategoryArticlesViewController.h"
#import "ZWLifeStyleNetworkManager.h"
#import "ZWAdvertiseSkipManager.h"

@interface ZWCategoryViewController ()

/** 显示简介 */
@property (strong, nonatomic) IBOutlet UILabel *briefLabel;

/** 显示频道名称 */
@property (strong, nonatomic) IBOutlet UILabel *channelName;

/** 显示频道封面或广告图片 */
@property (strong, nonatomic) IBOutlet UIImageView *channelImageView;

/** 标签显示容器 */
@property (nonatomic, strong) ZWSegmentedViewController *segmentedViewController;

/** 分类频道是否有广告 */
@property (nonatomic, strong) NSNumber *isAD;

/** 分类频道描述 */
@property (nonatomic, strong) NSString *tagBrief;

/** 标签图片,封面图片或者广告图片 */
@property (nonatomic, strong) NSString *tagImage;

/** 标题 */
@property (nonatomic,strong) NSString *tagTitle;

/**启动广告数据model*/
@property (nonatomic, strong)ZWArticleAdvertiseModel *adModel;


@end

@implementation ZWCategoryViewController

#pragma mark - Getter and Setting -
- (ZWSegmentedViewController *)segmentedViewController {
    if (!_segmentedViewController) {
        _segmentedViewController = [[ZWSegmentedViewController alloc] init];
    }
    return _segmentedViewController;
}
#pragma mark - Init -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"News" bundle:nil];
    ZWCategoryViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ZWCategoryViewController class])];
    return viewController;
}

#pragma mark - life cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sendRequestForLoadingHotTagsData];
    [self sendRequestForLoadingadvertiseData];
    [self configureUserInterface];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - FDFullscreenPopGesture -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    UIViewController *oneViewController = [[UIViewController alloc] init];
    oneViewController.title = @"全部";
    oneViewController.view.backgroundColor = [UIColor brownColor];
    
    UIViewController *twoViewController = [[UIViewController alloc] init];
    twoViewController.title = @"Google";
    twoViewController.view.backgroundColor = [UIColor purpleColor];
    
    UIViewController *threeViewController = [[UIViewController alloc] init];
    threeViewController.title = @"Apple";
    threeViewController.view.backgroundColor = [UIColor orangeColor];
    
    UIViewController *fourViewController = [[UIViewController alloc] init];
    fourViewController.title = @"surface";
    fourViewController.view.backgroundColor = [UIColor magentaColor];
    
    UIViewController *fiveViewController = [[UIViewController alloc] init];
    fiveViewController.title = @"腾讯";
    fiveViewController.view.backgroundColor = [UIColor brownColor];
    
    UIViewController *sixViewController = [[UIViewController alloc] init];
    sixViewController.title = @"微博";
    sixViewController.view.backgroundColor = [UIColor purpleColor];
    
    UIViewController *sevenViewController = [[UIViewController alloc] init];
    sevenViewController.title = @"淘宝";
    sevenViewController.view.backgroundColor = [UIColor orangeColor];
    
    UIViewController *eightViewController = [[UIViewController alloc] init];
    eightViewController.title = @"阿里巴巴";
    eightViewController.view.backgroundColor = [UIColor magentaColor];
    
    UIViewController *nineViewController = [[UIViewController alloc] init];
    nineViewController.title = @"支付宝";
    nineViewController.view.backgroundColor = [UIColor magentaColor];
    
    UIViewController *tenViewController = [[UIViewController alloc] init];
    tenViewController.title = @"微信";
    tenViewController.view.backgroundColor = [UIColor magentaColor];
    
    self.segmentedViewController.view.frame = CGRectMake(0, 160, SCREEN_WIDTH, SCREEN_HEIGH-160);
    self.segmentedViewController.subViewControllers = @[oneViewController, twoViewController, threeViewController, fourViewController, fiveViewController, sixViewController, sevenViewController, eightViewController, nineViewController, tenViewController];
    self.segmentedViewController.scrollEnabled = NO;
    [self.segmentedViewController addParentController:self];
}

/** 刷新界面数据 */
- (void)updateUserInterface {
    self.channelName.text = self.tagTitle;
    self.briefLabel.text = self.tagBrief;
    
    [self.channelImageView sd_setImageWithURL:[NSURL URLWithString:self.tagImage] placeholderImage:[UIImage imageNamed:@"icon_banner_ad"]];

    
}

#pragma mark - Data management -
/** 配置服务器返回的数据 */
- (void)configureData:(NSDictionary *)dict {
    self.isAD = dict[@"isAd"];
    self.tagBrief = dict[@"description"];
    self.tagImage = dict[@"img"];
    self.tagTitle = dict[@"title"];
}

#pragma mark - Event handler -
/** 点击返回按钮 */
- (IBAction)onTouchButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NetWork management -
/** 发送获取热门标签数据的网络请求 */
- (void)sendRequestForLoadingHotTagsData {
    [[ZWLifeStyleNetworkManager sharedInstance] loadHotTagsWithchannelID:self.channelId
                                                            successBlock:^(id result) {
                                                                NSLog(@"hot tags result is %@", result);
                                                            }
                                                            failureBlock:^(NSString *errorString) {
                                                                occasionalHint(errorString);
                                                            }];
}

/** 发送获取分类频道封面或广告数据的网络请求 */
- (void)sendRequestForLoadingadvertiseData {
    [[ZWLifeStyleNetworkManager sharedInstance] loadCatgoryAdvertiseWithchannelID:self.channelId successBlock:^(id result) {
        [self configureData:result];
        [self updateUserInterface];
        NSLog(@"CatgoryAdvertise resullt is %@", result);
    } failureBlock:^(NSString *errorString) {
        occasionalHint(errorString);
    }];
}

@end
