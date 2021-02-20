#import "FBBroadcastInfoView.h"
#import "FBCardView.h"
#import "FBLoginInfoModel.h"
#import "FBChatCell.h"
#import "FBLiveBottomView.h"
#import "FBLikeEmitter.h"
#import "FBChatView.h"
#import "FBLiveUsersView.h"
#import "FBLiveDiamondView.h"
#import "FBLiveGiftAnimationView.h"
#import "FBDanmuView.h"
#import "UIScreen+Devices.h"
#import "FBLiveQualityNotifyView.h"
#import "FBShareMenuView.h"
#import "FBLiveFansView.h"
#import "AppDelegate.h"
#import "FBLiveBaseViewController.h"
#import "FBDisguiseView.h"
#import "FBGiftAnimationHelper.h"
#import "UIImageView+AnimationCompletion.h"
#import "FBFullScreenGiftAnimationContainer.h"
#import "FBActivityTipView.h"
#import "CNPPopupController.h"
#import "FBVIPEnterAnimationContainer.h"
#import "FBTipAndGuideManager.h"

/** 主播头像、观众列表等和屏幕顶部的间距 */
#define kPaddingBetweenTopContainerAndTop 20

/** 礼物动画和聊天列表的间距 */
#define kPaddingBetweenGiftAndChat 100

/** 进场动画和聊天列表的间距 */
#define kPaddingBetweenVIPAndChat 15

/** 聊天列表和屏幕底部的间距 */
#define kPaddingBetweenChatAndBottom 53

/** 页面滚动状态，包括横向和竖向 */
typedef NS_ENUM(NSUInteger, FBRoomScrollStatus) {
    
    /** 允许滚动 */
    kRoomScrollStatusEnabled,
    
    /** 不允许滚动 */
    kRoomScrollStatusUnabled
};

@interface FBBroadcastInfoView () <FBActivityTipViewDelegate, CNPPopupControllerDelegate>

/** 顶部控件 */
@property (nonatomic, strong) UIView *topContainer;

/** 触摸背景 */
@property (nonatomic, strong) UIView *touchView;

/** 直播类型 */
@property (nonatomic, assign) FBLiveType liveType;

/** 点赞颜色 */
@property (nonatomic, strong) UIColor *likeColor;

/** 我的点亮 */
@property (nonatomic, strong) FBMessageModel *myHit;

/** 聊天键盘 */
@property (nonatomic, strong) FBChatKeyboard *chatKeyboard;

/** 礼物键盘 */
@property (nonatomic, strong, readwrite) FBGiftKeyboard *giftKeyboard;

/** 底部控件 */
@property (nonatomic, strong) FBLiveBottomView *bottomControl;

/** 点赞发射器 */
@property (nonatomic, strong) FBLikeEmitter *likeEmitter;

/** 聊天列表 */
@property (nonatomic, strong) FBChatView *chatView;

/** 观众列表 */
@property (nonatomic, strong) FBLiveUsersView *usersView;

/** 钻石数量 */
@property (nonatomic, strong) FBLiveDiamondView *diamondView;

/** 礼物动画 */
@property (nonatomic, strong) FBLiveGiftAnimationView *giftAnimationView;

/** 土豪用户入场动画 */
@property (nonatomic, strong) FBVIPEnterAnimationContainer *VIPAnimationContainer;

/** 全屏礼物动画的父控件 */
@property (nonatomic, strong) FBFullScreenGiftAnimationContainer *fullAnimationContainer;

/** 页面滚动状态，包括横向和竖向 */
@property (nonatomic, assign) FBRoomScrollStatus scrollStatus;

/** 弹幕动画 */
@property (nonatomic, strong) FBDanmuView *danmuView;

/** 显示开播时间 */
@property (nonatomic, strong) UILabel *timeCountLabel;

/** 显示开播ID */
@property (nonatomic, strong) UILabel *starMeIDLabel;

/** 主播网络质量差的提示 */
@property (nonatomic, strong) FBLiveQualityNotifyView *qualityNotifyView;

/** 粉丝贡献榜 */
@property (nonatomic, strong) FBLiveFansView *fansView;

/** 分享菜单 */
@property (nonatomic, strong) FBShareMenuView *shareMenuView;

/** 发言的伪视图 */
@property (nonatomic, strong) FBDisguiseView *statementView;

/** 点击钻石新手引导 */
@property (nonatomic, strong) UIView *fansGuideView;

/** 点击钻石新手引导(图片) */
@property (nonatomic, strong) UIImageView *fansGuideImageView;

/** 点击钻石新手引导(文字) */
@property (nonatomic, strong) UILabel *fansGuideLabel;

/** 更新主播的钻石总额定时器 */
@property (nonatomic, strong) NSTimer *diamondTimer;

/** 主播收到的礼物次数，定时更新主播的钻石总额要用到 */
@property (nonatomic) NSUInteger giftCount;

/** 发评论的次数 */
@property (nonatomic) NSUInteger commentCount;

/** 点击分享按钮的次数 */
@property (nonatomic) NSUInteger clickShareCount;

/** 引导提示 */
@property (nonatomic, strong) AMPopTip *popTip;

/** 进入页面的时间戳 */
@property (nonatomic, assign) NSTimeInterval enterTime;

/** 活动弹框视图 */
@property (nonatomic, strong) CNPPopupController *popupController;

/** 主播名字的隐藏状态(变成replay或live) */
@property (nonatomic, assign) BOOL changedNick;

/** 主播名字变化的定时器 */
@property (nonatomic, strong) NSTimer *avaterTimer;

@property (strong, nonatomic) NSString *identityCategory;

@end

@implementation FBBroadcastInfoView

- (instancetype)initWithFrame:(CGRect)frame liveType:(FBLiveType)liveType {
    
    if (self = [super initWithFrame:frame]) {
        
        self.liveType = liveType;
        
        self.backgroundColor = [UIColor clearColor];
        
        UIView *superview = self;
        __weak typeof(self) wself = self;
        
        [self addSubview:self.touchView];
        [self.touchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(superview);
        }];
        
        [self addSubview:self.topContainer];
        [self.topContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(38+34);
            make.top.equalTo(kPaddingBetweenTopContainerAndTop);
            make.left.right.equalTo(superview);
        }];
        
        [self addSubview:self.bottomControl];
        [self.bottomControl mas_makeConstraints:^(MASConstraintMaker *make) {
            if (kLiveTypeReplay == liveType) {
                make.left.right.bottom.equalTo(superview);
                make.height.equalTo(62);
            } else {
                make.left.right.equalTo(superview);;
                make.centerY.equalTo(superview.mas_bottom).offset(-28);
                make.height.equalTo(38);
            }
        }];
        
        if (liveType != kLiveTypeBroadcast) {
            [self addSubview:self.activityButton];
            [self.activityButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.equalTo(CGSizeMake(50, 50));
                make.bottom.equalTo(self.bottomControl.mas_top).offset(-10);
                make.centerX.equalTo(self).offset(SCREEN_WIDTH/2-29);
            }];
        }
        
        [self.activityButton addSubview:self.activityGiftNum];
        [self.activityGiftNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.activityButton).offset(-4);
            make.centerX.equalTo(self.activityButton);
        }];
        
        [self addSubview:self.chatView];
        [self.chatView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview).offset(12);
            make.right.equalTo(superview).offset(-40);
            make.height.equalTo(140);
            make.bottom.equalTo(superview).offset(-kPaddingBetweenChatAndBottom);
            if (self.liveType == kLiveTypeReplay) {
               make.bottom.equalTo(superview).offset(-kPaddingBetweenChatAndBottom - 20);
            }
        }];
        
        [self addSubview:self.qualityNotifyView];
        [self.qualityNotifyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(superview).offset(18);
            make.right.equalTo(superview).offset(-95);
            make.bottom.equalTo(wself.chatView.mas_top).offset(-15);
        }];
        self.qualityNotifyView.hidden = YES;
        
        // 左侧礼物动画的父控件
        [self addSubview:self.giftAnimationView];
        [self.giftAnimationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(1, 90));
            make.bottom.equalTo(wself.chatView.mas_top).offset(-kPaddingBetweenGiftAndChat);
            make.left.equalTo(superview);
        }];
        
        // 全屏礼物动画的父控件
        [self addSubview:self.fullAnimationContainer];
        [self.fullAnimationContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(superview);
            make.size.equalTo(CGSizeMake(1, 1));
        }];
        
        // 土豪用户进场动画
        [self addSubview:self.VIPAnimationContainer];
        [self.VIPAnimationContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(325, 30));
            make.bottom.equalTo(wself.chatView.mas_top).offset(-kPaddingBetweenVIPAndChat);
            make.left.equalTo(superview);
        }];
        
        [self addSubview:self.danmuView];
        [self.danmuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(1, 129));
            make.top.equalTo(wself.giftAnimationView.mas_top).offset(45);
            make.right.equalTo(superview);
        }];
        
        [self addSubview:self.likeEmitter];
        [self.likeEmitter mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(CGSizeMake(10, 10));
            make.bottom.equalTo(wself.bottomControl.mas_top);
            make.right.equalTo(superview).offset(-40);
        }];
        
        [self addSubview:self.chatKeyboard];
        [self.chatKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(superview);
            make.bottom.equalTo(superview).offset(55);
            make.height.equalTo(55);
        }];
        
        UIImageView *bottomBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_chat_masking"]];
        [self addSubview:bottomBackground];
        [bottomBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(superview);
            make.height.equalTo(@200);
        }];
        
        
        self.keyboardTriggerOffset = self.chatKeyboard.dop_height;
        
        [self addKeyboardNonpanningWithActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
            if (opening) {
                wself.chatKeyboard.dop_y = keyboardFrameInView.origin.y - wself.chatKeyboard.dop_height;
                wself.chatView.dop_y = keyboardFrameInView.origin.y - wself.chatKeyboard.dop_height - wself.chatView.dop_height;
                wself.giftAnimationView.dop_y = wself.chatView.dop_y - wself.giftAnimationView.dop_height - 10;
                wself.VIPAnimationContainer.dop_y = wself.chatView.dop_y - wself.VIPAnimationContainer.dop_height - kPaddingBetweenVIPAndChat;
                wself.danmuView.dop_y = wself.chatView.dop_y - wself.danmuView.dop_height - 10;
                wself.topContainer.dop_y = -CGRectGetHeight(wself.topContainer.bounds);
            }
            if (closing) {
                wself.chatKeyboard.dop_y = wself.dop_height;
                wself.chatView.dop_y = superview.dop_height - wself.chatView.dop_height - kPaddingBetweenChatAndBottom;
                wself.giftAnimationView.dop_y = wself.chatView.dop_y - wself.giftAnimationView.dop_height - kPaddingBetweenGiftAndChat;
                wself.VIPAnimationContainer.dop_y = wself.chatView.dop_y - wself.VIPAnimationContainer.dop_height - kPaddingBetweenVIPAndChat;
                wself.danmuView.dop_y = wself.chatView.dop_y - wself.danmuView.dop_height - kPaddingBetweenGiftAndChat;
                wself.topContainer.dop_y = kPaddingBetweenTopContainerAndTop;
            }
        }];
        
        if (kLiveTypeReplay == liveType) {
            //
        } else {
            if (kLiveTypeBroadcast == self.liveType) {
                self.identityCategory = @"anchor";
            } else if (kLiveTypePlay == self.liveType) {
                self.identityCategory = @"viewer";
            }
            [self addSubview:self.statementView];
        }
        
        [self addNotificationObservers];
        [self addTimers];
        self.enterTime = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (void)dealloc {
    [self removeNotificationObservers];
    [self removeTimers];
    [self removeKeyboardControl];
}

- (void)updateConstraints {
    CGFloat avatarWidth = 32.0;
    CGFloat padding = 32;
    CGFloat followButtonWidth = 40;
    CGFloat nickWidth = [FBUtility calculateWidth:self.broadcaster.nick fontSize:12];
    CGFloat liveWidth = (self.liveType == kLiveTypeReplay ? [FBUtility calculateWidth:@"Replay" fontSize:12] : [FBUtility calculateWidth:@"Live" fontSize:12]);
    
    __weak typeof(self) wself = self;
    [self.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(wself.avatarView.superview).offset(8);
        make.top.equalTo(wself.avatarView.superview);
        make.height.equalTo(@(38));
        if (self.followedBroadcaster) {
            make.width.equalTo(@(avatarWidth + nickWidth + padding));
        } else {
            make.width.equalTo(@(avatarWidth + nickWidth + padding + followButtonWidth));
        }
        if (self.changedNick) {
            make.width.equalTo(@(avatarWidth + liveWidth + padding));
        }
    }];
    
    [super updateConstraints];
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

#pragma mark - Getter & Setter -
- (UIView *)topContainer {
    if (!_topContainer ) {
        _topContainer  = [[UIView alloc] init];
        _topContainer.backgroundColor = [UIColor clearColor];
        [_topContainer debugWithBorderColor:[UIColor blueColor]];
        
        UIView *superview = _topContainer;
        
        [superview addSubview:self.avatarView];
        
        [superview addSubview:self.usersView];
        [self.usersView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarView.mas_right).offset(8);
            make.right.equalTo(superview).offset(-0.5-38);
            make.top.equalTo(superview);
            make.height.equalTo(38);
        }];
        
        [superview addSubview:self.diamondView];
        [self.diamondView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(22);
            make.left.equalTo(self.avatarView);
            make.right.equalTo(superview);
            make.top.equalTo(self.avatarView.mas_bottom).offset(12);
        }];
        
        if(kLiveTypeBroadcast == self.liveType) { //开播
            [superview addSubview:self.timeCountLabel];
            [self.timeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(22);
                make.right.equalTo(superview).offset(-10);
                make.top.equalTo(self.avatarView.mas_bottom).offset(12);
            }];
        } else { //直播/回放
            [superview addSubview:self.starMeIDLabel];
            [self.starMeIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(22);
                make.right.equalTo(superview).offset(-10);
                make.top.equalTo(self.avatarView.mas_bottom).offset(12);
            }];
        }
    }
    return _topContainer ;
}

- (FBLiveBottomView *)bottomControl {
    if (!_bottomControl) {
        _bottomControl = [[FBLiveBottomView alloc] initWithType:self.liveType];
        
        _bottomControl.backgroundColor = [UIColor clearColor];
        
        __weak typeof(self) wself = self;
        
        _bottomControl.doOpenChatKeyboardAction = ^ (void) {

            [wself openChatKeyboard];

            [wself.chatKeyboard.textField becomeFirstResponder];
            
            // 是否开启弹幕
            NSNumber *isBullet =(wself.chatKeyboard.isBullet ? @(1) : @(0));
            // 广播点击聊天按钮的打点通知
            NSDictionary *userInfo = @{@"host_id" : wself.broadcaster.userID,
                                       @"is_bullet" : isBullet};
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStatisticsClickChatButton object:nil userInfo:userInfo];
        };
        _bottomControl.doOpenShareMenuAction = ^ (UIButton *btn) {
            
            wself.clickShareCount += 1;
            
            [wself openShareMenu:btn];
            
            // 广播点击分享按钮的打点通知
            NSDictionary *userInfo = @{@"host_id" : wself.broadcaster.userID};
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStatisticsClickShareButton object:nil userInfo:userInfo];
        };
        
        _bottomControl.doOpenGiftKeyboardAction = ^ (void) {
            [wself openGiftKeyboard];
            // 广播点击礼物按钮的打点通知
            NSDictionary *userInfo = @{@"host_id" : wself.broadcaster.userID};
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStatisticsClickGiftButton object:nil userInfo:userInfo];
        };
        
    }
    return _bottomControl;
}

- (UIView *)touchView {
    if (!_touchView) {
        _touchView = [[UIView alloc] init];
        _touchView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) wself = self;
        [_touchView bk_whenTapped:^{
            if (kLiveTypeBroadcast != self.liveType) {
                [wself sendLike:wself.likeColor];
            }
            [wself hideKeyboard];
            [wself.popTip hide];
            [wself.shareMenuView dissmiss];
        }];
    }
    return _touchView;
}

- (void)setBroadcaster:(FBUserInfoModel *)broadcaster {
    _broadcaster = broadcaster;
    self.avatarView.user = self.broadcaster;
    // 如果主播是登录用户自己，则隐藏左上角关注按钮，否则，要检查关注状态
    if ([self.broadcaster isLoginUser]) {
        self.followedBroadcaster = YES;
    } else {
        // 已经关注了，隐藏关注按钮，没有关注，则不隐藏
        [self.broadcaster checkFollowingStatus:^(BOOL result) {
            self.followedBroadcaster = result;
        }];
    }
    
    [self requestForDiamondValue];
    // 暂时屏蔽禁言
    if (kLiveTypePlay == self.liveType) { // 如果是看直播，要检查自己是否为发言管理员
        [self requestForCheckingIsMyselfManager];
    } else if (kLiveTypeBroadcast == self.liveType) { // 如果是自己开播，自己必须为发言管理员
        self.isMeTalkManager = YES;
    } else {
        self.isMeTalkManager = NO;
    }
    
    if(kLiveTypePlay == self.liveType ||
       kLiveTypeReplay == self.liveType) { //直播或回放则需显示id
        NSString *text = [NSString stringWithFormat:@"StarMe ID: %@", self.broadcaster.userID];
        self.starMeIDLabel.text = text;
    }
}

- (void)setFollowedBroadcaster:(BOOL)followedBroadcaster {
    _followedBroadcaster = followedBroadcaster;
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.5 animations:^{
        [self layoutIfNeeded];
    }];
    self.avatarView.followedBroadcaster = _followedBroadcaster;
}

- (UIColor *)likeColor {
    if (!_likeColor) {
        _likeColor = [FBUtility randomLikeColor];
    }
    return _likeColor;
}

- (FBChatKeyboard *)chatKeyboard {
    if (!_chatKeyboard) {
        _chatKeyboard = [[FBChatKeyboard alloc] init];
        __weak typeof(self) wself = self;
        // 开播不显示发弹幕按钮
        _chatKeyboard.hideDanmuButton = (self.liveType == kLiveTypeBroadcast);
        _chatKeyboard.doSendMessageAction = ^ (NSString *message, FBMessageType type) {
            // 被禁言
            if (wself.isMeTalkBanned) {
                
                // 关闭禁言提示
                // [wself displayNotificationWithMessage:kLocalizationBeTalkBanned forDuration:2];
                
                // 被禁言的消息允许在本地回显
                FBMessageModel *model = [[FBMessageModel alloc] init];
                model.fromUser = [[FBLoginInfoModel sharedInstance] user];
                model.content = message;
                model.type = type;
                [wself receiveMessage:model];
                
            } else {
                if (wself.doSendMessageAction) {
                    wself.doSendMessageAction(message, type);
                    // 记录发评论的次数，在同一个直播间发评论超过三次，显示发弹幕引导提示
                    wself.commentCount += 1;
                    if (wself.commentCount >= 3) {
                        if (kLiveTypePlay == self.liveType) {
                            [wself showTipWithType:kTipSendDanmu];
                        }
                    }
                    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                                            action:@"发言成功"
                                                             label:[[FBLoginInfoModel sharedInstance] userID]
                                                             value:@(1)];
                }
            }
        };
    }
    return _chatKeyboard;
}

- (FBGiftKeyboard *)giftKeyboard {
    if (!_giftKeyboard) {
        _giftKeyboard = [[FBGiftKeyboard alloc] init];
        __weak typeof(self) wself = self;
        _giftKeyboard.doSendGiftAction = ^ (FBGiftModel *gift) {
            if (wself.doSendGiftAction) {
                wself.doSendGiftAction(gift);
                // 广播点击发送礼物按钮的打点通知
                NSString *broadcasterID = wself.broadcaster.userID;
                NSNumber *followed = @(0);
                if (wself.followedBroadcaster) {
                    followed = @(1);
                }
                NSNumber *sufficient = @(0); // 余额不足
                NSUInteger balance = [[FBLoginInfoModel sharedInstance] balance];
                if (balance == [gift.gold integerValue]) { // 余额平衡
                    sufficient = @(1);
                } else if (balance > [gift.gold integerValue]) { // 余额充足
                    sufficient = @(2);
                }
                NSDictionary *userInfo = @{@"host_id" : broadcasterID,
                                           @"gift_id" : gift.giftID,
                                           @"gift_diamonds": gift.gold,
                                           @"sufficient": sufficient};
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStatisticsClickSendGiftButton object:nil userInfo:userInfo];
            }
        };
        _giftKeyboard.doPurchaseAction = ^ () {
            if (wself.doPurchaseAction) {
                wself.doPurchaseAction();
            }
        };
    }
    return _giftKeyboard;
}

- (FBLikeEmitter *)likeEmitter {
    if (!_likeEmitter) {
        _likeEmitter = [[FBLikeEmitter alloc] init];
        [_likeEmitter debug];
    }
    return _likeEmitter;
}

- (FBChatView *)chatView {
    if (!_chatView) {
        _chatView = [[FBChatView alloc] init];
        _chatView.backgroundColor = [UIColor clearColor];
        [_chatView debug];
    }
    return _chatView;
}

- (FBLiveUsersView *)usersView {
    if (!_usersView) {
        _usersView = [[FBLiveUsersView alloc] init];
        __weak typeof(self) wself = self;
        _usersView.doTapAvatarAction = ^ (FBUserInfoModel *model) {
            [wself openCard:model];
            [wself.shareMenuView dissmiss];
        };
        [_usersView debug];
    }
    return _usersView;
}

- (FBLiveAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[FBLiveAvatarView alloc] init];
        __weak typeof(self) wself = self;
        _avatarView.doTapAvatarAction = ^ (FBUserInfoModel *user) {
            [wself openCard:user];
        };
        _avatarView.doFollowAction = ^ (FBUserInfoModel *user) {
            [wself requestForAddingFollow];
        };
    }
    return _avatarView;
}

- (FBLiveDiamondView *)diamondView {
    if (!_diamondView) {
        _diamondView = [[FBLiveDiamondView alloc] init];
        __weak typeof(self) wself = self;
        // 点击显示粉丝贡献榜
        _diamondView.doTapViewAction = ^ (void) {
            [wself showFansView];
        };
        // 是否显示钻石数
        _diamondView.hidden = !DIAMOND_NUM_ENABLED;
    }
    return _diamondView;
}

- (FBLiveGiftAnimationView *)giftAnimationView {
    if (!_giftAnimationView) {
        _giftAnimationView = [[FBLiveGiftAnimationView alloc] init];
        _giftAnimationView.backgroundColor = [UIColor clearColor];
        [_giftAnimationView debug];
        // 保持钻石数变化与礼物动画一致
        if (DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED) {
            __weak typeof(self) wself = self;
            _giftAnimationView.doAddingNumberCallback = ^ (FBGiftModel *gift) {
                [wself increaseDiamondCountWithGift:gift];
            };
        }
    }
    return _giftAnimationView;
}

- (FBVIPEnterAnimationContainer *)VIPAnimationContainer {
    if (!_VIPAnimationContainer) {
        _VIPAnimationContainer = [[FBVIPEnterAnimationContainer alloc] init];
        _VIPAnimationContainer.backgroundColor = [UIColor clearColor];
        [_VIPAnimationContainer debug];
    }
    return _VIPAnimationContainer;
}

- (FBFullScreenGiftAnimationContainer *)fullAnimationContainer {
    if (!_fullAnimationContainer) {
        _fullAnimationContainer = [[FBFullScreenGiftAnimationContainer alloc] init];
        _fullAnimationContainer.backgroundColor = [UIColor clearColor];
        // 保持钻石数变化与礼物动画一致
        if (DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED) {
            __weak typeof(self) wself = self;
            _fullAnimationContainer.doFinishAnimationCallback = ^ (FBGiftModel *gift) {
                [wself increaseDiamondCountWithGift:gift];
            };
        }
    }
    return _fullAnimationContainer;
}

- (void)increaseDiamondCountWithGift:(FBGiftModel *)gift {
    
    if (kLiveTypeReplay != self.liveType) {
        
        NSInteger diamondCount = [gift.gold integerValue];
        
        // 主播收到的钻石数在客户端本地增加到收到的钻石总额
        [self addDiamondCount:diamondCount];
        
        // 如果送礼的人是当前登录用户，则从本地扣除钻石余额
        if ([gift.fromUser isLoginUser]) {
            
            // 观众送出的钻石数在客户端本地从钻石余额中扣除
            [self.giftKeyboard deductBalance:diamondCount];
            
            // 广播通知向服务器请求更新当前登录用户的钻石余额（当前用户是观众）
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateBalance object:nil];
        }
    }
}

- (FBDanmuView *)danmuView {
    if (!_danmuView) {
        _danmuView = [[FBDanmuView alloc] init];
        _danmuView.backgroundColor = [UIColor clearColor];
    }
    return _danmuView;
}

- (FBLiveFansView *)fansView {
    if (!_fansView) {
        _fansView = [[FBLiveFansView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGH, SCREEN_WIDTH, SCREEN_HEIGH) withUser:self.broadcaster];
        NSInteger selectedIndex = [[AppDelegate tabBarController] selectedIndex];
        if (self.liveType == kLiveTypeBroadcast) {
            if (self.liveViewController) {
                _fansView.contributionControlelr.specificNavigationController = (UINavigationController *)(self.liveViewController.navigationController);
            }
        } else {
            _fansView.contributionControlelr.specificNavigationController = (UINavigationController *)[[AppDelegate tabBarController] viewControllers][selectedIndex];
        }
    }
    return _fansView;
}

- (FBDisguiseView *)statementView {
    if (!_statementView) {
        _statementView = [[FBDisguiseView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGH - 45, SCREEN_WIDTH - 116, 35) andIdentityCategory:self.identityCategory];

        _statementView.backgroundColor = [UIColor clearColor];
        __weak typeof(self) wself = self;
        // 单击弹出键盘视图
        _statementView.doOpenChatKeyboardAction = ^ (void) {
            [wself openChatKeyboard];
        };
        
        // 长按快速发言
        _statementView.doFastStatementAction = ^ (NSString *message) {
            if (wself.doSendMessageAction) {
                wself.doSendMessageAction(message, kMessageTypeDefault);
            }
        };
    }
    return _statementView;
}

- (UIView *)fansGuideView {
    if (!_fansGuideView) {
        _fansGuideView = [[UIView alloc] initWithFrame:self.bounds];
        [_fansGuideView bk_whenTapped:^{
            [_fansGuideView removeFromSuperview];
        }];
        _fansGuideView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_fansGuideView addSubview:self.fansGuideImageView];
        [_fansGuideView addSubview:self.fansGuideLabel];
    }
    return _fansGuideView;
}

- (UIImageView *)fansGuideImageView {
    if (!_fansGuideImageView) {
        _fansGuideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 44, SCREEN_HEIGH * 0.5 - 100)];
        _fansGuideImageView.image = [UIImage imageNamed:@"onlive_guide_02"];
    }
    return _fansGuideImageView;
}

- (UILabel *)fansGuideLabel {
    if (!_fansGuideLabel) {
        _fansGuideLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 140, 200, 0)];
        _fansGuideLabel.text = kLocalizationBecomeSuperFans;
        _fansGuideLabel.textColor = [UIColor whiteColor];
        _fansGuideLabel.font = [UIFont systemFontOfSize:15];
        _fansGuideLabel.numberOfLines = 0;
        [_fansGuideLabel sizeToFit];
    }
    return _fansGuideLabel;
}

- (UILabel *)timeCountLabel
{
    if(nil == _timeCountLabel) {
        _timeCountLabel = [[UILabel alloc] init];
        _timeCountLabel.font = FONT_SIZE_16;
        _timeCountLabel.textAlignment = NSTextAlignmentRight;
        _timeCountLabel.textColor = [UIColor whiteColor];
        _timeCountLabel.shadowColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.6];
        _timeCountLabel.shadowOffset = CGSizeMake(0, 1);
        _timeCountLabel.backgroundColor = [UIColor clearColor];
    }
    return _timeCountLabel;
}

- (UILabel *)starMeIDLabel
{
    if(nil == _starMeIDLabel) {
        _starMeIDLabel = [[UILabel alloc] init];
        _starMeIDLabel.font = FONT_SIZE_13;
        _starMeIDLabel.textAlignment = NSTextAlignmentRight;
        _starMeIDLabel.textColor = [UIColor hx_colorWithHexString:@"FFFFFF" alpha:0.5];
        _starMeIDLabel.backgroundColor = [UIColor clearColor];
    }
    return _starMeIDLabel;
}

- (FBLiveQualityNotifyView *)qualityNotifyView {
    if(!_qualityNotifyView) {
        _qualityNotifyView = [[FBLiveQualityNotifyView alloc] init];
        _qualityNotifyView.backgroundColor = [UIColor clearColor];
        [_qualityNotifyView sizeToFit];;
    }
    return _qualityNotifyView;
}

- (void)setLiveType:(FBLiveType)liveType {
    _liveType = liveType;
    self.avatarView.liveType = self.liveType;
}

- (void)setScrollStatus:(FBRoomScrollStatus)scrollStatus {
    if (_scrollStatus != scrollStatus) {
        _scrollStatus = scrollStatus;
        if (kRoomScrollStatusEnabled == _scrollStatus) {
            [self postNotificationScrollEnabled:YES];
        } else if (kRoomScrollStatusUnabled == _scrollStatus) {
            [self postNotificationScrollEnabled:NO];
        }
    }
}

- (AMPopTip *)popTip {
    if (!_popTip) {
        _popTip = [AMPopTip popTip];
        _popTip.shouldDismissOnTap = YES;
        _popTip.shouldDismissOnTapOutside = YES;
    }
    return _popTip;
}

- (UIButton *)activityButton {
    if (!_activityButton) {
        _activityButton = [[UIButton alloc] init];
        _activityButton.hidden = YES;
        [_activityButton addTarget:self action:@selector(onTouchButtonActivity) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _activityButton;
}

- (UILabel *)activityGiftNum {
    if (!_activityGiftNum) {
        _activityGiftNum = [[UILabel alloc] init];
        _activityGiftNum.textColor = COLOR_FFFFFF;
        _activityGiftNum.font = [UIFont boldSystemFontOfSize:13.0];
//        _activityGiftNum.text = @"x0";
    }
    
    return _activityGiftNum;
}

#pragma mark - Override -
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // 点击直播信息处不允许滑动
    CGPoint hitPoint = [self.avatarView convertPoint:point fromView:self];
    if ([self.avatarView pointInside:hitPoint withEvent:event]) {
        self.scrollStatus = kRoomScrollStatusUnabled;
        return hitView;
    }
    
    // 点击评论消息处不允许滑动
    hitPoint = [self.chatView convertPoint:point fromView:self];
    if ([self.chatView pointInside:hitPoint withEvent:event]) {
        self.scrollStatus = kRoomScrollStatusUnabled;
        return hitView;
    }
    
    // 点击各种按钮控件不允许滑动
    if ([hitView isKindOfClass:[UIButton class]]) {
        self.scrollStatus = kRoomScrollStatusUnabled;
        return hitView;
    }
    
    if (self.liveType == kLiveTypeReplay) {
        // 点击回放的进度条不允许滑动
        if ([hitView isKindOfClass:[UISlider class]]) {
            self.scrollStatus = kRoomScrollStatusUnabled;
            return hitView;
        }
    }
    
    self.scrollStatus = kRoomScrollStatusEnabled;
    
    // 点击钻石处穿透
    hitPoint = [self.diamondView convertPoint:point fromView:self];
    if ([self.diamondView pointInside:hitPoint withEvent:event]) {
        return self.touchView;
    }
    
    return hitView;
}

#pragma mark - Data Management -
- (void)reloadUsers:(NSArray *)users {
    [self.usersView reloadUsers:users];
}

#pragma mark - Network management -
/** 查询收到的钻石礼物 */
- (void)requestForDiamondValue {
    __weak typeof(self) wself = self;
    [[FBProfileNetWorkManager sharedInstance] loadProfitRecordWithUserID:[wself.broadcaster userID] success:^(id result) {
        [wself updateDiamondCount:[result[@"inout"][@"point"] integerValue]];
    } failure:^(NSString *errorString) {
        
    } finally:^{
        //
    }];
}

/** 关注主播 */
- (void)requestForAddingFollow {
    [[FBProfileNetWorkManager sharedInstance] addToFollowingListWithUserID:self.broadcaster.userID success:^(id result) {
        // 添加一个条件判断，避免连续点击关注按钮时发送两条关注公屏消息
        if (!self.followedBroadcaster) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationFollowSomebody object:self.broadcaster];
        }
        self.followedBroadcaster = YES;
        // 发送一条广播去刷新个人中心的关注粉丝数量
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateFollowNumber object:nil];
        // 广播关注主播的打点通知
        NSDictionary *userInfo = @{@"from" : @(0),
                                   @"host_id" : self.broadcaster.userID};
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStatisticsFollowBroadcaster object:nil userInfo:userInfo];
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

/** 查询其他用户的禁言状态 */
- (void)requestForCheckingTalkStatus:(FBUserInfoModel *)user {
    [[FBLiveTalkNetworkManager sharedInstance] checkTalkStatusWithUserID:user.userID broadcasterID:self.broadcaster.userID roomID:@"0" liveID:self.liveID success:^(id result) {
        if (0 == [result[@"dm_error"] integerValue]) {
            user.isTalkManager = [result[@"ismanger"] boolValue];
            user.isTalkBanned = [result[@"isbantalk"] boolValue];
        }
    } failure:^(NSString *errorString) {
        NSLog(@"errorString: %@", errorString);
    } finally:^{
        //
    }];
}

/** 查询登录用户自己是否为管理员 */
- (void)requestForCheckingIsMyselfManager {
    FBLiveBaseViewController *liveViewController = (FBLiveBaseViewController *)self.liveViewController;
    NSString *roomID = liveViewController.roomID;
    [[FBLiveTalkNetworkManager sharedInstance] checkTalkStatusWithUserID:[[FBLoginInfoModel sharedInstance] userID] broadcasterID:self.broadcaster.userID roomID:roomID liveID:self.liveID success:^(id result) {
        if (0 == [result[@"dm_error"] integerValue]) {
            self.isMeTalkManager = [result[@"ismanger"] boolValue];
            self.isMeTalkBanned = [result[@"isbantalk"] boolValue];
        }
    } failure:^(NSString *errorString) {
        NSLog(@"errorString: %@", errorString);
    } finally:^{
        //
    }];
}

#pragma mark - Event handler -
/** 添加广播监听 */
- (void)addNotificationObservers {
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenGiftKeyboard
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      wself.chatView.hidden = YES;
                                                      wself.bottomControl.hidden = YES;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationCloseGiftKeyboard
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      wself.chatView.hidden = NO;
                                                      wself.bottomControl.hidden = NO;
                                                      [wself destroyGiftKeyboard];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenShareMenu
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      wself.chatView.hidden = YES;
                                                      wself.bottomControl.hidden = YES;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationCloseShareMenu
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      wself.chatView.hidden = NO;
                                                      wself.bottomControl.hidden = NO;
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenUserCard
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      FBUserInfoModel *user = note.object;
                                                      [wself openCard:user];
                                                  }];
    
    //【礼物动画关键业务逻辑】用于测试，直接广播加载礼物动画，测试完记得删除
//    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationGiftAnimationTest
//                                                      object:nil
//                                                       queue:nil
//                                                  usingBlock:^(NSNotification *note) {
//                                                      FBGiftModel *gift = note.object;
//                                                      [wself receiveGift:gift];
//                                                  }];
}

/** 移除广播监听 */
- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)updateNick {
    self.changedNick = YES;
    self.avatarView.followButton.hidden = YES;
    self.avatarView.livingLabel.text = (self.liveType == kLiveTypeReplay ? @"Replay" : @"Live");
    [UIView animateWithDuration:1.0 animations:^{
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    }];
    if ([self.avaterTimer isValid]) {
        [self.avaterTimer invalidate];
        self.avaterTimer = nil;
    }
}
/** 添加定时器 */
- (void)addTimers {
    if ([self.avaterTimer isValid]) {
        [self.avaterTimer invalidate];
        self.avaterTimer = nil;
    }
    self.avaterTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateNick) userInfo:nil repeats:NO];
    
}

/** 移除定时器 */
- (void)removeTimers {
    [self.diamondTimer invalidate];
    self.diamondTimer = nil;
}

- (void)postNotificationScrollEnabled:(BOOL)scrollEnabled {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRoomScrollEnabled object:@(scrollEnabled)];
}

- (void)receiveMessage:(FBMessageModel *)message {
    if(kMessageTypeDanmu == message.type) {
        [self.danmuView receivedMessage:message];
    } else {
        //FIX_ME(区分类型)
        [self.chatView receiveMessage:message];
    }
}

- (void)sendLike:(UIColor *)color {
    
    if (self.doSendLikeAction) {
        self.doSendLikeAction(color);
        // 每触发点亮＋1，如果相临两次点亮的时间间隔小于1秒，则记为同一个事件（黄玉辉）
        [self st_reportClickLike];
        
    }
    
    // 本地回显
    [self receiveLike:color];
    
    if (!self.myHit) {
        if (self.doSendHitAction) {
            self.doSendHitAction(color);
        }
        FBMessageModel *message = [[FBMessageModel alloc] init];
        message.type = kMessageTypeHit;
        message.fromUser = [[FBLoginInfoModel sharedInstance] user];
        message.hitColor = color;
        self.myHit = message;
        [self receiveMessage:self.myHit];
    }
}

- (void)receiveLike:(UIColor *)color {
    [self emitLike:color];
}

- (void)receiveGift:(FBGiftModel *)model {
    __weak typeof(self) wself = self;
    
    //把广播过来的礼物模型的礼物包换成本地的礼物模型的礼物包 兼容旧的版本 因为旧的版本没有img_bag 不替换的话旧版送礼新版没有动画
    NSArray *giftJson = [[GVUserDefaults standardUserDefaults] giftList];
    NSArray *giftArray = [FBGiftModel mj_objectArrayWithKeyValuesArray:giftJson];
    for (FBGiftModel *gift in giftArray) {
        if ([gift.giftID isEqual:model.giftID]) {
            model.imageZip = gift.imageZip;
            break;
        }
    }
    
    //【礼物动画关键业务逻辑】判断礼物动画包是否已经下载到本地，礼物动画是小动画，还是全屏动画
    if ([FBGiftAnimationHelper existsZipWithGift:model]) {
        FBGiftAnimationInfoModel *info = [FBGiftAnimationHelper animationInfoWithGift:model];
        NSInteger animationType = [info.type integerValue];
        if (1 == animationType) {
            // 没有全屏动画的加到左侧礼物动画队列
            [wself.giftAnimationView receiveGift:model];
        } else {
            // 有全屏动画的加到全屏礼物动画队列
            [wself.fullAnimationContainer receiveGift:model];
        }
    } else {
        // 没有下载到本地的加入到左侧礼物动画队列，不播放动画
        [self.giftAnimationView receiveGift:model];
    }
    // 旧的业务逻辑
//    NSString *bagName = model.imageZip;
//    if ([bagName isValid]) {
//        [FBGiftAnimationHelper downloadZipFileForGift:model
//                                    completionHandler:^(NSArray *imageFiles, NSInteger animationType, NSTimeInterval duration) {
//                                        if (1 == animationType) {
//                                            // 没有全屏动画的加到左侧礼物动画队列
//                                            [wself.giftAnimationView receiveGift:model];
//                                        } else {
//                                            // 有全屏动画的加到全屏礼物动画队列
//                                            [wself.fullAnimationContainer receiveGift:model];
//                                        }
//                                    }];
//    } else { // 没有动画的默认加到左侧礼物动画队列
//        [self.giftAnimationView receiveGift:model];
//    }
    // 记录主播收到的礼物次数
    self.giftCount += 1;
    
    // 如果钻石数变更与礼物动画不必保持一致，则定时更新钻石数
    if (NO == DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED) {
        if (!self.diamondTimer) {
            self.diamondTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
                if (self.giftCount > 0) {
                    // 更新钻石余额时要把收到的礼物次数清零
                    self.giftCount = 0;
                    [self requestForDiamondValue];
                } else {
                    [self.diamondTimer invalidate];
                    self.diamondTimer = nil;
                }
            } repeats:YES];
        }
    }
}

- (void)enterUser:(FBUserInfoModel *)user {
    [self.VIPAnimationContainer enterUser:user];
}

/** 弹出用户资料卡片 */
- (void)openCard:(FBUserInfoModel *)user {
    
    FBCardView *cardView = [FBCardView showInView:self withUser:user];
    cardView.liveViewController = (FBLiveBaseViewController *)self.liveViewController;
    cardView.isMeTalkManager = self.isMeTalkManager;
    
    __weak typeof(self) wself = self;
    
    cardView.doGoHomepageAction = ^ (FBUserInfoModel *user) {
        if (wself.doGoHomepageAction) {
            wself.doGoHomepageAction(user);
        }
    };
    
    cardView.doGoFansContributionpageAction = ^(FBUserInfoModel *user) {
        if (wself.doGoFansContributionpageAction) {
            wself.doGoFansContributionpageAction(user);
        }
    };
    
    cardView.doReportAction = ^ (FBUserInfoModel *user) {
        if (wself.doReportAction) {
            wself.doReportAction(user);
        }
    };
    
    cardView.doManagerAction = ^ (FBUserInfoModel *user) {
        if (wself.doManagerAction) {
            wself.doManagerAction(user);
        }
    };
    
    // 如果弹出的是主播的名片，要根据名片内的关注状态变化来调整左上角的关注按钮是否隐藏
    if (user.userID.isEqualTo(self.broadcaster.userID)) {
        cardView.onFollowAction = ^ (BOOL isFollowing) {
            wself.followedBroadcaster = isFollowing;
        };
    }
    
    // 暂时屏蔽禁言
    [self requestForCheckingTalkStatus:user];
    
    [self hideKeyboard];
}


- (void)openShareMenu:(UIButton *)btn {
    
    self.shareMenuView = [[FBShareMenuView alloc] init];

    [self addSubview:self.shareMenuView];
    
     [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenShareMenu object:nil];
    
    __weak typeof(self) wself = self;
    self.shareMenuView.doShareLiveAction = ^(NSString *platform, FBShareLiveAction action, FBShareMenuView *menu) {
        wself.doShareLiveAction(platform, action);
        [menu dissmiss];
    };
}

/** 打开礼物键盘 */
- (void)openGiftKeyboard {
    [self addSubview:self.giftKeyboard];
    [self.giftKeyboard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenGiftKeyboard object:nil];
}

/** 打开聊天键盘 */
- (void)openChatKeyboard {
    // 解决提示和键盘同时出现的冲突
    if ([self.popTip isVisible]) {
        __weak typeof(self) wself = self;
        [self.popTip hide];
        [self bk_performBlock:^(id obj) {
            [wself.chatKeyboard.textField becomeFirstResponder];
        } afterDelay:0.1];
    } else {
        [self.chatKeyboard.textField becomeFirstResponder];
    }
}

/** 销毁礼物键盘 */
- (void)destroyGiftKeyboard {
    [self.giftKeyboard removeFromSuperview];
    self.giftKeyboard = nil;
}

/** 点赞动画 */
- (void)emitLike:(UIColor *)color {
    [self.likeEmitter receiveLikeWithColor:color];
}

- (void)updateDiamondCount:(NSInteger)count {
    [self.diamondView updateDiamondCount:count];
}

- (void)addDiamondCount:(NSInteger)count {
    [self.diamondView addDiamondCount:count];
}

- (void)updateUserCount:(NSInteger)count {
    [self.avatarView updateAudienceNumber:count];
}

/** 显示主播网络质量差的提示 */
- (void)showLiveQuality:(NSString *)message {
    self.qualityNotifyView.hidden = NO;
    [self.qualityNotifyView setText:message];
    [self.qualityNotifyView startAnimate];
}

/** 隐藏主播网络质量差的提示 */
- (void)hideLiveQuality {
    [self.qualityNotifyView stopAnimate];
    self.qualityNotifyView.hidden = YES;
}

/** 更新开播时长 */
-(void)updateTimeCountString:(NSString*)timeCountString
{
    self.timeCountLabel.text = timeCountString;
}

/** 显示粉丝贡献榜 */
- (void)showFansView {
    
    [self addSubview:self.fansView];
    
     // 粉丝贡献榜新手引导
    NSUInteger count = [FBTipAndGuideManager countInUserDefaultsWithType:kGuideClickDiamond];
    if (0 == count && self.liveType == kLiveTypePlay) {
        [_fansView addSubview:self.fansGuideView];
        [FBTipAndGuideManager addCountInUserDefaultsWithType:kGuideClickDiamond];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.fansView.y = 0;
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowFansView object:nil];
}

- (void)showTipWithType:(FBTipAndGuideType)type {
    
    // 解决提示和键盘同时出现的冲突
    if (self.isKeyboardOpened) {
        if (type != kTipSendDanmu) {
            return;
        }
    }
    
    // 缓存在本地的总提示次数
    NSUInteger countInUserDefaults = [FBTipAndGuideManager countInUserDefaultsWithType:type];
    // 在应用生命周期内的提示次数
    NSUInteger countForLifeCycle = [[FBTipAndGuideManager sharedInstance] countInLiftCycleWithType:type];
    switch (type) {
        // 引导用户关注主播
        case kTipFollowBroadcaster: {
            // 已关注了主播，本直播间不再提醒
            if (NO == self.followedBroadcaster && countForLifeCycle < 2 && countInUserDefaults < 10) {
                // 关注按钮的位置
                CGRect fromFrame = CGRectMake(self.avatarView.frame.size.width-50, 18, 75, 38);
                [self.popTip showText:kLocalizationFollowingTip direction:AMPopTipDirectionDown maxWidth:SCREEN_WIDTH*2/3 inView:self fromFrame:fromFrame duration:3];
                
                // 提示次数在应用生命周期内加一
                [[FBTipAndGuideManager sharedInstance] addCountInLiftCycleWithType:type];
                
                // 提示次数在本地缓存加一
                [FBTipAndGuideManager addCountInUserDefaultsWithType:type];
            }
            break;
        }
        // 引导用户更改头像
        case kTipSetAvatar: {
            if (0 == countInUserDefaults) {
                // 主播头像的位置
                CGRect fromFrame = CGRectMake(13, 33, 32, 32);
                [self.popTip showText:kLocalizationTipAvatar direction:AMPopTipDirectionDown maxWidth:SCREEN_WIDTH*2/3 inView:self fromFrame:fromFrame duration:3];
                
                // 提示次数在本地缓存加一
                [FBTipAndGuideManager addCountInUserDefaultsWithType:type];
            }
            break;
        }
        // 引导用户分享直播
        case kTipShareLive: {
            if (0 == self.clickShareCount && countForLifeCycle < 2) {
                // 分享按钮的位置
                CGRect fromFrame = CGRectMake(SCREEN_WIDTH-2*10-2*38, SCREEN_HEIGH-9-38, 38, 38);
                [self.popTip showText:kLocalizationTipShare direction:AMPopTipDirectionUp maxWidth:SCREEN_WIDTH inView:self fromFrame:fromFrame duration:3];
                
                // 提示次数在应用生命周期内加一
                [[FBTipAndGuideManager sharedInstance] addCountInLiftCycleWithType:type];
            }
            break;
        }
        // 引导主播设置摄像头
        case kTipSetCamera: {
            if (0 == countInUserDefaults) {
                // 摄像头设置按钮的位置
                CGRect fromFrame = CGRectMake(SCREEN_WIDTH-58-38, SCREEN_HEIGH-9-38, 38, 38);
                [self.popTip showText:kLocalizationTipCamera direction:AMPopTipDirectionUp maxWidth:SCREEN_WIDTH inView:self fromFrame:fromFrame duration:3];
                
                // 提示次数在本地缓存加一
                [FBTipAndGuideManager addCountInUserDefaultsWithType:type];
            }
            break;
        }
        // 引导主播感谢用户
        case kTipThankUsers: {
            // 钻石总额的位置
            CGRect fromFrame = CGRectMake(0, 80, 75, 22);
            [self.popTip showText:kLocalizationTipThanks direction:AMPopTipDirectionDown maxWidth:SCREEN_WIDTH*2/3 inView:self fromFrame:fromFrame duration:3];
            break;
        }
        // 引导用户发弹幕
        case kTipSendDanmu: {
            if (0 == countInUserDefaults) {
                CGRect fromFrame = self.chatKeyboard.bulletButton.frame;
                [self.popTip showText:kLocalizationTipDanmu direction:AMPopTipDirectionUp maxWidth:SCREEN_WIDTH inView:self.chatKeyboard fromFrame:fromFrame duration:3];
                
                // 提示次数在本地缓存加一
                [FBTipAndGuideManager addCountInUserDefaultsWithType:type];
            }
            break;
        }
        // 引导用户与主播聊天
        case kTipTalkToBroadcaster: {
            // 发过一次聊天本直播间不再提示
            if (0 == self.commentCount && countForLifeCycle < 2 && countInUserDefaults < 10) {
                CGRect fromFrame = CGRectMake(10, SCREEN_HEIGH-10-35, SCREEN_WIDTH-4*10-2*38, 35);
                [self.popTip showText:kLocalizationGuideChat direction:AMPopTipDirectionUp maxWidth:SCREEN_WIDTH*2/3 inView:self fromFrame:fromFrame duration:3];
                
                // 提示次数在应用生命周期内加一
                [[FBTipAndGuideManager sharedInstance] addCountInLiftCycleWithType:type];
                
                // 提示次数在本地缓存加一
                [FBTipAndGuideManager addCountInUserDefaultsWithType:type];
            }
            break;
        }
        // 提示用户给主播送礼
        case kTipSendGift: {
            if (countForLifeCycle < 2 && countInUserDefaults < 10) {
                // 礼物按钮的位置
                CGRect fromFrame = CGRectMake(SCREEN_WIDTH-10-38, SCREEN_HEIGH-9-38, 38, 38);
                [self.popTip showText:kLocalizationGuideSendGift direction:AMPopTipDirectionUp maxWidth:SCREEN_WIDTH*2/3 inView:self fromFrame:fromFrame duration:3];
                
                // 提示次数在应用生命周期内加一
                [[FBTipAndGuideManager sharedInstance] addCountInLiftCycleWithType:type];
                
                // 提示次数在本地缓存加一
                [FBTipAndGuideManager addCountInUserDefaultsWithType:type];
            }
            break;
        }
        case kTipRemindFollowMe: {
            if (countForLifeCycle < 2  && countInUserDefaults < 10) {
                // 关注按钮的位置
                CGRect fromFrame = CGRectMake(self.avatarView.frame.size.width-50, 30, 75, 38);
                [self.popTip showText:kLocalizationGuideFollowTip direction:AMPopTipDirectionDown maxWidth:SCREEN_WIDTH*2/3 inView:self fromFrame:fromFrame duration:3];
                
                // 提示次数在应用生命周期内加一
                [[FBTipAndGuideManager sharedInstance] addCountInLiftCycleWithType:type];
                
                // 提示次数在本地缓存加一
                [FBTipAndGuideManager addCountInUserDefaultsWithType:type];
            }
            break;
        }
        default:
            break;
    }
}

- (void)showSocketErrorView:(BOOL)bShow
{
    [self.diamondView showSocketErrorView:bShow];
}

- (void)onTouchButtonActivity {
    NSLog(@"点击了直播间活动礼物按钮");
    
    if ([self.activityGiftNum.text isEqualToString:@"x0"]) {
        [self popActivityTipView];
    } else {
        __weak typeof(self) wself = self;
        if (wself.doSendActivityGiftAction) {
            wself.doSendActivityGiftAction();
        }
    }
}

#pragma mark - Helper -
/** 弹出活动视图卡片 */
- (void)popActivityTipView {
    FBActivityTipView *view = [[FBActivityTipView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    view.activitydDelegate = self;
    view.doCancelCallback = ^ (void) {
        [self.popupController dismissPopupControllerAnimated:YES];
    };
    
    [self configureCardView:view];
}

#pragma mark - FBActivityTipViewDelegate -
- (void)clickSureButton {
    [self openGiftKeyboard];
}

#pragma mark - CNPPopupController Delegate
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}


#pragma mark - statistics
- (void)st_reportClickLike {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.broadcaster.userID];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.liveID];
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"like"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
