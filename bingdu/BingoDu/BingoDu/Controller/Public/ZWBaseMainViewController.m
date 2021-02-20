#import "ZWBaseMainViewController.h"
#import "UIButton+Block.h"
#import "ZWNewsSearchViewController.h"
#import "ZWUserViewController.h"
#import "ZWUserInfoModel.h"
#import "UIButton+WebCache.h"
#import "ZWCommonWebViewController.h"
#import "ZWPublicNetworkManager.h"
#import "UIButton+NHZW.h"

/** 默认头像 */
#define kImageAvatarPlaceholder @"btn_avatar_nav"

@interface ZWBaseMainViewController ()

/** 头像按钮 */
@property (nonatomic, strong) UIButton *avatarButton;

/** 搜索按钮 */
@property (nonatomic, strong) UIButton *searchButton;

@end

@implementation ZWBaseMainViewController

#pragma mark - Getter & Setter -
- (UIButton *)avatarButton {
    if (!_avatarButton) {
        // 头像宽度
        CGFloat avatarButtonWidth = 32;
        _avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _avatarButton.frame = CGRectMake(0, 0, avatarButtonWidth, avatarButtonWidth);
        UIImage *image = [UIImage imageNamed:kImageAvatarPlaceholder];
        [_avatarButton setImage:image forState:UIControlStateNormal];
        [_avatarButton setImage:image forState:UIControlStateHighlighted];
        _avatarButton.imageView.layer.cornerRadius = avatarButtonWidth/2;
        _avatarButton.imageView.layer.masksToBounds = YES;
        _avatarButton.imageView.layer.borderColor = [UIColor colorWithHexString:@"#cbf1ea"].CGColor;
        _avatarButton.imageView.layer.borderWidth = 0;
        __weak typeof(self) weakSelf = self;
        [_avatarButton addAction:^(UIButton *btn) {
            [MobClick event:@"click_user_center"];
            [weakSelf pushUserViewController];
        }];
    }
    return _avatarButton;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        UIImage *image = [UIImage imageNamed:@"btn_search_nav"];
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [_searchButton setImage:image forState:UIControlStateNormal];
        [_searchButton setImage:image forState:UIControlStateHighlighted];
        __weak typeof(self) weakSelf = self;
        [_searchButton addAction:^(UIButton *btn) {
            [weakSelf pushNewsSearchController];
        }];
    }
    return _searchButton;
}

#pragma mark - Life cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUserInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateAvatarImage];
    [self sendRequestForCheckMessageReminder];
}

#pragma mark - Network management -
/** 发送网络请求检测主界面头像的消息提醒（红点） */
- (void)sendRequestForCheckMessageReminder {
    __weak typeof(self) weakSelf = self;
    [[ZWPublicNetworkManager sharedInstance] checkMessageReminderWithSuccessBlock:^(id result) {
        if ([result[@"menu"] boolValue] ||
            [result[@"version"] boolValue]) {
            CGFloat redPointWidth = 5;
            [weakSelf.avatarButton addRedPointWithFrame:CGRectMake(26, 4, redPointWidth, redPointWidth) borderColor:[UIColor whiteColor] borderWidth:1];
        }
    } failureBlock:^(NSString *errorString) {
    }];
}

#pragma mark - UI management
/** 配置界面外观 */
- (void)initUserInterface {
    [self setupAvatarButton];
    [self setupRightBarButtonItem:self.searchButton];
}

/** 设置头像按钮 */
- (void)setupAvatarButton {
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil
                              action:nil];
    space.width = -4.5;
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(0, 0, 2, 30);
    UIImage *image = [UIImage imageNamed:@"btn_more_nav"];
    [moreButton setImage:image forState:UIControlStateNormal];
    [moreButton setImage:image forState:UIControlStateHighlighted];
    __weak typeof(self) weakSelf = self;
    [moreButton addAction:^(UIButton *btn) {
        [weakSelf pushUserViewController];
    }];
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    
    UIBarButtonItem *avatarItem = [[UIBarButtonItem alloc] initWithCustomView:self.avatarButton];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        // 解决位置偏移和触摸范围太大的问题
        UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:nil
                                                                     action:nil];
        self.navigationItem.leftBarButtonItems = @[space, moreItem, avatarItem, spaceItem];
    } else {
        self.navigationItem.leftBarButtonItems = @[space, moreItem, avatarItem];
    }
}

/** 更新头像 */
- (void)updateAvatarImage {
    NSURL *avatarImageURL = [NSURL URLWithString:[[ZWUserInfoModel sharedInstance] headImgUrl]];
    UIImage *placeholderImage = [UIImage imageNamed:kImageAvatarPlaceholder];
    [self.avatarButton sd_setImageWithURL:avatarImageURL forState:UIControlStateNormal placeholderImage:placeholderImage];
    [self.avatarButton sd_setImageWithURL:avatarImageURL forState:UIControlStateHighlighted placeholderImage:placeholderImage];
}

#pragma mark - Navigation -
/** 进入新闻搜索界面 */
- (void)pushNewsSearchController {
    ZWNewsSearchViewController *nextViewController = [[ZWNewsSearchViewController alloc] init];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

/** 进入用户中心界面 */
- (void)pushUserViewController {
    ZWUserViewController *nextViewController = [ZWUserViewController viewController];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

@end
