#import "ZWUserViewController.h"
#import "ZWSegmentedViewController.h"
#import "ZWMarketTableViewController.h"
#import "ZWFavoriteListViewController.h"
#import "ZWBingYouViewController.h"
#import "ZWMissionTableViewController.h"
#import "ZWSystemSettingViewController.h"
#import "ZWUserInfoModel.h"
#import "ZWLoginViewController.h"
#import "ZWUserSettingViewController.h"
#import "UIButton+WebCache.h"
#import "ZWRevenuetDataManager.h"
#import "UIImageView+WebCache.h"
#import "UIImageEffects.h"
#import "UIButton+NHZW.h"
#import "ZWVersionManager.h"
#import "UIAlertView+Blocks.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWRedPointManager.h"

@interface ZWUserViewController ()

/** 颜色背景 */
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

/** 图片背景 */
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

/** 头像 */
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;

/** 设置 */
@property (weak, nonatomic) IBOutlet UIButton *settingButton;

/** 昵称 */
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

/** 积分 */
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;

/** 余额 */
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

/** 子界面容器 */
@property (nonatomic, strong) ZWSegmentedViewController *segmentedViewController;

@end

@implementation ZWUserViewController

#pragma mark - Init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Public" bundle:nil];
    
    NSMutableString *storyboardID = [NSMutableString stringWithString:NSStringFromClass([ZWUserViewController class])];
    
    // 5.5英寸屏幕的控件布局和别的尺寸不一样
    if ([[UIScreen mainScreen] isFiveFivePhone]) {
        [storyboardID appendString:@"55"];
    }
    
    ZWUserViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:storyboardID];
    
    return viewController;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self showInvitationCodeAlert];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAvatar];
    [self updateNickName];
    [self updateFriendRedPoint];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self sendRequestForUpdatingRevenueData];
    // 集市有消息就添加红点
    [self judgeMarketViewControllerHasRedPoint];
}

#pragma mark - Getter & Setter -
- (ZWSegmentedViewController *)segmentedViewController {
    
    if (!_segmentedViewController) {
        
        ZWMissionTableViewController *oneViewController = [ZWMissionTableViewController viewController];
        oneViewController.title = @"任务";
        
        ZWMarketTableViewController *twoViewController = [ZWMarketTableViewController viewController];
        twoViewController.title = @"集市";
        
        ZWBingYouViewController *threeViewController = [ZWBingYouViewController viewController];
        threeViewController.title = @"并友";
        
        ZWFavoriteListViewController *fourViewController = [ZWFavoriteListViewController viewController];
        fourViewController.title = @"收藏";
        
        _segmentedViewController = [[ZWSegmentedViewController alloc] init];
        _segmentedViewController.view.frame = CGRectMake(0, [self heightForTopView], SCREEN_WIDTH, SCREEN_HEIGH-[self heightForTopView]);
        _segmentedViewController.subViewControllers = @[oneViewController, twoViewController, threeViewController, fourViewController];
        _segmentedViewController.scrollEnabled = NO;
        
        __weak typeof(self)weakSelf = self;
        _segmentedViewController.indexChangeBlock = ^(NSInteger index) {
            [weakSelf onSegmentValueChanged:index];
        };
    }
    return _segmentedViewController;
}

#pragma mark - Event handler -
/** 点击设置按钮 */
- (IBAction)onTouchButtonSetting:(id)sender {
    ZWSystemSettingViewController *nextViewController = [ZWSystemSettingViewController viewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 点击返回按钮 */
- (IBAction)onTouchButtonBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/** 点击头像 */
- (IBAction)onTouchButtonAvatar:(id)sender {
    if ([ZWUserInfoModel login]) {
        [self pushUserSettingViewController];
    } else {
        [self pushLoginViewController];
    }
}

/** 切换标签 */
- (void)onSegmentValueChanged:(NSInteger)index {
    id viewController = self.segmentedViewController.subViewControllers[index];
    if ([viewController respondsToSelector:@selector(refresh)]) {
        [viewController performSelector:@selector(refresh)];
        
    }
    // 点击集市和并友，移除红点
    if (1 == index || 2 == index) {
        [self removeRedPointAtIndex:index];
    }
    
    switch (index) {
        case 0:
            [MobClick event:@"mission_tab_show_personal_enter"];
            break;
        case 1:
            [MobClick event:@"market_tab_show_personal_center"];
            break;
        case 2:
            [MobClick event:@"friends_tab_show_personal_center"];
            break;
        case 3:
            [MobClick event:@"collection_tab_show_personal_center"];
            break;
    }
}

#pragma mark - UI management
/** 配置界面外观 */
- (void)configureUserInterface {
    self.backgroundView.backgroundColor = COLOR_MAIN;
    
    self.avatarButton.imageView.layer.cornerRadius = 30;
    self.avatarButton.imageView.layer.masksToBounds = YES;
    
    // 有新版本则在设置按钮上添加红点
    if ([ZWVersionManager hasNewVersion]) {
        // 设置按钮的宽度为30
        CGFloat redPointWidth = 5;
        [self.settingButton addRedPointWithFrame:CGRectMake(20, 8, redPointWidth, redPointWidth) borderColor:[UIColor whiteColor] borderWidth:1];
    }
    
    [self.segmentedViewController addParentController:self];
}

/** 更新头像 */
- (void)updateAvatar {
    NSURL *avatarURL = [NSURL URLWithString:[[ZWUserInfoModel sharedInstance] headImgUrl]];
    [self.avatarButton sd_setImageWithURL:avatarURL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"btn_avatar_user"]];
    
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, [self heightForTopView]);
    for (UIView *subview in self.avatarImageView.subviews) {
        [subview removeFromSuperview];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        __weak typeof(self) weakSelf = self;
        [self.avatarImageView sd_setImageWithURL:avatarURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, [self heightForTopView]);
                UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
                blurEffectView.frame = rect;
                blurEffectView.alpha = 0.97;
                [weakSelf.avatarImageView addSubview:blurEffectView];
                
                UIView *view = [[UIView alloc] initWithFrame:rect];
                view.backgroundColor = [UIColor blackColor];
                view.alpha = 0.3;
                [weakSelf.avatarImageView addSubview:view];
            }
        }];
    // iOS 7要用自定义的毛玻璃效果
    } else {
        UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:avatarURL]];
        UIImage *newImage = [UIImageEffects imageByApplyingLightEffectToImage:avatarImage];
        self.avatarImageView.image = newImage;
        
        if (self.avatarImageView.image) {
            UIView *view = [[UIView alloc] initWithFrame:rect];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.3;
            [self.avatarImageView addSubview:view];
        }
    }
}

/** 更新昵称 */
- (void)updateNickName {
    if ([[[ZWUserInfoModel sharedInstance] nickName] isValid]) {
        self.nickNameLabel.text = [[ZWUserInfoModel sharedInstance] nickName];
    } else {
        self.nickNameLabel.text = @"请登录";
    }
}

/** 更新积分和余额 */
- (void)updateRevenueValue {
    if ([ZWUserInfoModel login]) {
        self.pointLabel.text = [NSString stringWithFormat:@"积分：%0.2f", [ZWRevenuetDataManager todayPointRevenue]];
        self.balanceLabel.text = [NSString stringWithFormat:@"余额：%0.2f", [ZWRevenuetDataManager balance]];
    } else {
        self.pointLabel.text = [NSString stringWithFormat:@"积分：%0.2f", [self pointValue]];
        self.balanceLabel.text = @"余额：0.00";
    }
}

- (void)addRedPointAtIndex:(NSUInteger)index {
    [self.segmentedViewController addRedPointAtIndex:index];
}

- (void)removeRedPointAtIndex:(NSUInteger)index {
    [self.segmentedViewController removeRedPointAtIndex:index];
}

/** 提示填写邀请码 */
- (void)showInvitationCodeAlert {
    // 已经登录且没有填写过邀请码则提示
    if ([ZWUserInfoModel login] &&
        ![[[ZWUserInfoModel sharedInstance] inviteCode] isValid]) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (![standardUserDefaults valueForKey:kUserDefaultsInvitationCodeAlert]) {
            [UIAlertView showWithTitle:@""
                               message:@"你造吗？登录注册后填写好友的邀请码，可为好友赚取100积分哦~~还没码？向好友索取后可进入个人中心的资料编辑页补填。别错过哦！"
                     cancelButtonTitle:@"稍后再说"
                     otherButtonTitles:@[@"立即填写"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (alertView.cancelButtonIndex != buttonIndex) {
                                      [self pushUserSettingViewController];
                                  }
                              }];
            
            [standardUserDefaults setBool:YES forKey:kUserDefaultsInvitationCodeAlert];
            [standardUserDefaults synchronize];
        }
    }
}
/**更新并友红点*/
-(void)updateFriendRedPoint
{
    __weak typeof(self) weakSelf=self;
    // 有并友回复的新消息则添加红点
    BOOL hasNewReplay = [[NSUserDefaults standardUserDefaults] boolForKey:BINGYOU_HAVA_NEWREPLY];
    if (hasNewReplay && [ZWUserInfoModel login])
    {
        [self addRedPointAtIndex:2];
        ZWBingYouViewController *bingyouController=[self.segmentedViewController.subViewControllers objectAtIndex:2];
        [bingyouController hideOrShowRedPoint:YES];
    }
    else if(!hasNewReplay && [ZWUserInfoModel login])
    {
        [ZWRedPointManager manageRedPointAtFriendsModuleWithStatus:^(BOOL hidden) {
            if(!hidden)
            {
                [weakSelf addRedPointAtIndex:2];
                ZWBingYouViewController *bingyouController=[weakSelf.segmentedViewController.subViewControllers objectAtIndex:2];
                [bingyouController hideOrShowRedPoint:YES];
            }

        }];
    }
    else if (![ZWUserInfoModel login])
    {
        [self removeRedPointAtIndex:2];
        ZWBingYouViewController *bingyouController=[self.segmentedViewController.subViewControllers objectAtIndex:2];
         [bingyouController hideOrShowRedPoint:NO];
    }

}
#pragma mark - Network management -
/** 发送网络请求更新收入数据 */
- (void)sendRequestForUpdatingRevenueData {
    __weak typeof(self) weakSelf = self;
    [ZWRevenuetDataManager startUpdatingPointDataWithUserID:[ZWUserInfoModel userID]
                                                    success:^{
                                                        // 广播积分更新通知
                                                        NSNotification *notification = [NSNotification notificationWithName:kNotificationUpdatePointDataCompleted object:nil];
                                                        [[NSNotificationCenter defaultCenter] postNotification:notification];
                                                        [weakSelf updateRevenueValue];
                                                    }
                                                    failure:^{ [self updateRevenueValue]; }];
}

#pragma mark - Data management -
/** 今日已获积分 */
- (float)pointValue {
    ZWIntegralStatisticsModel* obj = [ZWIntegralStatisticsModel loadCustomObjectWithKey:kUserDefaultsPointData];
    return [ZWIntegralStatisticsModel sumIntegrationBy:obj];
}

#pragma mark - Navigation -
/** 进入登录界面 */
- (void)pushLoginViewController {
    ZWLoginViewController *nextViewController = [[ZWLoginViewController alloc] init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入账户设置界面 */
- (void)pushUserSettingViewController {
    ZWUserSettingViewController *nextViewController = [ZWUserSettingViewController viewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - FDFullscreenPopGesture -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

#pragma mark - helper -
/** 不同屏幕尺寸顶部的高度 */
- (CGFloat)heightForTopView {
    if ([[UIScreen mainScreen] isFiveFivePhone]) {
        return 220;
    }
    return 190;
}

/** 判断集市是否有显示红点*/
- (void)judgeMarketViewControllerHasRedPoint {
    ZWMarketTableViewController *viewcontroller = [ZWMarketTableViewController viewController];
    // 其中排除服务器返回的礼品商城的红点，只判断礼品商城本地的红点
    [viewcontroller sendRequestForLoadingMenuDataSucced:^(id result) {
        BOOL isHasRedPoint = NO;
        
        for (id obj in result) {
            // 礼品商城
            if ([[obj objectForKey:@"menu"] isEqualToString:@"GoodsMall"]) {
                // 本地没有储存礼品商城的红点，则集市上显示红点
                if (![[NSUserDefaults standardUserDefaults] objectForKey:@"GoodsMall"]) {
                    if ([[obj objectForKey:@"showSuperscript"] boolValue]) {
                        isHasRedPoint = YES;
                        break;
                    }
                }
            // 非礼品商城
            } else {
                // 服务器有返回红点角标的字段，则集市上显示红点
                if ([[obj objectForKey:@"showSuperscript"] boolValue]) {
                    isHasRedPoint = YES;
                    break;
                }
            }
        }
        if (isHasRedPoint) {
            [self addRedPointAtIndex:1];
        } else {
            [self removeRedPointAtIndex:1];
        }
    }
                                                    failed:^(NSString *errorString) {
                                                        //
                                                    }];
}

@end
