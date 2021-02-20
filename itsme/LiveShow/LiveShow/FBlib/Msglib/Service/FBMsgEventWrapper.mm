//
//  XXFlybirdMsgEventWrapper.cpp
//  LiveShow
//
//  Created by chenfanshun on 20/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#include "FBMsgEventWrapper.hpp"
#include "FBMsgService.h"

#import "FBLibLog.h"

FBMsgEventWrapper::FBMsgEventWrapper(FBMsgService* service)
{
    m_service = service;
}

void FBMsgEventWrapper::OnStatus(uint16_t status)
{    
    dispatch_async(dispatch_get_main_queue(), ^{
        if([m_service.msgEventDelegate respondsToSelector:@selector(onStatus:)]) {
            [m_service.msgEventDelegate onStatus:status];
        }
    });
}

void FBMsgEventWrapper::OnMessage(const std::string& msg)
{
    
    if([m_service.msgEventDelegate respondsToSelector:@selector(onMessage:)]) {
        NSData* data = [NSData dataWithBytes:msg.c_str() length:msg.length()];
        NSString* msgString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_service.msgEventDelegate onMessage:msgString];
        });
        
    };
}

void FBMsgEventWrapper::OnSDKLog(const char* log)
{
   // FBLIBLOG(@"%s", log);
}
