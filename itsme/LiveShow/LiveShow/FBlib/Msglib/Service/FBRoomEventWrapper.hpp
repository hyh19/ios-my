//
//  FBRoomEventWrapper.hpp
//  LiveShow
//
//  Created by chenfanshun on 20/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#ifndef FBRoomEventWrapper_hpp
#define FBRoomEventWrapper_hpp

#include <stdio.h>
#include "flybird.h"

#endif /* FBRoomEventWrapper_hpp */

@class FBMsgService;

/**
 *  频道消息的通知
 */
class FBRoomEventWrapper : public flybird::IFlyBirdFlockEvent
{
public:
    FBRoomEventWrapper(FBMsgService* service);
    virtual void OnStatus(uint16_t status);
    virtual void OnMessage(uint64_t uid, uint32_t type, std::string& msg);
    
private:
    FBMsgService*   m_service;
};