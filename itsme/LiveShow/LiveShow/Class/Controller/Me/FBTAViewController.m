#import "FBContactsModel.h"
#import "FBProfileNetWorkManager.h"
#import "FBContactsCell.h"
#import "FBProfileHeaderView.h"
#import "FBTAViewController.h"
#import "FBWebViewController.h"
//#import "FBBlackListStatusModel.h"
#import "FBAvatarController.h"
#import "FBFailureView.h"
#import "FBRecordCell.h"
#import "FBLivePlayBackViewController.h"
#import "FBLivePlayViewController.h"
#import "FBLiveInfoModel.h"
#import "FBLoginInfoModel.h"
#import "FBLiveManager.h"
#import "FBLiveRoomViewController.h"
#import "UIScreen+Devices.h"
#import "MJRefresh.h"
#import "FBBindListModel.h"


#import <Accounts/Accounts.h>

#define kBottomHeight 50
#define kRowHeight 60
#define kReplayRowHeight 100

typedef enum : NSUInteger {
    /** 回放 */
    FBHeaderViewButtonReplay   = 1,
    /** 关注 */
    FBHeaderViewButtonFollow   = 2,
    /** 粉丝 */
    FBHeaderViewButtonFans     = 3
    
} FBHeaderViewButton;

static int replayCount = 20;

@interface FBTAViewController ()<FBContactsCellDelegate>
//用来记录关注和粉丝button的tag值 根据值加载数据源方法
@property (nonatomic, assign) long buttonTag;
//用来记录关注和粉丝button的选中状态
@property (nonatomic, weak) FBTwoLabelButton *selectedButton;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) FBFailureView *failureView;

@property (nonatomic, strong) NSMutableArray *fansArray;

@property (nonatomic, strong) NSMutableArray *followArray;

@property (nonatomic, strong) NSMutableArray *replayArray;

@property (nonatomic, strong) FBLiveInfoModel *liveInfoModel;
//用来记录底部关注状态
@property (nonatomic, weak) UIButton *followButton;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) UIButton *liveStatusButton;
////用来记录底部黑名单状态
//@property (nonatomic, copy) NSString *blackStatus;
//@property (nonatomic, weak) UIButton *blackButton;


@property (nonatomic, copy) NSString *twitterFollowStatus;

@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBTAViewController

#pragma mark - Life Cycle -

- (instancetype)initWithModel:(FBUserInfoModel *)userModel {
    if (self = [super init]) {
        
        self.headerView.userInfoModel = userModel;
        self.userID = userModel.userID;
    }
    return self;
}

-(void)dealloc
{
    [self removeObserNotification];
}

+ (instancetype)taViewController:(FBUserInfoModel *)userModel {
    return [[FBTAViewController alloc] initWithModel:userModel];
}

#pragma mark -Notification -
-(void)addObserNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationFollowSomebody:) name:kNotificationFollowSomebody object:nil];
}

-(void)removeObserNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)onNotificationFollowSomebody:(NSNotification*)notify
{
    FBUserInfoModel *user = notify.object;
    if([user.userID isEqualToString:self.userID]) {
        [_followButton setSelected:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self requestForLiveStatus];
    //每隔30秒刷一次直播状态
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(requestForLiveStatus) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    [self setupTableview];
    [self setupHeaderView];
    [self setupBottomView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
    //    [self blackListStatus];
    
    //第一次进入显示回放页面
    _buttonTag = FBHeaderViewButtonReplay;
    
    [self loadFansList];
    [self loadFollowingList];
    [self loadReplayList];
    [self followingStatus];
    [self setupLoadMore];

    [self clickThirdPartyFollowButton];
    [self clickReplayFollowingAndFansButton];
    [self clickProtraitButton];
    
    [self.tableView insertSubview:self.failureView belowSubview:self.tableView.tableHeaderView];
    
    [self addObserNotification];
}

#pragma mark - Getter & Setter -




- (FBFailureView *)failureView {
    if (!_failureView) {
        _failureView = [[FBFailureView alloc] initWithFrame:CGRectMake(0, self.headerViewHeight, SCREEN_WIDTH, SCREEN_HEIGH - self.headerViewHeight) image:kLogoFailureView message:kLocalizationDefaultContent];
        _failureView.hidden = YES;
    }
    return _failureView;
}


- (NSMutableArray *)followArray {
    if (!_followArray) {
        _followArray = [NSMutableArray array];
    }
    return _followArray;
}

- (NSMutableArray *)fansArray {
    if (!_fansArray) {
        _fansArray = [NSMutableArray array];
    }
    return _fansArray;
}

- (NSMutableArray *)replayArray {
    if (!_replayArray) {
        _replayArray = [NSMutableArray array];
    }
    return _replayArray;
}



- (NSString *)twitterFollowStatus {
    if (!_twitterFollowStatus) {
        _twitterFollowStatus = kLocalizationButtonFollow;
    }
    return _twitterFollowStatus;
}


- (void)setupHeaderView {
    self.headerView.defaultSelectedButton.selected = YES;
    self.selectedButton = self.headerView.defaultSelectedButton;
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 16, 40, 40)];
    [backButton setImage:[UIImage imageNamed:@"back_nor"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goToBackController) forControlEvents:UIControlEventTouchDown];
    [self.headerView addSubview:backButton];
    
    //直播状态按钮
    UIButton *liveStatusButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 76, 28, 59, 20)];
    [liveStatusButton addTarget:self action:@selector(clickLiveStatusButton) forControlEvents:UIControlEventTouchUpInside];
    [liveStatusButton setImage:[UIImage imageNamed:@"pub_icon_livestatus1"] forState:UIControlStateNormal];
    liveStatusButton.hidden = YES;
    [self.headerView addSubview:liveStatusButton];
    self.liveStatusButton = liveStatusButton;
    
}




- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH - kBottomHeight, SCREEN_WIDTH, kBottomHeight)];
        _bottomView.alpha = 0.9;
        
        //初始化渐变层
        CAGradientLayer *layer = [CAGradientLayer layer];
        layer.frame = _bottomView.bounds;
        [_bottomView.layer addSublayer:layer];
        
        //设置渐变颜色方向
        layer.startPoint = CGPointMake(0, 0);
        layer.endPoint = CGPointMake(1, 0);

        //设定颜色组
        layer.colors = @[(__bridge id)COLOR_MAIN.CGColor,(__bridge id) COLOR_ASSIST_BUTTON.CGColor];
        
        //设定颜色分割点
        layer.locations = @[@(0.5) ,@(1)];
        
    }
    return _bottomView;
}

#pragma mark - UI Management -
- (void)setupLoadMore {
    // 上拉加载
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (_buttonTag == FBHeaderViewButtonFans) {
            [self loadMoreFans];
        } else if (_buttonTag == FBHeaderViewButtonFollow) {
            [self loadMoreFollowing];
        } else if (_buttonTag == FBHeaderViewButtonReplay) {
            [self loadMoreReplayList];
        }
    }];
    self.tableView.mj_footer = footer;
    footer.automaticallyHidden = YES;
    // 设置多语言
    [footer setTitle:kLocalizationMoveUpLoadMore forState:MJRefreshStateIdle];
    [footer setTitle:kLocalizationReleadeRefresh forState:MJRefreshStatePulling];
    [footer setTitle:kLocalizationRefreshing forState:MJRefreshStateRefreshing];
}

- (void)setupTableview {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBContactsCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBContactsCell class])];
    [self.tableView registerClass:[FBRecordCell class] forCellReuseIdentifier:NSStringFromClass([FBRecordCell class])];
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, kBottomHeight, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.headerView;
    if ([self.userID isEqualToString:[FBLoginInfoModel sharedInstance].userID]) {
        _bottomView.hidden = YES;
    }
}

//底部半透明view
- (void)setupBottomView {
    int count = 1;
    CGFloat width = SCREEN_WIDTH / count;
    UIButton *followButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, kBottomHeight)];
    [followButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    _followButton = followButton;
    [followButton addTarget:self action:@selector(onClickBottomFollowButton:) forControlEvents:UIControlEventTouchDown];
    [self setupBottomViewButton:followButton title:kLocalizationButtonFollow selectedTitle:kLocalizationButtonFollowing imageName:@"ta_icon_add" selectedImage:@"ta_icon_true"];
    followButton.showsTouchWhenHighlighted = YES;
    [followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.left.equalTo(_bottomView);
    }];
    [self.view addSubview:self.bottomView];
}

- (void)setupBottomViewButton: (UIButton *)button title:(NSString *)title selectedTitle:(NSString *)selectedTitle imageName: (NSString *)imageName selectedImage:(NSString *)selectedImage {
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:selectedTitle forState:UIControlStateSelected];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.bottomView addSubview:button];
}
#pragma mark - Network Management -
- (void)requestForCheckTwitterFollowStatus {
    TWTRSessionStore *sessionStore = [Twitter sharedInstance].sessionStore;
    NSString *userID = sessionStore.session.userID;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:userID forKey:@"source_id"];
    [parameters setValue:self.twitterID forKey:@"target_id"];
    NSError *error = nil;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSURLRequest *request = [client URLRequestWithMethod:@"GET" URL:@"https://api.twitter.com/1.1/friendships/show.json" parameters:parameters error:&error];
    [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data.length) {
            NSDictionary *friendship = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&connectionError];
            NSNumber *followed_by = friendship[@"relationship"][@"target"][@"followed_by"];
            if ([followed_by isEqual:@(0)]) {
                self.twitterFollowStatus = kLocalizationButtonFollow;
            } else {
                self.twitterFollowStatus = kLocalizationButtonFollowing;
            }
        }
    }];
}


- (void)requestForFollowOthersTwitter {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.twitterID forKey:@"user_id"];
    [parameters setValue:@"true" forKey:@"follow"];
    NSError *error = nil;
    TWTRSessionStore *sessionStore = [Twitter sharedInstance].sessionStore;
    NSString *userID = sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:@"https://api.twitter.com/1.1/friendships/create.json" parameters:parameters error:&error];
    __weak typeof(self) weakSelf = self;
    [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
            [weakSelf requestForCheckTwitterFollowStatus];
        if (!connectionError) {
            [strongSelf st_reportClickFacebookTwitterFollowWithID:@"follow_click" result:@"1"];
        } else {
            [strongSelf st_reportClickFacebookTwitterFollowWithID:@"follow_click" result:@"0"];
        }
    }];
}

- (void)requestForUnFollowOthersTwitter {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:self.twitterID forKey:@"user_id"];
    NSError *error = nil;
    TWTRSessionStore *sessionStore = [Twitter sharedInstance].sessionStore;
    NSString *userID = sessionStore.session.userID;
    TWTRAPIClient *client = [[TWTRAPIClient alloc] initWithUserID:userID];
    NSURLRequest *request = [client URLRequestWithMethod:@"POST" URL:@"https://api.twitter.com/1.1/friendships/destroy.json" parameters:parameters error:&error];
    __weak typeof(self) weakSelf = self;
    [client sendTwitterRequest:request completion:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            [weakSelf requestForCheckTwitterFollowStatus];
    }];
}

- (void)requestForLiveStatus {
    __block UIButton *liveStatusButton = self.liveStatusButton;
        [[FBProfileNetWorkManager sharedInstance] getUserLiveStatusWithUserID:self.userID success:^(id result) {
            _liveInfoModel = [FBLiveInfoModel mj_objectWithKeyValues:result[@"live"]];
            NSString *liveStatus = _liveInfoModel.live_id;
            if ([liveStatus isValid]) {
                liveStatusButton.hidden = NO;
                NSMutableArray *imgArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"pub_icon_livestatus1"],[UIImage imageNamed:@"pub_icon_livestatus2"], nil];
                [liveStatusButton.imageView setAnimationImages:[imgArray copy]];
                [liveStatusButton.imageView setAnimationDuration:1];
                [liveStatusButton.imageView startAnimating];
            } else {
                liveStatusButton.hidden = YES;
            }
        } failure:nil finally:nil];
}


- (void)followingStatus {
    __block NSString *relation = nil;
    [[FBProfileNetWorkManager sharedInstance] getRelationWithUserID:self.userID success:^(id result) {
        relation = result[@"relation"];
        if ([relation isKindOfClass:[NSString class]]) {
            if ([relation isEqualToString:@"friend"] || [relation isEqualToString:@"following"]) {
                _followButton.selected = YES;
            } else {
                _followButton.selected = NO;
            }
        } else {
            _followButton.selected = NO;
        }
    } failure:nil finally:nil];
}

/** 屏蔽
- (void)removeFromBlackList {
    [[FBProfileNetWorkManager sharedInstance] removeFromBlackListWithUserID:_userID success:^(id result) {
    } failure:^(NSString *errorString) {
        return;
    } finally:^{
        _blackButton.selected = NO;
    }];
}


- (void)addToBlackList {
    [[FBProfileNetWorkManager sharedInstance] addToBlackListWithUserID:_userID success:^(id result) {
        NSLog(@"拉黑:%@",result);
    } failure:^(NSString *errorString) {
        NSLog(@"拉黑失败:%@",errorString);
        return;
    } finally:^{
        _blackButton.selected = YES;
    }];
}

- (void)blackListStatus {
    [[FBProfileNetWorkManager sharedInstance] blackListStatusWithUserIDArray:@[_userID] success:^(id result) {
        NSLog(@"result:%@",result[@"users"]);
        if (result[@"users"]) {
            NSArray *statusArray = [FBBlackListStatusModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
            if (statusArray.count > 0) {
                FBBlackListStatusModel *status = statusArray[0];
                _blackStatus = status.stat;
                NSLog(@"_blackstatus:%@",_blackStatus);
            }
        }
    } failure:^(NSString *errorString) {
        NSLog(@"读取黑名单状态出错:%@",errorString);
    } finally:^{
        _blackButton.selected = [_blackStatus isEqualToString:@"blacklist"];
    }];
}
*/
//
////关注和粉丝数量
//- (void)loadNumbersOfFollowAndFans {
//    __weak typeof(self) weakSelf = self;
//    [[FBProfileNetWorkManager sharedInstance] loadFollowNumberWithUserID:self.userID success:^(id result) {
//        
//        NSString *replayNum = [NSString stringWithFormat:@"%@",result[@"records"]];
//        
//        NSString *followNum = [NSString stringWithFormat:@"%@",[FBUtility changeNumberWith:result[@"num_followings"]]];
//        
//        NSString *fansNum = [NSString stringWithFormat:@"%@",[FBUtility changeNumberWith:result[@"num_followers"]]];
//
//        NSArray *numberArray = @[replayNum,followNum,fansNum];
//        
//        weakSelf.headerView.numberArray = numberArray;
//
//    } failure:nil finally:nil];
//}




//加载关注列表
- (void)loadFollowingList {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadFollowingListWithUserID:self.userID startRow:0 count:20 success:^(id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (result[@"users"]) {
            weakSelf.followArray = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        }
        [strongSelf.tableView reloadData];
    } failure:nil finally:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
}

- (void)loadMoreFollowing {
    __weak typeof(self) weakSelf = self;
        [[FBProfileNetWorkManager sharedInstance] loadFollowingListWithUserID:self.userID startRow:self.followArray.count count:20 success:^(id result) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [weakSelf.followArray addObjectsFromArray:[FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]]];
            [strongSelf.tableView reloadData];
        } failure:nil finally:^{
            [weakSelf.tableView.mj_footer endRefreshing];
        }];
}


- (void)loadReplayList {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadSomeoneRecordsWithUserID:self.userID Offset:0 count:replayCount success:^(id result) {
        replayCount += 20;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        weakSelf.replayArray = [FBRecordModel mj_objectArrayWithKeyValuesArray:result[@"records"]];
        for (FBRecordModel *model in weakSelf.replayArray) {
            model.user = self.headerView.userInfoModel;
        }
        [strongSelf.tableView reloadData];
    } failure:nil finally:^{
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

- (void)loadMoreReplayList {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadSomeoneRecordsWithUserID:self.userID Offset:replayCount count:20 success:^(id result) {
        replayCount += 20;
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [weakSelf.replayArray addObjectsFromArray:[FBRecordModel mj_objectArrayWithKeyValuesArray:result[@"records"]]];
        for (FBRecordModel *model in weakSelf.replayArray) {
            model.user = weakSelf.headerView.userInfoModel;
        }
        [strongSelf.tableView reloadData];
    } failure:nil finally:^(){
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}


//加载粉丝列表
- (void)loadFansList {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadFollowerListWithUserID:self.userID startRow:0 count:20 success:^(id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        weakSelf.fansArray = [FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        [strongSelf.tableView reloadData];
    } failure:nil finally:nil];
}


- (void)loadMoreFans {
    __weak typeof(self) weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] loadFollowerListWithUserID:self.userID startRow:self.fansArray.count count:20 success:^(id result) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [weakSelf.fansArray addObjectsFromArray:[FBContactsModel mj_objectArrayWithKeyValuesArray:result[@"users"]]];
        [strongSelf.tableView reloadData];
    } failure:nil finally:^{
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - override -
- (void)updateHeaderViewFrame {
    [super updateHeaderViewFrame];
    self.failureView.y = self.headerViewHeight;
}

#pragma mark - Event Handler -
- (void)clickLiveStatusButton{
    if([self.userID isEqualToString:[FBLoginInfoModel sharedInstance].userID]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    NSString* currentLiveID = [[FBLiveManager sharedInstance] currentLiveID];
    if([currentLiveID isEqualToString:self.liveInfoModel.live_id]) {
        UIViewController *vc = [[FBLiveManager sharedInstance] currentLiveController];
        if(vc.parentViewController && [vc.parentViewController isKindOfClass:[UIPageViewController class]]) {
            UIViewController *vcParent = vc.parentViewController.parentViewController;
            if([vcParent isKindOfClass:[FBLiveRoomViewController class]]) {
                [self.navigationController popToViewController:vcParent animated:YES];
            }
        } else {
            [self.navigationController popToViewController:vc animated:YES];
        }
    } else {
        FBLivePlayViewController *vc = [[FBLivePlayViewController alloc] initWithModel:self.liveInfoModel];
        vc.fromType = kLiveRoomFromTypeHomepage;
        [vc startPlay];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


//返回上一个控制器
- (void)goToBackController{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)clickThirdPartyFollowButton {
    NSString *loginType = [FBLoginInfoModel sharedInstance].loginType;
    __weak typeof(self) weakSelf = self;
    self.headerView.clickThirdPartyFollowButton = ^(NSString *platform){
        
        if ([platform isEqualToString:kPlatformFacebook]) {
            
            [weakSelf st_reportClickFacebookTwitterButtonWithID:@"fb_click"];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:nil
                                       cancelButtonTitle:kLocalizationPublicCancel
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:kLocalizationViewFacebookPage, nil];
            
            [sheet bk_setHandler:^{
                
                [weakSelf.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kPlatformFacebook url:[NSString stringWithFormat:@"%@%@", kFacebookURL,weakSelf.facebookID] formattedURL:NO] animated:YES];
                
                [weakSelf st_reportClickFacebookTwitterButtonWithID:@"fbviewpage_click"];
                
            } forButtonAtIndex:0];
            
            [sheet showInView:weakSelf.view];
        } else if ([platform isEqualToString:kPlatformTwitter]) {
            
            [weakSelf st_reportClickFacebookTwitterButtonWithID:@"tw_click"];
            
            UIActionSheet *sheet = nil;
            
            BOOL unbind = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsUnbindTwitter];
            if ([loginType isEqualToString:kPlatformTwitter] && !unbind) {
                sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:nil
                                           cancelButtonTitle:kLocalizationPublicCancel
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:self.twitterFollowStatus, kLocalizationViewTwitterkPage, nil];
                
                
                [sheet bk_setHandler:^{
                    
                    if ([weakSelf.twitterFollowStatus isEqualToString:kLocalizationButtonFollow]) {
                        [weakSelf requestForFollowOthersTwitter];
                    } else if ([weakSelf.twitterFollowStatus isEqualToString:kLocalizationButtonFollowing]){
                        [weakSelf requestForUnFollowOthersTwitter];
                    }
                } forButtonAtIndex:0];
                
                [sheet bk_setHandler:^{
                    [weakSelf.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kPlatformTwitter url:[NSString stringWithFormat:@"%@intent/user?user_id=%@",kTwitterURL,weakSelf.twitterID] formattedURL:NO] animated:YES];
                    
                    [weakSelf st_reportClickFacebookTwitterButtonWithID:@"twviewpage_click"];
                } forButtonAtIndex:1];
                
            } else {
                sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                    delegate:nil
                                           cancelButtonTitle:kLocalizationPublicCancel
                                      destructiveButtonTitle:nil
                                           otherButtonTitles:kLocalizationViewTwitterkPage, nil];
                
                [sheet bk_setHandler:^{
                    [weakSelf.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kPlatformTwitter url:[NSString stringWithFormat:@"%@intent/user?user_id=%@",kTwitterURL,weakSelf.twitterID] formattedURL:NO] animated:YES];
                    
                    [weakSelf st_reportClickFacebookTwitterButtonWithID:@"twviewpage_click"];
                } forButtonAtIndex:0];
            }
            
            [sheet showInView:weakSelf.view];
        }

    };
}


//点击头像
- (void)clickProtraitButton {
    __weak typeof(self) weakSelf = self;
    self.headerView.clickPortraitButton = ^(UIButton *protrait, NSString *imageName) {
        FBAvatarController *avatarController = [[FBAvatarController alloc] init];
        avatarController.imageName = imageName;
        avatarController.type = FBAvatarViewTypeSave;
        [weakSelf presentViewController:avatarController animated:YES completion:nil];
    };
}



//跳转粉丝和关注列表 回放的tag为1 关注2 粉丝3
- (void)clickReplayFollowingAndFansButton {
    __weak typeof(self) weakSelf = self;
    weakSelf.headerView.clickReplayFollowingFansButton = ^(FBTwoLabelButton *button) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        weakSelf.selectedButton.selected = NO;
        button.selected = YES;
        strongSelf.selectedButton = button;
        strongSelf.buttonTag = button.tag;
        [strongSelf.tableView reloadData];
    };

}

- (void)onClickBottomFollowButton:(UIButton *)button {
    if (button.selected == NO) {
        button.selected = YES;
        [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:self.userID success:^(id result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
        } failure:^(NSString *errorString){
            button.selected = NO;
        } finally:nil];
    } else {
        button.selected = NO;
        [[FBProfileNetWorkManager sharedInstance] removeFromFollowingListWithUserID:self.userID success:^(id result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
        } failure:^(NSString *errorString){
            button.selected = YES;
        } finally:nil];
    }
}

/*屏蔽
- (void)blackButtonDidClick:(UIButton *)button {
    if   (button.selected) {[self removeFromBlackList];}
    else {[self addToBlackList];}
}
*/

- (void)contactsCell:(FBContactsCell *)cell changeFollowStatus:(UIButton *)button {
    FBUserInfoModel *user = cell.contacts.user;
    if (button.selected == NO) {
        button.selected = YES;
        [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:user.userID success:^(id result) {
            //给cell赋值防止重用出错
            cell.contacts.relation = @"following";
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
        } failure:^(NSString *errorString) {
            button.selected = NO;
        } finally:nil];
    } else {
        button.selected = NO;
        [[FBProfileNetWorkManager sharedInstance] removeFromFollowingListWithUserID:user.userID success:^(id result) {
            //给cell赋值防止重用出错
            cell.contacts.relation = @"xxx";
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:self];
        } failure:^(NSString *errorString) {
            button.selected = YES;
        } finally:nil];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_buttonTag == FBHeaderViewButtonReplay) {
        self.failureView.hidden = self.replayArray.count == 0 ? NO : YES;
        return self.replayArray.count;
    } else if (_buttonTag == FBHeaderViewButtonFollow) {
        self.failureView.hidden = self.followArray.count == 0 ? NO : YES;
        return self.followArray.count;
    } else if (_buttonTag == FBHeaderViewButtonFans) {
        self.failureView.hidden = self.fansArray.count == 0 ? NO : YES;
        return self.fansArray.count;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_buttonTag == FBHeaderViewButtonFans) {
        FBContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContactsCell class]) forIndexPath:indexPath];
        [cell cellColorWithIndexPath:indexPath];
        cell.delegate = self;
        cell.contacts = [self.fansArray safe_objectAtIndex:indexPath.row];
        return cell;
    } else if (_buttonTag == FBHeaderViewButtonFollow) {
        FBContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBContactsCell class]) forIndexPath:indexPath];
        [cell cellColorWithIndexPath:indexPath];
        cell.delegate = self;
        cell.contacts = [self.followArray safe_objectAtIndex:indexPath.row];
        return cell;
    } else if (_buttonTag == FBHeaderViewButtonReplay){
        FBRecordCell *cell = (FBRecordCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBRecordCell class]) forIndexPath:indexPath];
        [cell cellColorWithIndexPath:indexPath];
        cell.model = [self.replayArray safe_objectAtIndex:indexPath.row];
        return cell;
    } else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_buttonTag == FBHeaderViewButtonReplay) {
        return kReplayRowHeight;
    } else {
        return kRowHeight;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_buttonTag == FBHeaderViewButtonFans ) {
        [self pushFansTaViewControllerWithIndexPath:indexPath];
    } else if (_buttonTag == FBHeaderViewButtonFollow) {
        [self pushFollowTaViewControllerWithIndexPath:indexPath];
    } else if (_buttonTag == FBHeaderViewButtonReplay){
        [self pushLivePlayBackViewControllerWithIndexPath:indexPath];
    } else {
        NSLog(@"_buttonTag= %ld",_buttonTag);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Navigaiton -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (void)pushFansTaViewControllerWithIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *cellModel = [self.fansArray safe_objectAtIndex:indexPath.row];
    FBTAViewController *taViewController = [[FBTAViewController alloc] initWithModel:cellModel.user];
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

- (void)pushFollowTaViewControllerWithIndexPath:(NSIndexPath *)indexPath {
    FBContactsModel *cellModel = [self.followArray safe_objectAtIndex:indexPath.row];
    FBTAViewController *taViewController = [[FBTAViewController alloc] initWithModel:cellModel.user];
    taViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:taViewController animated:YES];
}

- (void)pushLivePlayBackViewControllerWithIndexPath:(NSIndexPath *)indexPath {
    FBRecordModel *model = [self.replayArray safe_objectAtIndex:indexPath.row];
    FBLivePlayBackViewController* vc = [[FBLivePlayBackViewController alloc] initWithModel:model];
    vc.fromType = kLiveRoomFromTypeHomepage;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Statistics -
/* 每点击tw fb */
- (void)st_reportClickFacebookTwitterButtonWithID:(NSString *)ID {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:ID  eventParametersArray:@[eventParmeter1]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/* 每点击tw fb 关注 */
- (void)st_reportClickFacebookTwitterFollowWithID:(NSString *)ID  result:(NSString *)result {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:ID  eventParametersArray:@[eventParmeter1]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
