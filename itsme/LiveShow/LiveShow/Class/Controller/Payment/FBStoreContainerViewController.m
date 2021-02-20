#import "FBStoreContainerViewController.h"
#import "FBStoreSegmentedControl.h"
#import "FBIAPViewController.h"
#import "FBLoginInfoModel.h"
#import <MessageUI/MFMailComposeViewController.h>

#define kEmailHelp @"support@ushow.media"

#define kHeightForHeader 80

#define kHeightForRow 125

#define kTagSegmentedControl 1000

#define kTagContainerView 2000

@interface FBStoreContainerViewController () <MFMailComposeViewControllerDelegate>

/** 顶部控件 */
@property (nonatomic, strong) UIView *tableHeaderView;

/** 钻石图标 */
@property (nonatomic, strong) UIImageView *diamondImageView;

/** 钻石余额 */
@property (nonatomic, strong) UILabel *balanceLabel;

/** 承载冲钻方式界面的容器 */
@property (nonatomic, strong) UIView *containerView;

/** App Store内置购买界面 */
@property (nonatomic, strong) FBIAPViewController *storeViewController;

/** 切换冲钻方式的控件 */
@property (nonatomic, strong) FBStoreSegmentedControl *segmentedControl;

/** 所有的冲钻方式界面 */
@property (nonatomic, strong) NSArray *viewControllers;

/** 当前冲钻方式界面 */
@property (nonatomic, strong) FBBaseStoreViewController *selectedViewController;

/** 冲钻帮助 */
@property (nonatomic, strong) UILabel *helpLabel;

@end

@implementation FBStoreContainerViewController {
    /** 当前页面 */
    FBBaseStoreViewController *_fromViewController;
    
    /** 目标页面 */
    FBBaseStoreViewController *_toViewController;
}

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self updateBalance];
}

#pragma mark - Getter & Setter -
- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHeightForHeader)];
        _tableHeaderView.backgroundColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:self.balanceLabel];
        [self.balanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_tableHeaderView.mas_centerX).offset(-21);
            make.centerY.equalTo(_tableHeaderView.mas_centerY);
        }];
        [_tableHeaderView addSubview:self.diamondImageView];
        [_diamondImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_tableHeaderView.mas_centerY);
            make.left.equalTo(self.balanceLabel.mas_right).offset(5);
        }];
    }
    return _tableHeaderView;
}

- (UIImageView *)diamondImageView {
    if (!_diamondImageView) {
        _diamondImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"charge_icon_diamond"]];
        [_diamondImageView sizeToFit];
    }
    return _diamondImageView;
}

- (UILabel *)balanceLabel {
    if (!_balanceLabel) {
        _balanceLabel = [[UILabel alloc] init];
        NSUInteger balance = [[FBLoginInfoModel sharedInstance] balance];
        _balanceLabel.text = [NSString stringWithFormat:@"%@ %ld",kLocalizationPaymentBalance, (long)balance];
        _balanceLabel.font = [UIFont systemFontOfSize:15];
        _balanceLabel.textColor = COLOR_444444;
        [_balanceLabel sizeToFit];
    }
    return _balanceLabel;
}

- (UIView *)containerView {
    if (!_containerView ) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.tag = kTagContainerView;
        
        FBBaseStoreViewController *defaultViewController = self.selectedViewController;
        _containerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, defaultViewController.heightForTableView);
        defaultViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth(_containerView.bounds), CGRectGetHeight(_containerView.bounds));
        [_containerView addSubview:defaultViewController.view];
        [self addChildViewController:defaultViewController];
        [defaultViewController didMoveToParentViewController:self];
        _fromViewController = defaultViewController;
    }
    return _containerView;
}

- (FBIAPViewController *)storeViewController {
    if (!_storeViewController) {
        _storeViewController = [[FBIAPViewController alloc] init];
        _storeViewController.storeTitle = @"App Store";
        _storeViewController.storeLogo = @"payment_charge_icon_app-store";
        __weak typeof(self) wself = self;
        _storeViewController.purchaseCallback = ^ (FBPurchaseStatus status, NSString *message) {
            switch (status) {
                case kPurchaseStatusProcess: {
                    [wself showPaymentProcessHUD];
                    break;
                }
                case kPurchaseStatusSuccess: {
                    [wself showPaymentSuccessHUD];
                    [wself updateBalance];
                    break;
                }
                case kPurchaseStatusFailure: {
                    [wself hidePaymentHUDs];
                    break;
                }
            }
        };
        _storeViewController.reloadDataCallback = ^ (void) {
            if (_storeViewController == wself.selectedViewController) {
                [wself updateHeightForContainer];
            }
        };
        
        // 打点
        _storeViewController.statisticsInfo = self.statisticsInfo;
    }
    return _storeViewController;
}

- (NSArray *)viewControllers {
    if (!_viewControllers) {
        _viewControllers = @[self.storeViewController];
    }
    return _viewControllers;
}

- (FBStoreSegmentedControl *)segmentedControl {
    if (!_segmentedControl) {
        _segmentedControl = [[FBStoreSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kHeightForRow)];
        _segmentedControl.backgroundColor = COLOR_FFFFFF;
        _segmentedControl.viewControllers = self.viewControllers;
        __weak typeof(self) wself = self;
        _segmentedControl.indexChangeBlock = ^ (NSUInteger index) {
            [wself switchToPageWithIndex:index];
            [wself updateHeightForContainer];
        };
        _segmentedControl.tag = kTagSegmentedControl;
    }
    return _segmentedControl;
}

- (FBBaseStoreViewController *)selectedViewController {
    FBBaseStoreViewController *selectedViewController = (FBBaseStoreViewController *)self.viewControllers[self.segmentedControl.selectedIndex];
    return selectedViewController;
}

- (UILabel *)helpLabel {
    if (!_helpLabel) {
        _helpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        _helpLabel.textAlignment = NSTextAlignmentCenter;
        _helpLabel.font = [UIFont systemFontOfSize:13];
        _helpLabel.textColor = [UIColor hx_colorWithHexString:@"888888"];
        NSString *string = [NSString stringWithFormat:@"%@%@", kLocalizationChargeHelpTip, kEmailHelp];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        NSRange range = [string rangeOfString:kEmailHelp];
        [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_MAIN range:range];
        _helpLabel.attributedText = attributedString;
        _helpLabel.userInteractionEnabled = YES;
        __weak typeof(self) wself = self;
        [_helpLabel bk_whenTapped:^{
            [wself sendEmail];
        }];
    }
    return _helpLabel;
}

#pragma mark - UI Management -
- (void)configUI {
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    self.tableView.backgroundColor = COLOR_BACKGROUND_APP;
    self.tableView.tableHeaderView = self.tableHeaderView;
    self.tableView.tableFooterView = self.helpLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)updateBalance {
    [self requestForBalance];
}

#pragma mark - Network Management -
- (void)requestForBalance {
    [[FBProfileNetWorkManager sharedInstance] loadProfitInfoSuccess:^(id result) {
        NSNumber *balance = result[@"account"][@"gold"];
        self.balanceLabel.text = [NSString stringWithFormat:@"%@ %@", kLocalizationPaymentBalance, balance];
        [[FBLoginInfoModel sharedInstance] setBalance:[balance integerValue]];
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

#pragma mark - Data Management -

#pragma mark - Event Handler -
/** 切换页面 */
- (void)switchToPageWithIndex:(NSUInteger)index {
    _toViewController = self.viewControllers[index];
    [self addChildViewController:_toViewController];
    [self transitionFromViewController:_fromViewController
                      toViewController:_toViewController
                              duration:0
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                [_fromViewController.view removeFromSuperview];
                                _toViewController.view.frame = self.containerView.bounds;
                                [self.containerView addSubview:_toViewController.view];
                            }
                            completion:^(BOOL finished) {
                                [_toViewController didMoveToParentViewController:self];
                                [_fromViewController removeFromParentViewController];
                                _fromViewController = _toViewController;
                            }];
}

/** 提示正在冲钻 */
- (void)showPaymentProcessHUD {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

/** 提示冲钻成功 */
- (void)showPaymentSuccessHUD {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = kLocalizationPaymentSuccess;
    [self.view addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

/** 关闭所有冲钻提示 */
- (void)hidePaymentHUDs {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

/** 提示信息 */
- (void)showHUDWithMessage:(NSString *)message {
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = message;
    HUD.margin = 10.f;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:2];
}

/** 发送邮件给客服 */
- (void)sendEmail {
    if (![MFMailComposeViewController canSendMail]) {
        [UIAlertView bk_showAlertViewWithTitle:nil
                                       message:kLocalizationPaymentSetupEmail
                             cancelButtonTitle:nil
                             otherButtonTitles:nil
                                       handler:nil];
        return;
    }
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    [mailController setToRecipients:@[kEmailHelp]];
    mailController.mailComposeDelegate = self;
    [self presentViewController:mailController animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (0 == indexPath.row) {
        if ([self.viewControllers count] >= 2) {
            if (![cell.contentView viewWithTag:kTagSegmentedControl]) {
                [cell.contentView addSubview:self.segmentedControl];
            }
        }
    } else if (1 == indexPath.row) {
        if (![cell.contentView viewWithTag:kTagContainerView]) {
            [cell.contentView addSubview:self.containerView];
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == indexPath.row) {
        if ([self.viewControllers count] >= 2) {
            return kHeightForRow;
        } else {
            return 0;
        }
    } else if (1 == indexPath.row) {
        return self.selectedViewController.heightForTableView;
    }
    return 0;
}



#pragma mark - Navigation -
+ (instancetype)pushMeToNavigationController:(UINavigationController *)navigationController {
    FBStoreContainerViewController *viewController = [[FBStoreContainerViewController alloc] init];
    viewController.hidesBottomBarWhenPushed = YES;
    [navigationController pushViewController:viewController animated:YES];
    return viewController;
}

#pragma mark - Help -
/** 更新商品列表的高度 */
- (void)updateHeightForContainer {
    self.containerView.dop_height = self.selectedViewController.heightForTableView;
    [self.tableView reloadData];
}

#pragma mark - MFMailComposeViewControllerDelegate -
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (result == MFMailComposeResultCancelled) {
        
    } else if (result == MFMailComposeResultSent) {
        [self showHUDWithMessage:kLocalizationSuccessfully];
    } else if (result == MFMailComposeResultFailed) {
        [self showHUDWithMessage:kLocalizationLoadingFailure];
    } else {
        
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
