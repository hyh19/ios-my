//
//  XXLiveServer.m
//  LiveShow
//
//  Created by chenfanshun on 19/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBLiveServer.h"
#import "arc.h"

//#import "FBLibLog.h"


@interface FBLiveServer()

@property(nonatomic) dispatch_queue_t livequeue;

@property(nonatomic, assign)BOOL       isExit;

@end

//void Logger(const std::string &name, const std::string &level, const std::string &context, const char *format, va_list args) {
//    char buf[1024];
//    vsprintf(buf, format, args);
//    std::string log = name + ":" + context + ":" + buf;
//    FBLIBLOG(@"ziwen log: %s", log.c_str());
//}

@implementation FBLiveServer

+(instancetype)shareInstance
{
    static dispatch_once_t predicate;
    static id instance = nil;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(id)init
{
    if(self = [super init]) {
        self.isExit = NO;
        
        //所有网络操作都需放到此线程队列
        _livequeue = dispatch_queue_create("Live NetEvent Queue", DISPATCH_QUEUE_SERIAL);
        
        dispatch_async(_livequeue, ^{
            //初始化网络库
            if(arc::Service* service = arc::GetService()) {
                service->Init();
                
#ifdef USE_FBLIBLOG
//                arc::ExternalLogger::Set(Logger);
#endif
            }
        });
        
        //开始监听网络事件
        [self beginListenNetEvent];
    }
    return self;
}

#pragma mark -循环监听网络事件
-(void)beginListenNetEvent
{
    @synchronized (self) {
        if(self.isExit) {
            return;
        }
    }
    
    __weak typeof(self)wSelf = self;
    dispatch_async(_livequeue, ^{
        if(arc::Service* service = arc::GetService()) {
            while (!wSelf.isExit && service->Pulse()) {
                //NSLog(@"i am not sleep");
            }
            /**
             * 这里要休眠100毫秒，注意usleep的单位是百万分之一秒，不能用sleep
             * 因为sleep的单位是秒
             */
            usleep(100000);
            __weak typeof(self)wwSelf = wSelf;
            if(_livequeue) {
                dispatch_async(_livequeue, ^{
                    [wwSelf beginListenNetEvent];
                });
            }
        }
    });
}

-(dispatch_queue_t)getLiveQueue
{
    return _livequeue;
}

-(void)releaseData
{
    @synchronized (self) {
        self.isExit = YES;
    }
}

@end
