#import "FBFullScreenViewController.h"
#import "CNPPopupController.h"
#import "FBActivityView.h"
#import "FBWebViewController.h"
#import "FBLiveSquareNetworkManager.h"
#import "FBRoomActivityModel.h"
#import "FBActivityTextModel.h"
#import "FBActivityHelper.h"

@interface FBFullScreenViewController () < UITableViewDelegate,UITableViewDataSource, CNPPopupControllerDelegate, FBActivityViewDelegate>

@property (nonatomic) NJKScrollFullScreen *scrollProxy;

/** 活动按钮 */
@property (strong, nonatomic) UIButton *activityButton;

/** 活动弹框视图 */
@property (nonatomic, strong) CNPPopupController *popupController;

/** 活动数据 */
@property (strong, nonatomic) FBRoomActivityModel *activityModel;

@property (strong, nonatomic) FBActivityTextModel *modelText;

@property (strong, nonatomic) NSMutableArray *imageArray;

@property (strong, nonatomic) NSMutableArray *textArray;

@end

@implementation FBFullScreenViewController

#pragma mark - Liye cycle -
- (void)dealloc {
    self.tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configScrollFullScreen];
    [self configureUserInterface];
    [self requestForActivityData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestForActivityData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_scrollProxy reset];
    [self showNavigationBar:animated];
    [self showTabBar:animated];
}

#pragma mark - UI Management -
- (void)configureUserInterface {
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.activityButton];
    [self.activityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(78, 72));
        make.right.equalTo(self.view).offset(-5);
        make.bottom.equalTo(self.view).offset(-55);
        
    }];
}

- (void)configScrollFullScreen {
    _scrollProxy = [[NJKScrollFullScreen alloc] initWithForwardTarget:self];
    self.tableView.delegate = (id)_scrollProxy;
    _scrollProxy.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetBars) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)resetBars {
    [_scrollProxy reset];
    [self showNavigationBar:NO];
    [self showTabBar:NO];
}

#pragma mark - Getter and Setter -
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UIButton *)activityButton {
    if (!_activityButton) {
        _activityButton = [[UIButton alloc] init];
        _activityButton.hidden = YES;
        [_activityButton addTarget:self action:@selector(onTouchButtonActivity) forControlEvents:UIControlEventTouchUpInside];
    }
    return _activityButton;
}

- (FBRoomActivityModel *)activityModel {
    if (!_activityModel) {
        _activityModel = [[FBRoomActivityModel alloc] init];
    }
    return _activityModel;
}

- (FBActivityTextModel *)modelText {
    if (!_modelText) {
        _modelText = [[FBActivityTextModel alloc] init];
    }
    return _modelText;
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    return _imageArray;
}

- (NSMutableArray *)textArray {
    if (!_textArray) {
        _textArray = [[NSMutableArray alloc] init];
    }
    return _textArray;
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

- (void)updateButtonUI {
    self.activityButton.hidden = NO;
    if (self.imageArray.count > 0) {
        NSMutableArray *imgArray = [[NSMutableArray alloc] init];
        for (int i = 1; i < self.imageArray.count; i ++) {
            [imgArray addObject:[UIImage imageWithContentsOfFile:self.imageArray[i]]];
        }
        [self.activityButton setImage:imgArray[1] forState:UIControlStateNormal];
        [self.activityButton.imageView setAnimationImages:[imgArray copy]];
        [self.activityButton.imageView setAnimationDuration:0.4];
        [self.activityButton.imageView startAnimating];
    }
}

#pragma mark - Data Management -
/** 配置活动数据 */
- (void)configActivityData:(id)data{
    [self.imageArray removeAllObjects];
    self.activityModel = [FBRoomActivityModel mj_objectWithKeyValues:data];
}

#pragma mark - Network Management -
/** 加载活动数据 */
- (void)requestForActivityData {
    [[FBLiveSquareNetworkManager sharedInstance] loadRoomActivitySuccess:^(id result) {
        NSLog(@"result %@", result);
        if (result && result[@"activity"]) {
            NSInteger code = [result[@"dm_error"] integerValue];
            if (0 == code) {
                [self configActivityData:result[@"activity"]];
                [self unZipActivityFile];
            }
        }
        
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 加载活动入口是否被点击的请求 */
- (void)requestForClickActivity{
    [[FBLiveSquareNetworkManager sharedInstance] loadClickActivitySuccess:^(id result) {
        NSLog(@"result %@", result);
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            self.activityButton.hidden = YES;
        }
        
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

#pragma mark - Event Handler -
- (void)onTouchButtonActivity{
    [self popActivityView];
    [self requestForClickActivity];
}

#pragma mark - Helper -
/** 弹出活动视图卡片 */
- (void)popActivityView {
    FBActivityView *view = [[FBActivityView alloc] initWithFrame:CGRectMake(0, 0, 300, 280)];
    view.activitydDelegate = self;
    view.title.text = self.modelText.halloweentips1;
    view.detail.text = self.modelText.halloweentips2;
    UIImage *image = [UIImage imageWithContentsOfFile:self.imageArray[0]];
    view.icon.image = image;
    
    view.doCancelCallback = ^ (void) {
        [self.popupController dismissPopupControllerAnimated:YES];
    };
    
    [self configureCardView:view];
}

// 解压返回的活动压缩包
- (void)unZipActivityFile {
    [FBActivityHelper downloadZipFileForActivity:self.activityModel.img_bag completionBlock:^{
        NSArray *imageFiles = [FBActivityHelper filesWithActivity:self.activityModel.img_bag];
        [self.imageArray addObjectsFromArray:imageFiles];
        NSDictionary *dict = [FBActivityHelper filesWithActivityText:self.activityModel.img_bag];
        for (NSDictionary *dic in dict[@"result"]) {
            FBActivityTextModel *model =[FBActivityTextModel mj_objectWithKeyValues:dic];
            [self.textArray addObject:model];
        }
        
        // 活动入口按钮图片更新
        [self updateButtonUI];
        
        // 存放活动文本
        for (FBActivityTextModel *textModel in self.textArray) {
            FBActivityTextModel *enText = [[FBActivityTextModel alloc] init];
            if ([textModel.lang containsString:@"en"]) {
                enText = textModel;
            }
            if ([textModel.lang containsString:[FBUtility shortPreferredLanguage]]) {
                self.modelText = textModel;
                return;
            } else {
                // 如果该IP地区有活动，翻译里面没有该手机的语言就默认显示英文翻译的文案
                self.modelText = enText;
            }
        }
        
    }];
}

#pragma mark - Navigation -
/** 进入活动详情界面 */
- (void)pushWebViewControllerWithBanner:(NSString *)url AndTitle:(NSString *)title {
    FBWebViewController *nextViewController = [[FBWebViewController alloc] initWithTitle:title url:url formattedURL:YES];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

#pragma mark - UITableViewDataSource -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - FBActivityViewDelegate -
- (void)clickIntroduceButton {
    [self pushWebViewControllerWithBanner:self.activityModel.url AndTitle:@"Introduction"];
}

- (void)clickSureButton {
    NSLog(@"点击了确定按钮");
}

#pragma mark - CNPPopupController Delegate
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}

#pragma mark - NJKScrollFullScreenDelegate -
- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollUp:(CGFloat)deltaY {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self moveNavigationBar:deltaY animated:YES];
        [self moveTabBar:-deltaY animated:YES];
    }
}

- (void)scrollFullScreen:(NJKScrollFullScreen *)proxy scrollViewDidScrollDown:(CGFloat)deltaY {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self moveNavigationBar:deltaY animated:YES];
        [self moveTabBar:-deltaY animated:YES];
    }
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollUp:(NJKScrollFullScreen *)proxy {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self hideNavigationBar:YES];
        [self hideTabBar:YES];
    }
}

- (void)scrollFullScreenScrollViewDidEndDraggingScrollDown:(NJKScrollFullScreen *)proxy {
    if (![self isContentHeightTooShortToLayoutUIBars]) {
        [self showNavigationBar:YES];
        [self showTabBar:YES];
    }
}

#pragma mark - Helper -
- (BOOL)isContentHeightTooShortToLayoutUIBars {
    BOOL isContentHeightTooShortToLayoutUIBars = (self.tableView.contentSize.height-self.tableView.contentInset.bottom < self.tableView.frame.size.height);
    return isContentHeightTooShortToLayoutUIBars;
}

@end
