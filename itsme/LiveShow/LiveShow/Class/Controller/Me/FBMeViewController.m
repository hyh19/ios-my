#import "FBLoginInfoModel.h"
#import "FBMeViewController.h"
#import "FBAvatarController.h"
#import "FBEditProfileViewController.h"
#import "FBMyFollowViewController.h"
#import "FBMyFollowerViewController.h"
#import "FBReplayViewController.h"
#import "FBSettingViewController.h"
#import "FBNormalCell.h"
#import "FBFeedBackViewController.h"
#import "FBAvatarGuideView.h"
#import "FBProfileHeaderView.h"
#import "FBBindListModel.h"
#import "FBStoreContainerViewController.h"
#import "FBWebViewController.h"
#import "FBTipAndGuideManager.h"

#define kRowHeight 55
#define kSectionHeight 10

/** 设置item的标记 */
typedef NS_ENUM(NSUInteger, FBMeViewItemTag) {
    /** 编辑资料*/
    FBMeViewItemTagEdit,
    /** 充值 */
    FBMeViewItemTagCharge,
    /** 等级 */
    FBMeViewItemTagLevel,
    /** 反馈 */
    FBMeViewItemTagFeedback,
    /** 设置 */
    FBMeViewItemTagSetting,
};


@interface FBMeViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, assign) NSTimeInterval enterTime;

@end

@implementation FBMeViewController

#pragma mark - Init -

#pragma mark - Life Cycle -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    [self setupTableView];

    [self clickReplayFollowingAndFansButton];
    [self clickProtraitButton];
    [self clickThirdPartyFollowButton];

    NSUInteger count = [FBTipAndGuideManager countInUserDefaultsWithType:kGuideChangeAvatar];
    if (0 == count) {
        [self displayGuideView];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Getter & Setter -
- (NSString *)userID {
    return [[FBLoginInfoModel sharedInstance] userID];
}

- (NSMutableArray *)data {
    if (!_data) {
        NSDictionary *edit     = @{
                                   @"name" : kLocalizationLabelEdit,
                                   @"icon" : [UIImage imageNamed:@"me_icon_edit"],
                                   @"tag"  : @(FBMeViewItemTagEdit)};
        NSDictionary *charge   = @{
                                   @"name" : kLocalizationLabelProfit,
                                   @"icon" : [UIImage imageNamed:@"me_icon_charge"],
                                   @"tag"  : @(FBMeViewItemTagCharge)};
        NSDictionary *level  = @{
                                   @"name" : kLocalizationLabelLevel,
                                   @"icon" : [UIImage imageNamed:@"me_icon_level"],
                                   @"tag"  : @(FBMeViewItemTagLevel)};
        NSDictionary *feedback = @{
                                   @"name" : kLocalizationLabelFeedBack,
                                   @"icon" : [UIImage imageNamed:@"me_icon_feedback"],
                                   @"tag"  : @(FBMeViewItemTagFeedback)};
        NSDictionary *setting  = @{
                                   @"name" : kLocalizationLabelSetting,
                                   @"icon" : [UIImage imageNamed:@"me_icon_setting"],
                                   @"tag"  : @(FBMeViewItemTagSetting)};

        _data = [NSMutableArray arrayWithObjects:edit, charge, level, feedback, setting, nil];
    }
    
    return _data;
}


#pragma mark - UI Management -
- (void)setupTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([FBNormalCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([FBNormalCell class])];
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.headerView;
    
    self.tableView.backgroundColor = COLOR_BACKGROUND_APP;
    self.headerView.userInfoModel = [FBLoginInfoModel sharedInstance].user;
    self.headerView.bottomLineView.hidden = YES;
    
    [self updateHeaderViewFrame];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.userInteractionEnabled = NO;
}

#pragma mark - Network Management -

#pragma mark - Event Handler -
- (void)clickReplayFollowingAndFansButton {
    __weak typeof(self) weakSelf = self;
    self.headerView.clickReplayFollowingFansButton = ^(FBTwoLabelButton *button) {
        if (button.tag == 1) {
            [weakSelf pushReplayViewController];
        } else if (button.tag == 2){
            [weakSelf pushFollowViewController];
        } else {
            [weakSelf pushFansViewController];
        }
    };

}

- (void)clickThirdPartyFollowButton {
    __weak typeof(self) weakSelf = self;
    self.headerView.clickThirdPartyFollowButton = ^(NSString *platform){
        
        if ([platform isEqualToString:kPlatformFacebook]) {
            
            [weakSelf st_reportClickEventWithID:@"fb_click"];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:nil
                                                      cancelButtonTitle:kLocalizationPublicCancel
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:kLocalizationViewFacebookPage, nil];
            
            
            
            [sheet bk_setHandler:^{
                [weakSelf.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kPlatformFacebook url:[NSString stringWithFormat:@"%@%@",kFacebookURL,weakSelf.facebookID]  formattedURL:NO] animated:YES];
                
                [weakSelf st_reportClickEventWithID:@"fbviewpage_click"];
                
            } forButtonAtIndex:0];
       
            [sheet showInView:weakSelf.view];
            
        } else if ([platform isEqualToString:kPlatformTwitter]) {
            
            [weakSelf st_reportClickEventWithID:@"tw_click"];
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:kLocalizationPublicCancel destructiveButtonTitle:nil otherButtonTitles:kLocalizationViewTwitterkPage, nil];
            
            [sheet bk_setHandler:^{
                [weakSelf.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kPlatformTwitter url:[NSString stringWithFormat:@"%@intent/user?user_id=%@",kTwitterURL, weakSelf.twitterID] formattedURL:NO] animated:YES];
                
                [weakSelf st_reportClickEventWithID:@"twviewpage_click"];
            } forButtonAtIndex:0];
            
            [sheet showInView:weakSelf.view];
        }
    };
}


//修改头像
- (void)clickProtraitButton {
    __weak typeof(self) weakSelf = self;
    
    self.headerView.clickPortraitButton = ^(UIButton *protrait, NSString *imageName) {
        FBAvatarController *avatarController = [[FBAvatarController alloc] init];
        avatarController.imageName = imageName;
        avatarController.type = FBAvatarViewTypeEdit;
        [weakSelf presentViewController:avatarController animated:YES completion:nil];
    };
}

#pragma mark - Navigation -

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (void)pushReplayViewController {
    FBReplayViewController *replay = [[FBReplayViewController alloc] init];
    replay.user = self.headerView.userInfoModel;
    replay.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:replay animated:YES];
}

- (void)pushFollowViewController {
    FBMyFollowViewController *followController = [[FBMyFollowViewController alloc] init];
    followController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:followController animated:YES];
}

- (void)pushFansViewController {
    FBMyFollowerViewController *followerController = [[FBMyFollowerViewController alloc] init];
    followerController.hidesBottomBarWhenPushed= YES;
    [self.navigationController pushViewController:followerController animated:YES];
}


#pragma mark - UITableViewDataSource -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FBNormalCell class]) forIndexPath:indexPath];
    cell.name.text = self.data[indexPath.row][@"name"];
    cell.icon.image = self.data[indexPath.row][@"icon"];
    cell.levelLabel.text = [NSString stringWithFormat:@"LV.%@",self.headerView.userInfoModel.ulevel];
    cell.levelLabel.hidden = ![cell.name.text isEqualToString:kLocalizationLabelLevel];
    return cell;
}
#pragma mark - UITableViewDelegate -

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

//隐藏最后一个cell底部的线
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    FBNormalCell *normalCell = (FBNormalCell *)cell;
    if (indexPath.row == self.data.count - 1) {
        normalCell.bottomLineView.hidden = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.data[indexPath.row];
    NSUInteger tag = [dict[@"tag"] integerValue];
    switch (tag) {
        case FBMeViewItemTagEdit:
            [self.navigationController pushViewController:[[FBEditProfileViewController alloc] initWithUserInfo:[FBLoginInfoModel sharedInstance].user] animated:YES];
            break;
        case FBMeViewItemTagCharge: {
            FBStoreContainerViewController *viewController = [FBStoreContainerViewController pushMeToNavigationController:self.navigationController];
            viewController.statisticsInfo[@"from"] = @(3);
            break;
        }
            
        case FBMeViewItemTagLevel:
            [self.navigationController pushViewController:[[FBWebViewController alloc] initWithTitle:kLocalizationLabelLevel url:kProfileLiveLevelURL formattedURL:YES] animated:YES];
            [self st_reportClickEventWithID:@"main_home_level_click"];
            break;
            
        case FBMeViewItemTagFeedback:
            [self.navigationController pushViewController:[FBFeedBackViewController feedBackViewController] animated:YES];
            break;

        case FBMeViewItemTagSetting:
            [self.navigationController pushViewController:[FBSettingViewController settingViewController] animated:YES];
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionHeight;
}

#pragma mark - 更换头像引导页 -
- (void)photoAciton: (UIImagePickerControllerSourceType ) sourceType {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.allowsEditing = YES;
    pickerController.sourceType = sourceType;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.3);
    [self showHUDWithTip:kLocalizationLoading delay:0 autoHide:NO];
    [[FBProfileNetWorkManager sharedInstance] updateUserPortrait:imageData constructingBody:^(id formData) {
        [formData appendPartWithFileData:imageData name:@"portrait" fileName:@"user_head_photo.jpg" mimeType:@"image/jpeg"];
    } success:^(id result) {
        [self showHUDWithTip:kLocalizationSuccessfully delay:2 autoHide:YES];
    } failure:^(NSString *errorString) {
        [self showHUDWithTip:kLocalizationError delay:2 autoHide:YES];
    } finally:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateProfile object:self];
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    }];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self displayGuideView];
}

- (void)showHUDWithTip:(NSString *)tip delay:(NSTimeInterval)delay autoHide:(BOOL)isAutoHide{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = tip;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    if (isAutoHide) {
        [hud hide:YES afterDelay:delay];
    }
}

- (void)displayGuideView {
    FBAvatarGuideView *avatarView = [[FBAvatarGuideView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH)];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:avatarView];
    avatarView.takePhoto = ^(){
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            return ;
        }
        [self photoAciton:UIImagePickerControllerSourceTypeCamera];
    };
    avatarView.selectPhoto = ^(){
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            return ;
        }
        [self photoAciton:UIImagePickerControllerSourceTypePhotoLibrary];
    };

    [FBTipAndGuideManager addCountInUserDefaultsWithType:kGuideChangeAvatar];
}

#pragma mark - Statistics - 
/* 点击事件打点 */
- (void)st_reportClickEventWithID:(NSString *)ID {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:ID  eventParametersArray:@[eventParmeter1]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
