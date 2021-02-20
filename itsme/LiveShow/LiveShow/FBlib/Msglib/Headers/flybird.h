/*
 * flrbird.h
 * Copyright (C) 2016 yushu <yushu@yushu-B85M-DS3H-A>
 *
 */

#ifndef API_FLRBIRD_H
#define API_FLRBIRD_H

#include <stdint.h>
#include <string>
#include <list>
#include <vector>
#include <map>

namespace flybird {

enum RetCode {
	Timeout = 1,
	ServerSuccess = 100,
	ServerBusy = 102,
	AccountNonexistent = 201,
	TokenWrong = 205,
	KickOff = 206,
	BeBan = 207
};

enum MsgTyep {
	MT_Chat = 10,	
	MT_Gift = 11,	
	MT_Normal = 12	
};

#define STEALTHY_SCORE 0xFFFFFFFF

class IFlyBirdEvent;
class IFlyBird;
class IFlyBirdFlockEvent;
class IFlyBirdFlock;

class IFlyBirdEvent{
	public:
		virtual void OnStatus(uint16_t status) = 0;
		virtual void OnMessage(const std::string&) = 0;
		virtual void OnSDKLog(const char* log) = 0;

};

class IFlyBird {
	public:
		virtual void Init() = 0;
		virtual void Uninit() = 0;
		virtual void RunTick(int ms) = 0;
		virtual void SetEvent(IFlyBirdEvent*) = 0;

		virtual void SetAddr(const std::string& ip, uint16_t port) = 0;
		virtual bool LoginByToken(const std::string& token) = 0;
		virtual bool Leave() = 0;
		virtual IFlyBirdFlock* JoinFlock(const std::string& roomid, uint32_t score, const std::string& ip, uint16_t port)= 0;
};


class IFlyBirdFlockEvent {
	public:
		virtual void OnStatus(uint16_t status) = 0;
		virtual void OnMessage(uint64_t uid, uint32_t type, std::string& msg) = 0;
};

class IFlyBirdFlock {
	public:
		virtual void SetEvent(IFlyBirdFlockEvent*) = 0;
		virtual uint32_t SendMessage(uint32_t type, const std::string& msg) = 0;
		virtual uint32_t Leave() = 0;
};

extern IFlyBird* GetFlyBird();
extern void Release(IFlyBird*);
}

#endif /* !TURTLE_H */
