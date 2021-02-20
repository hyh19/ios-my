//
//  FBLiveServer.h
//  LiveShow
//
//  Created by chenfanshun on 19/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  主要用于跑开播部分的网络循环，所有开播相关的网络操作放在同一线程队列
 *  线程队列通过getLiveQueue获得
 */
@interface FBLiveServer : NSObject

+(instancetype)shareInstance;

-(dispatch_queue_t)getLiveQueue;

-(void)releaseData;

@end
