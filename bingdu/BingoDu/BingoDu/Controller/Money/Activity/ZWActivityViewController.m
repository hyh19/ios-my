#import "ZWActivityViewController.h"
#import "ZWShareActivityView.h"
#import "ZWLoginViewController.h"
#import "UIAlertView+Blocks.h"
#import "ZWLaunchAdvertisemenViewController.h"
#import "ZWTitleLoopView.h"

@interface ZWActivityViewController ()

/** 活动数据 */
@property (nonatomic, strong) ZWActivityModel *model;

@end

@implementation ZWActivityViewController

#pragma mark - Init
- (instancetype)initWithModel:(ZWActivityModel *)model {
    NSString *formattedURLString = [self formattedURLStringWithModel:model];
    if (self = [super initWithURLString:formattedURLString]) {
        self.model = model;
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString {
    ZWActivityModel *model = [[ZWActivityModel alloc] initWithActivityID:0
                                                                   title:nil
                                                                subtitle:nil
                                                                     url:URLString];
    NSString *formattedURLString = [self formattedURLStringWithModel:model];
    if (self = [super initWithURLString:formattedURLString]) {
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *title = nil;
    if ([self.model.title isValid]) {
        title = self.model.title;
    } else {
        title = self.title;
    }
    self.navigationItem.titleView = [[ZWTitleLoopView alloc] initWithFrame:CGRectMake(0, 0, ((![[UIScreen mainScreen] isiPhone6])?100:200), 44) Title:title];
}

#pragma mark - Override -
- (void)close {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        // 判断是否从启动广告页进入的，若是则返回到该页
        if ([self.navigationController viewControllers].count >= 2 && [[self.navigationController viewControllers][1] isKindOfClass:[ZWLaunchAdvertisemenViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (void)share {
    [super share];
    [[ZWShareActivityView alloc] initNormalShareViewWithTitle:self.model.title
                                                      content:[self sharedURLString]
                                                          SMS:[self.model.title stringByAppendingString:[self formattedURLString]]
                                                        image:[UIImage imageNamed:@"logo"]
                                                          url:[self sharedURLString]
                                                     mobClick:@"_activity_page"
                                                       markSF:YES
                                                  shareResult:^(SSDKResponseState state, SSDKPlatformType type, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                                                      if (state == SSDKResponseStateSuccess) {
                                                          occasionalHint(@"分享成功");
                                                      } else if (state == SSDKResponseStateFail) {
                                                          [UIAlertView showWithTitle:@"提示"
                                                                             message:error.userInfo[@"error_message"]
                                                                   cancelButtonTitle:@"关闭"
                                                                   otherButtonTitles:nil
                                                                            tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                                //
                                                                            }];
                                                      }
                                                  }];
}

#pragma mark - UIWebViewDelegate -
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (UIWebViewNavigationTypeLinkClicked == navigationType) {
        
        NSString *path = [request.URL absoluteString];
        
        if ([path containsString:@"alert"] &&
            [path containsString:@"key=0"]) {
            __weak typeof(self) weakSelf = self;
            ZWLoginViewController *nextViewController = [ZWLoginViewController viewControllerWithSuccessBlock:^{
                [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[weakSelf formattedURLString]]]];
            } failureBlock:nil finallyBlock:nil];
            [self.navigationController pushViewController:nextViewController animated:YES];
            return NO;
        }
    }
    return YES;
}



#pragma mark - Helper -
/** 配置URL */
- (NSString *)formattedURLStringWithModel:(ZWActivityModel *)model {
    // 登录用户需要在活动地址中添加用户ID给H5
    NSString *URLString = [NSString stringWithString:model.url];
    
    if ([ZWUserInfoModel login]) {
        
        if ([URLString rangeOfString:@"?"].location == NSNotFound) {
            URLString = [NSString stringWithFormat:@"%@?uid=%@&",URLString,[ZWUserInfoModel userID]];
        } else {
            URLString = [NSString stringWithFormat:@"%@&uid=%@&",URLString,[ZWUserInfoModel userID]];
        }
        
    } else {
        if ([URLString rangeOfString:@"?"].location == NSNotFound) {
            URLString = [URLString stringByAppendingString:@"?"];
        }
    }
    
    URLString = [URLString stringByAppendingString:[NSString stringWithFormat:@"client=%@&activityId=%ld", @"2", model.activityID]];
    
    return URLString;
}

/** 格式化的URL */
- (NSString *)formattedURLString {
    return [self formattedURLStringWithModel:self.model];
}

/** 被分享的URL */
- (NSString *)sharedURLString {
    return [[self formattedURLString] stringByAppendingString:@"&share=1"];
}

@end
