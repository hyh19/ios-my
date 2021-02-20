#import "ZWBaseWebViewController.h"
#import "ALView+PureLayout.h"
#import "ZWUtility.h"
#import "UIButton+Block.h"
#import "KxMenu.h"

/**
 *  @author 黄玉辉->陈梦杉
 *  @ingroup view
 *  @brief 网页控制器底部工具栏
 */
@interface ZWWebToolBar : UIView

@end

@interface ZWWebToolBar ()

/** 后退按钮 */
@property (nonatomic, strong) UIButton *backwardButton;

/** 前进按钮 */
@property (nonatomic, strong) UIButton *forwardButton;

/** 刷新按钮 */
@property (nonatomic, strong) UIButton *refreshButton;

/** 记录是否已经完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation ZWWebToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backwardButton];
        [self addSubview:self.forwardButton];
        [self addSubview:self.refreshButton];
    }
    return self;
}

- (UIButton *)backwardButton {
    if (!_backwardButton) {
        _backwardButton = [UIButton newAutoLayoutView];
        UIImage *image = [UIImage imageNamed:@"btn_backward_normal"];
        [_backwardButton setImage:image forState:UIControlStateNormal];
        image = [UIImage imageNamed:@"btn_backward_disabled"];
        [_backwardButton setImage:image forState:UIControlStateDisabled];
    }
    return _backwardButton;
}

- (UIButton *)forwardButton {
    if (!_forwardButton) {
        _forwardButton = [UIButton newAutoLayoutView];
        UIImage *image = [UIImage imageNamed:@"btn_forward_normal"];
        [_forwardButton setImage:image forState:UIControlStateNormal];
        image = [UIImage imageNamed:@"btn_forward_disabled"];
        [_forwardButton setImage:image forState:UIControlStateDisabled];
    }
    return _forwardButton;
}

- (UIButton *)refreshButton {
    if (!_refreshButton) {
        _refreshButton = [UIButton newAutoLayoutView];
        UIImage *image = [UIImage imageNamed:@"btn_refresh_normal"];
        [_refreshButton setImage:image forState:UIControlStateNormal];
    }
    return _refreshButton;
}

- (void)updateConstraints {
    
    if (!self.didSetupConstraints) {
        
        CGSize size = CGSizeMake(30, 30);
        
        [self.backwardButton autoSetDimensionsToSize:size];
        [self.backwardButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:18];
        [self.backwardButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        [self.forwardButton autoSetDimensionsToSize:size];
        [self.forwardButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.backwardButton withOffset:15];
        [self.forwardButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        [self.refreshButton autoSetDimensionsToSize:size];
        [self.refreshButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20];
        [self.refreshButton autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        
        self.didSetupConstraints = YES;
    }
    [super updateConstraints];
}

@end

@interface ZWBaseWebViewController () <UIWebViewDelegate>

/** 网页地址 */
@property (nonatomic, strong) NSURL *URL;

/** 菜单按钮 */
@property (nonatomic, strong) UIButton *menuButton;

/** 关闭按钮 */
@property (nonatomic, strong) UIButton *closeButton;

/** Web view */
@property (nonatomic, strong, readwrite) UIWebView *webView;

/** 工具栏 */
@property (nonatomic, strong) ZWWebToolBar *toolBar;

/** 是否完成自动适配 */
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation ZWBaseWebViewController

- (instancetype)initWithURLString:(NSString *)URLString {
    if (self = [super init]) {
        self.URL = [NSURL URLWithString:URLString];
    }
    return self;
}

#pragma mark - Getter & Setter -
- (UIButton *)closeButton {
    if (!_closeButton) {
        UIImage *image = [UIImage imageNamed:@"btn_close"];
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [_closeButton setImage:image forState:UIControlStateNormal];
        [_closeButton setImage:image forState:UIControlStateHighlighted];
        __weak typeof(self) weakSelf = self;
        [_closeButton addAction:^(UIButton *btn) {
            [weakSelf close];
        }];
    }
    return _closeButton;
}

- (UIButton *)menuButton {
    if (!_menuButton) {
        UIImage *image = [UIImage imageNamed:@"comment_bar_more"];
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.frame = CGRectMake(0, 0, image.size.width+22, image.size.height);
        [_menuButton setImage:image forState:UIControlStateNormal];
        [_menuButton setImage:image forState:UIControlStateHighlighted];
        _menuButton.contentMode = UIViewContentModeScaleAspectFill;
        __weak typeof(self) weakSelf = self;
        [_menuButton addAction:^(UIButton *btn) {
            [weakSelf showActionMenu];
        }];
    }
    return _menuButton;
}

- (ZWWebToolBar *)toolBar {
    if (!_toolBar) {
        _toolBar = [ZWWebToolBar newAutoLayoutView];
    }
    return _toolBar;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [UIWebView newAutoLayoutView];
        _webView.scalesPageToFit = YES;
        _webView.delegate = self;
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (![ZWUtility networkAvailable]) {
        occasionalHint(@"网络不给力哦");
    }
    [self setupLeftBarButtonItem:self.closeButton rightBarButtonItem:self.menuButton];
    [self addEventHandlers];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadView {
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.toolBar];
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.webView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        
        [self.toolBar autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.webView];
        [self.toolBar autoSetDimension:ALDimensionHeight toSize:39];
        [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.toolBar autoPinEdgeToSuperviewEdge:ALEdgeBottom];
        
        self.didSetupConstraints = YES;
    }
    [super updateViewConstraints];
}

#pragma mark - Event handler -
/** 添加工具栏事件 */
- (void)addEventHandlers {
    __weak typeof(self) weakSelf = self;
    [self.toolBar.backwardButton addAction:^(UIButton *btn) {
        if ([weakSelf.webView canGoBack]) {
            [weakSelf.webView goBack];
        }
    }];
    
    [self.toolBar.forwardButton addAction:^(UIButton *btn) {
        if ([weakSelf.webView canGoForward]) {
            [weakSelf.webView goForward];
        }
    }];
    
    [self.toolBar.refreshButton addAction:^(UIButton *btn) {
        [weakSelf.webView reload];
    }];
}
/** 显示下拉菜单 */
- (void)showActionMenu {
    
    NSArray *menuItems = @[
      [KxMenuItem menuItem:@"分享"
                     image:nil
                    target:self
                    action:@selector(onTouchMenuItemShare)],
      
      [KxMenuItem menuItem:@"用浏览器打开"
                     image:nil
                    target:self
                    action:@selector(onTouchMenuItemOpenInSafari)],
      ];
    
    for (KxMenuItem *subItem in menuItems) {
        subItem.foreColor = [UIColor colorWithHexString:@"#adadad"];
        subItem.alignment = NSTextAlignmentLeft;
    }
    [KxMenu showMenuInView:self.view
                  fromRect:CGRectMake(SCREEN_WIDTH-38, 0, 40, 0)
                 menuItems:menuItems];
}

/** 点击分享菜单项 */
- (void)onTouchMenuItemShare {
    [self share];
}

/** 点击在浏览器打开菜单项 */
- (void)onTouchMenuItemOpenInSafari {
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

- (void)share {
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWebViewDelegate -
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.toolBar.backwardButton.enabled = [webView canGoBack];
    self.toolBar.forwardButton.enabled = [webView canGoForward];
}

@end


