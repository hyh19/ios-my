//
//  FBHostCacheManager.m
//  LiveShow
//
//  Created by chenfanshun on 26/04/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBHostCacheManager.h"
#import "Constant+Network.h"
#include <netdb.h>
#include <arpa/inet.h>

@interface FBHostCacheManager()

@property(nonatomic, strong)NSMutableDictionary *cacheDic;

@end

@implementation FBHostCacheManager

-(id)init
{
    if(self = [super init]) {
        self.cacheDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)begin
{
    [self fetchLiveStreamHost];
    
    //每隔半个钟查一次
    [NSTimer scheduledTimerWithTimeInterval:30*60 target:self selector:@selector(fetchLiveStreamHost) userInfo:nil repeats:YES];
}

-(void)fetchLiveStreamHost
{
    __weak typeof(self)weakSelf = self;
    [self getIpFromHost:LIVE_STREAM_HOST usingBlock:^(NSString *orgHost, NSString *ip) {
        [weakSelf onResultHost:orgHost ip:ip];
    }];
}

-(void)onResultHost:(NSString*)host ip:(NSString*)ip
{
    if([host length]) {
        self.cacheDic[host] = ip;
    }
}

- (NSString*)getCacheIpFromHost:(NSString*)hostName
{
    NSString *ip = self.cacheDic[hostName];
    if([ip length]) {
        return ip;
    }
    return hostName;
}

-(void)getIpFromHost:(NSString*)host usingBlock:(void (^)(NSString *orgHost, NSString *ip))result
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        const char* szname = [host UTF8String];
        struct hostent* phot = NULL ;
        @try
        {
            phot = gethostbyname(szname);
        }
        @catch (NSException * e)
        {
            return;
        }
        
        if(phot) {
            struct in_addr ip_addr;
            memcpy(&ip_addr,phot->h_addr_list[0],4);///h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡
            
            char ip[20] = {0};
            inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
            
            NSString* strIPAddress = [NSString stringWithUTF8String:ip];
            if(result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    result(host, strIPAddress);
                });
                
                NSLog(@"host: %@ ---->ip: %@", host, strIPAddress);
            }
        }
        
    });
}

@end
