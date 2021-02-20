#import "ZWSystemSettingViewController.h"
#import "MBProgressHUD.h"
#import "ZWPushMessageManager.h"
#import "GeTuiSdk.h"
#import "ZWMyNetworkManager.h"
#import "ZWVersionManager.h"
#import "ZWAboutViewController.h"
#import "ZWFeedbackViewController.h"
#import "ZWLoginViewController.h"
#import "ZWBindViewController.h"
#import "ZWModifyViewController.h"
#import "ZWIntegralStatisticsModel.h"
#import "ZWLoginManager.h"
#import "ZWBindingView.h"
#import "AppDelegate.h"
#import "ZWGuideManager.h"

#define IMAGE_COMMENT_TAG 30988
#define PUSH_INFO_TAG 30987
#define Tab_TAG 30986

@interface ZWSystemSettingViewController ()<ZWBindingViewDelegate>

/** 缓存label*/
@property (nonatomic, strong)UILabel *cacheMemoryLabel;

/** 缓存大小*/
@property (nonatomic, copy)NSString *sizeString;

/**消息推送开关*/
@property (nonatomic, strong)UISwitch *pushSwitch;

/** 更新版本label*/
@property (nonatomic, strong)UILabel *updateLabel;

/** 绑定label*/
@property (nonatomic, strong)UIView *bindingView;

@end

@implementation ZWSystemSettingViewController
#pragma mark - Init -
+ (instancetype)viewController {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Public" bundle:nil];
    ZWSystemSettingViewController *viewController = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([ZWSystemSettingViewController class])];
    return viewController;
    
    return viewController;
}

#pragma mark - Life cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /**帮助蒙层*/
    if([ZWUserInfoModel userID])
    {
        [ZWGuideManager showGuidePage:kGuidePageUser];
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MobClick event:@"setting_page_show"];
    
    self.title = @"系统设置";
    
    self.tableView.backgroundColor = COLOR_F8F8F8;
    
    self.view.backgroundColor = COLOR_F8F8F8;
    
    self.tableView.separatorColor = COLOR_E7E7E7;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter
- (UISwitch *)pushSwitch:(NSInteger)cellIndex
{
    UISwitch *tmpSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [tmpSwitch addTarget:self action:@selector(pushSwitchDidChange:) forControlEvents:UIControlEventValueChanged];
    
    if (cellIndex==0)
    {
        tmpSwitch.tag= PUSH_INFO_TAG;
        if(![NSUserDefaults loadValueForKey:kEnableForPush] || [[NSUserDefaults loadValueForKey:kEnableForPush] boolValue] == YES)
        {
            [tmpSwitch setOn:YES animated:NO];
        }
        else
        {
            [tmpSwitch setOn:NO animated:NO];
        }
    }
    else if (cellIndex == 1)
    {
        tmpSwitch.tag= Tab_TAG;
        if(![NSUserDefaults loadValueForKey:kUserDefaultsSelectedTab] || [[NSUserDefaults loadValueForKey:kUserDefaultsSelectedTab] boolValue] == NO)
        {
            [NSUserDefaults saveValue:@(NO) ForKey:kUserDefaultsSelectedTab];
            [tmpSwitch setOn:YES animated:NO];
        }
        else
        {
            [tmpSwitch setOn:NO animated:NO];
        }
    }
    else if(cellIndex==2)
    {
        tmpSwitch.tag= IMAGE_COMMENT_TAG;
        if(![NSUserDefaults loadValueForKey:kEnableForImageComment] || [[NSUserDefaults loadValueForKey:kEnableForImageComment] boolValue] == YES)
        {
            [tmpSwitch setOn:YES animated:NO];
        }
        else
        {
            [tmpSwitch setOn:NO animated:NO];
        }
    }
    return tmpSwitch;
    
}

- (UILabel *)cacheMemoryLabel
{
    if(!_cacheMemoryLabel)
    {
        _cacheMemoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _cacheMemoryLabel.textAlignment = NSTextAlignmentRight;
        _cacheMemoryLabel.textColor = [UIColor colorWithRed:100./255 green:100./255 blue:100./255 alpha:1.];
        _cacheMemoryLabel.text = @"读取中...";
        _cacheMemoryLabel.font = [UIFont systemFontOfSize:14.];
    }
    return _cacheMemoryLabel;
}

#pragma mark - Properties
/**更新缓存大小*/
- (void)updateMemorySize
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"URLCACHE"];
        NSString *size = [NSString stringWithFormat:@"%.1fMB",
                          [ZWUtility folderSizeAtPath:documentDirectory]];
        if (size) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.sizeString = size;
                [self.tableView reloadData];
            });
        }
    });
}

- (void)pushSwitchDidChange:(UISwitch *)sender
{
    ZWLog(@"pushSwitchDidChange");
    if(sender.on == YES )
    {
        if (sender.tag==PUSH_INFO_TAG)
        {
            [MobClick event:@"push_switch_on"];
            
            [GeTuiSdk setPushModeForOff:NO];
            [NSUserDefaults saveValue:@(YES) ForKey:kEnableForPush];
        }
        else if (sender.tag==IMAGE_COMMENT_TAG)
        {
            [MobClick event:@"picture_comment_switch_on"];
            
            [NSUserDefaults saveValue:@(YES) ForKey:kEnableForImageComment];
        }
        else if (sender.tag==Tab_TAG)
        {
            [NSUserDefaults saveValue:@(NO) ForKey:kUserDefaultsSelectedTab];
            [self.tableView reloadData];
        }
    }
    else if(sender.on == NO)
    {
        if (sender.tag==PUSH_INFO_TAG)
        {
            [self hint:@"" message:@"关闭推送功能可能会让您错过最新热门资讯，是否确认关闭？" trueTitle:@"确认关闭" trueBlock:^{
                
                [MobClick event:@"push_switch_off"];
                
                [[ZWMyNetworkManager sharedInstance] closePushNews];
                
                [GeTuiSdk setPushModeForOff:YES];
                
                [NSUserDefaults saveValue:@(NO) ForKey:kEnableForPush];
                
            } cancelTitle:@"取消" cancelBlock:^{
                
                [MobClick event:@"picture_comment_switch_off"];
                
                [sender setOn:YES animated:YES];
                
            }];
        }
        else if (sender.tag==IMAGE_COMMENT_TAG)
        {
            [self hint:@"" message:@"关闭图评显示就无法看到并友们好玩又有才的图评了，是否确认关闭？" trueTitle:@"确认关闭" trueBlock:^{
                
                [MobClick event:@"picture_comment_switch_off"];
                [NSUserDefaults saveValue:@(NO) ForKey:kEnableForImageComment];
                
                
            } cancelTitle:@"取消" cancelBlock:^{
                
                [sender setOn:YES animated:YES];
                
            }];
        }
        else if (sender.tag==Tab_TAG)
        {
            [NSUserDefaults saveValue:@(YES) ForKey:kUserDefaultsSelectedTab];
            [self.tableView reloadData];
        }
    }
}

/**
 *  检测用户在系统设置里是否允许通知
 *
 *  @return YES-允许,otherwise,NO.
 */
- (BOOL)isAllowedNotification {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {// system is iOS8
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }
    } else {//iOS7
        return YES;
    }
    
    return NO;
}

/**
 *  清除缓存成功后的处理
 */
- (void)clearCacheSuccess
{
    [self updateMemorySize];
    
    [MBProgressHUD hideHUDForView:[[[UIApplication sharedApplication] delegate] window] animated:NO];
    
    occasionalHint(@"清除成功");
    
    self.tableView.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
    
    [self.tableView reloadData];
}

/**
 *  更新绑定状态
 *  @param view 绑定的按钮
 */
- (void)updateBingdingView:(UIView *)view
{
    for(id object in [view subviews])
    {
        if([object isKindOfClass:[UIButton class]])
        {
            UIButton *button = object;
            switch (button.tag) {
                case 1000:
                    [button setImage:[UIImage imageNamed:@"sina_n"] forState:UIControlStateNormal];
                    break;
                case 1001:
                    [button setImage:[UIImage imageNamed:@"wechat_n"] forState:UIControlStateNormal];
                    break;
                case 1002:
                    [button setImage:[UIImage imageNamed:@"QQ_n"] forState:UIControlStateNormal];
                    break;
                    
                default:
                    break;
            }
        }
    }
    NSString *bingdingString = [[ZWUserInfoModel sharedInstance] bindSource];
    if(bingdingString)
    {
        if([bingdingString rangeOfString:@"QQ"].location != NSNotFound)
        {
            UIButton *button = (UIButton *)[view viewWithTag:1002];
            [button setImage:[UIImage imageNamed:@"QQ_y"] forState:UIControlStateNormal];
        }
        if([bingdingString rangeOfString:@"WEIXIN"].location != NSNotFound)
        {
            UIButton *button = (UIButton *)[view viewWithTag:1001];
            [button setImage:[UIImage imageNamed:@"wechat_y"] forState:UIControlStateNormal];
        }
        if([bingdingString rangeOfString:@"WEIBO"].location != NSNotFound)
        {
            UIButton *button = (UIButton *)[view viewWithTag:1000];
            [button setImage:[UIImage imageNamed:@"sina_y"] forState:UIControlStateNormal];
        }
    }
}

- (UIView *)bindingView
{
    if(!_bindingView)
    {
        _bindingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 105, 35)];
        NSArray *imageNames = @[@"sina_n", @"wechat_n", @"QQ_n"];
        for(int i =0; i < 3; i++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@", imageNames[i]]] forState:UIControlStateNormal];
            button.frame = CGRectMake(i*35, 0, 35, 35);
            button.tag = i+1000;
            [button addTarget:self action:@selector(bindingEventHandler:) forControlEvents:UIControlEventTouchUpInside];
            [_bindingView addSubview:button];
        }
    }
    return _bindingView;
}

- (UILabel *)updateLabel
{
    if(!_updateLabel)
    {
        _updateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        _updateLabel.textAlignment = NSTextAlignmentRight;
        _updateLabel.textColor =[UIColor colorWithRed:100./255 green:100./255 blue:100./255 alpha:1.];
        NSString *curVersion = [ZWUtility versionCode];
        _updateLabel.text = [NSString stringWithFormat:@"当前版本V%@", curVersion ];
        _updateLabel.font = [UIFont systemFontOfSize:14.];
        _updateLabel.minimumScaleFactor = 0.7f;
    }
    return _updateLabel;
}

- (NSArray *)cellTitles
{
    NSString *userDefaultTabTitle = @"默认导航(即时资讯)";
    if(![NSUserDefaults loadValueForKey:kUserDefaultsSelectedTab] || [[NSUserDefaults loadValueForKey:kUserDefaultsSelectedTab] boolValue] == NO)
    {
        userDefaultTabTitle = @"默认导航(生活方式)";
    }
    
    if(![ZWUserInfoModel login])
    {
        return @[@[@"绑定社交账号",], @[@"接受资讯推送", userDefaultTabTitle, @"显示图评", @"清除缓存"], @[@"关于并读", @"意见反馈"], @[@"退出登录"]];
    }
    else if ([ZWUserInfoModel login] && ![ZWUserInfoModel linkMobile])
    {
        return @[@[@"绑定手机号码",@"绑定社交账号",], @[@"接受资讯推送", userDefaultTabTitle, @"显示图评", @"清除缓存"], @[@"关于并读", @"意见反馈"], @[@"退出登录"]];
    }
    
    return @[@[@"修改手机号码",@"绑定社交账号",], @[@"接受资讯推送", userDefaultTabTitle, @"显示图评", @"清除缓存"], @[@"关于并读", @"意见反馈"], @[@"退出登录"]];
}

/**
 *  绑定第三方账号用户信息(QQ,微信,微博)
 *  @param bingType 绑定平台类型
 */
- (void)bingDingloginWithType:(BindingType)bingType
{
    if([[ZWUserInfoModel sharedInstance] bindSource])
    {
        if(bingType == SinaType)
        {
            if([[[ZWUserInfoModel sharedInstance] bindSource] rangeOfString:@"WEIBO"].location != NSNotFound)
            {
                return;
            }
        }
        else if(bingType == WechatType)
        {
            if([[[ZWUserInfoModel sharedInstance] bindSource] rangeOfString:@"WEIXIN"].location != NSNotFound)
            {
                return;
            }
        }
        else if(bingType == QQType)
            if([[[ZWUserInfoModel sharedInstance] bindSource] rangeOfString:@"QQ"].location != NSNotFound)
            {
                return;
            }
    }
    [MobClick event:@"bind_new_social_account"];//友盟统计
    NSArray *typeArray = @[@"1",@"997",@"998"];
    SSDKPlatformType type = (SSDKPlatformType)[[typeArray objectAtIndex:bingType] integerValue];
    
    __weak typeof(self) weakSelf=self;
    
    [ZWLoginManager loginWithType:type pushViewController:self loginResult:^(BOOL isLoginSuccess) {
        if(isLoginSuccess)
        {
            [[weakSelf tableView] reloadData];
        }
    }];
}

#pragma mark -ZWBindingViewDelegate
- (void)bingdingPlatformWithType:(BindingType)type
{
    [self bingDingloginWithType:type];
}

#pragma mark - UI EventHandler
/**
 *  社交账号绑定，微博按钮的tag值为1000，微信按钮的tag值为1001，QQ按钮的tag值为1002
 *  @param sender 触发的按钮
 */
- (void)bindingEventHandler:(UIButton *)sender
{
    [self bingDingloginWithType:(BindingType)sender.tag - 1000];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([ZWUserInfoModel login])
    {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
    {
        if([ZWUserInfoModel login])
        {
            return 2;
        }
        return 1;
    }
    else if (section == 1)
    {
        return 4;
    }
    else if (section == 2)
    {
        return 2;
    }
    else if(section == 3)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%d-%d", (int)indexPath.section, (int)indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSArray *titles = [self cellTitles];
    
    cell.textLabel.text = titles[indexPath.section][indexPath.row];
    
    cell.textLabel.textColor = COLOR_333333;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.textLabel.font = [UIFont systemFontOfSize:15.];
    
    cell.accessoryView = nil;
    
    if(indexPath.section == 1 && indexPath.row == 3)
    {
        cell.accessoryView = [self cacheMemoryLabel];
        if(!self.sizeString)
        {
            [self updateMemorySize];
        }
        [self cacheMemoryLabel].text = self.sizeString;
    }
    else if(indexPath.section == 1)
    {
        if([self isAllowedNotification] || indexPath.row==1 || indexPath.row == 2) {
            cell.accessoryView = [self pushSwitch:indexPath.row];
        } else {
            cell.accessoryView = nil;
        }
    }
    
    if([cellIdentifier isEqualToString:([ZWUserInfoModel userID]?
                                        @"cell0-1":@"cell0-0")])
    {
        cell.accessoryView = [self bindingView];
        
        [self updateBingdingView:[self bindingView]];
    }
    else if([cellIdentifier isEqualToString:@"cell2-0"])
    {
        cell.accessoryView = [self updateLabel];
        
        if([ZWVersionManager hasNewVersion])
        {
            [self updateLabel].text = @"有新版本了";
            [self updateLabel].textColor = [UIColor colorWithHexString:@"#fb8313"];
        }
        else
        {
            NSString *curVersion = [ZWUtility versionCode];
            [self updateLabel].text = [NSString stringWithFormat:@"当前版本V%@", curVersion ];
            [self updateLabel].textColor = [UIColor colorWithRed:100./255 green:100./255 blue:100./255 alpha:1.];
        }
    }
    
    //cell的样式
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if(([cellIdentifier isEqualToString:@"cell0-0"] && [ZWUserInfoModel login]) || [cellIdentifier isEqualToString:@"cell2-1"])
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        imageView.frame = CGRectMake(0, 0, 15, 15);
        cell.accessoryView = imageView;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(indexPath.section == 1 && indexPath.row == 3)//清除缓存
    {
        if([self.sizeString isEqualToString:@"0.0MB"])
            return;
        [self hint:@"清除缓存,会删除已下载资讯信息,是否继续?" trueTitle:@"继续" trueBlock:^{
            self.tableView.userInteractionEnabled = NO;
            [MBProgressHUD showHUDAddedTo:[[[UIApplication sharedApplication] delegate] window] animated:YES];
            dispatch_async(
                           dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                           , ^{
                               [ZWUtility cleanCache];
                               [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];
                           });
            [MobClick event:@"clear_cache"];//友盟统计
        } cancelTitle:@"取消" cancelBlock:^{
        }];
    }
    else if (indexPath.section == 1 && indexPath.row == 0 && [self isAllowedNotification] == NO)//新闻推送
    {
        hint(@"请在iOS系统上的“设置 > 通知”中将并读客户端设置为“允许通知”，即可收到最新的热点新闻推送。");
    }
    else if (indexPath.section == 0 && indexPath.row == 0)//绑定手机号码
    {
        if([ZWUserInfoModel login])
        {
            if ([ZWUserInfoModel linkMobile]) {
                
                ZWModifyViewController *modifyMobileVC = [[UIStoryboard storyboardWithName:@"Mobile" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([ZWModifyViewController class])];
                [self.navigationController pushViewController:modifyMobileVC animated:YES];
                
            }else
            {
                ZWBindViewController *bindMobileVC = [ZWBindViewController viewController];
                [self.navigationController pushViewController:bindMobileVC animated:YES];
            }
        }
        else
        {
            ZWLoginViewController *loginView = [[ZWLoginViewController alloc] init];
            [self.navigationController pushViewController:loginView animated:YES];
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 1)//绑定社交账号
    {
        if([ZWUserInfoModel userID])
        {
            NSString *bingdingString = [ZWUserInfoModel sharedInstance].bindSource;
            if( [bingdingString rangeOfString:@"QQ"].location == NSNotFound &&[bingdingString rangeOfString:@"WEIXIN"].location == NSNotFound && [bingdingString rangeOfString:@"WEIBO"].location == NSNotFound)
            {
                ZWBindingView *bingdingView = [[ZWBindingView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
                bingdingView.bingdingDelegate = self;
                [[AppDelegate sharedInstance].window addSubview:bingdingView];
            }
            return;
        }
    }
    else if (indexPath.section == 2 && indexPath.row == 0)//关于并读
    {
        ZWAboutViewController *aboutView = [[ZWAboutViewController alloc] init];
        aboutView.view.frame = self.view.frame;
        [self.navigationController pushViewController:aboutView animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row == 1)//意见反馈
    {
        ZWFeedbackViewController *feedbackView = [[ZWFeedbackViewController alloc] init];
        [self.navigationController pushViewController:feedbackView animated:YES];
    }
    else if(indexPath.section == 3 && indexPath.row == 0)//退出登录
    {
        [MobClick event:@"click_logout_button"];//友盟统计
        [self hint:@"退出后将无法享受更多个性化服务。是否继续退出？" trueTitle:@"退出" trueBlock:^{
            [MobClick event:@"logout"];//友盟统计
            
            [[ZWUserInfoModel sharedInstance] logout];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadChannel" object:nil];//刷新频道列表
            [self.tableView reloadData];
            
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"bingyou_refresh_time"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"msg_refresh_time"];
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:NEWEST_RELPLY_KEY];
            
        } cancelTitle:@"取消" cancelBlock:^{
            [MobClick event:@"cancel_logout"];//友盟统计
        }];
    }
}

@end
