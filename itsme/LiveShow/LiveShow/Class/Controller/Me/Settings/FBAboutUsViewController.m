#import "FBAboutUsViewController.h"
#import "FBUtility.h"
#import "FBWebViewController.h"
#import "UIActionSheet+Blocks.h"
#import "FBNetworkAPIViewController.h"

@interface FBAboutUsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *version;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

//多语言
@property (weak, nonatomic) IBOutlet UILabel *aboutUs;
@property (weak, nonatomic) IBOutlet UILabel *terms;
@property (weak, nonatomic) IBOutlet UILabel *rules;
@property (weak, nonatomic) IBOutlet UILabel *privacy;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (nonatomic) BOOL showActionSheet;

@end

@implementation FBAboutUsViewController
+ (instancetype)aboutUsViewController {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"FBSettingViewController" bundle:nil];
    FBAboutUsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
    return viewController;
                                               
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.backgroundColor = COLOR_BACKGROUND_APP;
    // 版本号 Build号
    self.version.text = [NSString stringWithFormat:@"StarMe V%@ Build%@", [FBUtility versionCode], [FBUtility buildCode]];
    
    [self mutilanguage];

    // 长按提示版本信息或切换服务器环境
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressAction)];
    [self.view addGestureRecognizer:gesture];
    self.icon.image = [UIImage imageNamed:@"about_icon_logo"];
}

/** 提示当前App版本信息，便于定位问题 */
- (void)showAppInfo {
    NSString *title = [NSString stringWithFormat:@"%@ %@ (%@)", [FBUtility targetVersion], [FBUtility versionCode], [FBUtility buildCode]];
    [UIAlertView bk_showAlertViewWithTitle:title
                                   message:[FBUtility versionInfo]
                         cancelButtonTitle:@"Close"
                         otherButtonTitles:@[@"Copy"]
                                   handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                       if (alertView.cancelButtonIndex != buttonIndex) {
                                           UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                           pasteboard.string = [FBUtility versionInfo];
                                       }
                                   }];
}

- (void)onLongPressAction {
    if (!self.showActionSheet) {
        self.showActionSheet = YES;
        __weak typeof(self) wself = self;
        [UIActionSheet presentOnView:self.view withTitle:nil cancelButton:@"Cancel" destructiveButton:@"App Information" otherButtons:@[@"Network API List"] onCancel:^(UIActionSheet *actionSheet) {
            //
        } onDestructive:^(UIActionSheet *actionSheet) {
            self.showActionSheet = NO;
            [wself showAppInfo];
        } onClickedButton:^(UIActionSheet *actionSheet, NSUInteger index) {
            self.showActionSheet = NO;
            switch (index) {
                case 1: {
                    FBNetworkAPIViewController *viewController = [[FBNetworkAPIViewController alloc] init];
                    [self.navigationController pushViewController:viewController animated:YES];
                }
                    break;
                default:
                    break;
            }
        }];
    }
    
}

#pragma mark - TableView Delegate -
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self pushWebViewController:kAboutUsContactURL title:kLocalizationLabelAboutus];
        
    } else if (indexPath.row == 2) {
        [self pushWebViewController:kAboutUsTermsURL title:kLocalizationTerms];
        
    } else if (indexPath.row == 3) {
        [self pushWebViewController:kAboutUsRulesURL title:kLocalizationRules];
        
    } else if (indexPath.row == 4) {
        [self pushWebViewController:kAboutUsPolicyURL title:kLocalizationPrivacy];
    }
}

- (void)mutilanguage {
    _aboutUs.text = kLocalizationLabelAboutus;
    _terms.text = kLocalizationTerms;
    _rules.text = kLocalizationRules;
    _privacy.text = kLocalizationPrivacy;
}

#pragma mark - Helper -
- (void)pushWebViewController:(NSString *)urlString title:(NSString *)title{
    FBWebViewController *webViewController = [[FBWebViewController alloc] initWithTitle:title url:urlString formattedURL:YES];
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
