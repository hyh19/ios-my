//
//  XXFlybirdRoomEventWrapper.cpp
//  LiveShow
//
//  Created by chenfanshun on 20/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#include "FBRoomEventWrapper.hpp"
#include "FBMsgService.h"

FBRoomEventWrapper::FBRoomEventWrapper(FBMsgService* service)
{
    m_service = service;
}

void FBRoomEventWrapper::OnStatus(uint16_t status)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([m_service.roomEventDelegate respondsToSelector:@selector(onRoomStatus:)]) {
            [m_service.roomEventDelegate onRoomStatus:status];
        }
    });
}

void FBRoomEventWrapper::OnMessage(uint64_t uid, uint32_t type, std::string& msg)
{


    if([m_service.roomEventDelegate respondsToSelector:@selector(onMessage:msgType:message:)]) {
        NSData* data = [NSData dataWithBytes:msg.c_str() length:msg.length()];
        NSString* msgString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_service.roomEventDelegate onMessage:uid msgType:type message:msgString];
        });
    }
}