//
//  FBLivePrepareViewController.m
//  LiveShow
//
//  Created by chenfanshun on 15/02/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#define USE_MIRAEYE 1

#import "FBLiveOnViewController.h"
#import "FBLiveStreamNetworkManager.h"
#import "FBLivePrepareView.h"

#import "FBMsgService.h"
#import "FBMsgPacketHelper.h"

#if USE_MIRAEYE
#import "FBMiraeyeRecorder.h"
#else
#import "FBRecorder.h"
#endif

#import "FBLoginInfoModel.h"
#import "FBTAViewController.h"
#import "FBLiveEndView.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterCore/TwitterCore.h>
#import <TwitterKit/TwitterKit.h>
#import "FBGAIManager.h"
#import "FBLocationManager.h"
#import "KxMenu.h"
#import "FBWebViewController.h"
#import "FBNetDiagnosisReportManager.h"
#import "FBLiveLoadingView.h"
#import "FBRoomManagerModel.h"
#import "FBTalkManagersViewController.h"
#import "FBLiveCountDownView.h"
#import "FBLoginManager.h"
#import <limits.h>
#import "FBAvatarController.h"
/**
 *  先pre获取开播id->getPublishStream获取开播流，进行开播->
 start进行上报玉书那边->定时ping房间，保持连接->joinroom进入房间
 */

@interface FBLiveOnViewController ()<FBRoomEventDelegate>

@property (nonatomic, strong) FBLivePrepareView *prePareView;

@property(nonatomic, strong)FBLiveLoadingView   *loadingView;

#if USE_MIRAEYE
@property (nonatomic, strong) FBMiraeyeRecorder    *recorder;
#else
@property (nonatomic, strong) FBRecorder    *recorder;
#endif

/** 开播时选用的tags*/
@property(nonatomic, strong) NSString       *tagsString;

/** 是否使用地理位置*/
@property (nonatomic, assign) BOOL          useLocation;

/** 是否自动分享到facebook*/
@property (nonatomic, assign) BOOL          facebookAutoShare;

/** 是否自动分享到twitter*/
@property (nonatomic, assign) BOOL          twitterAutoShare;

/** 视频是否连上*/
@property (nonatomic, assign) BOOL          isPublishConnected;

/** 视频首次连上*/
@property (nonatomic, assign) BOOL          firstPublishConnected;

/** 是否重连过*/
@property (nonatomic, assign) BOOL          hasReconnected;

@property (nonatomic, strong) NSString      *live_name;

/** 直播间所在分组*/
@property (nonatomic, assign) NSInteger      group;

/** ping房间定时器*/
@property (nonatomic, strong)NSTimer       *timerPing;

/** 定时统计开播状况*/
@property (nonatomic, strong)NSTimer        *timerSummary;

/** 重练总次数*/
@property (nonatomic, assign)NSInteger      summaryReconnectCount;

/** 断开次数*/
@property (nonatomic, assign)NSInteger      reconnectCount;

/**  prepare请求失败次数*/
@property (nonatomic, assign)NSInteger      prePareCount;

/** 用于统计查询用时 */
@property(nonatomic, assign)NSTimeInterval  timeQueryBegin;

/** 查询地址耗时 */
@property(nonatomic, assign)NSInteger       timeQueryUse;

/** 视频加载耗时 */
@property(nonatomic, assign)NSInteger       timeVideoLoadUse;

/** 当前开播地址 */
@property(nonatomic, strong)NSString        *currentOpenLiveUrl;

/** 当前查询url */
@property(nonatomic, strong)NSString        *currentQueryUrl;

@property (nonatomic, assign) BOOL savedIdleTimer;

/** 刷新收到的钻石定时器 */
@property (nonatomic, strong) NSTimer *diamondTimer;

/** 调用startlive次数 */
@property (nonatomic, assign) NSInteger startLiveTimes;

/** stopopenlive 失败次数 */
@property (nonatomic, assign) NSInteger stopLiveFailureTimes;

/** 没数据通知时的时间戳 */
@property (nonatomic, assign) NSInteger nodataTimeStamp;

/** 没数据通知时的定时器 */
@property (nonatomic, strong)  NSTimer   *nodataCheckTimer;


/** 统计开播时长 */
@property(nonatomic, strong) NSTimer *timerLiveTick;

/** 开播时长 */
@property (nonatomic, assign) NSInteger totalOpenLiveTime;

@property (nonatomic, assign) BOOL finishCountDown;

/** 点亮数 */
@property (nonatomic, assign) NSInteger lightCount;

/** 评论数 */
@property (nonatomic, assign) NSInteger commentCount;

/** 弹幕数 */
@property (nonatomic, assign) NSInteger bulletCount;

/** 钻石数 */
@property (nonatomic, assign) NSInteger diamondCount;

/** 新增粉丝数 */
@property (nonatomic, assign) NSInteger newFansCount;

/** 当前电量量 */
@property (nonatomic, assign) CGFloat   currentBatteryLevel;

/** 丢包率 */
@property (nonatomic, assign) CGFloat   lossPacketRate;

/** 观众数边界（用户总数达到10、100、300时，提示主播引导用户关注自己） */
@property (nonatomic) NSUInteger userNumberBoundary;

/** 主播开播时系统消息提示，每隔5秒提示一次，提示完本次开播期间不再提示 */
@property (nonatomic) NSMutableArray *openingMessages;

@end

@implementation FBLiveOnViewController

#pragma mark - Init -
- (instancetype)init {
    if (self = [super init]) {
        self.broadcaster = [[FBLoginInfoModel sharedInstance] user];
        self.liveType = kLiveTypeBroadcast;
        self.roomID = @"0";
    }
    return self;
}

#pragma mark - Life Cycle -
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _isPublishConnected = NO;
    _firstPublishConnected = NO;
    _hasReconnected = NO;
    _finishCountDown = NO;
    _recorder = nil;
    _reconnectCount = 0;
    _prePareCount = 0;
    _timeQueryBegin = 0;
    _summaryReconnectCount = 0;
    _startLiveTimes = 0;
    _totalOpenLiveTime = 0;
    _stopLiveFailureTimes = 0;
    _lightCount = 0;
    _commentCount = 0;
    _bulletCount = 0;
    _diamondCount = 0;
    _newFansCount = 0;
    _lossPacketRate = 0;
    //设置session
    [self setupSession];
    
    [self.view addSubview:self.prePareView];
    
    [self prepareOpenLive];
    
    //禁止休眠
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    [[FBGAIManager sharedInstance] ga_sendScreenHit:@"开播准备"];
    
    self.enterTime = [[NSDate date] timeIntervalSince1970];
    
    _currentBatteryLevel = [FBUtility getBatteryLevel];

    [self checkEditPortarit];

}

-(void)dealloc
{
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    
    NSLog(@"dealloc: %@", self);
}

#pragma mark - Getter & Setter -
- (void)onTouchButtonClose {
    [super onTouchButtonClose];
    [self askToLogout];
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS action:@"关闭" label:[[FBLoginInfoModel sharedInstance] userID] value:@(1)];
}

- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[FBLiveLoadingView alloc] initWithFrame:self.view.bounds andPortrait:self.broadcaster.portrait currentImg:self.broadcaster.avatarImage];
        [_loadingView setTips:kLocalizationLoading];
    }
    return _loadingView;
}

- (NSMutableArray *)openingMessages {
    if (!_openingMessages) {
        _openingMessages = [NSMutableArray arrayWithObjects:kLocalizationAssistant1,
                            kLocalizationAssistant2, kLocalizationAssistant3, kLocalizationAssistant4,
                            kLocalizationAssistant5, nil];
    }
    return _openingMessages;
}

#pragma mark - UI Management -
/** 配置UI */
- (void)configUI {
    [self.view addSubview:self.infoContainer];
    [self.view addSubview:self.closeButton];
    UIView *superView = self.view;
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(38, 38));
        make.right.equalTo(superView);
        make.top.equalTo(superView).offset(20);
    }];
}

#pragma mark - Network Management -
/**
 *  收到房间的相关状态
 */
-(void)onRoomStatus:(uint16_t)status
{
    if(kRetCodeServerSuccess == status) {
        [self.infoContainer.contentView showSocketErrorView:NO];
        
        NSLog(@"join room success");
    } else {
        [self.infoContainer.contentView showSocketErrorView:YES];
        
        NSLog(@"room states changed: %zd", status);
    }
}

/**
 *  房间内收到的消息
 */
-(void)onMessage:(uint64_t)uid msgType:(uint32_t)type message:(NSString*)msg
{
    //解包
    NSDictionary* param = [FBMsgPacketHelper unpackRoomMsg:msg withType:type];
    switch (type) {
        case KMsgTypeFirstHit: //点亮
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            UIColor *color = param[COLOR_KEY];
            
            if(fromUser.userID) {
                // 自己发送的点亮在本地回显
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    FBMessageModel *message = [[FBMessageModel alloc] init];
                    message.type = kMessageTypeHit;
                    message.fromUser = fromUser;
                    message.hitColor = color;
                    [self.infoContainer.contentView receiveMessage:message];
                    
                    _lightCount++;
                }
            }
        }
            break;
        case KMsgTypeLike: //点赞
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            UIColor *color = param[COLOR_KEY];
            if(fromUser.userID) {
                // 自己发送的点赞在本地回显，这里不显示
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    [self.infoContainer.contentView receiveLike:color];
                }
            }
            
        }
            break;
        case kMsgTypeRoomChat:  //普通消息
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            NSString* content = param[MESSAGE_KEY];
            NSInteger subType = [param[MESSAGE_SUBTYPE_KEY] integerValue];
            
            FBMessageType messageType = kMessageTypeDefault;
            switch (subType) {
                case kMsgSubTypeNormal:
                    messageType = kMessageTypeDefault;
                    break;
                case kMsgSubTypeFollow:
                    messageType = kMessageTypeFollow;
                    _newFansCount++;
                    break;
                case kMsgSubTypeShare:
                    messageType = kMessageTypeShare;
                    break;
                default:
                    break;
            }
            
            if(fromUser.userID) {
                // 自己发送的消息在本地回显
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    FBMessageModel *message = [[FBMessageModel alloc] init];
                    message.fromUser = fromUser;
                    message.content = content;
                    message.type = messageType;
                    [self.infoContainer.contentView receiveMessage:message];
                    
                    if(kMsgSubTypeNormal == subType) {
                        _commentCount++;
                    }
                }
            }
        }
            break;
        case KMsgTypeGift: //送礼
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            FBUserInfoModel* toUser = param[TOUSER_KEY];
            FBGiftModel* gift = param[GIFT_KEY];
            
            if(fromUser.userID) {
                // 自己发送的礼物在本地回显
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    gift.fromUser = fromUser;
                    gift.toUser = toUser;
                    [self.infoContainer.contentView receiveGift:gift];
                    
                    // 在公屏显示送礼消息
                    NSString *message = [NSString stringWithFormat:@"%@ %@", kLocalizationSendGift, gift.name];
                    FBMessageModel *model = [[FBMessageModel alloc] init];
                    model.fromUser = fromUser;
                    model.content = message;
                    model.type = kMessageTypeGift;
                    [self.infoContainer.contentView receiveMessage:model];
                }
            }
            
            _diamondCount += [gift.gold integerValue];
        }
            break;
        case kMsgTypeBullet: //弹幕
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            NSString* message = param[MESSAGE_KEY];
            if(fromUser.userID) {
                // 自己发送的消息在本地回显
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    FBMessageModel *model = [[FBMessageModel alloc] init];
                    model.fromUser = fromUser;
                    model.content = message;
                    model.type = kMessageTypeDanmu;
                    [self.infoContainer.contentView receiveMessage:model];
                    
                    _bulletCount++;
                }
            }
        }
            break;
        case kMsgTypeDiamondTotalCount: //总的钻石数
        {
            // 如果钻石数变化与礼物动画不必保持一致，则可以更新钻石数
            if (NO == DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED) {
                NSInteger count = [param[DIAMONDCOUNT_KEY] integerValue];
                [self.infoContainer.contentView updateDiamondCount:count];
            }
        }
            break;
        case kMsgTypeBanOpenLive: //封禁
        {
            NSInteger day = [param[BANED_DAY] integerValue];
            if(1 == day) {
                [self onPlayerLogoutWithNormaly:NO];
                
                [UIAlertView bk_showAlertViewWithTitle:@"" message:kLocalizationBanOneDayTip cancelButtonTitle:kLocalizationIKnowThat otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            } else if(-1 == day) { //forever
                [self onPlayerLogoutWithNormaly:NO];
                
                [UIAlertView bk_showAlertViewWithTitle:@"" message:kLocalizationBanForeverTip cancelButtonTitle:kLocalizationIKnowThat otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            }
        }
            break;
        case kMsgTypeRoomManager:   //频道管理
        {
            FBRoomManagerModel *model = param[CHANNELMANAGER_KEY];
            
            [self onRoomManagerEvent:model];
        }
            break;
        case kMsgTypeUserEnter: {
            FBUserInfoModel *user = param[FROMUSER_KEY];
            NSDictionary *detail = param[USER_ENTER_INFO_KEY];
            NSInteger effect = [detail[@"effect"] integerValue];
            // 普通观众入场
            if (1 == effect) {
                FBMessageModel *message = [FBMessageModel enterMessageForCommonUser:user];
                [self.infoContainer.contentView receiveMessage:message];
            // 土豪观众入场
            } else if (2 == effect) {
                [self.infoContainer.contentView enterUser:user];
                FBMessageModel *message = [FBMessageModel enterMessageForVIP:user];
                [self.infoContainer.contentView receiveMessage:message];
            }
        }
            break;
        default:
            break;
    }
}

- (void)onRoomManagerEvent:(FBRoomManagerModel*)model
{
    NSString *eventString = model.event;
    if([eventString isEqualToString:kEventSetManager]) { //设置管理员
        FBMessageModel *message = [FBUtility talkMessageWithType:kMessageTypeAuthorize content:[NSString stringWithFormat:kLocalizationSetSomeoneManger, model.user.nick]];
        [self.infoContainer.contentView receiveMessage:message];
    } else if([eventString isEqualToString:kEventUnsetManager]) { //取消管理员
        FBMessageModel *message = [FBUtility talkMessageWithType:kMessageTypeUnauthorize content:[NSString stringWithFormat:kLocalizationRemoveSomeoneManager, model.user.nick]];
        [self.infoContainer.contentView receiveMessage:message];
    } else if([eventString isEqualToString:kEventBanTalk]) { //禁言
        /**
         // 关闭禁言屏显
         FBMessageModel *message = [FBUtility talkMessageWithType:kMessageTypeTalkBanned content:[NSString stringWithFormat:kLocalizationBanSomeoneTalk, model.user.nick]];
         [self.infoContainer.contentView receiveMessage:message];
         */
    } else if([eventString isEqualToString:kEventUnbanTalk]) { //解除禁言
        
    } else if([eventString isEqualToString:kEventbanUser]) { //封锁用户
        
    } else if([eventString isEqualToString:kEventUnbanUser]) { //解除封锁用户
        
    }
}

/** 查询收到的钻石礼物 */
- (void)requestForDiamondValue {
    __weak typeof(self) wself = self;
    [[FBProfileNetWorkManager sharedInstance] loadProfitRecordWithUserID:[wself.broadcaster userID] success:^(id result) {
        NSInteger count = [result[@"inout"][@"point"] integerValue];
        // 对外广播收到的钻石数量
        [wself broadcastDiamondCount:count];
        [wself.infoContainer.contentView updateDiamondCount:count];
    } failure:^(NSString *errorString) {
        
    } finally:^{
        //
    }];
}

- (void)requestForAuthorizingTalkManager:(FBUserInfoModel *)user {
    [[FBLiveTalkNetworkManager sharedInstance] setManagerWithUserID:user.userID success:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) { // 设置管理员成功
            user.isTalkManager = YES;
        } else if (505 == code) { // 管理员已经到上限
            //
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

- (void)requestForDeauthorizingTalkManager:(FBUserInfoModel *)user {
    [[FBLiveTalkNetworkManager sharedInstance] unsetManagerWithUserID:user.userID success:^(id result) {
        if (0 == [result[@"dm_error"] integerValue]) {
            user.isTalkManager = NO;
        }
    } failure:^(NSString *errorString) {
        //
    } finally:^{
        //
    }];
}

#pragma mark - Data Management -

#pragma mark - Event Handler -
- (void)addNotificationObservers {
    [super addNotificationObservers];
    
    __weak typeof(self) wself = self;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenLiveConnected object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"openlive stream connected");
        [wself onOpenLiveSuccess];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenLiveClosed object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"openlive stream closed");
        [wself onOpenLiveStreamClosed];
    }];
    
    //没数据发送
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOpenLiveNoneData object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself reportOpenLiveError:@"openlive nodata"];
        [wself onOpenLiveNoneData];
        NSLog(@"openlive nodata");
    }];
    
    //编码出问题
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationMediaEncoderError object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString *error = [note object];
        [wself reportOpenLiveError:error];
        NSLog(@"%@", error);
    }];
    
    
    //其他设备登录
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOtherDeviceLogin object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself onPlayerLogoutWithNormaly:NO];
        [wself dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // 切换摄像头
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationChangeCamera object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself.recorder changeCamera];
    }];
    
    //摄像头菜单
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationCameraMenu object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *dic = (NSDictionary*)[note object];
        [wself onCameraMenu:dic];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationFinishLive object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself dismissViewControllerAnimated:YES completion:nil];
    }];
    
    //bitrate更改
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationVideoBitrateChanged object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString *obj = [note object];
        [wself reportBitRateChange:obj];
    }];
    
    //开播质量
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationVideoQulityIfGood object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        BOOL isGood = [[note object] integerValue];
        [wself onNotifyVideoQulityIfGood:isGood];
    }];
    
    //group与ip地址不匹配
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLiveGroupNotMatch object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
    }];
    
    //强制退出直播间
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationForceExitLiveRoom object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself onPlayerLogoutWithNormaly:NO];
        [wself dismissViewControllerAnimated:YES completion:nil];
    }];
    
    // 主播首次收到礼物，钻石从0增加
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationReceiveGiftFirstTime
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [wself showThanksTip];
                                                  }];
    
}

-(void)addApplicationNotificationObservers
{
    __weak typeof(self)wself = self;
    //进入前台模式
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself handleEnterForgroud];
    }];
    
    //非激活状态(打电话,锁屏，切后台等)
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself handleEnterBackground];
    }];
}

/** 进入后台模式 */
-(void)handleEnterBackground
{
    [self broadcastActiveState:kBroadcasterStatusOffline];
}

/** 进入前台模式 */
-(void)handleEnterForgroud
{
    //如果切回前台模式发现断线了，则重连
    if(!_isPublishConnected) {
        [self checkReOpenLiveStream];
    }
    
    [self broadcastActiveState:kBroadcasterStatusOnline];
}

- (void)addTimers {
    [super addTimers];
    
    // 如果钻石数变更与礼物动画不必保持一致，则定时更新钻石数
    if (NO == DIAMOND_NUM_GIFT_ANIMATION_SYNC_ENABLED) {
        __weak typeof(self) wself = self;
        // 开播端定时刷新左上角收到的钻石
        if (kLiveTypeBroadcast == self.liveType) {
            if (!self.diamondTimer) {
                self.diamondTimer = [NSTimer bk_scheduledTimerWithTimeInterval:10 block:^(NSTimer *timer) {
                    [wself requestForDiamondValue];
                } repeats:YES];
            }
        }
    }
}

-(FBLivePrepareView*)prePareView
{
    if(nil == _prePareView) {
        _prePareView = [[FBLivePrepareView alloc] initWithFrame:self.view.bounds];
        
        __weak typeof(self)wself = self;
        _prePareView.doClose = ^() {
            [wself exitWithoutOpenLive];
        };
        
        _prePareView.doOpenLive = ^(BOOL useLocation, BOOL useHighQuailty, BOOL facebookShare, BOOL twitterShare, NSString *tagsString){
            if(wself) {
                wself.useLocation = useLocation;
                wself.facebookAutoShare = facebookShare;
                wself.twitterAutoShare = twitterShare;
                wself.tagsString = tagsString;
                [wself startOpenLive:YES];
                
                if(useHighQuailty) {
                    [wself.recorder setHighQuailty:useHighQuailty];
                }
                
                [wself doAutoShareFabceook:facebookShare andTwitter:twitterShare];
            }
        };
        
        // 自动分享
        BOOL shareAutomatical = YES;
        
        _prePareView.doBindFacebook = ^(){
            if (shareAutomatical) {
                [wself bindFacebook];
            } else {
                [wself shareLiveWithPlatform:kPlatformFacebook liveID:wself.liveID broadcaster:[[FBLoginInfoModel sharedInstance] user] action:kShareLiveActionClickPrepareButton];
            }
        };
        
        _prePareView.doBindTwitter = ^(){
            if (shareAutomatical) {
                [wself bindTwitter];
            } else {
                [wself shareLiveWithPlatform:kPlatformTwitter liveID:wself.liveID broadcaster:[[FBLoginInfoModel sharedInstance] user] action:kShareLiveActionClickPrepareButton];
            }
        };
        
        _prePareView.doShowRule = ^(){
            [wself gotoRules];
        };
        
    }
    return _prePareView;
}

#pragma mark - 开播相关 -x
/** 先向服务器申请直播id等相关信息 */
-(void)prepareOpenLive
{
    __weak typeof(self)wSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] prepareToOpenLiveSuccess:^(id result) {
        [wSelf onPrepareResult:result];
        NSLog(@"prepare live success");
    } failure:^(NSString *errorString) {
        [wSelf onOpenLiveFailed];
        [wSelf checkPrepareRequest];
        NSLog(@"prepare live failed");
    }];
}

-(void)onPrepareResult:(NSDictionary*)result
{
    @try {
        NSInteger retCode = [result[@"dm_error"] integerValue];
        if(50 == retCode) { //50是禁播
            NSInteger code = [result[@"code"] integerValue];
            if(412 == code) { //等级低于2级不能开播
                __weak typeof(self)weakSelf = self;
                [UIAlertView bk_showAlertViewWithTitle:@"" message:kLocalizationLowlevelToOpenLive cancelButtonTitle:kLocalizationPublicConfirm otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [weakSelf exitWithoutOpenLive];
                }];
                return;
            } else if(413 == code) { //禁播1天
                __weak typeof(self)weakSelf = self;
                [UIAlertView bk_showAlertViewWithTitle:@"" message:kLocalizationBanOneDayOpenLiveTip cancelButtonTitle:kLocalizationIKnowThat otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [weakSelf exitWithoutOpenLive];
                }];
                return;
            } else if(414 == code) { //永久禁播
                __weak typeof(self)weakSelf = self;
                [UIAlertView bk_showAlertViewWithTitle:@"" message:kLocalizationBanForeverDayOpenLiveTip cancelButtonTitle:kLocalizationIKnowThat otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [weakSelf exitWithoutOpenLive];
                }];
                return;
            }
        }
        
        //liveid或group不存在则重新拉取
        NSString *liveID = result[@"liveid"];
        NSString *group = result[@"group"];
        NSString *roomID = [NSString stringWithFormat:@"%@", result[@"roomid"]];
        if(nil == group || ![liveID isValid]) {
            [self checkPrepareRequest];
        } else {
            self.liveID = liveID;
            self.roomID = roomID;
            self.infoContainer.contentView.liveID = liveID;
            self.group = [group integerValue];
            
            //准备就绪才“开播”按钮才能点
            [_prePareView enableOpenLive:YES];
        }
    }
    @catch (NSException *exception) {
        [self checkPrepareRequest];
    }
}

-(void)checkPrepareRequest
{
    //重试1分钟
    _prePareCount++;
    if(_prePareCount < 10) {
        __weak typeof(self)weakSelf = self;
        [NSTimer bk_scheduledTimerWithTimeInterval:6 block:^(NSTimer *timer) {
            [weakSelf prepareOpenLive];
        } repeats:NO];
    } else {
        [self onPlayerLogoutWithNormaly:NO];
        
        [self displayNotificationWithMessage:kLocalizationNetworkErrorStopLive forDuration:3];
        
        // 每点击直播编辑页面的开始直播按钮＋1（陈番顺）
        [self st_reportBroadcastStartEventWithResult:@"0"];
    }
}

/** step1: 向服务器获取开播流 */
-(void)startOpenLive:(BOOL)isFirst
{
    //[self showLoading];
    
    self.live_name = [_prePareView getLiveName];
    
    //第一次才需要设置
    if(isFirst) {
        [self showCountDownView];
        
        [self setUpOpenLiveReady];
        
        [self addApplicationNotificationObservers];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *countNum = [defaults objectForKey:kUserDefaultsOpenLiveCount];
        NSInteger count = [countNum integerValue];
        count++;
        [defaults setValue:@(count) forKey:kUserDefaultsOpenLiveCount];
        [defaults setObject:@"0" forKey:kUserDefaultsNormalExitOpenLive];
        [defaults synchronize];
        
    }
    
    //获取开播流(流名用uid)
    NSString* userID = [[FBLoginInfoModel sharedInstance] userID];
    NSUInteger uid = (NSUInteger)[userID longLongValue];
    
    _timeQueryBegin = [[NSDate date] timeIntervalSince1970];
    __weak typeof(self) wSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] getPublishStreamName:userID publish:uid sesssionid:self.liveID success:^(NSString *requestUrl, id result) {
        wSelf.currentQueryUrl = requestUrl;
        [wSelf onPublishStreamResult:result];
    } failure:^(NSString *errorString) {
        //重连
        [wSelf checkReOpenLiveStream];
        [wSelf reportOpenLiveError:@"get publish stream error"];
        NSLog(@"get publish stream error");
    }];
}

-(void)onPublishStreamResult:(NSDictionary*)result
{
    NSString* url = result[@"url"];
    NSString* token = result[@"token"];
    
    if([url length] && [token length]) {
        self.currentOpenLiveUrl = url;
        //开播
        [self publishLiveWithURL:url token:token];
        
        //统计时间
        NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval interval = timeNow - _timeQueryBegin;
        int ms = (int)(interval*1000) + 1;
        self.timeQueryUse = ms;
        _timeQueryBegin = timeNow;
    } else {
        [self onOpenLiveFailed];
        
        NSString *errorMsg = [NSString stringWithFormat:@"url:%@ token:%@ invaild", url, token];
        [self reportOpenLiveError:errorMsg];
        NSLog(@"%@", errorMsg);
        
        [self checkReOpenLiveStream];
    }
}

/**  step2: 正式开播*/
-(void)publishLiveWithURL:(NSString*)url token:(NSString*)token
{
    [_recorder startWithUrl:url andToken:token];
    NSLog(@"publish stream url:%@, token:%@", url, token);
}

/**  开播成功（即正式上传开播流了）*/
-(void)onOpenLiveSuccess
{
    _isPublishConnected = YES;
    _reconnectCount = 0;
    _startLiveTimes = 0;
    [self hideLoading];
    //进房间
    [self joinRoom];
    
    //延迟5秒钟上报
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onDelayToReportOpenLive) userInfo:nil repeats:NO];
    
    //统计视频加载时间
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = timeNow - _timeQueryBegin;
    int ms = (int)(interval*1000) + 1;
    self.timeVideoLoadUse = ms;
    [[FBLiveStreamNetworkManager sharedInstance] reportDataLogWithUrl:self.currentOpenLiveUrl queryUrl:self.currentQueryUrl querySlaps:self.timeQueryUse streamSlaps:self.timeVideoLoadUse liveid:self.liveID type:@"publish" isreconnect:_hasReconnected bitRate:nil ping:nil error:nil success:^(id result) {
        NSLog(@"report openlive time use success");
    } failure:^(NSString *errorString) {
        NSLog(@"report openlive time use failure");
    } finally:^{
        
    }];
    
    if(!_firstPublishConnected) {
        _firstPublishConnected = YES;
        
        // 每点击直播编辑页面的开始直播按钮＋1（陈番顺）
        [self st_reportBroadcastStartEventWithResult:@"1"];
    }
    
    //开始统计
    [self beginSummary];
    
    if(_finishCountDown) {
        //开始计时
        [self beginTimeCount];
    }
}

-(void)onDelayToReportOpenLive
{
    //上报
    [self reportStartOpenLive];
}

-(void)onOpenLiveStreamClosed
{
    _isPublishConnected = NO;
    [self showLoading];
    
    //先关闭再重连
    [_recorder stopOpenLive];
    
    [self checkReOpenLiveStream];
    
    [self reportOpenLiveError:@"OpenLiveStreamClosed"];
}

/**
 *  开播断了重连
 */
-(void)checkReOpenLiveStream
{
    //非激活状态则不重连
    if(UIApplicationStateActive !=  [[UIApplication sharedApplication] applicationState]) {
        return;
    }
    
    [self endCheckNoData];
    
    _hasReconnected = YES;
    _reconnectCount++;
    _summaryReconnectCount++;
    
    if(_reconnectCount <= 4) {
        //重连接
        [self startOpenLive:NO];
        
        NSLog(@"reconnect times: %zd", _reconnectCount);
    } else {
        [self onPlayerLogoutWithNormaly:NO];
        
        [self displayNotificationWithMessage:kLocalizationNetworkErrorStopLive forDuration:3];
        
        // 每点击直播编辑页面的开始直播按钮＋1（陈番顺）
        [self st_reportBroadcastStartEventWithResult:@"0"];
    }
}

/** step3: 进入房间 */
-(void)joinRoom
{
    [self.infoContainer.contentView showSocketErrorView:YES];
    
    [[FBMsgService sharedInstance] setRoomEventDelegate:self];
    [[FBMsgService sharedInstance] joinRoom:self.liveID inGroup:_group isPublish:YES];
}

/** step3: 向服务器上报开播 */
-(void)reportStartOpenLive
{
    NSString *city, *longitude, *latitude;
    if(_useLocation) {
        city = [FBLocationManager city];
        longitude = [FBLocationManager longitude];
        latitude = [FBLocationManager latitude];
    } else {
        city = @"";
        longitude = @"";
        latitude = @"";
    }
    //是否上热门
    NSInteger   hotState = 1;
#ifndef DEBUG
    hotState  = 1;
#else
    hotState = 0;
#endif
    
    if(_isPublishConnected) {
        __weak typeof(self)weakSelf = self;
        [[FBLiveStreamNetworkManager sharedInstance] startToOpenLive:self.liveID name:_live_name city:city longitude:longitude latitude:latitude state:hotState location:@"" success:^(id result) {
            [weakSelf onReportStartLiveSuccess];
            NSLog(@"report start live success");
        } failure:^(NSString *errorString) {
            [weakSelf onReportStartLiveFailure];
            NSLog(@"report start live failed");
        }];
    }
}

-(void)onReportStartLiveFailure
{
    if(_isPublishConnected) {
        _startLiveTimes++;
        
        //失败后每隔10s上报1次，连续2分钟都失败则直接退出
        if(_startLiveTimes < 12) {
            [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(onDelayToReportOpenLive) userInfo:nil repeats:NO];
        } else {
            [self onPlayerLogoutWithNormaly:NO];
            
            [self displayNotificationWithMessage:kLocalizationNetworkErrorStopLive forDuration:3];
        }
    }
}

-(void)onReportStartLiveSuccess
{
    //每隔30s ping一次
    if(nil == _timerPing) {
        _timerPing = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(onKeepAlive) userInfo:nil repeats:YES];
    }
}

/** 定时ping房间*/
-(void)onKeepAlive
{
    [[FBLiveStreamNetworkManager sharedInstance] keepOpenLiveAlive:self.liveID success:^(id result) {
        NSLog(@"open live keep alive");
    } failure:^(NSString *errorString) {
        NSLog(@"faile to keep alive");
    }];
}

/** 准备就绪*/
-(void)setUpOpenLiveReady
{
    //除准备开播的view
    [_prePareView removeFromSuperview];
    _prePareView = nil;
    
    
    [self configUI];
    [self monitorLiveUsers];
}

-(void)onOpenLiveFailed {
    [self removeTimers];
}

//询问是否确定结束开播
-(void)askToLogout
{
    NSString *msg = NSLocalizedString(@"exit_play", @"你确定退出直播吗？");
    NSString *cancel = NSLocalizedString(@"global_cancel", @"取消");
    NSString *ok = NSLocalizedString(@"confirm", @"确定");
    
    __weak typeof(self)weakSelf = self;
    [UIAlertView bk_showAlertViewWithTitle:@"" message:msg cancelButtonTitle:cancel otherButtonTitles:@[ok] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if(1 == buttonIndex) {
            [weakSelf onPlayerLogoutWithNormaly:YES];
        }
    }];
}

#pragma mark - 退出开播
-(void)onPlayerLogoutWithNormaly:(BOOL)isNormally
{
    self.exitRoom = YES;
    
    [self hideLoading];
    
    [self beginDiagnosisNetWork];
    
    // 移除直播信息层
    [self.infoContainer removeFromSuperview];
    
    BOOL showNotSaveInfo = (_totalOpenLiveTime < 30*60);
    
    //提示信息页
    FBLiveEndView* view = [[FBLiveEndView alloc] initWithFrame:self.view.bounds liveid:self.liveID type:FBLiveEndViewTypeMine showNotSave:showNotSaveInfo isNetworkError:NO];
    
    NSString *timeCountString = [self getTimeCountString];
    if([timeCountString length]) {
        [view updateTimeString:timeCountString];
    }
    
    UIImage* lastView = [_recorder getLastFrame];
    [view update:[FBLoginInfoModel sharedInstance].user bkgImage:lastView];
    [self.view addSubview:view];
    
    [self exitOpenLive];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationExitLiveRoom object:nil];

    
    // 每主播进入直播结束页面（陈番顺）
    [self st_reportBroadcastEndEventWithType:isNormally];
}

-(void)exitOpenLive
{
    if(_recorder) {
        _lossPacketRate = [_recorder getLosspackRate];
        [_recorder stopPreview];
        [_recorder stopOpenLive];
    }
    
    [self reportStopOpenLive];
    
    [[FBMsgService sharedInstance] setRoomEventDelegate:nil];
    //广播退出房间
    [self broadcastExitOpenLiveMsg];
    //再退出房间
    [[FBMsgService sharedInstance] leaveRoom];
    
    [self removeTimers];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"1" forKey:kUserDefaultsNormalExitOpenLive];
    [userDefaults synchronize];
}

-(void)reportStopOpenLive
{
    if([self.liveID length]) {
        __weak typeof(self)weakSelf = self;
        [[FBLiveStreamNetworkManager sharedInstance] stopOpenLive:self.liveID success:^(id result) {
            
        } failure:^(NSString *errorString) {
            [weakSelf onStopOpenLiveFailure];
        }];
    }
}

-(void)onStopOpenLiveFailure
{
    if(_stopLiveFailureTimes < 5) {
        __weak typeof(self)weakSelf = self;
        [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
            [weakSelf reportStopOpenLive];
        } repeats:NO];
        
        _stopLiveFailureTimes++;
    }
}

//还未曾开播成功
- (void)exitWithoutOpenLive
{
    if(_recorder) {
        [_recorder stopPreview];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)removeTimers {
    [super removeTimers];
    if(_timerPing) {
        [_timerPing invalidate];
        _timerPing = nil;
    }
    
    if(_timerSummary) {
        [_timerSummary invalidate];
        _timerSummary = nil;
    }
    
    if (self.diamondTimer) {
        [self.diamondTimer invalidate];
        self.diamondTimer = nil;
    }
    
    if(_timerLiveTick) {
        [_timerLiveTick invalidate];
        _timerLiveTick = nil;
    }
    
    if(_nodataCheckTimer) {
        [_nodataCheckTimer invalidate];
        _nodataCheckTimer = nil;
    }
}

/** 准备录制相关设定*/
-(void)setupSession
{
    if(nil == _recorder) {
#if USE_MIRAEYE
        _recorder = [[FBMiraeyeRecorder alloc] init];
#else
        _recorder = [[FBRecorder alloc] init];
#endif
        
        UIView* preView = [_recorder getPreView];
        preView.frame = self.view.bounds;
        [self.view insertSubview:preView atIndex:0];
        
        [_recorder startPreview];
    }
}

#pragma mark - 发频道相关消息
/** 广播退出开播 */
-(void)broadcastExitOpenLiveMsg
{
    NSString* packString = [FBMsgPacketHelper packExitOpenLiveMsg:@""];
    [[FBMsgService sharedInstance] sendExitOpenLiveMessage:packString];
}

/** 广播主播当前状态 */
-(void)broadcastActiveState:(NSInteger)status
{
    NSString *packString = [FBMsgPacketHelper packBroadcasterState:status from:[FBLoginInfoModel sharedInstance].user];
    [[FBMsgService sharedInstance] sendBroadcasterStatusMessage:packString];
}

#pragma mark - 统计丢包重连等情况上报 -
-(void)beginSummary
{
    [self.timerSummary invalidate];
    
    __weak typeof(self)weakSelf = self;
    self.timerSummary = [NSTimer bk_scheduledTimerWithTimeInterval:60.0 block:^(NSTimer *timer) {
        [weakSelf reportSummary];
    } repeats:YES];
}

-(void)endSummary
{
    [self.timerSummary invalidate];
    self.timerSummary = nil;
}

-(void)reportSummary
{
    NSString *dropPack = [_recorder getDroupPackSummary];
    
    NSMutableString* format = [[NSMutableString alloc] init];
    [format appendString:@"<html><body>"];
    [format appendString:@"<br>"];
    
    NSString *appVersion = [NSString stringWithFormat:@"%@/%@", [FBUtility versionCode], [FBUtility buildCode]];
#if TARGET_VERSION_ENTERPRISE==1
    appVersion = [NSString stringWithFormat:@"%@_%@", appVersion, @"en"];
#else
    appVersion = [NSString stringWithFormat:@"%@_%@", appVersion, @"appstore"];
#endif
    
    [format appendFormat:@"app version:     %@<br>",  appVersion];
    [format appendFormat:@"system version:  %@<br>",  [FBUtility systemVersion]];
    [format appendFormat:@"platform:        %@<br>",  [FBUtility platform]];
    //使用硬编码
    [format appendFormat:@"video use hw accel        <br>"];
    
    [format appendFormat:@"current openlive stream:  %@<br>",  _currentOpenLiveUrl];
    if(_isPublishConnected) {
        [format appendFormat:@"current live is living: <br>"];
    } else {
        [format appendFormat:@"current live is not living: <br>"];
    }
    [format appendFormat:@"reconnect count:     %ld<br>",  (long)_summaryReconnectCount];
    [format appendFormat:@"drop packet:         %@<br>",  dropPack];
    [format appendString:@"</body></html>"];
    
    [[FBLiveStreamNetworkManager sharedInstance] reportDataLog:format success:^(id result) {
        NSLog(@"report summary success");
    } failure:^(NSString *errorString) {
        NSLog(@"report summary failure");
    } finally:^{
        
    }];
}

-(void)reportBitRateChange:(NSString*)bitString
{
    [[FBLiveStreamNetworkManager sharedInstance] reportDataLogWithUrl:self.currentOpenLiveUrl queryUrl:self.currentQueryUrl querySlaps:self.timeQueryUse streamSlaps:self.timeVideoLoadUse liveid:self.liveID type:@"bitrate" isreconnect:_hasReconnected bitRate:bitString ping:nil error:nil success:^(id result) {
        NSLog(@"report bitrate change success");
    } failure:^(NSString *errorString) {
        NSLog(@"report bitrate change failure");
    } finally:^{
        
    }];
}

-(void)reportOpenLiveError:(NSString*)errorString
{
    [[FBLiveStreamNetworkManager sharedInstance] reportDataLogWithUrl:self.currentOpenLiveUrl queryUrl:self.currentQueryUrl querySlaps:self.timeQueryUse streamSlaps:self.timeVideoLoadUse liveid:self.liveID type:@"liveerror" isreconnect:_hasReconnected bitRate:nil ping:nil error:errorString success:^(id result) {
        NSLog(@"report OpenLive error success");
    } failure:^(NSString *errorString) {
        NSLog(@"report OpenLive error failure");
    } finally:^{
        
    }];
}

/** 诊断网络 */
-(void)beginDiagnosisNetWork
{
    if([self.currentOpenLiveUrl length]) {
        [[FBNetDiagnosisReportManager sharedInstance] diagnosisWithUrl:self.currentOpenLiveUrl queryUrl:self.currentQueryUrl querySlaps:self.timeQueryUse streamSlaps:self.timeVideoLoadUse liveid:self.liveID isReconnect:_hasReconnected];
        
        NSLog(@"beginDiagnosisNetWork");
    }
    
}

-(void)onNotifyVideoQulityIfGood:(BOOL)isGood
{
    //UI
    if(isGood) {
        [self.infoContainer.contentView hideLiveQuality];
    } else {
        [self.infoContainer.contentView showLiveQuality:kLocalizationLiveonSelfBadNetWork];
        // 15秒后自动消失
        __weak typeof(self) wself = self;
        [self bk_performBlock:^(id obj) {
            [wself.infoContainer.contentView hideLiveQuality];
        } afterDelay:15];
    }
    
    //广播当前网络质量
    NSInteger status = isGood ? kBroadcasterStatusGoodNetwork : kBroadcasterStatusBadNetwork;
    [self broadcastActiveState:status];
}

-(void)onOpenLiveNoneData
{
    _nodataTimeStamp = [[NSDate date] timeIntervalSince1970];
    [_nodataCheckTimer invalidate];
    
    __weak typeof(self)weakSelf = self;
    _nodataCheckTimer = [NSTimer bk_scheduledTimerWithTimeInterval:1.0 block:^(NSTimer *timer) {
        [weakSelf onCheckNoData];
    } repeats:YES];
}

-(void)onCheckNoData
{
    //超过20s，加上原来miraeye那边的10s（共30s）则直播结束
    if([[NSDate date] timeIntervalSince1970] - _nodataTimeStamp > 20) {
        [self endCheckNoData];
        
        [self onPlayerLogoutWithNormaly:NO];
    }
}

-(void)endCheckNoData
{
    [_nodataCheckTimer invalidate];
    _nodataCheckTimer = nil;
}

-(void)onCameraMenu:(NSDictionary *)dic
{
    NSString *beautyImgName = _recorder.isBeauty ? @"live_beauty_on" : @"live_beauty_off";
    NSString *flashImgName = _recorder.isFlashOpen ? @"live_flash_on" : @"live_flash_off";
    
    
    KxMenuItem *menuBeauty = [KxMenuItem menuItem:kLocalizationRoomBeauty
                                            image:[UIImage imageNamed:beautyImgName]
                                           target:self
                                           action:@selector(changeBeauty)];
    menuBeauty.foreColor = _recorder.isBeauty ? [UIColor whiteColor] : [UIColor hx_colorWithHexString:@"#ffffff" alpha:0.5];
    
    KxMenuItem *menuFlash = [KxMenuItem menuItem:kLocalizationRoomFlash
                                           image:[UIImage imageNamed:flashImgName]
                                          target:self
                                          action:@selector(changeFlashMode)];
    menuFlash.foreColor = _recorder.isFlashOpen ? [UIColor whiteColor] : [UIColor hx_colorWithHexString:@"#ffffff" alpha:0.5];
    
    KxMenuItem *menuFlip = [KxMenuItem menuItem:kLocalizationFlipCamera
                                          image:[UIImage imageNamed:@"live_camera_flip"]
                                         target:self
                                         action:@selector(changeCamera)];
    menuFlip.foreColor = [UIColor whiteColor];
    
    NSArray *menuItems = @[menuBeauty, menuFlash, menuFlip];
    
    @try {
        CGFloat x = [dic[@"x"] floatValue];
        CGFloat y = [dic[@"y"] floatValue];
        CGFloat width = [dic[@"width"] floatValue];
        CGFloat height = [dic[@"height"] floatValue];
        
        CGRect frame = CGRectMake(x, y, width, height);
        [KxMenu showMenuInView:self.view
                      fromRect:frame
                     menuItems:menuItems];
    }
    @catch (NSException *exception) {
        
    }
}

-(void)changeBeauty
{
    [_recorder setBeauty:!_recorder.isBeauty];
}

-(void)changeFlashMode
{
    [_recorder setFlash:!_recorder.isFlashOpen];
}

-(void)changeCamera
{
    [_recorder changeCamera];
}

-(void)gotoRules
{
    FBWebViewController *webViewController = [[FBWebViewController alloc] initWithTitle:kLocalizationRules url:kAboutUsTermsURL formattedURL:YES];
    [self.navigationController pushViewController:webViewController animated:YES];
}

-(void)showLoading
{
    if(nil == self.loadingView.superview) {
        //插在信息层下
        [self.view insertSubview:self.loadingView belowSubview:self.infoContainer];
        
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    [self.loadingView startAnimate];
    [self.loadingView hideBackground:YES];
}

-(void)hideLoading
{
    [self.loadingView stopAnimate];
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}

- (void)showCountDownView {
    FBLiveCountDownView *countDownView = [[FBLiveCountDownView alloc] initWithFrame:self.view.bounds];
    __weak typeof(self)weakSelf = self;
    countDownView.finishBeginCountDown = ^() {
        [weakSelf onCountDownFinish];
    };
    
    [self.view addSubview:countDownView];
}

-(void)onCountDownFinish
{
    _finishCountDown = YES;
    
    if(self.exitRoom) {
        return;
    }
    
    if(!self.isPublishConnected) {
        [self showLoading];
    } else {
        //开始计时
        [self beginTimeCount];
    }
}

-(void)beginTimeCount
{
    if(nil == self.timerLiveTick) {
        self.timerLiveTick = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimeCount:)  userInfo:nil repeats:YES];
    }
}

-(void)onTimeCount:(NSTimer*)timer
{
    _totalOpenLiveTime++;
    
    //更新显示
    NSString *timeCountString = [self getTimeCountString];
    [self.infoContainer.contentView updateTimeCountString:timeCountString];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *countNum = [defaults objectForKey:kUserDefaultsOpenLiveCount];
    NSInteger count = [countNum integerValue];
    if(1 == count) {
        if(5 == _totalOpenLiveTime) { //设置直播页面
            [self showAvatarTip];
        } else if(5*60 == _totalOpenLiveTime) { //设置摄像头
            [self showCameraTip];
        }
    }
    
    // 主播开播后提示，每隔5秒出现一条，结束为止
    if ([self.openingMessages count] > 0) {
        if (_totalOpenLiveTime % 5 == 0) {
            NSString *content = [self.openingMessages firstObject];
            FBMessageModel *message = [FBMessageModel assistantMessageWithContent:content];
            [self.infoContainer.contentView receiveMessage:message];
            [self.openingMessages safe_removeObject:content];
        }
    }
}


-(NSString*)getTimeCountString;
{
    if(0 == _totalOpenLiveTime) {
        return @"";
    }
    
    NSInteger hour = _totalOpenLiveTime/3600;
    NSInteger minus = (_totalOpenLiveTime - hour*3600)/60;
    NSInteger sec = (_totalOpenLiveTime - hour*3600 - minus*60);
    NSString *timeCountString = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", hour, minus, sec];
    return timeCountString;
}

#pragma mark - Override -
- (void)doManagerAction:(FBUserInfoModel *)user {
    [super doManagerAction:user];
    NSString *destructiveButton = nil;
    if (user.isTalkManager) { // 管理员不允许禁言
        destructiveButton = nil;
    } else {
        if (user.isTalkBanned) { // 已经被禁言，不出现禁言菜单项
            destructiveButton = kLocalizationFrozenTalk;
        } else { // 没有被禁言，出现禁言菜单项
            destructiveButton = kLocalizationFreezeTalk;
        }
    }
    
    // 默认出现设为管理员和管理员列表菜单项
    NSArray *otherButtons = @[kLocalizationAuthorizeTalkManager, kLocalizationTalkManagers];
    if (user.isTalkBanned) { // 已经被禁言，不允许设置为管理员
        otherButtons = @[kLocalizationTalkManagers];
    } else {
        if (user.isTalkManager) { // 已经被设置为管理员，出现删除管理员菜单项
            otherButtons = @[kLocalizationDeauthorizeTalkManager, kLocalizationTalkManagers];
        }
    }
    
    [UIActionSheet presentOnView:self.view
                       withTitle:nil
                    cancelButton:kLocalizationPublicCancel
               destructiveButton:destructiveButton
                    otherButtons:otherButtons
                        onCancel:nil
                   onDestructive:^(UIActionSheet *actionSheet) {
                       NSString *buttonTitle = [actionSheet buttonTitleAtIndex:actionSheet.destructiveButtonIndex];
                       if (buttonTitle.isEqualTo(kLocalizationFreezeTalk)) { // 禁言
                           if (!user.isTalkBanned) {
                               [self banUserTalk:user]; // 没有被禁言的用户才允许对其禁言
                           }
                       }
                   } onClickedButton:^(UIActionSheet *actionSheet, NSUInteger index) {
                       NSString *buttonTitle = [actionSheet buttonTitleAtIndex:index];
                       if (buttonTitle.isEqualTo(kLocalizationAuthorizeTalkManager)) { // 设为管理员
                           [self requestForAuthorizingTalkManager:user];
                       } else if (buttonTitle.isEqualTo(kLocalizationDeauthorizeTalkManager)) { // 删除管理员
                           [self requestForDeauthorizingTalkManager:user];
                       } else if (buttonTitle.isEqualTo(kLocalizationTalkManagers)) { // 管理员列表
                           [self pushTalkManagersViewController];
                       }
                   }];
}

- (void)onUserNumberChanged:(NSUInteger)num {
    [super onUserNumberChanged:num];
    if (num < 10) {
        // 初始化边界条件为10
        if (num >= self.userNumberBoundary) {
            self.userNumberBoundary = 10;
        }
    } else if (num < 100) {
        // 调高边界条件到100
        if (num >= self.userNumberBoundary) {
            // 观众数在10~99之间，跨过10的门槛，提示一次，并且调高边界条件
            [self showBroadcastorRemindUsersToFollowTip];
            self.userNumberBoundary = 100;
        }
    } else if (num < 300) {
        // 调高边界条件到300
        if (num >= self.userNumberBoundary) {
            // 观众数在100~299之间，跨过100的门槛，提示一次，并且调高边界条件
            [self showBroadcastorRemindUsersToFollowTip];
            self.userNumberBoundary = 300;
        }
    } else {
        // 调高边界条件到300以上
        if (num >= self.userNumberBoundary) {
            // 观众数在300以上，跨过300的门槛，提示一次，并且调高边界条件到最大
            [self showBroadcastorRemindUsersToFollowTip];
            self.userNumberBoundary = INT_MAX;
        }
    }
}

#pragma mark - Navigation -
- (void)checkEditPortarit {
    NSString *uid = [FBLoginInfoModel sharedInstance].userID;
    NSString *uids = [[NSUserDefaults standardUserDefaults] stringForKey:kUserDefaultsEditPortraitUids];
    if (uids.length) {
        BOOL edit = [uids containsString:uid];
        if (!edit) {
            NSString *newUids = [uids stringByAppendingString:uid];
            [self saveUid:newUids];
            [self presentAvatarViewController];
        }
    } else {
        [self saveUid:uid];
        [self presentAvatarViewController];
    }
}

- (void)saveUid:(NSString *)userID {
    [[NSUserDefaults standardUserDefaults] setObject:userID forKey:kUserDefaultsEditPortraitUids];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)presentAvatarViewController {
    FBAvatarController *avatarController = [[FBAvatarController alloc] init];
    avatarController.type = FBAvatarViewTypeEdit;
    avatarController.imageName = [[FBLoginInfoModel sharedInstance] user].portrait;
    [self presentViewController:avatarController animated:YES completion:^{
    }];
}

/** 进入禁言管理员列表 */
- (void)pushTalkManagersViewController {
    FBTalkManagersViewController *nextViewController = [[FBTalkManagersViewController alloc] initWithBroadcaster:self.broadcaster];
    nextViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nextViewController animated:YES];
}

-(void)bindFacebook
{
    __weak typeof(self)weakSelf = self;
    [FBLoginManager loginWithType:kPlatformFacebook token:nil fromViewController:self isBindAccount:YES success:^(id result) {
        [weakSelf.prePareView notifyFacebookBookBindSuccess];
    } failure:^(NSString *errorString) {
        
    } cancel:^{
        
    } finally:^{
        
    }];

}

-(void)bindTwitter
{
    __weak typeof(self)weakSelf = self;
    [FBLoginManager loginWithType:kPlatformTwitter token:nil fromViewController:self isBindAccount:YES success:^(id result) {
        NSInteger code = [result[@"dm_error"] integerValue];
        if (0 == code) {
            [weakSelf.prePareView notifyTwitterBookBindSuccess];
        } else if (4 == code) {
            [self showProgressHUDWithTips:kLocalizationHadConnected];
        }
    } failure:^(NSString *errorString) {
        
    } cancel:^{
        
    } finally:^{
        
    }];

}

-(void)doAutoShareFabceook:(BOOL)bFacebook andTwitter:(BOOL)bTwitter
{
    if(!bFacebook && !bTwitter) {
        return;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if(bFacebook) {
        [array addObject:kPlatformFacebook];
    }
    if(bTwitter) {
        [array addObject:kPlatformTwitter];
    }
    NSMutableString *platformString = [[NSMutableString alloc] init];
    for(NSInteger i = 0; i < [array count]; i++)
    {
        if(0 == i) {
            [platformString appendString:array[i]];
        } else {
            [platformString appendString:@"@"];
            [platformString appendString:array[i]];
        }
    }
    
    NSString *sharedURLString = kURLShare(self.broadcaster.userID, self.liveID, [[FBLoginInfoModel sharedInstance] userID]);
    __weak typeof(self)weakSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] autoShareTo:platformString shareUrl:sharedURLString success:^(id result) {
        @try {
            NSInteger code = [result[@"dm_error"] integerValue];
            if (0 == code) {
                [weakSelf showShareResultHUD:YES];
                NSLog(@"auto share success");
                
                NSInteger golds = [result[@"gold"] integerValue];
                if(golds > 0) {
                    [self showGainGold:golds];
                }
            } else {
                [weakSelf showShareResultHUD:NO];
                NSLog(@"auto share failed");
            }
        } @catch (NSException *exception) {
            
        }
    } failure:^(NSString *errorString) {
        [weakSelf showShareResultHUD:NO];
        NSLog(@"auto share failed");
    } finally:^{
        
    }];
}

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

#pragma mark - Helper -
/** 显示的提示语 */
- (void)showProgressHUDWithTips:(NSString *)tips {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelText = tips;
    hud.margin = 10.f;
    hud.yOffset = 0.0f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:3];
}

#pragma mark - Statistics -
-(NSString*)getShareParam
{
    NSString *param = @"";
    if(_facebookAutoShare) {
        param = @"1";
        if(_twitterAutoShare) {
            param = @"1&2";
        }
    } else if(_twitterAutoShare) {
        param = @"2";
    }
    return param;
}

/** 每点击直播编辑页面的开始直播按钮＋1 */
- (void)st_reportBroadcastStartEventWithResult:(NSString *)result {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"camera" value:[NSString stringWithFormat:@"%d",!self.recorder.isFrontCamera]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"title" value:[NSString stringWithFormat:@"%d",(0 != [self.live_name length])]];
    
    NSString *shareParam = [self getShareParam];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"share" value:shareParam];
    NSInteger location = -1;
    if(_useLocation) {
        NSString* city = [FBLocationManager city];
        if([city length]) {
            location = 1; //定位成功
        } else {
            location = 0; //定位失败
        }
    }
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"location" value:[NSString stringWithFormat:@"%ld",(long)location]];
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"result" value:result];
    NSInteger timeUse = _timeQueryUse + _timeVideoLoadUse;
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%ld",(long)timeUse]];
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"title_tag" value:self.tagsString];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"live_start"  eventParametersArray:@[eventParmeter1, eventParmeter2, eventParmeter3, eventParmeter4, eventParmeter5, eventParmeter6, eventParmeter7, eventParmeter8]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];

}

/** 每主播进入直播结束页面 */
- (void)st_reportBroadcastEndEventWithType:(BOOL)type {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"type" value:[NSString stringWithFormat:@"%d",type]];
    long totalTime = _totalOpenLiveTime*1000;
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%ld",totalTime]];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"people" value:[NSString stringWithFormat:@"%ld",self.userCount]];
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"like" value:[NSString stringWithFormat:@"%ld",self.lightCount]];
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"comment" value:[NSString stringWithFormat:@"%ld",self.commentCount]];
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"bullet" value:[NSString stringWithFormat:@"%ld",self.bulletCount]];
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"diamonds" value:[NSString stringWithFormat:@"%ld",self.diamondCount]];
    EventParameter *eventParmeter9 = [FBStatisticsManager eventParameterWithKey:@"new_fans" value:[NSString stringWithFormat:@"%ld",self.newFansCount]];
    EventParameter *eventParmeter10 = [FBStatisticsManager eventParameterWithKey:@"reason" value:[NSString stringWithFormat:@"%d",type]];
    
    
    //耗电百分比
    CGFloat batteryLevel = [FBUtility getBatteryLevel];
    NSInteger batteryPercent = (batteryLevel - _currentBatteryLevel)*100;
    EventParameter *eventParmeter11 = [FBStatisticsManager eventParameterWithKey:@"battery" value:[NSString stringWithFormat:@"%zd",batteryPercent]];
    
    //卡顿率(卡顿时间/总时间)，这里取丢包率
    NSInteger buffer = totalTime*_lossPacketRate;
    EventParameter *eventParmeter12 = [FBStatisticsManager eventParameterWithKey:@"buffer" value:[NSString stringWithFormat:@"%zd",buffer]];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"live_end" eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4,eventParmeter5,eventParmeter6,eventParmeter7,eventParmeter8,eventParmeter9,eventParmeter10,eventParmeter11, eventParmeter12]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
