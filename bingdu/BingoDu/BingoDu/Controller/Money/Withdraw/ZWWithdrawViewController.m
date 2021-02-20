#import "ZWWithdrawViewController.h"
#import "ZWMoneyNetworkManager.h"
#import "ZWCommonFunc.h"
#import "ZWAddBankCardViewController.h"
#import "ZWBankWithdrawViewController.h"
#import "ZWWithdrawCell.h"
#import "UIImageView+WebCache.h"
#import "ZWWithdrawWayModel.h"
#import "ZWThirdPartyWithdrawViewController.h"
#import "UIAlertView+Blocks.h"
#import "RTLabel.h"
#import "ZWWithdrawQuotaCell.h"
#import "ZWWithdrawRecordViewController.h"
#import "ZWStoreViewController.h"
#import "ZWGuideManager.h"
#import "UIAlertView+Blocks.h"
#import "ZWIdVerificationViewController.h"
#import "ZWBindViewController.h"

@interface ZWWithdrawViewController ()

/** 提现方式数组 */
@property (nonatomic, strong) NSMutableArray *withdrawWaysArray;

/** 用户本周可享受的免手续费提现次数 */
@property (nonatomic, assign) NSInteger weeklyFreeQuota;

/** 存在的身份证信息 */
@property (nonatomic, strong) NSString *idCardNumber;

/** Table header view */
@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;

/** Table footer view */
@property (strong, nonatomic) IBOutlet UIView *tableFooterView;

@end

@implementation ZWWithdrawViewController

#pragma mark - Getter & Setter -
+ (instancetype)viewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Withdraw" bundle:nil];
    ZWWithdrawViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ZWWithdrawViewController class])];
    return viewController;
}

- (NSMutableArray *)withdrawWaysArray {
    if (!_withdrawWaysArray) {
        _withdrawWaysArray = [[NSMutableArray alloc] init];
    }
    return _withdrawWaysArray;
}

#pragma mark - Life cycle -
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 友盟统计
    [MobClick event:@"encashment_page_show"];
    
    [ZWGuideManager showGuidePage:kGuidePageWithdraw];
    
    // 每次进入重新刷新数据，保证剩余份额是最新的
    [self sendRequestForLoadingWithdrawWays];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureUserInterface];
}

#pragma mark - Data management -
- (void)configureData:(NSDictionary *)data {
    
    // 用户本周可享受的免手续费提现次数
    NSNumber *num = data[@"hasFree"];
    
    if (num) {
        self.weeklyFreeQuota = [num integerValue];
    }
    
    // 用户的存在的身份证信息
    NSString *idCardNum = data[@"idCardNum"];
    if (idCardNum) {
        self.idCardNumber = idCardNum;
    }
    
    // 全部提现方式
    NSArray *array = data[@"platforms"];
    
    if (array && [array count]>0) {
        
        [self.withdrawWaysArray removeAllObjects];
        
        for (NSDictionary *data in array) {
            ZWWithdrawWayModel *model = [[ZWWithdrawWayModel alloc] initWithData:data];
            [self.withdrawWaysArray safe_addObject:model];;
        }
    }
}

#pragma mark - UI management -
/** 配置界面外观和数据 */
- (void)configureUserInterface {
    
    self.tableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 55);
    
    self.tableFooterView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
}

/** 刷新界面 */
- (void)updateUserInterface {
    [self.tableView reloadData];
}

#pragma mark - Network management -
/** 发送网络请求获取提现方式 */
- (void)sendRequestForLoadingWithdrawWays {
    
    [[ZWMoneyNetworkManager sharedInstance] loadWithdrawWaysWithUserID:[ZWUserInfoModel userID]
                                                                succed:^(id result) {
                                                                    [self configureData:result];
                                                                    [self updateUserInterface];
                                                                }
                                                                failed:^(NSString *errorString) {
                                                                    hint(errorString);
                                                                }];
}

/** 发送网络请求删除已添加的银行卡 */
- (void)sendRequestForDeletingBankCardAtIndexPath:(NSIndexPath *)indexPath {
    
    ZWWithdrawWayModel *model = self.withdrawWaysArray[indexPath.row];
    
    [[ZWMoneyNetworkManager sharedInstance] deleteBankWithUserID:[ZWUserInfoModel userID]
                                                   cardNb:[model.account base64String]
                                                   succed:^(id result) {
                                                       
                                                       [self.withdrawWaysArray removeObjectAtIndex:indexPath.row];
                                                       
                                                       [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                       
                                                       [self.tableView reloadData];
                                                   }
                                                   failed:^(NSString *errorString) {
                                                       hint(errorString);
                                                   }];
    
}

#pragma mark - Event handler -
/** 官方提现额度已被抢完提示 */
- (void)showOfficialQuotaEmpty {
    [UIAlertView showWithTitle:nil
                       message:@"今天的额度已被抢完啦~不过不要紧，您的余额还可用于礼品商城兑换丰富奖品哦！"
             cancelButtonTitle:@"取消"
             otherButtonTitles:@[@"去商城看看"]
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == 1) {
                              [self pushStoreViewController];
                          }
                      }];
}

/** 用户每周一次的第三方支付平台免费提现额度用完提示 */
- (void)showWeeklyFreeQuotaEmpty {
    // 用户本周免费提现额度已经用完，提示用户选择其它方式
    [UIAlertView showWithTitle:nil
                       message:@"为保证其他并友也能公平地享受免费提现服务，每位并友每周只能申请一次，不便之处还请谅解。"
             cancelButtonTitle:@"选择其它方式"
             otherButtonTitles:nil
                      tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) { }];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.withdrawWaysArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 最后一行显示添加银行卡按钮，其余显示提现方式
    if (indexPath.row < [self.withdrawWaysArray count]) {
        
        ZWWithdrawWayModel *model = self.withdrawWaysArray[indexPath.row];
        
        ZWWithdrawCell *cell = nil;
        
        if (model.hasQuota) {
            cell = (ZWWithdrawQuotaCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWWithdrawQuotaCell class])];
        } else {
            cell = (ZWWithdrawCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZWWithdrawCell class])];
        }
        cell.data = model;
        return cell;
    }
    // 添加银行卡
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddBankCardCell"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [self.withdrawWaysArray count]) {
        
        ZWWithdrawWayModel *model = self.withdrawWaysArray[indexPath.row];
        
        // 银行卡可以滑动删除，第三方提现工具不可以删除
        if (kWithdrawWayBank == model.type) {
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 滑动删除银行卡
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (indexPath.row < [self.withdrawWaysArray count]) {
            
            ZWWithdrawWayModel *model = self.withdrawWaysArray[indexPath.row];
            
            // 银行卡可以滑动删除，第三方提现工具不可以删除
            if (kWithdrawWayBank == model.type) {
                [self sendRequestForDeletingBankCardAtIndexPath:indexPath];
            }
        }
    }
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [self.withdrawWaysArray count]) {
        
        ZWWithdrawWayModel *model = self.withdrawWaysArray[indexPath.row];
        // 提现到银行卡
        if (kWithdrawWayBank == model.type) {
            // 有设置限额
            if (model.hasQuota) {
                if (model.quato>0) {
                    [self pushNextViewController:model];
                } else {
                    [self showOfficialQuotaEmpty];
                }
            // 无设置限额
            } else {
                [self pushNextViewController:model];
            }
        // 提现到第三方支付平台
        } else {
            // 有设置限额
            if (model.hasQuota) {
                // 仍有额度没抢完
                if (model.quato>0) {
                    
                    // 判断有无绑定手机号
                    if (![ZWUserInfoModel linkMobile]) {
                        [self pushLinkMobileViewControllerIfNeededFromViewController:self];
                        return;
                    } else {
                        if (model.isFree) {
                            // 用户没抢过
                            if (self.weeklyFreeQuota>0) {
                                [self pushWhetherVerifyIDViewController:model];
                                // 用户已经抢过
                            } else {
                                [self showWeeklyFreeQuotaEmpty];
                            }
                        } else {
                            [self pushWhetherVerifyIDViewController:model];
                        }
                    }
                 // 额度抢完
                } else {
                    [self showOfficialQuotaEmpty];
                }
                // 无设置限额
            } else {
                [self pushWhetherVerifyIDViewController:model];
            }
            
        }
    } else {
        // 进行添加银行卡界面
        [self pushNextViewController:nil];
    }
}

#pragma mark - Navigation -
/** 判断是否有绑定手机号，无则前往绑定 */
- (void)pushLinkMobileViewControllerIfNeededFromViewController:(UIViewController *)controller {
    
    __weak UIViewController *weakInstance = controller;
    
    [self hint:@"申请提现必须先绑定手机号码，是否现在绑定？"
     trueTitle:@"前往绑定"
     trueBlock:^{
         ZWBindViewController *viewController = [ZWBindViewController viewController];
         [weakInstance.navigationController pushViewController:viewController animated:YES];
         
     }
   cancelTitle:@"取消"
   cancelBlock:^{}];
}

/** 判断是否进入验证身份证信息界面 */
- (void)pushWhetherVerifyIDViewController:(ZWWithdrawWayModel *)model {
    if (model) {
        // 判断身份证信息是否为空，为空则进入验证身份信息界面
        if (![self.idCardNumber isValid]) {
            [self pushIDVerificationViewController:model];
        } else {
            [self pushThirdPartyWithdrawViewControllerWithModel:model];
        }
    }
}

/** 进入下一个界面：银行卡界面或添加银行卡界面 */
- (void)pushNextViewController:(ZWWithdrawWayModel *)model {
    
    if (model) {
        // 如果没有身份证或银行卡归属地信息，则进入添加银行卡界面
        if ((![model.idCardNum isValid]) ||
            (![model.bankArea isValid])) {
            [UIAlertView showWithTitle:nil
                               message:@"您需要补充部分银行卡信息，才能继续进行银行卡提现"
                     cancelButtonTitle:@"取消"
                     otherButtonTitles:@[@"补充信息"]
                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (alertView.cancelButtonIndex != buttonIndex) {
                                      [self pushAddBankCardViewControllerWithModel:model];
                                  }
                              }];
            
        } else {
            [self pushBankWithdrawViewControllerWithModel:model];
        }
        
    } else {
        // 补充银行卡信息，身份证和银行卡归属地
        [self pushAddBankCardViewControllerWithModel:nil];
    }
}

/**
 *  进入添加银行卡界面
 *
 *  @param model model为nil时，添加新的银行，model不为nil时，补充银行卡信息
 */
- (void)pushAddBankCardViewControllerWithModel:(ZWWithdrawWayModel *)model {
    ZWAddBankCardViewController *pushviewController = [ZWAddBankCardViewController viewController];
    pushviewController.model = model;
    [self.navigationController pushViewController:pushviewController animated:YES];
}

/** 进入银行卡提现申请界面 */
- (void)pushBankWithdrawViewControllerWithModel:(ZWWithdrawWayModel *)model {
    ZWBankWithdrawViewController *viewController = [ZWBankWithdrawViewController viewController];
    viewController.model = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

/** 进入第三方支付平台提现申请界面 */
- (void)pushThirdPartyWithdrawViewControllerWithModel:(ZWWithdrawWayModel *)model {
    ZWThirdPartyWithdrawViewController *viewController = [ZWThirdPartyWithdrawViewController viewController];
    viewController.model = model;
    [self.navigationController pushViewController:viewController animated:YES];
}

/** 进入礼品商城界面 */
- (void)pushStoreViewController {
    ZWStoreViewController *nextViewController = [[ZWStoreViewController alloc] init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入身份证验证界面 */
- (void)pushIDVerificationViewController:(ZWWithdrawWayModel *)model {
    ZWIdVerificationViewController *nextViewController = [ZWIdVerificationViewController viewController];
    nextViewController.model = model;
    [self.navigationController pushViewController:nextViewController animated:YES];
    
}

@end
