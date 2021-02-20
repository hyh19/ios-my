#import "FBConnectedAccountViewController.h"
#import "FBConnectedAccountCell.h"
#import "FBConnectedAccountCard.h"
#import "FBAccountTipsView.h"
#import "FBAccountListModel.h"
#import "FBBindUserInfoModel.h"
#import "FBConnectedAccountModel.h"
#import "FBUtility.h"
#import "FBLoginInfoModel.h"
#import "FBLoginManager.h"
#import "VKSDK.h"
#import "CNPPopupController.h"
#import "FBProfileNetWorkManager.h"

static NSArray *SCOPE = nil;

@interface FBConnectedAccountViewController ()<FBConnectedAccountCardDelegate, FBEmailUnConnectedAccountCardDelegate, VKSdkUIDelegate, VKSdkDelegate, CNPPopupControllerDelegate>

@property (nonatomic, strong) CNPPopupController *popupController;

/** 账户数组 */
@property (nonatomic, strong) NSMutableArray *accountArray;

/** 绑定账号下的footView */
@property (strong, nonatomic) FBAccountTipsView *footView;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBConnectedAccountViewController

#pragma mark - Init -
+ (instancetype)viewController {
    FBConnectedAccountViewController *viewController = [[FBConnectedAccountViewController alloc] init];
    return viewController;
}

/** 初始化VK信息 */
- (void)initializeVKInfo {
    SCOPE = @[VK_PER_FRIENDS, VK_PER_PHOTOS, VK_PER_EMAIL, VK_PER_OFFLINE];
    [[VKSdk initializeWithAppId:@"5435576"] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            
            NSLog(@"result!");
            
        } else if (error) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"cancel" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
    
    [VKSdk authorize:SCOPE];
}

#pragma mark - Getter and Setter -
- (NSMutableArray *)accountArray {
    if (!_accountArray) {
        _accountArray = [FBAccountListModel mj_objectArrayWithFilename:@"FBConnectedAccount.plist"];
    }
    return _accountArray;
}

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureUserInterface];
    [self loadUserInfos];
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    
    [FBUtility bindPlatformStatusWithPlatform:kPlatformFacebook confirmCompletionBlock:^{
        [self onTouchButtonBindWithType:kPlatformFacebook token:nil];
    } cancelCompletionBlock:^{
        //
    }];
    
    [FBUtility bindPlatformStatusWithPlatform:kPlatformTwitter confirmCompletionBlock:^{
        [self onTouchButtonBindWithType:kPlatformTwitter token:nil];
    } cancelCompletionBlock:^{
        //
    }];
}

#pragma mark - UI management -
/** 配置界面外观 */
- (void)configureUserInterface {
    
    self.navigationItem.title = kLocalizationConnectedAccount;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 70;
    
    [self.tableView registerClass:[FBConnectedAccountCell class] forCellReuseIdentifier:NSStringFromClass([FBConnectedAccountCell class])];
    
    self.footView = [[FBAccountTipsView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
    self.tableView.tableFooterView = self.footView;
}

/** 配置弹出卡片的UI */
- (void)configureCardView:(UIView *)view {
    CNPPopupTheme *theme = [CNPPopupTheme defaultTheme];
    theme.cornerRadius = 10;
    theme.popupContentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[view]];
    self.popupController.maskBackgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.popupController.theme = theme;
    self.popupController.delegate = self;
    [self.popupController presentPopupControllerAnimated:YES];
}

#pragma mark - Data Management -
/** 刷新用户绑定的账号信息 */
- (void)updateBindUserInfsoData:(id)data {
    [self.accountArray removeAllObjects];
    self.accountArray = [FBAccountListModel mj_objectArrayWithFilename:@"FBConnectedAccount.plist"];
    
    NSMutableArray *infosArray = [FBBindUserInfoModel mj_objectArrayWithKeyValuesArray:data[@"bindlist"]];

    for (FBAccountListModel *accountModel in self.accountArray) {

        for (FBBindUserInfoModel *model in infosArray) {
            if ([accountModel.platform isEqualToString:model.platform]) {
                accountModel.infosModel = model;
            }
        }
        
    }

    [self.tableView reloadData];
}

#pragma mark - Network Management -
/** 加载用户绑定账号信息请求 */
- (void)loadUserInfos {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[FBProfileNetWorkManager sharedInstance] getUserBlindInfosWithSuccess:^(id result) {
        
        [self updateBindUserInfsoData:result];
        
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Event Handler -
/** 点击绑定按钮绑定第三方账号 */
- (void)onTouchButtonBindWithType:(NSString *)type token:(NSString *)token{
    
    // 点击按钮时间戳
    NSTimeInterval st_clicktime = [[NSDate date] timeIntervalSince1970];
    __block NSString *st_result = nil;
    __weak typeof(self) wself = self;
    
    [FBLoginManager loginWithType:type
                            token:token
               fromViewController:self
                    isBindAccount:YES
                          success:^(id result) {
                              NSInteger code = [result[@"dm_error"] integerValue];
                              NSString *errorString = result[@"error_msg"];
                              if (0 == code) {
                                  [self updateData];
                                  [self showProgressHUDWithTips:kLocalizationConnectedSuccessed];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationBind object:nil];
                                  
                                  if ([type isEqualToString:kPlatformTwitter]) {
                                      [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserDefaultsUnbindTwitter];
                                      [[NSUserDefaults standardUserDefaults] synchronize];
                                  }
                                  st_result = @"1";
                                  
                              } else if (4 == code) {
                                  [self showProgressHUDWithTips:kLocalizationHadConnected];
                                  st_result = errorString;
                              } else {
                                  [self showProgressHUDWithTips:kLocalizationConnectedFailed];
                                  st_result = errorString;
                              }
                          }
                          failure:^(NSString *errorString) {
                              NSLog(@"errorString is %@", errorString);
                              st_result = errorString;
                          }
                           cancel:^{
                               NSLog(@"cancel");
                           }
                          finally:^{
                              // 每点击绑定账号一次+1（林思敏）
                              NSTimeInterval st_endtime = [[NSDate date] timeIntervalSince1970] * 1000 - st_clicktime * 1000;
                              [wself st_reportConnectedAccountEventType:type result:st_result time:st_endtime];
                              [MBProgressHUD hideHUDForView:self.view animated:YES];
                          }];

}

#pragma mark - TableView dataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[FBUtility preferredLanguage] containsString:@"ru"]) {
        return 4;
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FBConnectedAccountCell *cell = (FBConnectedAccountCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBConnectedAccountCell class]) forIndexPath:indexPath];
    
    if (indexPath.row == 2) {
        if ([[FBUtility preferredLanguage] containsString:@"ru"]){
            cell.accountModel = self.accountArray[2];
            
        } else {
            cell.accountModel = self.accountArray[3];
            cell.separatorView.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.accountModel = self.accountArray[indexPath.row];
        if (indexPath.row == 3) {
            cell.separatorView.backgroundColor = [UIColor whiteColor];
        }
    }

    return cell;
}

#pragma mark - TableView delegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self popBingCardWithPlatform:0];
    } else if (indexPath.row == 1) {
        [self popBingCardWithPlatform:1];
    } else  if (indexPath.row == 2) {
        
        if ([[FBUtility preferredLanguage] containsString:@"ru"]){
            [self popBingCardWithPlatform:2];
        }else {
            [self touchEmailCell];
        }
        
    } else if (indexPath.row == 3) {
        
        if ([[FBUtility preferredLanguage] containsString:@"ru"]) {
            [self touchEmailCell];
        } else {
            // none
        }
    }
}

#pragma mark - FBEmailUnConnectedAccountCardDelegate -
/** 刷新邮箱绑定或者解绑后的数据 */
- (void)updateEmailData {
    [FBUtility updateConnectedAccountsWithSuccessBlock:^{
        //
    } failureBlock:^{
        //
    }];
    
    [self loadUserInfos];
}

#pragma mark - FBConnectedAccountCardDelegate -
/** 点击绑定按钮触发的事件 */
- (void)clickConnectedAccount:(NSString *)type {
    
    if ([type isEqualToString:kPlatformVK]) {
        [self initializeVKInfo];
    }
    else {
        [self onTouchButtonBindWithType:type token:nil];
    }
}

/** 刷新绑定或者解绑后的数据 */
- (void)updateData {
    [FBUtility updateConnectedAccountsWithSuccessBlock:^{
        //
    } failureBlock:^{
        //
    }];
    [self loadUserInfos];
}

#pragma mark - VKSDK Delegate -
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    //
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        
        [self onTouchButtonBindWithType:kPlatformVK token:result.token.accessToken];
        
    } else if (result.error) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"cancel" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)vkSdkUserAuthorizationFailed {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - CNPPopupController Delegate
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}


#pragma mark - Helper -
/** 显示的提示语 */
- (void)showProgressHUDWithTips:(NSString *)tips {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.mode = MBProgressHUDModeText;
    hud.color = COLOR_MAIN;
    hud.activityIndicatorColor = [UIColor grayColor];
    hud.detailsLabelText = tips;
    hud.margin = 10.f;
    hud.yOffset = -64.0f;
    [hud show:YES];
    [hud hide:YES afterDelay:3];
}

/** 弹出邮箱未绑定的卡片 */
- (void)popUNBingCard {
    FBEmailUnConnectedAccountCard *view = [[FBEmailUnConnectedAccountCard alloc] initWithFrame:CGRectMake(0, 0, 310, 355)];
    
    view.icon.image = [UIImage imageNamed:@"user_icon_email"];
    
    view.delegate = self;
    
    view.doCancelCallback = ^ (void) {
        [self.popupController dismissPopupControllerAnimated:YES];
    };
    
    [self configureCardView:view];
}

/** 弹出绑定卡片 */
- (void)popBingCardWithPlatform:(NSUInteger)num{

    FBConnectedAccountCard *view = [[FBConnectedAccountCard alloc] init];
    view.delegate = self;
    view.accountModel = [self.accountArray safe_objectAtIndex:num];
    
    if (!view.accountModel.infosModel.nick && view.accountModel.infosModel.openid && ![view.accountModel.infosModel.platform isEqualToString:kPlatformEmail]) {
        view.frame = CGRectMake(0, 0, 310, 355);
    } else {
        view.frame = CGRectMake(0, 0, 310, 290);
    }
    
    if ([self.accountArray count] > 0) {
        //
    }else {
        NSMutableArray *colorArray = [@[COLOR_MAIN, COLOR_ASSIST_BUTTON] mutableCopy];
        UIImage *backImage = [view.addbutton buttonImageFromColors:colorArray ByGradientType:leftToRight];
//        [view.addbutton setBackgroundColor:[UIColor colorWithPatternImage:backImage]];
        [view.addbutton setBackgroundImage:backImage forState:UIControlStateNormal];
        [view.addbutton setTitle:kLocalizationAdd forState:UIControlStateNormal];
    }
    
    view.doCancelCallback = ^ (void) {
        [self.popupController dismissPopupControllerAnimated:YES];
    };
    
    [self configureCardView:view];
}

/** 点击email弹出对应状态的卡片 */
- (void)touchEmailCell{
    if ([self.accountArray count] > 0) {
        FBAccountListModel *model = [self.accountArray objectAtIndex:3];
        if (model.infosModel.openid) {
            [self popBingCardWithPlatform:3];
        } else {
            [self popUNBingCard];
        }
    }
}

#pragma mark - Statistics -
/** 每点击绑定账号一次+1 */
- (void)st_reportConnectedAccountEventType:(NSString *)type result:(NSString *)result time:(NSTimeInterval)time {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"type" value:type];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%lf",time]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"login"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
