//
//  FBRtmpOpenLiveService.m
//  LiveShow
//
//  Created by chenfanshun on 19/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBRtmpOpenLiveService.h"
#import "rtmpconnection.hpp"
#import "rtmp.h"
#import "FBLiveServer.h"


@interface FBRtmpOpenLiveService()

{
    miraeyej::RtmpConnection   *rtmpConnection;
}

@property(nonatomic, copy)NSString  *url;
@property(nonatomic, copy)NSString  *token;
@property(nonatomic, assign)BOOL    isConnected;

@end

@implementation FBRtmpOpenLiveService

-(id)initWithUrl:(NSString*)url andToken:(NSString*)token;
{
    if(self = [super init]) {
        self.isConnected = NO;
        self.url = url;
        self.token = token;
        
        rtmpConnection = NULL;
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"%@ dealloc", self);
}

-(void)start
{
    dispatch_queue_t queue = [[FBLiveServer shareInstance] getLiveQueue];
    if(queue) {
        __weak typeof(self)wSelf = self;
        dispatch_async(queue, ^{
            if(wSelf) {
                tincan::ClientInfo info;
                
                NSString* name = [wSelf getAppNameFrom:wSelf.url];
                std::string strName = std::string([name UTF8String], [name length]);
                info.SetApp(strName);
                
                std::string strUrl = std::string([wSelf.url UTF8String], [wSelf.url length]);
                info.SetServerUrl(strUrl);
                info.SetObjectEncoding(amf::Encoding::AMF3);
                tincan::NetConnection *connection = tincan::CreateNetConnection();
                connection->SetClientInfo(info);
                
                std::string strToken = std::string([wSelf.token UTF8String], [wSelf.token length]);
                amf::Array array;
                array[0] = strToken;
                connection->Connect(strUrl, array, rtmp::GetProtocol());
                
                rtmpConnection = new miraeyej::RtmpConnection(wSelf, connection, true, "");
            }
        });
    }
}

-(void)stop
{
    @synchronized (self) {
        self.isConnected = NO;
    }
    
    dispatch_queue_t queue = [[FBLiveServer shareInstance] getLiveQueue];
    if(queue) {
        dispatch_async(queue, ^{
            if(rtmpConnection) {
                rtmpConnection->ReleaseService();
                rtmpConnection->Close();
                delete rtmpConnection;
                rtmpConnection = NULL;
            }
        });
    }
}

-(void)sendAudioTimeStamp:(UInt32)timeStamp withData:(NSData*)data  andLeftTime:(UInt32)lifetime
{
    dispatch_queue_t queue = [[FBLiveServer shareInstance] getLiveQueue];
    if(queue) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(queue, ^{
            @synchronized (weakSelf) {
                if(weakSelf.isConnected && rtmpConnection) {
                    @autoreleasepool {
                        std::string strData((char*)data.bytes, data.length);
                        rtmpConnection->SendAudio(timeStamp, strData, lifetime);
                    }
                }
            }
        });
    }
}

-(void)sendVideoTimeStamp:(UInt32)timeStamp withData:(NSData*)data andLeftTime:(UInt32)lifetime
{
    dispatch_queue_t queue = [[FBLiveServer shareInstance] getLiveQueue];
    if(queue) {
        __weak typeof(self)weakSelf = self;
        dispatch_async(queue, ^{
            @synchronized (weakSelf) {
                if(weakSelf.isConnected && rtmpConnection) {
                    @autoreleasepool {
                        std::string strData((char*)data.bytes, data.length);
                        rtmpConnection->SendVideo(timeStamp, strData, lifetime);
                    }
                }
            }
        });
    }
}

-(MEQos*)getQos
{
    @synchronized (self) {
        if(self.isConnected && rtmpConnection) {
            return rtmpConnection->getQos();
        }
    }

    return nil;
}

-(void)onConnected
{
    @synchronized (self) {
        self.isConnected = YES;
    }
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([weakSelf.delegate respondsToSelector:@selector(onOpenLiveConnected)]) {
            [weakSelf.delegate onOpenLiveConnected];
        }
    });
}

-(void)onClose
{
    @synchronized (self) {
        self.isConnected = NO;
    }
    
    [self stop];
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if([weakSelf.delegate respondsToSelector:@selector(onOpenLiveClosed)]) {
            [weakSelf.delegate onOpenLiveClosed];
        }
    });
}

-(NSString*)getAppNameFrom:(NSString*)url
{
    NSString* appName = @"";
    NSString* proto = @"rtmp://";
    NSRange range = [url rangeOfString:proto];
    if(range.location != NSNotFound) {
        url = [url substringFromIndex:range.length];
    }
    NSArray* spliters = [url componentsSeparatedByString:@"/"];
    if(2 == [spliters count]) {
        appName = spliters[1];
    }
    return appName;
}

@end
