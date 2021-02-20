//
//  FBLivePlayBackViewController.m
//  LiveShow
//
//  Created by chenfanshun on 30/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLivePlayBackViewController.h"
#import "FBLiveStreamNetworkManager.h"
#import "FBMsgPacketHelper.h"
#import "FBMsgService.h"

#import "KxMovieViewController.h"
#import "FBMovieViewController.h"
#import "UIImage-Helpers.h"

#import "FBTAViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <TwitterCore/TwitterCore.h>
#import <TwitterKit/TwitterKit.h>
#import "FBGiftKeyboard.h"

#import "FBGAIManager.h"
#import "FBLiveLoadingView.h"
#import "FBLivePlayViewController.h"
#import "FBMeViewController.h"
#import "FBFollowView.h"
#import "FBServerSettingsModel.h"


@interface FBMsgModel : NSObject

@property(nonatomic, assign)long long   timeStamp;
@property(nonatomic, assign)NSInteger   type;
@property(nonatomic, strong)NSDictionary *dicMsg;

@end

@implementation FBMsgModel

@end


@interface FBLivePlayBackViewController ()<kxMovieDelegate, FBMovieDelegate>

@property(nonatomic, strong)FBRecordModel *model;

@property(nonatomic, strong)KxMovieViewController   *playerController;
//@property(nonatomic, strong)FBMovieViewController *playerController;

@property(nonatomic, strong)FBLiveLoadingView *loadingView;

@property(nonatomic, strong)NSMutableArray *arrayMsg;

@property(nonatomic, assign)NSTimeInterval timeBeginPlay;

@property(nonatomic, assign)NSTimeInterval timeVideoLoadUse;

@property(nonatomic, assign)NSTimeInterval viewTotalTime;

//观看回放多长时间弹提示窗
@property(nonatomic, assign)NSInteger      viewRecordinterrupt;

//当前播放到的位置
@property(nonatomic, assign)CGFloat         currentPosition;

@end

@implementation FBLivePlayBackViewController

-(void)dealloc
{
    NSLog(@"dealloc %@", self);
}

-(id)initWithModel:(FBRecordModel*)model
{
    if(self = [super init]) {
        self.model = model;
        self.liveID = self.model.modelID;
        self.roomID = @"0";
        self.broadcaster = self.model.user;
        self.liveType = kLiveTypeReplay;
        self.fromType = kLiveRoomFromTypeHomepage;
        self.viewTotalTime = 0;
        self.currentPosition = 0;
        
        NSInteger nInterrupt = [[FBServerSettingManager sharedInstance] replayInterrupting];
        self.viewRecordinterrupt = nInterrupt;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configUI];
    
    //开始播放
    [self beginPlay];
    
    //获取回放信息
    [self fetchRecordMessages];
    
    //上报回放
    [self reportPlayback];
    
    //打点
//    [self st_reportInBroadcastRoomEvent];
    
    self.viewTotalTime = 0;
    [self playTimeCount];
    
    //延迟5ms通知
    __weak typeof(self)weakSelf = self;
    [NSTimer bk_scheduledTimerWithTimeInterval:0.005 block:^(NSTimer *timer) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPlayMovieNow object:weakSelf];
    } repeats:NO];
}


- (void)st_reportInBroadcastRoomEvent {
    //进入直播间 in_broadcast 打点
//    
//    FBRecordModel *live = self.model;
//    
//    RoomEventParameter *eventParameter1 = [FBStatisticsManager roomEventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
//    RoomEventParameter *eventParameter2 = [FBStatisticsManager roomEventParameterWithKey:@"broadcast_type" value:@"0"];
//    RoomEventParameter *eventParameter3 = [FBStatisticsManager roomEventParameterWithKey:@"host_id" value:live.user.userID];
//    RoomEventParameter *eventParameter4 = [FBStatisticsManager roomEventParameterWithKey:@"people" value:live.clickNumber.stringValue];
//    
//    RoomEvent *roomEvent = [FBStatisticsManager roomEventWithMoudleId:0 positionId:0 roomId:live.modelID.intValue broadcastId:live.user.userID.intValue Id:@"in_broadcast" roomeventParametersArray:@[eventParameter1,eventParameter2,eventParameter3,eventParameter4]];
//    UserActionData *actionData = [FBStatisticsManager userActionDataWithSessionId:[[[NSDate alloc] init] timeIntervalSince1970] eventsArray:@[roomEvent]];
//    [FBStatisticsManager report:actionData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)configUI
{
    [self.view addSubview:self.playerController.view];
    
    UIView *superView = self.view;
    [self.view addSubview:self.loadingView];
    [self.loadingView startAnimate];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView);
    }];
    
    [self.view addSubview:self.infoContainer];
    // TODO: 解决从个人中心进入直播回放信息层会闪一下的问题
    if ([self.navigationController.viewControllers[0] isKindOfClass:[FBMeViewController class]]) {
        self.infoContainer.hidden = YES;
        __weak typeof(self) wself = self;
        [self bk_performBlock:^(id obj) {
            wself.infoContainer.hidden = NO;
        } afterDelay:0.5];
    }
    
    __weak typeof(self) wself = self;
    // 点击播放或暂停按钮
    self.infoContainer.contentView.bottomControl.replayPanel.doPlayToggleCallback = ^ (UIButton *button) {
      [wself trogglePlay];
    };
    
    // 拖动进度条
    self.infoContainer.contentView.bottomControl.replayPanel.doSlideCallback = ^ (UISlider *slider) {
        [wself onSlierChange:slider];
    };
    
    [self.view addSubview:self.closeButton];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(38, 38));
        make.right.equalTo(superView);
        make.top.equalTo(superView).offset(20);
    }];
}

-(void)beginPlay
{
    NSArray* arrayAddr = _model.arrayRecordURL;
    if(arrayAddr.count) {
        NSString* url = arrayAddr[0];
        //暂时只支持http协议
        url = [url stringByReplacingOccurrencesOfString:@"https" withString:@"http"];
        [self.playerController playWithPath:url];
        
        self.timeBeginPlay = [[NSDate date] timeIntervalSince1970];
        NSLog(@"play url: %@", url);
    } else {
        NSLog(@"play url invalid");
    }
}

-(void)reportPlayback
{
    [[FBLiveStreamNetworkManager sharedInstance] reportWatchRecordWithLiveID:_model.modelID
                                                               broadcasterID:_model.user.userID
                                                                     success:^(id result) {
                                                                         //
                                                                     }
                                                                     failure:^(NSString *errorString) {
                                                                         //
                                                                     }
                                                                     finally:^{
                                                                         //
                                                                     }];
}

-(void)fetchRecordMessages
{
    if([_model.messageURLString isValid]) {
        NSURLSessionConfiguration* defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager* manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:defaultConfig];
        
        NSURL* url = [NSURL URLWithString:_model.messageURLString];
        
        __weak typeof(self)wSelf = self;
        NSURLSessionDownloadTask* task = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:url] progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            //缓存在本地
            NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
            NSString *path = [cacheDir stringByAppendingPathComponent:response.suggestedFilename];
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            
            return fileURL;
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if(filePath) {
                if(wSelf) {
                    NSString* content = [NSString stringWithContentsOfURL:filePath encoding:NSUTF8StringEncoding error:nil];
                    [wSelf onMessageListResult:content];
                }
                
                [[NSFileManager defaultManager] removeItemAtURL:filePath error:nil];
            } else {
                NSLog(@"download path empty");
            }
        }];
        
        [task resume];
    } else {
        NSLog(@"recordmessage url invalid");
    }
}

-(void)onMessageListResult:(NSString*)result
{
    if([result length]) {
        //以换行符分开
        NSArray* list = [result componentsSeparatedByString:@"\n"];
        if(list.count) {
            if(nil == self.arrayMsg) {
                self.arrayMsg = [[NSMutableArray alloc] init];
                long long timeStampBegin = 0;
                for(NSString* item in list)
                {
                    NSData* data = [item dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary* param = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(param) {
                        @try {
                            long long timeStamp = [param[@"time"] longLongValue];
                            //第一条信息用于时间参考标准
                            if(timeStampBegin == 0) {
                                timeStampBegin = timeStamp;
                                continue;
                            }
                            
                            NSInteger type = [param[@"type"] integerValue];
                            NSString *msg = param[@"msg"];
                            NSDictionary* dicMsg = [FBMsgPacketHelper unpackRoomMsg:msg withType:type];
                            
                            FBMsgModel* model = [[FBMsgModel alloc] init];
                            //时间差
                            model.timeStamp = (timeStamp - timeStampBegin)/1000;
                            model.type = type;
                            model.dicMsg = dicMsg;
                            
                            [self.arrayMsg addObject:model];
                        }
                        @catch (NSException *exception) {
                            
                        }
                    }
                }
            }
        }
    }
}

-(NSDictionary*)getMsgFromTimeEllipse:(CGFloat)tick
{
    return nil;
}

#pragma mark - Gettter & Setter -
-(KxMovieViewController*)playerController
{
    if(nil == _playerController) {
        _playerController = [[KxMovieViewController alloc] initWithParameters:nil bouns:self.view.bounds isRealTime:NO];
        //_playerController = [[FBMovieViewController alloc] initWithParameters:nil bouns:self.view.bounds isRealTime:NO];
        _playerController.delegate = self;
    }
    return _playerController;
}

- (FBLiveLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[FBLiveLoadingView alloc] initWithFrame:self.view.bounds andPortrait:_model.user.portrait currentImg:_model.user.avatarImage];
        _loadingView.backgroundColor = [UIColor blackColor];
        [_loadingView setTips:kLocalizationLoading];
    }
    return _loadingView;
}

#pragma mark - Event Handler -
- (void)addNotificationObservers {
    [super addNotificationObservers];
    
    __weak typeof(self)weakSelf = self;
    //其他设备登录
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationOtherDeviceLogin object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [weakSelf onLogout];
    }];

    //进入回放
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationPlayMovieNow object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //非当前的才需要处理
        if(weakSelf && weakSelf != note.object) {
            [weakSelf pureLogoutTo:note.object];
        }
    }];
}


/**
 * 只移除当前viewcontroller，把前后的重新拼接
 */
- (void)pureLogoutTo:(UIViewController *)vc
{
    self.exitRoom = YES;
    
    [self.loadingView stopAnimate];
    [self.loadingView removeFromSuperview];
    
    [self.playerController closePlayStream];
    
    [self removePlayTimers];
    
    UINavigationController *nav = self.navigationController;
    NSArray *array = nav.viewControllers;
    for(NSInteger i = 0; i < [array count]; i++)
    {
        if(self == array[i]) {
            if(i > 0) {
                //前面一个
                UIViewController *vcPre = array[i-1];
                UIViewController *vcAfter = nil;
                if(i + 1 < [array count]) {
                    //后面一个
                    vcAfter = array[i + 1];
                }
                
                //先pop到前面一个
                [nav popToViewController:vcPre animated:NO];
                if(vcAfter) {
                    //再把后面的拼接回来
                    [nav pushViewController:vcAfter animated:NO];
                    [nav pushViewController:vc animated:NO];
                }
                break;
            }
        }
    }
}

#pragma mark - Override -

#pragma mark - Network Management -

#pragma mark - play action -
//切换播放/暂停
-(void)trogglePlay
{
    [self.playerController trogglePlay];
}

-(void)onSlierChange:(UISlider*)slier
{
    CGFloat progress = slier.value;
    [self.playerController setPlayProgress:progress];
}

- (void)onTouchButtonClose {
    [super onTouchButtonClose];
    [self onLogout];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationQuitMovieNow object:nil];
}

#pragma mark - 播放状态 -
-(void)onVideoWidth:(CGFloat)width height:(CGFloat)height
{
    NSLog(@"video come...");
    
    [self.loadingView stopAnimate];
    [self.loadingView removeFromSuperview];
    
    self.timeVideoLoadUse = ([[NSDate date] timeIntervalSince1970] - self.timeBeginPlay)*1000;
    // 每进入直播间＋1（陈番顺）
    [self st_reportJoinPlaybackRoomWithResult:YES];
}

-(void)onPlayError:(NSError*)error
{
    NSLog(@"play error");
    // 每进入直播间＋1（陈番顺）
    [self st_reportJoinPlaybackRoomWithResult:NO];
}

-(void)onPlayTimeOut
{
    NSLog(@"play timeout");
}

-(void)onUpdatePlayState:(BOOL)isPlaying
{
    [self.infoContainer.contentView.bottomControl.replayPanel updatePlayState:isPlaying];
}

-(void)onUpdateProgressWithPosition:(CGFloat)position duration:(CGFloat)duration
{
    [self.infoContainer.contentView.bottomControl.replayPanel updateProgressWithPosition:position duration:duration];
    
    //避免重复检查
    if((int)self.currentPosition != (int)position) {
        //检查该时间戳下是否有消息
        [self checkMsgFromTimeStamp:position];
        self.currentPosition = position;
    }
}

-(void)onBuffer:(NSTimeInterval)bufferTime
{
    
}

-(void)checkMsgFromTimeStamp:(CGFloat)timeStamp
{
    if([self.arrayMsg count]) {
        FBMsgModel* model = [[FBMsgModel alloc] init];
        model.timeStamp = (long long)timeStamp;
        
        NSRange searchRange = NSMakeRange(0, self.arrayMsg.count);
        NSInteger findIndex = [self.arrayMsg indexOfObject:model inSortedRange:searchRange options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            FBMsgModel* model1 = (FBMsgModel*)(obj1);
            FBMsgModel* model2 = (FBMsgModel*)(obj2);
            if(model1.timeStamp > model2.timeStamp) {
                return NSOrderedDescending;
            } else if(model1.timeStamp < model2.timeStamp) {
                return NSOrderedAscending;
            }
            return NSOrderedSame;
        }];
        
        if(findIndex != NSNotFound) {
            FBMsgModel* msgModel = self.arrayMsg[findIndex];
            [self onMessage:msgModel];
        }
    }
}

-(void)onMessage:(FBMsgModel*)model
{
    NSDictionary* param = model.dicMsg;
    switch (model.type) {
        case KMsgTypeFirstHit: //点亮
        {
            FBUserInfoModel* from = param[FROMUSER_KEY];
            UIColor* color = param[COLOR_KEY];
            FBMessageModel *model = [[FBMessageModel alloc] init];
            model.type = kMessageTypeHit;
            model.fromUser = from;
            model.hitColor = color;
            [self.infoContainer.contentView receiveMessage:model];
        }
            break;
        case KMsgTypeLike: //点赞
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            UIColor *color = param[COLOR_KEY];
            [self.infoContainer.contentView receiveLike:color];
        }
            break;
        case kMsgTypeRoomChat:  //普通消息
        {
            FBUserInfoModel *fromUser = param[FROMUSER_KEY];
            NSString *message = param[MESSAGE_KEY];
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
            
            FBMessageModel *model = [[FBMessageModel alloc] init];
            model.fromUser = fromUser;
            model.content = message;
            model.type = messageType;
            
            if ([message isValid]) {
                [self.infoContainer.contentView receiveMessage:model];
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
            break;
        case kMsgTypeBullet: //弹幕
        {
            FBUserInfoModel* fromUser = param[FROMUSER_KEY];
            NSString* content = param[MESSAGE_KEY];
            
            if(fromUser.userID) {
                FBMessageModel *message = [[FBMessageModel alloc] init];
                message.fromUser = fromUser;
                message.content = content;
                message.type = kMessageTypeDanmu;
                [self.infoContainer.contentView receiveMessage:message];
            }
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - 退出 -
-(void)onLogout
{
    self.exitRoom = YES;
    
    [self.loadingView stopAnimate];
    [self.loadingView removeFromSuperview];
    
    [self.playerController closePlayStream];
    
    [self removePlayTimers];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Statistics -
/** 每进入直播间＋1 */
- (void)st_reportJoinPlaybackRoomWithResult:(BOOL)result {
    
    EventParameter *eventParmeter1 = [FBStatisticsManager eventParameterWithKey:@"net" value:[NSString stringWithFormat:@"%d",[FBStatisticsManager networkType]]];
    
    EventParameter *eventParmeter2 = [FBStatisticsManager eventParameterWithKey:@"from" value:[NSString stringWithFormat:@"%zd",self.fromType]];
    
    EventParameter *eventParmeter3 = [FBStatisticsManager eventParameterWithKey:@"broadcast_id" value:self.liveID];
    
    EventParameter *eventParmeter4 = [FBStatisticsManager eventParameterWithKey:@"broadcast_type" value:@"0"];
    
    EventParameter *eventParmeter5 = [FBStatisticsManager eventParameterWithKey:@"host_id" value:self.broadcaster.userID];
    
    EventParameter *eventParmeter6 = [FBStatisticsManager eventParameterWithKey:@"result" value:[NSString stringWithFormat:@"%d",result]];
    EventParameter *eventParmeter7 = [FBStatisticsManager eventParameterWithKey:@"in_people" value:@"0"];
    
    EventParameter *eventParmeter8 = [FBStatisticsManager eventParameterWithKey:@"time" value:[NSString stringWithFormat:@"%ld", (long)self.timeVideoLoadUse]];
    
    EventParameter *eventParmeter9 = [FBStatisticsManager eventParameterWithKey:@"out_people" value:@"0"];
    
    Event *event = [FBStatisticsManager eventWithSessionId:self.enterTime ID:@"broadcast_in"  eventParametersArray:@[eventParmeter1,eventParmeter2,eventParmeter3,eventParmeter4,eventParmeter5,eventParmeter6,eventParmeter7,eventParmeter8,eventParmeter9]];
    EventsData *data = [FBStatisticsManager eventsDataWithEventsArray:@[event]];
    [FBStatisticsManager report:data];
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
    
    NSString *myID = [[FBLoginInfoModel sharedInstance] userID];
    //自己则不检查
    if([self.broadcaster.userID isEqualToString:myID]) {
        return;
    }
    
    //超过时长则弹窗提示关注
    if(self.viewRecordinterrupt == self.viewTotalTime && !self.infoContainer.contentView.followedBroadcaster) {
        [self showAlertFollow];
    }
}


-(void)showAlertFollow
{
    __weak typeof(self)weakSelf = self;
    [FBFollowView showInView:self.view withUser:self.broadcaster followAction:^() {
        [weakSelf.infoContainer.contentView requestForAddingFollow];
    }];
}

@end
