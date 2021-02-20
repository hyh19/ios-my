//
//  FBMsgService.m
//  LiveShow
//
//  Created by chenfanshun on 20/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBMsgService.h"
#import "flybird.h"
#import "FBMsgEventWrapper.hpp"
#import "FBRoomEventWrapper.hpp"

#import "FBLiveStreamNetworkManager.h"
#import "FBLoginInfoModel.h"

#import "FBLibLog.h"

#define MAX_REFRECH_LIMIT   8

@interface FBAddressModel : NSObject
/**  ip地址*/
@property(nonatomic, strong)NSString*   ip;
/**  端口*/
@property(nonatomic, assign)NSInteger   port;
/**  ip所在分组*/
@property(nonatomic, assign)NSInteger   group;

@end

@implementation FBAddressModel

@end

@interface FBMsgService()

{
    FBMsgEventWrapper   *_msgEvent;
    FBRoomEventWrapper   *_roomEvent;
    flybird::IFlyBirdFlock     *_roomSession;
    NSMutableArray       *_gateWayList;
    NSMutableArray     *_roomAddressList;
    NSInteger           _refetchCount;
}

@property(nonatomic, assign) NSInteger           isExit;

@property(nonatomic) dispatch_queue_t flybirdQueue;

@end

@implementation FBMsgService


-(id)init
{
    if(self = [super init]) {
        _refetchCount = 0;
        _isExit = NO;
        _flybirdQueue = dispatch_queue_create("Flybird Net Queue", DISPATCH_QUEUE_SERIAL);
        
        //初始化网络库
        dispatch_async(_flybirdQueue, ^{
            if(flybird::IFlyBird* flybird = flybird::GetFlyBird()) {
                signal(SIGPIPE, SIG_IGN);
                flybird->Init();
                
                FBLIBLOG(@"sock init");
                
                _msgEvent = new FBMsgEventWrapper(self);
                flybird->SetEvent(_msgEvent);
                
                //开始网络事件监听
                [self beginTheLoop];
                
            }
        });
        
    }
    return self;
}

-(void)dealloc
{
    [self releaseData];
}

#pragma mark - 开始网络事件循环
-(void)beginTheLoop
{
    @synchronized (self) {
        if(_isExit) {
            NSLog(@"beginTheLoop I am exit");
            return;
        }
        
        __weak typeof(self)wSelf = self;
        dispatch_async(_flybirdQueue, ^{
            if(!wSelf.isExit) {
                if(flybird::IFlyBird* flybird = flybird::GetFlyBird()) {
                    //跑100ms
                    flybird->RunTick(100);
                    /**
                     * 这里要休眠100毫秒，注意usleep的单位是百万分之一秒，不能用sleep
                     * 因为sleep的单位是秒
                     */
                    usleep(100000);
                    
                    __weak typeof(self)wwSelf = wSelf;
                    dispatch_async(_flybirdQueue, ^{
                        [wwSelf beginTheLoop];
                    });
                }
            }
        });
    }
}

/**
 *  设置要连接到登陆的网络地址和端口
 *
 *  @param adrress 网络地址
 *  @param port    端口号
 */
-(void)setAddress:(NSString*)adrress port:(NSInteger)port
{
    dispatch_async(_flybirdQueue, ^{
        if(flybird::IFlyBird* flybird = flybird::GetFlyBird()) {
            FBLIBLOG(@"sock set address: %s", [adrress UTF8String]);
            flybird->SetAddr([adrress UTF8String], port);
        }
    });
}

/**
 *  登陆IM
 *
 *  @param token 服务器返回的token
 */
-(void)loginByToken:(NSString*)token
{
    dispatch_async(_flybirdQueue, ^{
        if(flybird::IFlyBird* flybird = flybird::GetFlyBird()) {
            FBLIBLOG(@"sock login by token: %s", [token UTF8String]);
            flybird->LoginByToken([token UTF8String]);
            
        }
    });
}

#pragma mark - 登录
-(void)login
{
    if([_gateWayList count]) {
        [self loginFromAddressList:_gateWayList];
    } else {
        [self tryToFetchGateWayAddress];
    }
    
    //预先拉直播间地址列表
    [self fetchLiveIPSWithPublish:NO];
}

-(void)tryToFetchGateWayAddress
{
    //先获取地址列表
    [[FBLiveStreamNetworkManager sharedInstance] getGateWayAddressSuccess:^(id result) {
        @try {
            if(nil == _gateWayList) {
                _gateWayList = [[NSMutableArray alloc] init];
            }
            NSMutableArray* array = [self getAddressList:result];
            if([array count]) {
                [_gateWayList addObjectsFromArray:array];
            }
            [self loginFromAddressList:_gateWayList];
        }
        @catch (NSException *exception) {
            [self checkRefetchGateWayAddress];
        }
    } failure:^(NSString *errorString) {
        [self checkRefetchGateWayAddress];
        
        //获取失败，要尝试多次
        NSLog(@"fetch gateWayList error");
    }];
}

-(void)checkRefetchGateWayAddress
{
    _refetchCount++;
    if(_refetchCount < MAX_REFRECH_LIMIT) {
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(tryToFetchGateWayAddress) userInfo:nil repeats:NO];
    }
}

/**
 *  从返回的gateway列表地址登陆
 *
 *  @param addrList 地址列表
 */
-(void)loginFromAddressList:(NSArray*)addrList
{
    if([addrList count]) {
        FBAddressModel* model = addrList[0];
        [self setAddress:model.ip port:model.port];
        
        NSString* token = [[FBLoginInfoModel sharedInstance] tokenString];
        [self loginByToken:token];
    } else {
        NSLog(@"login addresslist empty");
    }
}

-(NSMutableArray*)getAddressList:(NSDictionary*)dic
{
    @try {
        NSArray* array = dic[@"iplist"];
        if([array count]) {
            NSMutableArray* addressList = [[NSMutableArray alloc] init];
            for(NSDictionary* item in array)
            {
                NSString* addr = item[@"addr"];
                NSInteger group = [item[@"group"] integerValue];
                
                FBAddressModel* model = [[FBAddressModel alloc] init];
                model.group = group;
                //ip:port
                NSArray* separe = [addr componentsSeparatedByString:@":"];
                if(2 == [separe count]) {
                    model.ip = separe[0];
                    model.port = [separe[1] integerValue];
                } else {
                    model.ip = addr;
                    model.port = 0;
                }
                
                [addressList addObject:model];
            }
            return addressList;
        }
    }
    @catch (NSException *exception) {
        
    }
    return nil;
}

#pragma mark - 退出登录
-(void)logout
{
    dispatch_async(_flybirdQueue, ^{
        if(flybird::IFlyBird* flybird = flybird::GetFlyBird()) {
            flybird->Leave();
        }
    });
}

-(void)releaseData
{
    @synchronized (self) {
        _isExit = YES;
    }
    
//    dispatch_async(_flybirdQueue, ^{
//        if(flybird::IFlyBird* flybird = flybird::GetFlyBird()) {
//            flybird->SetEvent(NULL);
//            //flybird->Leave();
//            //flybird::Release(flybird);
//            
//            if(_msgEvent) {
//                delete _msgEvent;
//            }
//        }
//        
//        if(_roomSession) {
//            _roomSession->SetEvent(NULL);
//            _roomSession->Leave();
//        }
//        
//        if(_roomEvent) {
//            delete _roomEvent;
//        }
//        
//        NSLog(@"flybird release");
//    });
}

#pragma mark - 进出房间 -
-(void)fetchLiveIPSWithPublish:(BOOL)bPublish
{
    //仅拉取ip地址列表
    [self fetchLiveIPSAndJoinRoom:@"" inGroup:0 isPublish:bPublish];
}

-(void)fetchLiveIPSAndJoinRoom:(NSString*)room_id inGroup:(NSInteger)group isPublish:(BOOL)bPublish
{
    __weak typeof(self)weakSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] getCurrentOpenLiveRoomSuccess:^(id result) {
        NSMutableArray *addressList = [self getAddressList:result];
        if([addressList count]) {
            [_roomAddressList removeAllObjects];
            _roomAddressList = addressList;
            //room_id不为空才表明需要进房间
            if([room_id length]) {
                [weakSelf joinRoom:room_id inGroup:group fromAddList:_roomAddressList isPublish:bPublish];
            }
        } else {
            FBLIBLOG(@"empty address list");
        }
        
    } failure:^(NSString *errorString) {
        FBLIBLOG(@"fetch current room address error");
    }];
}

-(void)joinRoom:(NSString*)room_id ip:(NSString*)ip port:(NSInteger)port isPublish:(BOOL)bPublish
{
    dispatch_async(_flybirdQueue, ^{
        if(NULL == _roomEvent) {
            _roomEvent = new FBRoomEventWrapper(self);
        }
        
        //先退出原来房间
        if(_roomSession) {
            _roomSession->Leave();
        }
        
        if(flybird::IFlyBird* flybird = flybird::GetFlyBird()) {
            _roomSession = flybird->JoinFlock([room_id UTF8String], bPublish ? 0xffffffff : 0
                                              , [ip UTF8String], port);
            if(_roomSession) {
                _roomSession->SetEvent(_roomEvent);
            }
        }
    });
}

-(void)joinRoom:(NSString*)room_id inGroup:(NSInteger)group fromAddList:(NSArray*)addressList isPublish:(BOOL)bPublish
{
    //ip地址要对应房间所在分组
    BOOL bMatch = NO;
    for(FBAddressModel* model in addressList)
    {
        if(model.group == group) {
            [self joinRoom:room_id ip:model.ip port:model.port isPublish:bPublish];
            bMatch = YES;
            break;
        }
    }
    if(!bMatch) {
        FBLIBLOG(@"group not match the current room address");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLiveGroupNotMatch object:nil];
    }
}

-(void)joinRoom:(NSString*)room_id inGroup:(NSInteger)group isPublish:(BOOL)bPublish
{
    if([_roomAddressList count]) {
        [self joinRoom:room_id inGroup:group fromAddList:_roomAddressList isPublish:bPublish];
        
        //每次进房间都拉一次
        [self fetchLiveIPSWithPublish:bPublish];
    } else {
        [self fetchLiveIPSAndJoinRoom:room_id inGroup:group isPublish:bPublish];
    }
}

-(void)leaveRoom
{
    dispatch_async(_flybirdQueue, ^{
        if(_roomSession) {
            _roomSession->SetEvent(NULL);
            _roomSession->Leave();
            _roomSession = NULL;
        }
    });
}

#pragma mark - 发送消息
-(void)sendMessageToRoom:(uint32_t)msgType message:(NSString*)msg
{
    dispatch_async(_flybirdQueue, ^{
        if(_roomSession) {
            _roomSession->SendMessage(msgType, [msg UTF8String]);
        }
    });
}

-(void)sendRoomMessage:(NSString*)msg
{
    [self sendMessageToRoom:kMsgTypeRoomChat message:msg];
}

-(void)sendGiftMessage:(NSString*)msg
{
    [self sendMessageToRoom:KMsgTypeGift message:msg];
}

-(void)sendFirstHitMessage:(NSString*)msg
{
    [self sendMessageToRoom:KMsgTypeFirstHit message:msg];
}

-(void)sendLikeMessage:(NSString*)msg
{
    [self sendMessageToRoom:KMsgTypeLike message:msg];
}

-(void)sendExitOpenLiveMessage:(NSString*)msg
{
    [self sendMessageToRoom:KMsgTypeExitOpenLive message:msg];
}

-(void)sendBulletMessage:(NSString*)msg
{
    [self sendMessageToRoom:kMsgTypeBullet message:msg];
}

-(void)sendBroadcasterStatusMessage:(NSString*)msg
{
    [self sendMessageToRoom:kMsgTypeBrocasterStatus message:msg];
}

-(void)sendDiamondTotalCountMessage:(NSString*)msg
{
    [self sendMessageToRoom:kMsgTypeDiamondTotalCount message:msg];
}

@end
