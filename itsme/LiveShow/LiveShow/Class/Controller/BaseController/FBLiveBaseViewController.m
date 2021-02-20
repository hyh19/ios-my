#import "FBLiveBaseViewController.h"
#import "FBLiveRoomNetworkManager.h"

#import "FBMsgPacketHelper.h"
#import "FBMsgService.h"

#import "FBGAIManager.h"
#import "CWStatusBarNotification.h"
#import "FBTAViewController.h"
#import "FBLiveStreamNetworkManager.h"
#import "Line.h"
#import "VKSDK.h"
#import "NSTimer+Addition.h"
#import "FBStoreContainerViewController.h"

#import "FBGetDiamondsView.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import "FBLiveActivityModel.h"
#import "FBRoomActivityModel.h"
#import "FBActivityHelper.h"

#import "FBContributeListViewController.h"

static NSArray *SCOPE = nil;

@interface FBLiveBaseViewController ()<VKSdkUIDelegate, VKSdkDelegate>

/** 拉取观众列表定时器*/
@property (nonatomic, strong) NSTimer *loadUsersTimer;

/** 拉取观众失败重试次数 */
@property (nonatomic) NSInteger requestUsersCount;

/** 送礼物的开始时间，用于统计 */
@property (nonatomic) NSTimeInterval sendGiftBegin;

@property (strong, nonatomic) FBRoomActivityModel *activityModel;


@end

@implementation FBLiveBaseViewController

- (void)dealloc {
    [self removeNotificationObservers];
    [self removeTimers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //暂停下载礼物动画包
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSuspendGiftZipTask object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotificationObservers];
    [self addTimers];
    self.requestUsersCount = 0;
    self.exitRoom = NO;
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    
    [self requestForActivityData];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //恢复下载礼物动画包
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationResumeGiftZipTask object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestForReporting:(FBReportModel *)model {
    [self displayNotificationWithMessage:kLocalizationReportUser forDuration:2];
    [[FBLiveRoomNetworkManager sharedInstance] sendReportWithUserID:model.userID liveID:model.liveID type:model.type message:model.message success:^(id result) {
        //
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

#pragma mark - Getter & Setter -
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"pub_icon_close"] forState:UIControlStateNormal];
        __weak typeof(self) wself = self;
        [_closeButton bk_addEventHandler:^(id sender) {
            [wself onTouchButtonClose];
            
        } forControlEvents:UIControlEventTouchUpInside];
        [_closeButton debugWithBorderColor:[UIColor redColor]];
    }
    return _closeButton;
}

- (NSMutableArray *)liveUsers {
    if (!_liveUsers) {
        _liveUsers = [NSMutableArray array];
    }
    return _liveUsers;
}

- (void)setUserCount:(NSUInteger)userCount {
    _userCount = userCount;
    [self.infoContainer.contentView updateUserCount:self.userCount];
}

- (FBBroadcastInfoContainerView *)infoContainer {
    if (!_infoContainer) {
        _infoContainer = [[FBBroadcastInfoContainerView alloc] initWithFrame:self.view.bounds type:self.liveType];
        _infoContainer.contentView.broadcaster = self.broadcaster;
        _infoContainer.contentView.liveID = self.liveID;
        _infoContainer.contentView.liveViewController = self;
        __weak typeof(self) wself = self;
        _infoContainer.contentView.doSendMessageAction = ^ (NSString *message, FBMessageType type) {
            [wself doSendMessageAction:message type:type];
        };
        
        _infoContainer.contentView.doSendLikeAction = ^ (UIColor *color) {
            [wself doSendLikeAction:color];
        };
        
        _infoContainer.contentView.doSendHitAction = ^ (UIColor *color) {
            [wself doSendHitAction:color];
        };
        
        _infoContainer.contentView.doSendGiftAction = ^ (FBGiftModel *gift) {
            [wself doSendGiftAction:gift];
        };
        
        _infoContainer.contentView.doPurchaseAction = ^ (void) {
            [wself pushPurchaseViewControllerWithActionTag:1];
            [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_GIFT_STATITICS action:@"充值" label:[[FBLoginInfoModel sharedInstance] userID] value:@(1)];
        };
        
        _infoContainer.contentView.doGoContributeAction = ^ (void) {
            [wself doGoContributeAction:wself.broadcaster];
        };
        
        _infoContainer.contentView.doShareLiveAction = ^ (NSString *platform, FBShareLiveAction action) {
            [wself doShareLiveAction:platform action:action];

        };
        
        _infoContainer.contentView.doGoHomepageAction = ^ (FBUserInfoModel *user) {
            [wself doGoHomepageAction:user];
        };
        
        _infoContainer.contentView.doGoFansContributionpageAction = ^ (FBUserInfoModel *user) {
            [wself doGoFansContributionpageAction:user];
        };
        
        _infoContainer.contentView.doReportAction = ^ (FBUserInfoModel *user) {
            [wself doReportAction:user];
        };
        
        _infoContainer.contentView.doManagerAction = ^ (FBUserInfoModel *user) {
            [wself doManagerAction:user];
        };
        
        _infoContainer.contentView.doSendActivityGiftAction = ^ (void) {
            [wself doSendActivityGift];
        };
        
    }
    return _infoContainer;
}

- (AMPopTip *)popTip {
    if (!_popTip) {
        _popTip = [AMPopTip popTip];
        _popTip.shouldDismissOnTap = YES;
        _popTip.shouldDismissOnTapOutside = YES;
    }
    return _popTip;
}

- (FBRoomActivityModel *)activityModel {
    if (!_activityModel) {
        _activityModel = [[FBRoomActivityModel alloc] init];
    }
    return _activityModel;
}

#pragma mark - 发频道相关消息
/** 普通消息 */
-(void)sendMsg:(NSString*)msg withSubType:(NSInteger)subType
{
    NSString* packString = [FBMsgPacketHelper packRoomMsg:msg from:[FBLoginInfoModel sharedInstance].user withSubType:subType];
    [[FBMsgService sharedInstance] sendRoomMessage:packString];
}

-(void)sendBullet:(NSString*)msg withTransactionId:(NSString*)transaction_id
{
    NSString *packString = [FBMsgPacketHelper packBulletMsg:msg from:[FBLoginInfoModel sharedInstance].user withTransactionId:transaction_id];
    [[FBMsgService sharedInstance] sendBulletMessage:packString];
}

/** 点亮 */
-(void)sendFirstHit:(UIColor*)color
{
    NSString* packString = [FBMsgPacketHelper packFirstHitMsgFrom:[FBLoginInfoModel sharedInstance].user color:color];
    [[FBMsgService sharedInstance] sendFirstHitMessage:packString];
}

/** 点赞 */
-(void)sendLike:(UIColor*)color
{
    NSString* packString = [FBMsgPacketHelper packLikeMsgFrom:[FBLoginInfoModel sharedInstance].user color:color];
    [[FBMsgService sharedInstance] sendLikeMessage:packString];
}

- (void)sendGift:(FBGiftModel *)gift withTransactionId:(NSString*)transaction_id {
    NSString* packString = [FBMsgPacketHelper packGiftMsgFrom:[FBLoginInfoModel sharedInstance].user to:gift.toUser gift:gift giftCount:1 withTransactionId:transaction_id];
    [[FBMsgService sharedInstance] sendGiftMessage:packString];
    
    NSString* giftID = [NSString stringWithFormat:@"gift_%@", gift.giftID];
    
    
    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_GIFT_STATITICS action:@"送礼" label:giftID value:@(1)];
    

     [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_GIFT_STATITICS action:@"赠送礼物" label:[[FBLoginInfoModel sharedInstance] userID] value:@(1)];
}

- (void)broadcastDiamondCount:(NSInteger)count
{
    NSString* packString = [FBMsgPacketHelper packDiamondTotalCountMessage:count form:[FBLoginInfoModel sharedInstance].user];
    [[FBMsgService sharedInstance] sendDiamondTotalCountMessage:packString];
}

- (void)shareLiveWithPlatform:(NSString *)platform liveID:(NSString *)liveID broadcaster:(FBUserInfoModel *)broadcaster action:(FBShareLiveAction)action {
    
    __weak typeof(self) wself = self;
    NSString *sharedURLString = kURLShare(broadcaster.userID, liveID, [[FBLoginInfoModel sharedInstance] userID]);
    
    NSString *sharedTitle = [NSString stringWithFormat:kLocalizationShareDesc, broadcaster.nick];
    
    //twitter  line  vk 分享用这个
    NSString *shareText = [NSString stringWithFormat:kLocalizationShareText,broadcaster.nick];
    
    // Facebook
    if (platform.isEqualTo(kPlatformFacebook)) {
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:sharedURLString];
        NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@", kRequestURLImageScale, broadcaster.portrait];
        content.imageURL = [NSURL URLWithString:imageURLString];
        content.contentTitle = sharedTitle;
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.mode = FBSDKShareDialogModeAutomatic;
        dialog.delegate = self;
        dialog.shareContent = content;
        dialog.fromViewController = self;
        [dialog show];
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                             action:@"分享到facebook"
                                              label:[[FBLoginInfoModel sharedInstance] userID]
                                              value:@(1)];
        wself.statisticsInfo[@"st_shareLiveAction"] = @(action);

        // Twitter
    } else if (platform.isEqualTo(kPlatformTwitter)) {
        
        UIImageView *avatarView = [[UIImageView alloc] init];
        NSString *imageURLString = [NSString stringWithFormat:@"%@?url=%@&w=%f&h=%f", kRequestURLImageScale, broadcaster.portrait, SCREEN_WIDTH, SCREEN_WIDTH];
        [avatarView sd_setImageWithURL:[NSURL URLWithString:imageURLString]
                      placeholderImage:kDefaultImageAvatar
                               options:SDWebImageRetryFailed
                              progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                  NSLog(@"下载进度：%f", (double)receivedSize / expectedSize);
                              }
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 NSLog(@"----图片加载完毕---%@", image);
                                 
                                 TWTRComposer *composer = [[TWTRComposer alloc] init];
                                 [composer setText:shareText];
                                 [composer setImage:avatarView.image];
                                 [composer setURL:[NSURL URLWithString:sharedURLString]];
                                 
                                 if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                                     [composer showFromViewController:wself completion:^(TWTRComposerResult result) {
                                         NSString *st_result = @"0";
                                         if (result == TWTRComposerResultCancelled) {
                                             st_result = @"1";
                                         } else {
                                             st_result = @"2";
                                             NSString *message = [NSString stringWithFormat:kLocalizationShareLive, @""];
                                             [wself doSendMessageAction:message type:kMessageTypeShare];
                                             [self showShareResultHUD:YES];
                                             [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                                                     action:@"分享成功twitter"
                                                                                      label:[[FBLoginInfoModel sharedInstance] userID]
                                                                                      value:@(1)];
                                             
                                             [self shareGainGoldWithPlatform:kPlatformTwitter];
                                             
                                             // 每成功分享直播＋1
                                             [self st_reportShareLiveEventWithPlatform:kPlatformTwitter];
                                             
                                         }
                                         if (kShareLiveActionClickLiveRoomMenu == action) {
                                             // 每选择分享弹窗中的任何一项＋1（李世杰）
                                             [wself st_reportClickShareMenuWithShareType:@"2" result:st_result];
                                         }
                                     }];
                                     [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                                             action:@"分享到twitter"
                                                                              label:[[FBLoginInfoModel sharedInstance] userID]
                                                                              value:@(1)];
                                 } else {
                                     GBDeviceModel model = [GBDeviceInfo deviceInfo].model;
                                     if (model == GBDeviceModeliPhone7 || model == GBDeviceModeliPhone7Plus) {
                                         [UIAlertView bk_showAlertViewWithTitle:kLocalizationTwitterTitle message:kLocalizationTwitterDetail cancelButtonTitle:kLocalizationPublicConfirm otherButtonTitles:nil handler:nil];
                                     }
                                 }
                             }];
        
    } else if ([platform isEqualToString:kPlatformLine]) {
        if ([Line isLineInstalled]) {
            NSString *lineShareText = [NSString stringWithFormat:@"%@\n%@",shareText,sharedURLString];
            [Line shareText:lineShareText];
        } else {
            [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationPleaseInstallLine cancelButtonTitle:kLocalizationPublicConfirm otherButtonTitles:nil handler:nil];
        }
        if (kShareLiveActionClickLiveRoomMenu == action) {
            // 每选择分享弹窗中的任何一项＋1（李世杰）
            [wself st_reportClickShareMenuWithShareType:@"Line" result:@"2"];
        }
        
        // 每成功分享直播＋1
        [self st_reportShareLiveEventWithPlatform:kPlatformLine];
        
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                             action:@"分享到line"
                                              label:[[FBLoginInfoModel sharedInstance] userID]
                                              value:@(1)];
    } else if ([platform isEqualToString:kPlatformVK]) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                             action:@"分享到vk"
                                              label:[[FBLoginInfoModel sharedInstance] userID]
                                              value:@(1)];
        
        SCOPE = @[VK_PER_FRIENDS, VK_PER_PHOTOS, VK_PER_EMAIL, VK_PER_OFFLINE];
        [[VKSdk initializeWithAppId:@"5435576"] registerDelegate:self];
        [[VKSdk instance] setUiDelegate:self];
        
        VKShareDialogController *shareDialog = [VKShareDialogController new];
        shareDialog.text = @"VK share";
        
        shareDialog.uploadImages = @[[VKUploadImage uploadImageWithImage:broadcaster.avatarImage
                                                               andParams:[VKImageParameters jpegImageWithQuality:1.0]]];
        
        shareDialog.shareLink = [[VKShareLink alloc] initWithTitle:shareText link:[NSURL URLWithString:sharedURLString]];
        
        [shareDialog setCompletionHandler:^(VKShareDialogController *dialog, VKShareDialogControllerResult result) {
            
            if (VKShareDialogControllerResultDone == result) {
                
                NSString *message = [NSString stringWithFormat:kLocalizationShareLive, @""];
                [wself doSendMessageAction:message type:kMessageTypeShare];
                [self showShareResultHUD:YES];
                [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                        action:@"分享成功vk"
                                                         label:[[FBLoginInfoModel sharedInstance] userID]
                                                         value:@(1)];
                
                [self shareGainGoldWithPlatform:kPlatformVK];
                
                // 每成功分享直播＋1
                [self st_reportShareLiveEventWithPlatform:kPlatformVK];
                
            } else if (VKShareDialogControllerResultCancelled == result) {
                //
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            
            if (kShareLiveActionClickLiveRoomMenu == action) {
                NSString *st_result = @"0";
                if (VKShareDialogControllerResultDone == result) {
                    st_result = @"2";
                } else if (VKShareDialogControllerResultCancelled == result) {
                    st_result = @"1";
                }
                // 每选择分享弹窗中的任何一项＋1（李世杰）
                [wself st_reportClickShareMenuWithShareType:@"VK" result:st_result];
            }
        
        }];
        [self presentViewController:shareDialog animated:YES completion:nil];
        
    } else if ([platform isEqualToString:kPlatformKakao]) {
        if ([KOAppCall canOpenKakaoTalkAppLink]) {
            KakaoTalkLinkObject *label = [KakaoTalkLinkObject createLabel:shareText];
            KakaoTalkLinkObject *image = [KakaoTalkLinkObject createImage:[NSString stringWithFormat:@"%@?url=%@", kRequestURLImageScale, broadcaster.portrait] width:138 height:80];
            KakaoTalkLinkObject *webLink = [KakaoTalkLinkObject createWebLink:sharedTitle url:sharedURLString];
            
            [KOAppCall openKakaoTalkAppLink:@[label, image, webLink]];
            [wself st_reportClickShareMenuWithShareType:@"5" result:@"2"];
            
            // 每成功分享直播＋1
            [self st_reportShareLiveEventWithPlatform:kPlatformKakao];
            
        } else {
            [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationPleaseInstallKakao cancelButtonTitle:kLocalizationPublicConfirm otherButtonTitles:nil handler:nil];
            [wself st_reportClickShareMenuWithShareType:@"5" result:@"1"];
        }
    }
}

- (void)pushUserViewController:(FBUserInfoModel *)user {
    FBTAViewController *nextViewController = [[FBTAViewController alloc] initWithModel:user];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (void)pushContributeListViewController:(FBUserInfoModel *)user {
    __weak typeof(self) weakSelf = self;
    [FBContributeListViewController pushMeToNavigationController:weakSelf.navigationController withUser:user];
}

- (void)pushPurchaseViewControllerWithActionTag:(NSInteger)tag {
    UINavigationController *navigationController = self.navigationController;
    // 在上下滑动切换房间的模式下
    if (self.parentViewController && [self.parentViewController isKindOfClass:[UIPageViewController class]]) {
        navigationController = self.parentViewController.parentViewController.navigationController;
    }

    FBStoreContainerViewController *viewController = [FBStoreContainerViewController pushMeToNavigationController:navigationController];
    // tag = 1 点“充值”按钮，tag = 2 点充值对话框的“确认”按钮
    viewController.statisticsInfo[@"from"] = @(tag);
    viewController.statisticsInfo[@"host_id"] = self.broadcaster.userID;
    viewController.statisticsInfo[@"broadcast_id"] = self.liveID;
}

- (void)onTouchButtonClose {
    
}

- (void)addNotificationObservers {
    
    __weak typeof(self) wself = self;
    
    // 打开礼物键盘
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenGiftKeyboard
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [wself onNotificationOpenGiftKeyboard:note];
                                                  }];
    
    // 关闭礼物键盘
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationCloseGiftKeyboard
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [wself onNotificationCloseGiftKeyboard:note];
                                                  }];
    
    // 打开分享菜单
//    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenShareMenu object:nil queue:nil usingBlock:^(NSNotification *note) {
//        [wself onNotificationOpenShareMenu:note];
//    }];
//    
    // 关闭分享菜单
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationCloseShareMenu object:nil queue:nil usingBlock:^(NSNotification *note) {
        [wself onNotificationCloseShareMenu:note];
    }];
    
    // 显示粉丝贡献榜
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationShowFansView object:nil queue:nil usingBlock:^(NSNotification *note) {
        [wself onNotificationShowFansView:note];
    }];
    
    // 隐藏粉丝贡献榜
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationHideFansView object:nil queue:nil usingBlock:^(NSNotification *note) {
        [wself onNotificationHideFansView:note];
    }];
    
    // 关注了某个主播
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationFollowSomebody
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      FBUserInfoModel *user = note.object;
                                                      if (user.userID.isEqualTo(wself.broadcaster.userID)) {
                                                          NSString *message = [NSString stringWithFormat:@"%@ %@", kLocalizationButtonFollowing, user.nick];
                                                          [wself doSendMessageAction:message type:kMessageTypeFollow];
                                                          
                                                          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                                          [defaults setValue:@"follow" forKey:kUserDefaultsEnableFollow];
                                                          [defaults synchronize];
                                                      }
                                                  }];
    
    ///-----------------------------------------------------------------------------
    /// 统计打点要监听的广播通知
    ///-----------------------------------------------------------------------------
    if (kLiveTypePlay == self.liveType ||
        kLiveTypeReplay == self.liveType) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStatisticsFollowBroadcaster
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          // 主播ID self.broadcaster.userID
                                                          // 直播ID self.liveID
                                                          // 直播类型 self.liveType
                                                          // 进入直播间的时间戳 self.enterTime
                                                          NSString *broadcasterID = note.userInfo[@"host_id"];
                                                          NSNumber *from = note.userInfo[@"from"];

                                                          if (broadcasterID.isEqualTo(wself.broadcaster.userID)) {
                                                              // 每在直播间关注主播＋1（黄玉辉）
                                                              [wself st_reportFollowEventWithFrom:from];
                                                          }
                                                      }];
        
        
    }
    
    if (kLiveTypePlay == self.liveType ||
        kLiveTypeReplay == self.liveType) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStatisticsClickChatButton
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          // 主播ID self.broadcaster.userID
                                                          // 直播ID self.liveID
                                                          // 直播类型 self.liveType
                                                          // 进入直播间的时间戳 self.enterTime
                                                          NSString *broadcasterID = note.userInfo[@"host_id"];
                                                          NSNumber *isBullet = note.userInfo[@"is_bullet"];
                                                          
                                                          
                                                          if (broadcasterID.isEqualTo(wself.broadcaster.userID)) {
                                                              // 每点击发送评论按钮＋1（黄玉辉）
                                                              [wself st_reportClickChatButtonEventWithIsBullet:isBullet];
                                                          }
                                                      }];
        
        
    }
    
    if (kLiveTypePlay == self.liveType ||
        kLiveTypeReplay == self.liveType) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStatisticsClickShareButton
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          // 主播ID self.broadcaster.userID
                                                          // 直播ID self.liveID
                                                          // 直播类型 self.liveType
                                                          // 进入直播间的时间戳 self.enterTime
                                                          NSTimeInterval time = ([[NSDate date] timeIntervalSince1970] - wself.enterTime) * 1000;
                                                          NSString *broadcasterID = note.userInfo[@"host_id"];
                                                          BOOL followed = wself.infoContainer.contentView.followedBroadcaster;
                                                          if (broadcasterID.isEqualTo(wself.broadcaster.userID)) {
                                                              // 每点击分享图标＋1（黄玉辉）
                                                              [wself st_reportClickShareButtonEventWithFollowed:followed time:time];
                                                          }
                                                      }];
        
        
    }
    
    if (kLiveTypePlay == self.liveType ||
        kLiveTypeReplay == self.liveType) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStatisticsClickGiftButton
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          // 主播ID self.broadcaster.userID
                                                          // 直播ID self.liveID
                                                          // 直播类型 self.liveType
                                                          // 进入直播间的时间戳 self.enterTime
                                                          // 当前剩余的钻石数 [[FBLoginInfoModel sharedInstance] balance]
                                                          NSString *broadcasterID = note.userInfo[@"host_id"];
                                                          if (broadcasterID.isEqualTo(wself.broadcaster.userID)) {
                                                              // 每点击礼物盒＋1（黄玉辉）
                                                              [wself st_reportClickGiftButtonEvent];
                                                          }
                                                      }];
        
        
    }
    
    if (kLiveTypePlay == self.liveType ||
        kLiveTypeReplay == self.liveType) {
        [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationStatisticsClickSendGiftButton
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification *note) {
                                                          // 主播ID self.broadcaster.userID
                                                          // 直播ID self.liveID
                                                          // 直播类型 self.liveType
                                                          // 进入直播间的时间戳 self.enterTime
                                                          // 当前剩余的钻石数 [[FBLoginInfoModel sharedInstance] balance]
                                                          NSString *broadcasterID = note.userInfo[@"host_id"];
                                                          NSString *giftID = [NSString stringWithFormat:@"%@",note.userInfo[@"gift_id"]]; // 礼物ID
                                                          NSString *giftDiamonds = [NSString stringWithFormat:@"%@",note.userInfo[@"gift_diamonds"]];; // 礼物需要的钻石数
                                                          NSString *sufficient = [NSString stringWithFormat:@"%@",note.userInfo[@"sufficient"]]; // 余额是否充足
                                                        
                                                          if (broadcasterID.isEqualTo(wself.broadcaster.userID)) {
                                                              // 每点击礼物盒的发送按钮＋1（黄玉辉）
                                                              [wself st_reportClickSendGiftButtonEventWithGiftID:giftID giftDiamonds:giftDiamonds sufficient:sufficient];
                                                          }
                                                      }];
        
        
    }
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addTimers {
    
}

- (void)removeTimers {
    if (self.loadUsersTimer) {
        [self.loadUsersTimer invalidate];
        self.loadUsersTimer = nil;
    }
}

- (void)removePlayTimers {
    if (self.playTimeTimer) {
        [self.playTimeTimer invalidate];
        self.playTimeTimer = nil;
    }
}

- (void)onNotificationOpenShareMenu:(NSNotification *)note {
    self.closeButton.hidden = YES;
}

- (void)onNotificationCloseShareMenu:(NSNotification *)note {
    self.closeButton.hidden = NO;
}

- (void)onNotificationOpenGiftKeyboard:(NSNotification *)note {
    self.closeButton.hidden = YES;
}

- (void)onNotificationCloseGiftKeyboard:(NSNotification *)note {
    self.closeButton.hidden = NO;
}

- (void)onNotificationShowFansView:(NSNotification *)note {
    self.closeButton.hidden = YES;
}

- (void)onNotificationHideFansView:(NSNotification *)note {
    self.closeButton.hidden = NO;
}

- (void)doSendMessageAction:(NSString *)message type:(FBMessageType)type {
    if(kMessageTypeDanmu == type) {
        [self requestForSendingDanmu:message];
    } else {
        NSInteger subType = kMsgSubTypeNormal;
        switch (type) {
            case kMessageTypeDefault:
                subType = kMsgSubTypeNormal;
                break;
            case kMessageTypeFollow:
                subType = kMsgSubTypeFollow;
                break;
            case kMessageTypeShare:
                subType = kMsgSubTypeShare;
                break;
            default:
                break;
        }
        
        [self sendMsg:message withSubType:subType];
        // 发送消息直接在本地回显
        FBMessageModel *model = [[FBMessageModel alloc] init];
        model.fromUser = [[FBLoginInfoModel sharedInstance] user];
        model.content = message;
        model.type = type;
        [self.infoContainer.contentView receiveMessage:model];
    }
}

- (void)doSendGiftAction:(FBGiftModel *)gift {
    [self requestForSendingGift:gift];
}

- (void)doSendLikeAction:(UIColor *)color {
    if (kLiveTypeBroadcast != self.liveType) {
        [self sendLike:color];
    }
}
- (void)doSendHitAction:(UIColor *)color {
    if (kLiveTypeBroadcast != self.liveType) {
        [self sendFirstHit:color];
    }
}
- (void)doShareLiveAction:(NSString *)platform action:(FBShareLiveAction)action {
    [self shareLiveWithPlatform:platform liveID:self.liveID broadcaster:self.broadcaster action:action];
}

- (void)doGoHomepageAction:(FBUserInfoModel *)user {
    [self pushUserViewController:user];
}

- (void)doGoFansContributionpageAction:(FBUserInfoModel *)user {
    [self pushContributeListViewController:user];
}

- (void)doGoContributeAction:(FBUserInfoModel *)user {
    
}

- (void)doReportAction:(FBUserInfoModel *)user {
    FBReportModel *report = [[FBReportModel alloc] init];
    [self requestForReporting:report];
}

- (void)doManagerAction:(FBUserInfoModel *)user {
    
}

- (void)doSendActivityGift {
    NSLog(@"送了一个活动礼物");
    [self requestForSendActivityGift];
}

/** 监控观众列表 */
- (void)monitorLiveUsers {
    // 先请求一次数据，以后十秒更新一次
    [self requestForLiveUsers];
}

#pragma mark - Data Management -
/** 处理返回的观众数据 */
- (void)configUsers:(NSArray *)users {
    if (self.userCount > 50) {
        for (FBUserInfoModel *user in users) {
            // 已经在观众列表里的用户不重新添加
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID = %@", user.userID];
            NSArray *array = [self.liveUsers filteredArrayUsingPredicate:predicate];
            if ([array count] > 0) {
                //
            } else {
                [self.liveUsers safe_addObject:user];
            }
        }
    } else {
        [self.liveUsers removeAllObjects];
        [self.liveUsers safe_addObjectsFromArray:users];
    }
    
    // 处理异常情况
    if (self.userCount > 0) {
        if ([self.liveUsers count] <= 0) {
            // 观众总数大于0，但是观众列表没有数据，把观众总数修改为0
            self.userCount = 0;
        }
    } else {
        if ([self.liveUsers count] > 0) {
            // 观众总数等于0，但是观众列表有数据，把观众总数修改为列表内的实际观众数
            self.userCount = [self.liveUsers count];
        }
    }
    
    // 手动把当前登录用户调整到观众列表的首位
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userID = %@", [[FBLoginInfoModel sharedInstance] userID]];
        NSArray *array = [self.liveUsers filteredArrayUsingPredicate:predicate];
        if ([array count] > 0) {
            [self.liveUsers safe_removeObjectsInArray:array];
        } else {
            self.userCount += 1;
        }
        [self.liveUsers safe_insertObject:[[FBLoginInfoModel sharedInstance] user] atIndex:0];
    }
    
    // 观众数变动的回调函数
    [self onUserNumberChanged:self.userCount];

    /**
     *  @since 2.0.0
     *  @brief 观众按等级排序
     */
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"ulevel" ascending:NO];
    NSArray *sortedArray = [self.liveUsers sortedArrayUsingDescriptors:@[sortDescriptor]];
    self.liveUsers = [NSMutableArray arrayWithArray:sortedArray];
}

#pragma mark - Network Management -
/** 请求观众列表 */
- (void)requestForLiveUsers {
    __weak typeof(self) wself = self;
    NSInteger offset = 0;
    if (self.userCount > 50) {
        // 减去登录用户自己
        offset = [self.liveUsers count]-1;
        if (offset < 0) { offset = 0; }
    }
    [[FBLiveStreamNetworkManager sharedInstance] loadUsersWithLiveID:[self.liveID longLongValue] offset:offset count:50 success:^(id result) {
        NSInteger count = [result[@"total"] integerValue];
        NSArray *users = [FBUserInfoModel mj_objectArrayWithKeyValuesArray:result[@"users"]];
        // 更新观众总数
        wself.userCount = count;

        // 更新观众列表
        [wself configUsers:users];
        
        // 重载观众列表
        [wself.infoContainer.contentView reloadUsers:self.liveUsers];
        
        // 成功拉取数据则开启定时刷新
        [self addTimerForUpdatingUsers];
        
    } failure:^(NSString *errorString) {
        // 拉取失败重试三次
        if (wself.requestUsersCount < 3) {
            if (!self.loadUsersTimer) {
                [wself requestForLiveUsers];
                wself.requestUsersCount += 1;
            }
        } else {
            [self addTimerForUpdatingUsers];
        }
    } finally:^{
        //
    }];
}

- (void)requestForSendingDanmu:(NSString *)content {
    __weak typeof(self) wself = self;
    FBGiftModel *danmu = [FBGiftModel mj_objectWithKeyValues:[GVUserDefaults standardUserDefaults].danmuInfo];
    [[FBLiveRoomNetworkManager sharedInstance] sendGiftToUser:0 withGiftID:danmu.giftID count:1 liveID:[wself.liveID longLongValue] success:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        // dm_error状态码为0时表示送礼成功，13表示余额不足
        if (0 == code) {
            // 送礼的交易ID
            id transactionID = result[@"transaction_id"];
            // 广播弹幕通知
            if (transactionID) {
                [self sendBullet:content withTransactionId:[transactionID stringValue]];
            } else {
                [self sendBullet:content withTransactionId:@"0"];
            }
            
            // 观众发弹幕在客户端本地从钻石余额中扣除
            [wself.infoContainer.contentView.giftKeyboard deductBalance:[danmu.gold integerValue]];
            
            // 发送消息直接在本地回显
            FBMessageModel *message = [[FBMessageModel alloc] init];
            message.fromUser = [[FBLoginInfoModel sharedInstance] user];
            message.content = content;
            message.type = kMessageTypeDanmu;
            [self.infoContainer.contentView receiveMessage:message];
        } else if (13 == code) {
            [wself showAlertCharge];
        }
    } failure:^(NSString *errorString) {
        [self displayNotificationWithMessage:errorString forDuration:2];
    } finally:^{
        //
    }];
}

- (void)requestForSendingGift:(FBGiftModel *)gift {
    __weak typeof(self) wself = self;
    self.sendGiftBegin = [[NSDate date] timeIntervalSince1970];
    [[FBLiveRoomNetworkManager sharedInstance] sendGiftToUser:self.broadcaster.userID withGiftID:gift.giftID count:1 liveID:[self.liveID longLongValue] success:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        // dm_error状态码为0时表示送礼成功，13表示余额不足
        if (0 == code) {

            [self doSendGiftSuccessfullyCallback:result gift:gift updateBalanceBlock:^(NSInteger diamondCount) {
                // 观众送出的钻石数在客户端本地从钻石余额中扣除
                [wself.infoContainer.contentView.giftKeyboard deductBalance:diamondCount];
                
                // 广播通知向服务器请求更新当前登录用户的钻石余额（当前用户是观众）
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateBalance object:nil];
            }];
            
            // 统计送礼时长
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            NSTimeInterval interval = now * 1000 - self.sendGiftBegin * 1000;
            [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_GIFT_STATITICS action:@"送礼时长" label:[[FBLoginInfoModel sharedInstance] userID] value:@(interval)];
            
            // 统计送礼结果
            NSString* giftID = [NSString stringWithFormat:@"gift_%@", gift.giftID];
            [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_GIFT_STATITICS action:@"送礼" label:giftID value:@(1)];
            [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_GIFT_STATITICS action:@"礼物类型" label:giftID value:@(1)];
            [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_GIFT_STATITICS action:@"赠送成功" label:[[FBLoginInfoModel sharedInstance] userID] value:@(1)];
            
            // 在直播间的观看时长
            NSTimeInterval liveTime = ([[NSDate date] timeIntervalSince1970] - self.enterTime) * 1000;
            // 每送出礼物成功/失败＋1（黄玉辉）
            [self st_reportSendGiftResultEventWithFollowed:self.infoContainer.contentView.followedBroadcaster time:liveTime result:@"1" diamondFrom:@"0"];
        } else if (13 == code) {
            [wself showAlertCharge];
            // 每送出礼物成功/失败＋1（黄玉辉）
            // 在直播间的观看时长
            NSTimeInterval liveTime = ([[NSDate date] timeIntervalSince1970] - self.enterTime) * 1000;
            [self st_reportSendGiftResultEventWithFollowed:self.infoContainer.contentView.followedBroadcaster time:liveTime result:@"0" diamondFrom:@"0"];
        }
    } failure:^(NSString *errorString) {
        [self displayNotificationWithMessage:errorString forDuration:2];
        // 每送出礼物成功/失败＋1（黄玉辉）
        // 在直播间的观看时长
        NSTimeInterval liveTime = ([[NSDate date] timeIntervalSince1970] - self.enterTime) * 1000;
        [self st_reportSendGiftResultEventWithFollowed:self.infoContainer.contentView.followedBroadcaster time:liveTime result:@"0" diamondFrom:@"0"];
    } finally:^{
        //
    }];
}

- (void)requestForFreezingTalk:(FBUserInfoModel *)user {
    [[FBLiveTalkNetworkManager sharedInstance] freezeTalkWithUserID:user.userID liveID:self.liveID success:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            user.isTalkBanned = YES;
        } else if (503 == code) {// 自己不是管理员
            [self displayNotificationWithMessage:kLocalizationBeUnauthorized forDuration:2];
        } else if (504 == code) {// 对方是管理员
            //
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 加载活动数据 */
- (void)requestForActivityData {
    [[FBLiveRoomNetworkManager sharedInstance] loadLiveActivitySuccess:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            self.infoContainer.contentView.activityButton.hidden = NO;
            FBLiveActivityModel *model = [FBLiveActivityModel mj_objectWithKeyValues:result];
            self.activityModel = [FBRoomActivityModel mj_objectWithKeyValues:result[@"activity"]];
            
            [FBActivityHelper downloadZipFileForActivity:self.activityModel.img_bag_live completionBlock:^{
                NSArray *imageFiles = [FBActivityHelper filesWithActivity:self.activityModel.img_bag_live];
                if (imageFiles.count > 0) {
                    UIImage *image1 = [UIImage imageWithContentsOfFile:imageFiles[0]];
                    UIImage *image2 = [UIImage imageWithContentsOfFile:imageFiles[1]];
                    
                    [self.infoContainer.contentView.activityButton setImage:image1 forState:UIControlStateNormal];
                    [self.infoContainer.contentView.activityButton setImage:image2 forState:UIControlStateHighlighted];
                    self.infoContainer.contentView.activityGiftNum.text = [NSString stringWithFormat:@"x%@", model.num];
                }
            }];
            
        }
    
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}


//活动礼物送礼请求
- (void)requestForSendActivityGift {
    __weak typeof(self) weakSelf = self;
    //获取对应的活动礼物模型
    NSArray *giftJson = [[GVUserDefaults standardUserDefaults] giftList];
    NSArray *giftArray = [FBGiftModel mj_objectArrayWithKeyValuesArray:giftJson];
    FBGiftModel *activityGiftModel = nil;
    for (FBGiftModel *gift in giftArray) {
        if ([gift.giftID isEqual:self.activityModel.gid]) {
            activityGiftModel = gift;
            break;
        }
    }
    
    if (!activityGiftModel) {
        return;
    }
    
    [[FBLiveRoomNetworkManager sharedInstance] loadActivitySendGiftToUser:self.broadcaster.userID withGiftID:self.activityModel.gid count:1 liveID:[self.liveID longLongValue] Success:^(id result) {

        NSInteger code = [result[@"dm_error"] integerValue];

        if (0 == code) {
            
            [self doSendGiftSuccessfullyCallback:result gift:activityGiftModel updateBalanceBlock:nil];
        }
        
        //刷新南瓜数据
        [weakSelf requestForActivityData];
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

// 成功送礼后的回调
- (void)doSendGiftSuccessfullyCallback:(id)result gift:(FBGiftModel *)giftModel updateBalanceBlock:(void(^)(NSInteger diamondCount))updateBlock{
    
    self.sendGiftCount += 1;
    
    __weak typeof(self) wself = self;
    
    id transactionID = result[@"transaction_id"];
    
    // 广播送礼通知
    if (transactionID) {
        [wself sendGift:giftModel withTransactionId:[transactionID stringValue]];
    } else {
        [wself sendGift:giftModel withTransactionId:@""];
    }
    
    // 发送礼物的动画直接在本地回显
    giftModel.fromUser = [[FBLoginInfoModel sharedInstance] user];
    giftModel.toUser = wself.broadcaster;
    [wself.infoContainer.contentView receiveGift:giftModel];
    
    // 发送礼物的消息直接在本地回显
    NSString *message = [NSString stringWithFormat:@"%@ %@", kLocalizationSendGift, giftModel.name];
    FBMessageModel *model = [[FBMessageModel alloc] init];
    model.fromUser = [[FBLoginInfoModel sharedInstance] user];
    model.content = message;
    model.type = kMessageTypeGift;
    [wself.infoContainer.contentView receiveMessage:model];
    
    
    if (NO == DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED) {
        
        NSInteger diamondCount = [giftModel.gold integerValue];
        
        // 主播收到的钻石数在客户端本地增加到收到的钻石总额
        [wself.infoContainer.contentView addDiamondCount:diamondCount];
        
        // 用户更新钻石余额
        if (updateBlock) {
            updateBlock(diamondCount);
        }
    }
}

#pragma mark - Event Handler -
- (void)showGainGold:(NSInteger)golds
{
    [FBGetDiamondsView showInView:self.view withDaimonds:golds];
}

- (void)banUserTalk:(FBUserInfoModel *)user {
    [self requestForFreezingTalk:user];
}

- (void)unbanUserTalk:(FBUserInfoModel *)user {
    
}

/** 定时刷新观众列表 */
- (void)addTimerForUpdatingUsers {
    if (!self.exitRoom) {
        if(!self.loadUsersTimer) {
            __weak typeof(self) wself = self;
            self.loadUsersTimer = [NSTimer bk_scheduledTimerWithTimeInterval:10 block:^(NSTimer *timer) {
                [wself requestForLiveUsers];
            } repeats:YES];
        }
    }
}

#pragma mark - FBSDKSharingDelegate -
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    if (results[@"postId"]) {
        NSString *message = [NSString stringWithFormat:kLocalizationShareLive, @""];
        [self doSendMessageAction:message type:kMessageTypeShare];
        [self showShareResultHUD:YES];
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS action:@"分享成功facebook" label:[[FBLoginInfoModel sharedInstance] userID] value:@(1)];
        
        NSInteger action = [self.statisticsInfo[@"st_shareLiveAction"] integerValue];
        if (action == kShareLiveActionClickLiveRoomMenu) {
            // 每选择分享弹窗中的任何一项＋1（李世杰）
            [self st_reportClickShareMenuWithShareType:@"1" result:@"2"];
        }
        
        [self shareGainGoldWithPlatform:kPlatformFacebook];
        
        // 每成功分享直播＋1
        [self st_reportShareLiveEventWithPlatform:kPlatformFacebook];
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    [self showShareResultHUD:NO];
    NSInteger action = [self.statisticsInfo[@"st_shareLiveAction"] integerValue];
    if (action == kShareLiveActionClickLiveRoomMenu) {
        // 每选择分享弹窗中的任何一项＋1（李世杰）
        [self st_reportClickShareMenuWithShareType:@"1" result:@"0"];
    }
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSInteger action = [self.statisticsInfo[@"st_shareLiveAction"] integerValue];
    if (action == kShareLiveActionClickLiveRoomMenu) {
        // 每选择分享弹窗中的任何一项＋1（李世杰）
        [self st_reportClickShareMenuWithShareType:@"1" result:@"1"];
    }
}

#pragma mark - UINavigationController+FDFullscreenPopGesture -
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (BOOL)fd_interactivePopDisabled {
    return YES;
}

#pragma mark - Helper -
/** 提示分享结果 */
- (void)showShareResultHUD:(BOOL)success {
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.mode = MBProgressHUDModeText;
    if (success) {
        HUD.labelText = kLocalizationShareSuccessfully;
    } else {
        HUD.labelText = kLocalizationShareFailed;
    }
    [self.view addSubview:HUD];
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

/** 提示余额不足 */
- (void)showAlertCharge {
    [self.infoContainer.contentView hideKeyboard];
    __weak typeof(self) wself = self;
    [UIAlertView bk_showAlertViewWithTitle:nil message:kLocalizationDialogRechagreHint cancelButtonTitle:kLocalizationPublicCancel otherButtonTitles:@[kLocalizationPublicConfirm] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [wself pushPurchaseViewControllerWithActionTag:2];
        }
    }];
}

- (void)onUserNumberChanged:(NSUInteger)num {
    //
}

#pragma mark - VKSDK Delegate -
- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    //    [self onTouchButtonLoginWithVK];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        //
    } else if (result.error) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"cancel" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)vkSdkUserAuthorizationFailed {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self.navigationController.topViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - 分享领钻 -
-(void)shareGainGoldWithPlatform:(NSString*)platformString
{
    __weak typeof(self)weakSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] shareGainGold:platformString success:^(id result) {
        [weakSelf onGainGoldResult:result];
    } failure:^(NSString *errorString) {
        
    } finally:^{
        
    }];

}

-(void)onGainGoldResult:(NSDictionary*)result
{
    @try {
        NSInteger golds = [result[@"gold"] integerValue];
        if(golds > 0) {
            [self showGainGold:golds];
        }
    } @catch (NSException *exception) {
        
    }
}

#pragma mark - Statistics -
/** 每点击礼物盒＋1 */
- (void)st_reportClickGiftButtonEvent {

    NSString *parmeter7Value = [NSString stringWithFormat:@"%lu",[FBLoginInfoModel sharedInstance].balance];
    
    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"rest_diamonds" value:parmeter7Value];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    
    [array addObject:eventParmeter];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"giftbox_click"  eventParametersArray:array];
    
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    
    [FBStatisticsManager report:data];
}

/** 每点击礼物盒的发送按钮＋1 */
- (void)st_reportClickSendGiftButtonEventWithGiftID:(NSString *)giftID giftDiamonds:(NSString *)giftDiamonds sufficient:(NSString *)sufficient {
    
    NSString *parmeter7Value = [NSString stringWithFormat:@"%lu",[FBLoginInfoModel sharedInstance].balance];
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"rest_diamonds" value:parmeter7Value];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"gift_id" value:giftID];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"gift_diamonds" value:giftDiamonds];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"sufficient" value:sufficient];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    
    [array safe_addObject:eventParmeter1];
    [array safe_addObject:eventParmeter2];
    [array safe_addObject:eventParmeter3];
    [array safe_addObject:eventParmeter4];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"gift_send"  eventParametersArray:array];
    
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    
    [FBStatisticsManager report:data];
}

// 点击分享图标
- (void)st_reportClickShareButtonEventWithFollowed:(BOOL)followed time:(NSTimeInterval)time {
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"share_click"  eventParametersArray:array];
    
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    
    [FBStatisticsManager report:data];
}

/** 每在直播间关注主播＋1 */
- (void)st_reportFollowEventWithFrom:(NSNumber *)from {

    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"from" value:[NSString stringWithFormat:@"%@",from]];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    //替换第6个参数
    [array replaceObjectAtIndex:5 withObject:eventParmeter];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"follow"  eventParametersArray:array];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每送出礼物成功/失败＋1 */
- (void)st_reportSendGiftResultEventWithFollowed:(BOOL)followed time:(NSTimeInterval)time result:(NSString *)result diamondFrom:(NSString *)diamondFrom {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"diamond_from" value:diamondFrom];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    
    [array safe_addObject:eventParmeter1];
    [array safe_addObject:eventParmeter2];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"gift_send_result"  eventParametersArray:array];
    
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    
    [FBStatisticsManager report:data];
}

/** 点击聊天按钮 */
- (void)st_reportClickChatButtonEventWithIsBullet:(NSNumber *)isBullet {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    EventParameter *eventParmeter = [FBStatisticsManager eventParameterWithKey:@"is_bullet" value:[NSString stringWithFormat:@"%@",isBullet]];
    [array safe_addObject:eventParmeter];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"comment" eventParametersArray:array];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每选择分享弹窗中的任何一项＋1 */
- (void)st_reportClickShareMenuWithShareType:(NSString *)shareType result:(NSString *)result {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"share_type" value:shareType];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"login_type" value:[NSString stringWithFormat:@"%zd",[FBStatisticsManager loginStatus]]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    [array safe_addObject:eventParmeter1];
    [array safe_addObject:eventParmeter2];
    [array safe_addObject:eventParmeter3];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"share" eventParametersArray:array];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每成功分享直播＋1 */
- (void)st_reportShareLiveEventWithPlatform:(NSString *)platform {
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self st_commonEventParameters]];
    NSString *shareType = @"0";
    if (shareType.isEqualTo(kPlatformFacebook)) {
        shareType = @"1";
    } else if (shareType.isEqualTo(kPlatformTwitter)) {
        shareType = @"2";
    } else if (shareType.isEqualTo(kPlatformVK)) {
        shareType = @"3";
    } else if (shareType.isEqualTo(kPlatformLine)) {
        shareType = @"4";
    } else if (shareType.isEqualTo(kPlatformKakao)) {
        shareType = @"5";
    }
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"type" value:shareType];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:[NSString stringWithFormat:@"%zd",self.fromType]];
    [array safe_addObject:eventParmeter1];
    [array safe_addObject:eventParmeter2];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"share" eventParametersArray:array];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 通用统计事件参数 */
- (NSArray *)st_commonEventParameters {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.broadcaster.userID];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.liveID];
    
    NSString *parmeter4Value = (self.liveType == kLiveTypeReplay ? @"0" : @"1");
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:parmeter4Value];
    
    NSTimeInterval time = ([[NSDate date] timeIntervalSince1970] - self.enterTime) * 1000;
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%f",time]];
    
    NSString *parameter6Value = (self.infoContainer.contentView.followedBroadcaster ? @"1" : @"0");
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"followed" value:parameter6Value];
    
    return @[eventParmeter1, eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6];
}

@end
