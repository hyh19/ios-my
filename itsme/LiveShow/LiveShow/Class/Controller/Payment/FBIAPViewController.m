#import "FBIAPViewController.h"
#import "FBIAPCell.h"
#import "MKStoreKit.h"
#import "UIView+Borders.h"
#import "FBGAIManager.h"
#import <AppsFlyer/AppsFlyer.h>
#import "FBLoginInfoModel.h"

#define kHeightForRow 50
#define kHeightForSectionHeader 40
#define kReceiptData @"receiptData"
#define kReceiptProductIdentifier @"productIdentifier"
#define kReceiptBase64BData @"receiptBase64Data"
#define kPlatform @"App Store"

#define kGAIActionChargeFailure @"充值失败"

#define kGAIActionRequestTimeInterval @"请求钻石到账时长"

#define kGAILabelInAppPurchaseFailure @"扣款失败"

#define kGAILabelDiamondFailure @"钻石到账失败"

#define kGAILabelOneSecond @"1秒以内"

#define kGAILabelTwoSecond @"2秒以内"

#define kGAILabelThreeSecond @"3秒以内"

#define kGAILabelFourSecond @"4秒以内"

#define kGAILabelFiveSecond @"5秒以内"

#define kGAILabelSixSecond @"6秒或者以上"

@interface FBIAPViewController ()

@property (nonatomic, strong) UILabel *titleLabel;

/** 商品信息 */
@property (nonatomic, strong) NSArray *products;

/** 充值失败重试次数 */
@property (nonatomic, assign) NSInteger retryCount;

/** 记录进入当前界面的时间 用于计算时间差 */
@property (nonatomic, strong) NSDate *intoDate;

@end

@implementation FBIAPViewController

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取进入时间
    _intoDate = [NSDate date];
    
    [self addNotificationObservers];
    [self configUI];
    if ([self.products count] <= 0) {
        [self requestForProducts];
    } else {
        [self st_markTime];
        [self st_markResult:1];
        [self st_reportDisplayStorePage];
    }
    [self doLastFailedPurchase];
    [[FBGAIManager sharedInstance] ga_sendScreenHit:@"充值"];
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                            action:@"充值"
                                             label:@"PV/UUID"
                                             value:@(1)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 企业版提示无法充值
#if TARGET_VERSION_ENTERPRISE
    [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationEnterpriseVersionAlert cancelButtonTitle:nil otherButtonTitles:nil handler:nil];
#endif
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS action:@"返回" label:[[FBLoginInfoModel sharedInstance] userID] value:@(1)];
}

- (void)dealloc {
    [self removeNotificationObservers];
    NSTimeInterval seconds = [_intoDate timeIntervalSinceNow];
    if (seconds <= 30) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS action:@"页面停留" label:@"页面停留30s" value:@(1)];
    } else if (seconds <= 60) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS action:@"页面停留" label:@"页面停留60s" value:@(1)];
    } else if (seconds <= 90) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS action:@"页面停留" label:@"页面停留90s" value:@(1)];
    } else {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS action:@"页面停留" label:@"页面停留90s以上" value:@(1)];
    }
    
    [[FBNewGAIManager sharedInstance] ga_sendTime:CATEGORY_RECHARGE_STATITICS intervalMillis:-seconds name:[[FBLoginInfoModel sharedInstance] userID] label:@"平均停留时长"];
}

#pragma mark - Getter & Setter -
- (NSArray *)products {
    if (!_products) {
        if ([[self availableProducts] count] > 0) {;
            _products = [self availableProducts];
        } else {
            _products = [NSArray array];
        }
    }
    return _products;
}

- (CGFloat)heightForTableView {
    return kHeightForSectionHeader + kHeightForRow * self.products.count;
}

#pragma mark - UI Management -
/** 配置界面 */
- (void)configUI {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBIAPCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBIAPCell class])];
    self.tableView.backgroundColor = COLOR_F0F7F6;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationItem.title = kLocalizationLabelProfit;
}

- (void)updateUI {
    [self.tableView reloadData];
    if (self.reloadDataCallback) {
        self.reloadDataCallback();
    }
}

#pragma mark - Network Management -
- (void)requestForPurchasingWithProductIdentifier:(NSString*)productIdentifier{
    __weak typeof(self) wself = self;
    NSInteger count = [self diamondCountWithProductIdentifier:productIdentifier];
    
    // 记录请求钻石到账的开始时间
    self.requestDiamondBegin = [[NSDate date] timeIntervalSince1970];
    
    [[FBStoreNetworkManager sharedInstance] depositWithGold:count platform:kPlatform bundleID:[FBUtility bundleID] receiptBase64Data:[self receiptBase64Data] success:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            
            if (wself.purchaseCallback) {
                wself.purchaseCallback(kPurchaseStatusSuccess, nil);
            }
            // 如果上次有未购买成功的，则移除
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kReceiptData];
            if (dict) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kReceiptData];
            }
            
            // 计算请求钻石到账的时长
            NSTimeInterval requestDiamondEnd = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval interval = requestDiamondEnd - self.requestDiamondBegin;
            
            if (interval <= 1) {
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                        action:kGAIActionRequestTimeInterval
                                                         label:kGAILabelOneSecond
                                                         value:@(1)];
            } else if (interval <= 2) {
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                        action:kGAIActionRequestTimeInterval
                                                         label:kGAILabelTwoSecond
                                                         value:@(1)];
            } else if (interval <= 3) {
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                        action:kGAIActionRequestTimeInterval
                                                         label:kGAILabelThreeSecond
                                                         value:@(1)];
            } else if (interval <= 4) {
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                        action:kGAIActionRequestTimeInterval
                                                         label:kGAILabelFourSecond
                                                         value:@(1)];
            } else if (interval <= 5) {
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                        action:kGAIActionRequestTimeInterval
                                                         label:kGAILabelFiveSecond
                                                         value:@(1)];
            } else {
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                        action:kGAIActionRequestTimeInterval
                                                         label:kGAILabelSixSecond
                                                         value:@(1)];
            }
            
            // 打点， 充值成功
            [wself st_markResult:1];
            wself.statisticsInfo[@"time"] = [NSString stringWithFormat:@"%f", interval * 1000];
            [wself st_reportClickRechargeWithEventType:1];
            
            // 状态码在200~299之间重试，大于等于300不重试
        } else if (code >= 200 && code < 300) {
            [wself retryRechargeDiamondRequest:productIdentifier];
        }
        
    } failure:^(NSString *errorString) {
        [wself retryRechargeDiamondRequest:productIdentifier];
    } finally:^{
        //
    }];
    
}

/** 加载内购商品列表 */
- (void)requestForProducts {
    NSArray *productIdentifiers = [[GVUserDefaults standardUserDefaults] productIdentifiers];
    if ([productIdentifiers count] > 0) {
        // 从App Store请求内置购买商品
        [[MKStoreKit sharedKit] startProductRequestWithProductIdentifiers:productIdentifiers];
    } else {
        // 从服务器拉取商品ID，然后向App Store请求内置购买商品
        [FBUtility startProductRequest];
    }
}

-(void)reportToFlyerAndGAI:(NSString*)productIdentifier
{
#ifndef DEBUG
    NSInteger count = [self diamondCountWithProductIdentifier:productIdentifier];
    
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:@{AFEventParamContentId: productIdentifier,
                                                                              AFEventParamContentType:@"coin",
                                                                              AFEventParamRevenue: @(count),
                                                                              AFEventParamCurrency:@"USD"}];
    
    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_GIFT_STATITICS action:@"充值" label:@"app store" value:@(count)];
#endif
    
}

#pragma mark - Data Management -
- (void)configData {
    self.products = [self availableProducts];
    // 打点
    [self st_markTime];
    if ([self.products count] > 0) {
        [self st_markResult:1];
    } else {
        [self st_markResult:0];
    }
    [self st_reportDisplayStorePage];
}

#pragma mark - Event Handler -
/** 添加广播监听 */
- (void)addNotificationObservers {
    
    __weak typeof(self) wself = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSString *productIdentifier = note.object;
                                                      [wself requestForPurchasingWithProductIdentifier:productIdentifier];
                                                      [wself reportToFlyerAndGAI:productIdentifier];
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      /**
                                                       *  @author 黄玉辉
                                                       *  @since 1.7.2
                                                       *  @brief 上报商店充值失败的事件
                                                       */
                                                      [self st_markResult:0];
                                                      self.statisticsInfo[@"time"] = @"0";
                                                      [wself st_reportClickRechargeWithEventType:0];
                                                      
                                                      [wself bk_performBlock:^(id obj) {
                                                          if (wself.purchaseCallback) {
                                                              wself.purchaseCallback(kPurchaseStatusFailure, nil);
                                                          }
                                                      } afterDelay:0.25];
                                                      
                                                      [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                                                              action:kGAIActionChargeFailure
                                                                                               label:kGAILabelInAppPurchaseFailure
                                                                                               value:@(1)];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      [wself bk_performBlock:^(id obj) {
                                                          [wself configData];
                                                          [wself updateUI];
                                                      } afterDelay:0.25];
                                                  }];
}

/** 移除广播监听 */
- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 重新进行上一次的失败购买 */
- (void)doLastFailedPurchase {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kReceiptData];
    if (dict) {
        [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationChargeOrder cancelButtonTitle:kLocalizationPublicCancel otherButtonTitles:@[kLocalizationPublicConfirm] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (1 == buttonIndex) {
                if (self.purchaseCallback) {
                    self.purchaseCallback(kPurchaseStatusProcess, nil);
                }
                self.retryCount = 0;
                NSString *productIdentifier = dict[kReceiptProductIdentifier];
                [self requestForPurchasingWithProductIdentifier:productIdentifier];
            }
        }];
    }
}

/** 请求失败后重新发起增加钻石请求 */
- (void)retryRechargeDiamondRequest:(NSString *)productIdentifier {
    if (self.retryCount < 3) {
        [self requestForPurchasingWithProductIdentifier:productIdentifier];
        self.retryCount += 1;
        
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                                action:kGAIActionChargeFailure
                                                 label:kGAILabelDiamondFailure
                                                 value:@(1)];
    } else {
        if (self.purchaseCallback) {
            self.purchaseCallback(kPurchaseStatusFailure, nil);
        }
        NSString *message = kLocalizationChargeFailNetwork;
        [UIAlertView bk_showAlertViewWithTitle:nil message:message cancelButtonTitle:kLocalizationPublicConfirm otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        // 缓存购买凭证，下次进入充值界面重新充值
        NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        NSDictionary *dict = @{kReceiptProductIdentifier : productIdentifier,
                               kReceiptBase64BData       : [receiptData base64EncodedStringWithOptions:0]};
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:kReceiptData];
        
        // 打点， 充值失败
        NSTimeInterval requestDiamondEnd = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval interval = requestDiamondEnd - self.requestDiamondBegin;
        [self st_markResult:1];
        self.statisticsInfo[@"time"] = [NSString stringWithFormat:@"%f", interval * 1000];
        [self st_reportClickRechargeWithEventType:1];
        
#ifndef DEBUG
        // 上报内置购买成功后充钻石失败事件
        [[FBNewGAIManager sharedInstance] ga_sendChargeFailure:[receiptData base64EncodedStringWithOptions:0]];
#endif
    }
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBIAPCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBIAPCell class]) forIndexPath:indexPath];
    cell.product = self.products[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate -
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kHeightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kHeightForSectionHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = COLOR_BACKGROUND_APP;
    [view addTopBorderWithHeight:0.5 andColor:COLOR_e3e3e3];
    [view addBottomBorderWithHeight:0.5 andColor:COLOR_e3e3e3];
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.mas_left).offset(@15);
        make.centerY.equalTo(view.mas_centerY);
    }];
    label.textColor = COLOR_888888;
    label.font = FONT_SIZE_12;
    [label sizeToFit];
    label.text = kLocalizationCharge;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SKProduct *product = self.products[indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kReceiptData];
    if (dict) {
        [self doLastFailedPurchase];
    } else {
        [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:product.productIdentifier];
        if (self.purchaseCallback) {
            self.purchaseCallback(kPurchaseStatusProcess, nil);
        }
    }
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_RECHARGE_STATITICS
                                            action:self.products[indexPath.row]
                                             label:[[FBLoginInfoModel sharedInstance] userID]
                                             value:@(1)];
    
    // 打点
    NSInteger count = [self diamondCountWithProductIdentifier:product.productIdentifier];
    self.statisticsInfo[@"money"] = [NSString stringWithFormat:@"%ld", (long)count];
}

#pragma mark - Helper -
/** 读取钻石数量 */
- (NSInteger)diamondCountWithProductIdentifier:(NSString *)productIdentifier {
    NSArray *array = [productIdentifier componentsSeparatedByString:@"."];
    NSInteger count = [[array lastObject] integerValue];
    return count;
}

/** 购买凭证 */
- (NSString *)receiptBase64Data {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:kReceiptData];
    // 如果有上一次未购买成功的，则返回上一次的购买凭证
    if (dict) {
        NSString *receiptBase64Data = dict[kReceiptBase64BData];
        return receiptBase64Data;
    }
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    return [receipt base64EncodedStringWithOptions:0];
}

- (NSArray *)availableProducts {
    NSArray *availableProducts = [[MKStoreKit sharedKit] availableProducts];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"price" ascending:YES];
    NSArray *sortedProducts = [availableProducts sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedProducts;
}

#pragma mark - Statistics -
// 记录从进入页面到内容展示出来所花费的时间
- (void)st_markTime {
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = now - self.enterTime;
    self.statisticsInfo[@"time"] = @(interval * 1000);
}

// 记录是否获取内容成功
- (void)st_markResult:(NSInteger)result {
    self.statisticsInfo[@"result"] = @(result);
}

/** 每展示充值页面＋1 */
- (void)st_reportDisplayStorePage {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"login_status" value:[NSString stringWithFormat:@"%lu",[FBStatisticsManager loginStatus]]];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"from" value:self.statisticsInfo[@"from"]];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.statisticsInfo[@"broadcast_id"]];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.statisticsInfo[@"host_id"]];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"time" value:self.statisticsInfo[@"time"]];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"result" value:self.statisticsInfo[@"result"]];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"recharge_pageshow"  eventParametersArray:@[eventParmeter1, eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/**
 *  @brief 每次点击充值+1
 *  @param eventType 事件类型：0-商店充值失败，1-App服务器冲钻失败
 */
- (void)st_reportClickRechargeWithEventType:(NSInteger)eventType {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"money" value:self.statisticsInfo[@"money"]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"pay_type" value:@"1"];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.statisticsInfo[@"host_id"]];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.statisticsInfo[@"broadcast_id"]];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"result" value:self.statisticsInfo[@"result"]];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"time" value:self.statisticsInfo[@"time"]];
    
    /**
     *  @author 黄玉辉
     *  @since 1.7.2
     *  @brief 上报商店充值失败的事件
     */
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"event_type" value:[NSString stringWithFormat:@"%ld", eventType]];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"recharge_click"  eventParametersArray:@[eventParmeter1, eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7, eventParmeter8]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
