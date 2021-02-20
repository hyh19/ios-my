
#import "ZWNewsWebViewController.h"
#import "ZWShareActivityView.h"
#import "UIAlertView+Blocks.h"

@interface ZWNewsWebViewController ()

@end

@implementation ZWNewsWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Override -
- (void)share {
    [super share];
    [[ZWShareActivityView alloc] initNormalShareViewWithTitle:self.title
                                                      content:self.webView.request.URL.absoluteString                                                          SMS:self.webView.request.URL.absoluteString
                                                        image:[UIImage imageNamed:@"logo"]
                                                          url:self.webView.request.URL.absoluteString
                                                     mobClick:@""
                                                       markSF:NO
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

@end
