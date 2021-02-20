//
//  FBLivePlayViewController.m
//  LiveShow
//
//  Created by chenfanshun on 03/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLivePlayViewController.h"
#import "FBLiveStreamNetworkManager.h"

#import "FBMsgService.h"
#import "FBMsgPacketHelper.h"
//#import "KxMovieViewController.h"
//#import "FBMovieViewController.h"
#import "FBIJKMoiveViewController.h"
#import "FBLiveRoomViewController.h"

#import "FBLiveProtocolManager.h"
#import "FBGiftKeyboard.h"
#import "FBGiftModel.h"

#import "FBLiveEndView.h"
#import "FBTAViewController.h"
#import "FBMessageModel.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterCore/TwitterCore.h>
#import <TwitterKit/TwitterKit.h>

#import "FBGAIManager.h"

#import "FBLiveManager.h"
#import "FBLiveLoadingView.h"

#import "UIScreen+Devices.h"

#import "FBRoomManagerModel.h"
#import "FBTipAndGuideManager.h"

#define USE_PRINT_DEBUG     0

//最多重连次数
#define MAX_RECONNECT_COUNT         5

#define VIEWTAG_LIVEEND     10000


@interface FBLivePlayViewController ()<FBRoomEventDelegate, FBIJKMovieDelegate>

/** 流名称（用uid）*/
@property(nonatomic, copy)NSString  *streamName;

/** 开播者id */
/** 直播间所在分组 */
@property(nonatomic, assign)NSInteger   group;

//@property(nonatomic, strong)KxMovieViewController *playerController;
@property(nonatomic, strong)FBIJKMoiveViewController *playerController;


/** 重连次数 */
@property(nonatomic, assign)NSInteger      reconnectCount;

/** 是否重连过 */
@property(nonatomic, assign)BOOL            hasReconnected;

/** 视频是否首次加载 */
@property(nonatomic, assign)BOOL            isVideoFirstLoaded;

/** 用于统计查询用时 */
@property(nonatomic, assign)NSTimeInterval  timeQueryBegin;

/** 查询地址所耗时间(ms) */
@property(nonatomic, assign)NSInteger  timeQueryUse;

/** 视频加载所耗时间(ms) */
@property(nonatomic, assign)NSInteger  timeVideoLoadUse;

/** 当前播放url */
@property(nonatomic, strong)NSString    *currentPlayUrl;

/** 当前查询url */
@property(nonatomic, strong)NSString    *currentQueryUrl;

/** 当前直播协议（rtmp/hls） */
@property (nonatomic, strong) NSString *currentProtocol;

@property(nonatomic, strong) FBLiveLoadingView *loadingView;

/** 保存系统当前是否允许休眠 */
@property (nonatomic, assign) BOOL      savedIdleTimer;

/** 总的重连次数 */
@property (nonatomic, assign) NSInteger totalReconnectCount;

/** 检查live_id重连次数 */
@property (nonatomic, assign) NSInteger checkLiveIDCount;

/** 记录进入当前界面的时间 用于计算时间差 */
@property (nonatomic, strong) NSDate *intoDate;

/** 重连开始时间 */
@property (nonatomic, assign) NSTimeInterval reconnectBeginTime;

/** 观看时长 */
@property (nonatomic, assign)NSTimeInterval  viewTotalTime;

/** 送礼引导页 */
@property (nonatomic, strong) UIView *giftGuideView;

/** 钻石引导页 */
@property (nonatomic, strong) UIView *diamondGuideView;

/** 主播离开后，定时检查主播状态 */
@property (nonatomic, strong) NSTimer   *timerCheckBroadcasterState;

/** 主播离开时间戳 */
@property (nonatomic, assign) NSTimeInterval broadcasterAwayTime;

/** 进房间开始时间戳 */
@property (nonatomic, assign) NSTimeInterval joinRoomBeginTime;

/** 进房间所耗时间 */
@property (nonatomic, assign) NSInteger     joinRoomUseTime;

/** 当前电量量 */
@property (nonatomic, assign) CGFloat       currentBatteryLevel;

/** 缓冲时间 */
@property (nonatomic, assign) CGFloat       bufferTotalTime;

@end

@implementation FBLivePlayViewController

-(id)initWithModel:(FBLiveInfoModel*)model
{
    if(self = [super init]) {
        self.liveInfo = model;
        self.streamName = model.broadcaster.userID;
        self.liveID = model.live_id;
        self.roomID = model.roomID;
        self.group = [model.group integerValue];
        self.broadcaster = model.broadcaster;
        self.liveType = kLiveTypePlay;
        self.reconnectCount = 0;
        self.totalReconnectCount = 0;
        self.checkLiveIDCount = 0;
        self.bufferTotalTime = 0;
        self.viewTotalTime = 0;
        self.exitRoom = NO;
        self.hasReconnected = NO;
        self.isVideoFirstLoaded = YES;
        self.joinRoomUseTime = 0;
        self.currentProtocol = [[FBLiveProtocolManager sharedInstance] getPlayLiveProtocol];
        self.userCount = [self.liveInfo.spectatorNumber integerValue];
        _timeQueryBegin = [[NSDate date] timeIntervalSince1970];
        
        self.fromType = kLiveRoomFromTypeUnknown;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configUI];
    
    //禁止休眠
    _savedIdleTimer = [[UIApplication sharedApplication] isIdleTimerDisabled];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
#if USE_PRINT_DEBUG
    NSString* msg = [NSString stringWithFormat:@"region: %zd, protocol: %@", [[FBLiveProtocolManager sharedInstance] getCurrentRegion], [[FBLiveProtocolManager sharedInstance] getPlayLiveProtocol]];
    [self logPrintOutMessage:msg];
#endif

    [[FBGAIManager sharedInstance] ga_sendScreenHit:@"直播间"];
    
    [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS
                                            action:@"直播房间"
                                             label:@"PV/UUID"
                                             value:@(1)];
    
    _intoDate = [NSDate date];
    _currentBatteryLevel = [FBUtility getBatteryLevel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    NSLog(@"dealloc FbLivePlayViewController");
    [self removeLoading];
    [self sendTime];
}

/**
 *  进入直播间
 */
-(void)joinRoom
{
    [self.infoContainer.contentView showSocketErrorView:YES];
    
    [[FBMsgService sharedInstance] setRoomEventDelegate:self];
    
    [[FBMsgService sharedInstance] leaveRoom];
    [[FBMsgService sharedInstance] joinRoom:self.liveID inGroup:_group isPublish:NO];
    
    self.joinRoomBeginTime = [[NSDate date] timeIntervalSince1970];
}

/**
 *  退出房间
 */
-(void)doExitRoom
{
    [self.playerController closePlayStream];
    [self.playerController.view removeFromSuperview];
    self.playerController = nil;
    
    [[FBMsgService sharedInstance] setRoomEventDelegate:nil];
    [[FBMsgService sharedInstance] leaveRoom];
    
    //观看超过30分钟则标记一下达到评分引导条件
    if(self.viewTotalTime >= 30*60) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"1" forKey:kUserDefaultsEnableScoringGuide];
        [defaults synchronize];
    }
}

/**
 *  获取直播流
 */
-(void)fetchPlayStream
{
    _timeQueryBegin = [[NSDate date] timeIntervalSince1970];

    __weak typeof(self) weakSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] getPlayStreamName:self.streamName player:[FBLoginInfoModel sharedInstance].userID protocol:_currentProtocol session:self.liveID quality:0 success:^(NSString *requestUrl, id result) {
        weakSelf.currentQueryUrl = requestUrl;
        [weakSelf onPlayStreamResult:result];
    } failure:^(NSString *errorString) {
        NSLog(@"fetch play stream failed");
        
        [weakSelf reportLivePlayError:@"fetch play stream failed"];
        [weakSelf checkReconnect];
    }];
}

-(void)onPlayStreamResult:(NSDictionary*)result
{
    if(self.exitRoom) {
        return;
    }
    
    @try {
        NSInteger retCode = [result[@"result"] integerValue];
        
        if(0 == retCode) {
            NSString* protocol = result[@"protocol"];
            NSString* url = result[@"url"];
            if([url length]) {
                if([protocol isEqualToString:@"rtmp"]) {
                    NSArray* array = [url componentsSeparatedByString:@"?token="];
                    if(2 == [array count]) {
                        NSString* pre = array[0];
                        NSString* token = array[1];
                        url = [NSString stringWithFormat:@"%@/a conn=S:%@",pre,token];
                    }
                }
                
                self.currentPlayUrl = url;
                [self doPlay:url];
                NSLog(@"live_id: %@ playstream url: %@", _liveInfo.live_id, url);
                
                
                
                //统计视频查询时间
                NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval interval = timeNow - _timeQueryBegin;
                int ms = (int)(interval*1000) + 1;
                self.timeQueryUse = ms;
                NSString* briefUrl = [self getBriefURL:self.currentPlayUrl];
                NSString *labelString = @"视频查询";
                [[FBGAIManager sharedInstance] ga_sendTime:CATEGORY_VIDEO_STATITICS intervalMillis:ms name:briefUrl label:labelString];
                CGFloat second = ms/1000 + 0.5;
                labelString = [NSString stringWithFormat:@"%@%.1fs", labelString, second];
                [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_VIDEO_STATITICS action:briefUrl label:labelString value:@(1)];
                _timeQueryBegin = timeNow;
                
#if USE_PRINT_DEBUG
                NSString* msg = [NSString stringWithFormat:@"query url result:%@ time:%zd ms", url, ms];
                [self logPrintOutMessage:msg];
#endif
            } else {
                //检查重连
                [self checkReconnect];
                [self reportLivePlayError:@"playurl empty"];
                NSLog(@"playurl empty");
                
#if USE_PRINT_DEBUG
                [self logPrintOutMessage:@"query playurl empty"];
#endif
            }
        } else if(4 == retCode) { //m3u8没生成
            NSLog(@"m3u8 not generate, do reconnect");
            
            [self reportLivePlayError:@"m3u8 not generate, do reconnect"];
            [self checkReconnect];
        } else { //其他情况直接退出
            NSString *errorMsg = [NSString stringWithFormat:@"fetch playstrem error, code: %ld, i'am out", (long)retCode];
            NSLog(@"%@", errorMsg);
            
            [self reportLivePlayError:errorMsg];
            [self onPlayerLogoutWithManually:NO isNetError:NO];
        }
    }
    @catch (NSException *exception) {
        //检查重连
        [self checkReconnect];
        [self reportLivePlayError:@"parse playurl exception"];
        
        NSLog(@"parse playurl exception");
        
#if USE_PRINT_DEBUG
        [self logPrintOutMessage:@"parse playurl exception"];
#endif
    }
}

-(void)checkReconnect
{
    //有重连过
    self.hasReconnected = YES;
    
    if(0 == self.reconnectCount) {
        _reconnectBeginTime = [[NSDate date] timeIntervalSince1970];
    }
    
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    self.reconnectCount++;
    //30s内
    if(!self.exitRoom && (timeNow - _reconnectBeginTime < 30)) {
        //每隔0.5 ～ 2s重新跑播放流程
        CGFloat interval = (5 + random() % 16)/10.0;
        [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(fetchPlayStream) userInfo:nil repeats:NO];
        
        NSString* msg = [NSString stringWithFormat:@"reconnect time: %zd", self.reconnectCount];
        NSLog(@"%@", msg);
        
#if USE_PRINT_DEBUG
        [self logPrintOutMessage:msg];
        [self displayNotificationWithMessage:@"网络断开，正在重新连接"
                             backgroundColor:[UIColor redColor]
                                 forDuration:2];
#endif
    } else {
        //超过重连次数就当断掉了
        [self onPlayerLogoutWithManually:NO isNetError:YES];
        
        //满足超过30s才显示（有可能切换直播后还会再调，此时不该显示）
        if(timeNow - _reconnectBeginTime >= 30) {
            [self showNetError];
        }
    }
}

#pragma mark - 播放
-(void)doPlay:(NSString*)url
{
    if(nil == self.playerController) {
        //self.playerController = [[KxMovieViewController alloc] initWithParameters:nil bouns:self.view.bounds isRealTime:YES];
        self.playerController = [[FBIJKMoiveViewController alloc] initWithParameters:nil bouns:self.view.bounds isRealTime:YES];
        self.playerController.delegate = self;
        //插在loading下面
        [self.view insertSubview:self.playerController.view belowSubview:self.loadingView];
    }
    [self.playerController playWithPath:url];
}

#pragma mark - Getter & Setter -
- (UIView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[FBLiveLoadingView alloc] initWithFrame:self.view.bounds andPortrait:self.broadcaster.portrait currentImg:self.broadcaster.avatarImage];
    }
    return _loadingView;
}

- (UIView *)giftGuideView {
    if (!_giftGuideView) {
        _giftGuideView = [[UIView alloc] init];
        _giftGuideView.backgroundColor = [UIColor hx_colorWithHexString:@"000000" alpha:0.3];
        [_giftGuideView bk_whenTouches:1 tapped:1 handler:^{
            [_giftGuideView removeFromSuperview];
        }];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:@"room_icon_guide_gift"];
        [imageView debug];
        [_giftGuideView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([[UIScreen mainScreen] isThreeFivePhone]) {
                make.size.equalTo(CGSizeMake(30, 120));
            }
            else if ([[UIScreen mainScreen] isFourPhone]) {
                make.size.equalTo(CGSizeMake(60, 220));
            }
            else {
                make.size.equalTo(CGSizeMake(102, 340));
            }
//            make.size.equalTo(CGSizeMake(102, 340));
            make.left.equalTo(_giftGuideView).offset(10);
            make.top.equalTo(_giftGuideView).offset(105);
        }];
        
        UITextView *textView = [[UITextView alloc] init];
        textView.backgroundColor = [UIColor clearColor];
        textView.textColor = [UIColor whiteColor];
        textView.font = FONT_SIZE_15;
        textView.editable = NO;
        textView.userInteractionEnabled = NO;
        textView.text = kLocalizationGuideGift;
        [textView debugWithBorderColor:[UIColor blueColor]];
        [_giftGuideView addSubview:textView];
        [textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_giftGuideView).insets(UIEdgeInsetsMake(165, 80, 0, 40));
        }];
        
    }
    return _giftGuideView;
}

- (void)setUserCount:(NSUInteger)userCount {
    [super setUserCount:userCount];
    if (!self.exitRoom) {
        NSDictionary *userInfo = @{@"count"  : @(userCount),
                                   @"liveID" : self.liveID};
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateLiveUsersCount object:self.liveInfo userInfo:userInfo];
    }
}

#pragma mark - Event Handler -
- (void)onTouchButtonClose {
    [super onTouchButtonClose];
    [self onPlayerLogoutWithManually:YES isNetError:NO];
}

- (void)addNotificationObservers {
    [super addNotificationObservers];
    __weak typeof(self) wself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationFinishLive object:nil queue:nil usingBlock:^(NSNotification *note) {
        [wself destoryViewController];
    }];
    
    //其他设备登录
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOtherDeviceLogin object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself onPlayerLogoutWithManually:YES isNetError:NO];
    }];
    
    //播放完了，再跑重连逻辑
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationFinishPlayMovie object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        FBIJKMoiveViewController *player = [note object];
        if(player == wself.playerController) {
            [wself showLoadingWithTips:kLocalizationLoading hideBackground:(wself.totalReconnectCount > 0)];
            [wself checkReconnect];
        }
    }];
    
    //播放器错误日志
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPlayErrorLog object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        NSString *msg = [note object];
        [wself reportLivePlayError:msg];
    }];
    
    //group与ip地址不匹配
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationLiveGroupNotMatch object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
    }];
    
    //强制退出直播间
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationForceExitLiveRoom object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself onPlayerLogoutWithManually:YES isNetError:NO];
    }];
    
    //有播放在进行
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPlayMovieNow object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself.playerController pause];
    }];
    
    //有播放退出
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationQuitMovieNow object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [wself.playerController play];
    }];
}

/** 显示送礼引导页 */
- (void)showGiftGuide {
    self.giftGuideView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGH);
    [self.view addSubview:self.giftGuideView];
    [FBTipAndGuideManager addCountInUserDefaultsWithType:kGuideSendGift];
}

/** 隐藏送礼引导页 */
- (void)hideGiftGuide {
    [self.giftGuideView removeFromSuperview];
    self.giftGuideView = nil;
}

#pragma mark - Override -

- (void)onNotificationOpenGiftKeyboard:(NSNotification *)note {
    [super onNotificationOpenGiftKeyboard:note];
    if (DIAMOND_NUM_ENABLED) {
        NSUInteger count = [FBTipAndGuideManager countInUserDefaultsWithType:kGuideSendGift];
        if (0 == count) {
            [self showGiftGuide];
        }
    }
}

#pragma mark - Network Management -
/** 发送停留时长 */
- (void)sendTime {
    NSTimeInterval seconds = [_intoDate timeIntervalSinceNow];
//    NSString *label = [NSString stringWithFormat:@"%@,%lf",[[FBLoginInfoModel sharedInstance] userID],-seconds];
    
    if (seconds <= 30) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS action:@"页面停留" label:@"页面停留30s" value:@(1)];
    } else if (seconds <= 60) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS action:@"页面停留" label:@"页面停留60s" value:@(1)];
    } else if (seconds <= 90) {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS action:@"页面停留" label:@"页面停留90s" value:@(1)];
    } else {
        [[FBNewGAIManager sharedInstance] ga_sendEvent:CATEGORY_ROOM_STATITICS action:@"页面停留" label:@"页面停留90s以上" value:@(1)];
    }
    
    [[FBNewGAIManager sharedInstance] ga_sendTime:CATEGORY_ROOM_STATITICS intervalMillis:-seconds name:[[FBLoginInfoModel sharedInstance] userID] label:@"平均停留时长"];
    
}

/**
 *  收到房间的相关状态
 */
-(void)onRoomStatus:(uint16_t)status
{
    if(kRetCodeServerSuccess == status) {
        
        [[FBLiveStreamNetworkManager sharedInstance] reportWatchLiveWithLiveID:self.liveID
                                                                 broadcasterID:self.broadcaster.userID
                                                                       success:^(id result) {
                                                                           //
                                                                       }
                                                                       failure:^(NSString *errorString) {
                                                                           //
                                                                       }
                                                                       finally:^{
                                                                           //
                                                                       }];
        
        [self.infoContainer.contentView showSocketErrorView:NO];
        
        self.joinRoomUseTime = ([[NSDate date] timeIntervalSince1970] - self.joinRoomBeginTime)*1000;
    } else {
        [self.infoContainer.contentView showSocketErrorView:YES];
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
            
            // 自己发送的点亮在本地回显
            if(fromUser.userID) {
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    FBMessageModel *message = [[FBMessageModel alloc] init];
                    message.type = kMessageTypeHit;
                    message.fromUser = fromUser;
                    message.hitColor = color;
                    [self.infoContainer.contentView receiveMessage:message];
                }
            }

        }
            break;
        case KMsgTypeLike: //点赞
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            UIColor *color = param[COLOR_KEY];
            // 自己发送的点赞在本地回显，这里不显示
            if(fromUser.userID) {
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    [self.infoContainer.contentView receiveLike:color];
                }
            }
        }
            break;
        case kMsgTypeRoomChat:  //普通消息
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            NSString* message = param[MESSAGE_KEY];
            NSInteger subType = [param[MESSAGE_SUBTYPE_KEY] integerValue];
            
            FBMessageType messageType = kMessageTypeDefault;
            switch (subType) {
                case kMsgSubTypeNormal:
                    messageType = kMessageTypeDefault;
                    break;
                case kMsgSubTypeFollow:
                    messageType = kMessageTypeFollow;
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
                    FBMessageModel *messge = [[FBMessageModel alloc] init];
                    messge.fromUser = fromUser;
                    messge.content = message;
                    messge.type = messageType;
                    [self.infoContainer.contentView receiveMessage:messge];
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
                    NSString *content = [NSString stringWithFormat:@"%@ %@", kLocalizationSendGift, gift.name];
                    FBMessageModel *message = [[FBMessageModel alloc] init];
                    message.fromUser = fromUser;
                    message.content = content;
                    message.type = kMessageTypeGift;
                    [self.infoContainer.contentView receiveMessage:message];
                }
            }
        }
            break;
        case KMsgTypeExitOpenLive: //主播退出房间
        {
            NSLog(@"brocaster exit ");
            [self onPlayerLogoutWithManually:NO isNetError:NO];
        }
            break;
        case kMsgTypeBullet: //弹幕
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            NSString* content = param[MESSAGE_KEY];
            
            if(fromUser.userID) {
                // 自己发送的消息在本地回显
                if (!fromUser.userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
                    FBMessageModel *message = [[FBMessageModel alloc] init];
                    message.fromUser = fromUser;
                    message.content = content;
                    message.type = kMessageTypeDanmu;
                    [self.infoContainer.contentView receiveMessage:message];
                }
            }
        }
            break;
        case kMsgTypeBrocasterStatus: //主播状态
        {
            NSInteger state = [param[BROADCASTSTATE_KEY] integerValue];
            switch (state) {
                case kBroadcasterStatusOffline: //离开
                {
                    [self onBroadcasterAway];
                }
                    break;
                case kBroadcasterStatusOnline: //在线
                {
                    [self onBroadcasterComeback];
                }
                    break;
                case kBroadcasterStatusBadNetwork: //主播网络状态差
                {
                    [self.infoContainer.contentView showLiveQuality:kLocalizationLiveonToWatcherBadNetWork];
                    // 15秒后自动消失
                    __weak typeof(self) wself = self;
                    [self bk_performBlock:^(id obj) {
                        [wself.infoContainer.contentView hideLiveQuality];
                    } afterDelay:15];
                }
                    break;
                case kBroadcasterStatusGoodNetwork: //主播网络状态好
                {
                    [self.infoContainer.contentView hideLiveQuality];
                }
                    break;
                default:
                    break;
            }
            
            NSLog(@"broadcaster: %@ current stat: %d", self.broadcaster.userID, (int)state);
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
        case kMsgTypeBanOpenLive: //禁播
        {
            [self onPlayerLogoutWithManually:NO isNetError:NO];
            
            FBLiveEndView *view = [self.view viewWithTag:VIEWTAG_LIVEEND];
            [view updateALertTips:kLocalizationBanBrocasterTip];
            
            [self st_reportExitLiveRoomWithResult:NO];
            [self st_reportExitLiveRoomRealTimeWithResult:5];
        }
            break;
        case kMsgTypeRoomManager:   //频道管理
        {
            FBRoomManagerModel *model = param[CHANNELMANAGER_KEY];
            
            [self onRoomManagerEvent:model];
        }
        case kMsgTypeUserEnter: {
            FBUserInfoModel *user = param[FROMUSER_KEY];
            NSDictionary *detail = param[USER_ENTER_INFO_KEY];
            NSInteger effect = [detail[@"effect"] integerValue];
            // 土豪观众入场
            if (2 == effect) {
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
    NSString *userID = [model.uid stringValue];
    if([eventString isEqualToString:kEventSetManager]) { //设置管理员
        // 判断自己是否被设置为管理员
        if (userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
            self.infoContainer.contentView.isMeTalkManager = YES;
            [self displayNotificationWithMessage:kLocalizationBeAuthorized forDuration:2];
        }
        
        FBMessageModel *message = [FBUtility talkMessageWithType:kMessageTypeAuthorize content:[NSString stringWithFormat:kLocalizationSetSomeoneManger, model.user.nick]];
        [self.infoContainer.contentView receiveMessage:message];
        
    } else if([eventString isEqualToString:kEventUnsetManager]) { //取消管理员
        // 判断自己是否被取消管理员
        if (userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
            self.infoContainer.contentView.isMeTalkManager = NO;
            [self displayNotificationWithMessage:kLocalizationBeUnauthorized forDuration:2];
        }
        
        FBMessageModel *message = [FBUtility talkMessageWithType:kMessageTypeUnauthorize content:[NSString stringWithFormat:kLocalizationRemoveSomeoneManager, model.user.nick]];
        [self.infoContainer.contentView receiveMessage:message];
    } else if([eventString isEqualToString:kEventBanTalk]) { //禁言
        // 判断自己是否被禁言
        if (userID.isEqualTo([[FBLoginInfoModel sharedInstance] userID])) {
            self.infoContainer.contentView.isMeTalkBanned = YES;
            // 关闭禁言提示
            // [self displayNotificationWithMessage:kLocalizationBeTalkBanned forDuration:2];
        }
        
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

#pragma mark - UI Management -
/** 配置UI */
- (void)configUI {
    [self showLoadingWithTips:kLocalizationLoading hideBackground:NO];
    
    UIView *superView = self.view;
    
    [self.view addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(38, 38));
        make.right.equalTo(superView);
        make.top.equalTo(superView).offset(20);
    }];
}

-(void)addBrocastInfoContainer
{
    [self.view insertSubview:self.infoContainer belowSubview:self.closeButton];
    [self monitorLiveUsers];
}

-(void)unInitUI
{
    [self.closeButton removeFromSuperview];
    self.closeButton = nil;
    
    [self.infoContainer removeFromSuperview];
    self.infoContainer = nil;
}

-(void)showLoadingWithTips:(NSString*)tips hideBackground:(BOOL)isHide
{
    if(nil == self.loadingView.superview) {
        //插在信息层下
        [self.view insertSubview:self.loadingView belowSubview:self.infoContainer];
        
        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    
    self.loadingView.hidden = NO;
    [self.loadingView setTips:tips];
    [self.loadingView startAnimate];
    [self.loadingView hideBackground:isHide];
}

-(void)hideLoading
{
    [self.loadingView stopAnimate];
    self.loadingView.hidden = YES;
}

-(void)removeLoading
{
    [self.loadingView removeFromSuperview];
    [self.loadingView stopAnimate];
    self.loadingView = nil;
}

#pragma mark - 播放状态 -
-(void)onVideoWidth:(CGFloat)width height:(CGFloat)height
{
    self.reconnectCount = 0;
    
    [self hideLoading];
    
    //统计视频加载时间
    NSTimeInterval timeNow = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval interval = timeNow - _timeQueryBegin;
    int ms = (int)(interval*1000) + 1;
    self.timeVideoLoadUse = ms;
    NSString* briefUrl = [self getBriefURL:self.currentPlayUrl];
    NSString *labelString = @"视频加载";
    [[FBGAIManager sharedInstance] ga_sendTime:CATEGORY_VIDEO_STATITICS intervalMillis:ms name:briefUrl label:labelString];
    CGFloat second = ms/1000 + 0.5;
    labelString = [NSString stringWithFormat:@"%@%.1fs", labelString, second];
    [[FBGAIManager sharedInstance] ga_sendEvent:CATEGORY_VIDEO_STATITICS action:briefUrl label:labelString value:@(1)];
    [[FBLiveStreamNetworkManager sharedInstance] reportDataLogWithUrl:self.currentPlayUrl queryUrl:self.currentQueryUrl querySlaps:self.timeQueryUse streamSlaps:ms liveid:self.liveID type:@"play" isreconnect:_hasReconnected bitRate:nil ping:nil error:nil success:^(id result) {
        NSLog(@"report time use success");
    } failure:^(NSString *errorString) {
        NSLog(@"report time use failure");
    } finally:^{
        
    }];
    
#if USE_PRINT_DEBUG
    [self logPrintOutMessage:msg];
    [self displayNotificationWithMessage:@"连接成功，开始直播"
                         backgroundColor:[UIColor blueColor]
                             forDuration:2];
#endif
    
    if(self.totalReconnectCount) {
        NSLog(@"total reconnect time count: %ld", (long)self.totalReconnectCount);
    }
    self.totalReconnectCount++;

    //首次加载视频则检查liveid是否对得上
    if(self.isVideoFirstLoaded) {
        self.isVideoFirstLoaded = NO;
        
        [self checkLiveID];
        // 每进入直播间＋1（陈番顺）
        [self st_reportJoinLiveRoomWithResult:YES];
    }
}

-(void)onPlayError:(NSError*)error
{
    [self showLoadingWithTips:kLocalizationLoading hideBackground:(_totalReconnectCount > 0)];
    
    //连接不上，修改协议再重连
    [self changePlayProtocol];

    [self checkReconnect];
    
#if USE_PRINT_DEBUG
    [self logPrintOutMessage:@"play error"];
#endif
    
    NSLog(@"play error");
}

-(void)onPlayTimeOut
{
    //kxmovie内部已经重连过来，连不上，直接退出
    [self onPlayerLogoutWithManually:NO isNetError:YES];
    
    [self showNetError];
    
    NSLog(@"play time out");
}

-(void)onUpdatePlayState:(BOOL)isPlaying
{
    
}

-(void)onUpdateProgressWithPosition:(CGFloat)position duration:(CGFloat)duration
{
    
}

-(void)onBuffer:(NSTimeInterval)bufferTime
{
    self.bufferTotalTime += bufferTime;
}

/** 切换播放协议 */
-(void)changePlayProtocol
{
    if([_currentProtocol isEqualToString:@"hls"]) {
        _currentProtocol = @"aws-hls";
    } else {
        _currentProtocol = @"hls";
    }
}

-(void)showNetError
{
    // 如果是切换房间的模式，用父控制器的提示
    if (self.parentViewController && [self.parentViewController isKindOfClass:[UIPageViewController class]]) {
        FBLiveRoomViewController *roomViewController = (FBLiveRoomViewController *)self.parentViewController.parentViewController;
        [roomViewController showNetworkError];
    } else {
        [self displayNotificationWithMessage:kLocalizationNetworkErrorStopWatch forDuration:3];
    }
}

#pragma mark - 主播退出开播 -
-(void)onPlayerLogoutWithManually:(BOOL)isManually isNetError:(BOOL)bNetError
{
    NSLog(@"onPlayerLogoutWithManually: %zd", isManually);
    self.exitRoom = YES;
    
    [self doExitRoom];
    [self removeTimers];
    
    //手动退出则直接退出viewcontroller
    //否则出现提示界面
    if(isManually) {
        [self destoryViewController];
        
        [self st_reportExitLiveRoomRealTimeWithResult:1];
    } else {
        // 移除直播信息层
        [self.infoContainer removeFromSuperview];
        self.infoContainer = nil;
        
        //回到提示界面
        [_loadingView removeFromSuperview];
        
        FBLiveEndView* view = [[FBLiveEndView alloc] initWithFrame:self.view.bounds liveid:self.liveID type:FBLiveEndViewTypeOthers showNotSave:NO isNetworkError:bNetError];
        view.fromType = self.fromType;
        view.tag = VIEWTAG_LIVEEND;
        [view update:self.broadcaster bkgImage:nil];
        [self.view addSubview:view];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationExitLiveRoom object:nil];
        
        [self st_reportExitLiveRoomRealTimeWithResult:4];
    }
    
    [[FBLiveManager sharedInstance] setCurrentLiveController:nil];
    [[FBLiveManager sharedInstance] setCurrentLiveID:@""];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];
    
    [self st_reportExitLiveRoomWithResult:!bNetError];
    
    //没加载成功过
    if(bNetError && self.isVideoFirstLoaded) {
        // 每进入直播间＋1（陈番顺）
        [self st_reportJoinLiveRoomWithResult:NO];
    }
}

-(void)destoryViewController
{
    [self removeLoading];
    
    [[FBLiveManager sharedInstance] setCurrentLiveController:nil];
    [[FBLiveManager sharedInstance] setCurrentLiveID:@""];
    
    if (self.parentViewController && [self.parentViewController isKindOfClass:[UIPageViewController class]]) {
        FBLiveRoomViewController *roomViewController = (FBLiveRoomViewController *)self.parentViewController.parentViewController;
        [roomViewController.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//测试，显示耗时
-(void)logPrintOutMessage:(NSString*)msg
{
#if USE_PRINT_DEBUG
    FBMessageModel *model = [[FBMessageModel alloc] init];
    model.fromUser = nil;
    model.content = msg;
    model.type = kMessageTypeDefault;
    [self.infoContainer.infoView receiveMessage:model];
#endif
}

-(NSString*)getBriefURL:(NSString*)url
{
    NSString* brief = url;
    NSArray* array = [url componentsSeparatedByString:@"://"];
    if(2 == array.count) {
        NSString* protocol = array[0];
        url = array[1];
        array = [url componentsSeparatedByString:@"/"];
        if(array.count) {
            url = array[0];
        }
        brief = [NSString stringWithFormat:@"%@://%@", protocol, url];
    } else {
        array = [url componentsSeparatedByString:@"/"];
        if(array.count) {
            brief = array[0];
        }
    }
    return brief;
}

#pragma mark - 开始/结束播放 -
-(void)startPlay
{
    self.exitRoom = NO;
    //获取开播流
    [self fetchPlayStream];
    
    //进入房间
    [self joinRoom];
    
    //延迟到直播逻辑才显示
    [self addBrocastInfoContainer];
    
    [[FBLiveManager sharedInstance] setCurrentLiveController:self];
    [[FBLiveManager sharedInstance] setCurrentLiveID:self.liveID];
    
    self.viewTotalTime = 0;
    [self playTimeCount];
}

-(void)endPlay
{
    self.exitRoom = YES;
    
    [self doExitRoom];
    [self removeTimers];
    
    //清除所有ui
    [self unInitUI];
    //加上初适ui（loading和关闭按钮）
    [self configUI];
    
    [[FBLiveManager sharedInstance] setCurrentLiveController:nil];
    [[FBLiveManager sharedInstance] setCurrentLiveID:@""];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:_savedIdleTimer];

    [self recommendNotification];
    
    // 每成功退出直播间＋1（陈番顺）
}

-(void)checkLiveID
{
    __weak typeof(self)weakSelf = self;
    [[FBProfileNetWorkManager sharedInstance] getUserLiveStatusWithUserID:self.broadcaster.userID success:^(id result) {
        FBLiveInfoModel* model = [FBLiveInfoModel mj_objectWithKeyValues:result[@"live"]];
        
        [weakSelf onLiveIDResult:model.live_id];
    } failure:^(NSString *errorString) {
        //重试
        [weakSelf reCheckLiveID];
    } finally:^{
    }];
}

-(void)reCheckLiveID
{
    _checkLiveIDCount++;
    
    if(_checkLiveIDCount < 6) {
        __weak typeof(self)weakSelf = self;
        [NSTimer bk_scheduledTimerWithTimeInterval:5 block:^(NSTimer *timer) {
            [weakSelf checkLiveID];
        } repeats:NO];
    }
}

-(void)onLiveIDResult:(NSString*)live_id
{
    //live_id不一致则重新进房间
    if([live_id isValid] && ![live_id isEqualToString:self.liveID]) {
        self.liveID = live_id;
        
        [self joinRoom];
        
        NSLog(@"different live id: 1: %@ 2:%@", self.liveID, live_id);
    }
}

-(void)onBroadcasterAway
{
    [self showLoadingWithTips:kLocalizationTemporyLeave hideBackground:YES];
    
    [self.playerController pause];
    
    //开始定时检查
    [self beginCheckBroadcasterState];
}

-(void)onBroadcasterComeback
{
    [self hideLoading];
    
    [self.playerController play];
    
    [self endCheckBroadcasterState];
}

-(void)beginCheckBroadcasterState
{
    [self endCheckBroadcasterState];
    
    _broadcasterAwayTime = [[NSDate date] timeIntervalSince1970];
    self.timerCheckBroadcasterState = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimerCheckBroadcasterState) userInfo:nil repeats:YES];
}

-(void)onTimerCheckBroadcasterState
{
    //超过30s还没收到回来消息则认为该消息已经丢掉了，手动收一下
    if([[NSDate date] timeIntervalSince1970] - _broadcasterAwayTime >= 30) {
        [self onBroadcasterComeback];
    }
}

-(void)endCheckBroadcasterState
{
    [self.timerCheckBroadcasterState invalidate];
    self.timerCheckBroadcasterState = nil;
}

/** 观看时间统计 */
-(void)playTimeCount
{
    if(nil == self.playTimeTimer) {
        self.playTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                              target:self
                                                            selector:@selector(onTimeCount:)
                                                            userInfo:nil
                                                             repeats:YES];
    }
}

-(void)onTimeCount:(NSTimer*)timer{
    self.viewTotalTime++;
    
    // 观看时长
    NSInteger time = (NSInteger)self.viewTotalTime;
    
    // 进入直播间第1分钟，10分钟，提示用户关注主播
    if (1*60==time || 10*60==time) {
        [self showFollowTip];
    }
    
    // 用户进入直播间第2分钟，15分钟，提示用户与主播聊天
    if (2*60==time || 15*60==time) {
        [self showChatTip];
    }
    
    // 用户进入直播间第5分钟，25分钟，提示用户分享直播
    if (5*60==time || 25*60==time) {
        [self showShareTip];
    }
    
    // 用户进入直播间第3分钟，20分钟，提示用户给主播送礼物，送过一次礼物本直播间不再提示
    if (3*60==time || 20*60==time) {
        if (0 == self.sendGiftCount) {
            [self showSendGiftTip];
        }
    }
}

-(void)removeTimers
{
    [super removeTimers];
    
    [self.timerCheckBroadcasterState invalidate];
    self.timerCheckBroadcasterState = nil;
    
    [self removePlayTimers];
}

-(void)reportLivePlayError:(NSString*)errorString
{
    [[FBLiveStreamNetworkManager sharedInstance] reportDataLogWithUrl:self.currentPlayUrl queryUrl:self.currentQueryUrl querySlaps:self.timeQueryUse streamSlaps:0 liveid:self.liveID type:@"playerror" isreconnect:_hasReconnected bitRate:nil ping:nil error:errorString success:^(id result) {
        NSLog(@"report live play success");
    } failure:^(NSString *errorString) {
        NSLog(@"report live play failure");
    } finally:^{
        
    }];
}

#pragma mark - Override
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
    
    [UIActionSheet presentOnView:self.view
                       withTitle:nil
                    cancelButton:kLocalizationPublicCancel
               destructiveButton:destructiveButton
                    otherButtons:nil
                        onCancel:nil
                   onDestructive:^(UIActionSheet *actionSheet) {
                       NSString *buttonTitle = [actionSheet buttonTitleAtIndex:actionSheet.destructiveButtonIndex];
                       if (buttonTitle.isEqualTo(kLocalizationFreezeTalk)) { // 禁言
                           if (!user.isTalkBanned) { // 没有被禁言的用户才允许对其禁言
                               [self banUserTalk:user];
                           }
                       }
                   } onClickedButton:^(UIActionSheet *actionSheet, NSUInteger index) {
                       //
                   }];
}

#pragma mark - helper -
/** 推荐通知 */
- (void)recommendNotification{
    // 在退出观看直播时，本地记录用户观看直播的次数
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults valueForKey:kUserDefaultsWatch]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:0] forKey:kUserDefaultsWatch];
    }
    NSInteger num = [[defaults valueForKey:kUserDefaultsWatch] integerValue];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:(num + 1)] forKey:kUserDefaultsWatch];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 用户是否有关注的人数
    NSArray *replayFollowFansNum = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaultsReplayFollowFansNumber];
    NSString *followNum = replayFollowFansNum[1];
    
    // 用户是否在观看过程中关注了主播
    NSString *enableFollow = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsEnableFollow];
    
    // 用户没有关注过主播、在观看的过程中并没有关注主播且在退出的同时已经观看了超过1场的直播 (新需求：改为观看1次后弹出推荐主播列表)
    if (![enableFollow isEqualToString:@"follow"] && (num > 0) && [followNum isEqualToString:@"0"]) {
        
        // 通知推荐主播列表
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"enableRecommend" forKey:kUserDefaultsEnableRecommend];
        [defaults synchronize];
    }
}

#pragma mark - Statistics -
/** 每用户展示直播结束页面＋1（离线上报） */
- (void)st_reportExitLiveRoomWithResult:(BOOL)result {
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"from" value:[NSString stringWithFormat:@"%zd",self.fromType]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.liveID];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.broadcaster.userID];
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"reason" value:[NSString stringWithFormat:@"%zd",result]];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"broadcast_end"  eventParametersArray:@[eventParmeter1, eventParmeter2, eventParmeter3,eventParmeter4,eventParmeter5,eventParmeter6]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每成功退出直播间＋1（实时上报） */
- (void)st_reportExitLiveRoomRealTimeWithResult:(NSInteger)result
{
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"module_id" value:[NSString stringWithFormat:@"%zd",self.fromType]];
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.liveID];
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.broadcaster.userID];
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"reason" value:[NSString stringWithFormat:@"%zd",result]];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"chatroom" value:[NSString stringWithFormat:@"%zd",self.joinRoomUseTime]];
    NSInteger watchTime = ([[NSDate date] timeIntervalSince1970] - self.joinRoomBeginTime)*1000;
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%ld",watchTime]];
    
    //耗电百分比
    CGFloat batteryLevel = [FBUtility getBatteryLevel];
    NSInteger batteryPercent = (batteryLevel - _currentBatteryLevel)*100;
    EventParameter *eventParmeter9 = [FBStatisticsManager eventParameterWithKey:@"battery" value:[NSString stringWithFormat:@"%zd",batteryPercent]];
    
    //缓冲总时间ms
    NSInteger totalBufer = self.bufferTotalTime*1000;
    EventParameter *eventParmeter10 = [FBStatisticsManager eventParameterWithKey:@"buffer" value:[NSString stringWithFormat:@"%ld",totalBufer]];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"out_broadcast"  eventParametersArray:@[eventParmeter1, eventParmeter2, eventParmeter3,eventParmeter4,eventParmeter5,eventParmeter6, eventParmeter7, eventParmeter8,eventParmeter9, eventParmeter10]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

/** 每进入直播间＋1 */
- (void)st_reportJoinLiveRoomWithResult:(BOOL)isSuccess {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"from" value:[NSString stringWithFormat:@"%zd",self.fromType]];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.liveID];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"1"];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.broadcaster.userID];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"result" value:[NSString stringWithFormat:@"%d",isSuccess]];
    
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"in_people" value:[NSString stringWithFormat:@"%ld",self.userCount]];
    
    NSInteger timeUse = _timeQueryUse + _timeVideoLoadUse;
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%ld",timeUse]];
    
    NSInteger outpeople = 0;
    if(kLiveRoomFromTypeFollowing == self.fromType ||
       kLiveRoomFromTypeHot == self.fromType ||
       kLiveRoomFromTypeNew == self.fromType) {
        outpeople = [self.liveInfo.spectatorNumber integerValue];
    }
    EventParameter *eventParmeter9 = [FBStatisticsManager eventParameterWithKey:@"out_people" value:[NSString stringWithFormat:@"%ld",outpeople]];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"broadcast_in"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,
eventParmeter4,eventParmeter5,eventParmeter6,eventParmeter7,eventParmeter8,eventParmeter9]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
}

@end
