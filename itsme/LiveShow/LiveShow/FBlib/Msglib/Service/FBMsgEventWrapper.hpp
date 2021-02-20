//
//  FBMsgEventWrapper.hpp
//  LiveShow
//
//  Created by chenfanshun on 20/02/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#ifndef FBFlybirdMsgEventWrapper_hpp
#define FBFlybirdMsgEventWrapper_hpp

#include <stdio.h>
#include "flybird.h"

#endif /* FBFlybirdMsgEventWrapper_hpp */

@class FBMsgService;

/**
 *  在线时推送，登陆状态等的通知
 */
class FBMsgEventWrapper : public flybird::IFlyBirdEvent
{
public:
    FBMsgEventWrapper(FBMsgService* service);
    
    virtual void OnStatus(uint16_t status);
    virtual void OnMessage(const std::string&);
    virtual void OnSDKLog(const char* log);
    
private:
    FBMsgService*   m_service;
};
