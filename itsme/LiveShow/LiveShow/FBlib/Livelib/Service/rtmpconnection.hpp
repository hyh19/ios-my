#ifndef MIRAEYEJ_RTMPCONNECTION_HPP
#define MIRAEYEJ_RTMPCONNECTION_HPP

#include "tincan.h"
#include "MEQos.h"

@class FBRtmpOpenLiveService;

namespace miraeyej {

class RtmpConnection : public tincan::NetConnectionHandler, public tincan::NetStreamHandler {
public:
    RtmpConnection(FBRtmpOpenLiveService* service, tincan::NetConnection *connection, bool publish, const std::string &streamName);
    virtual ~RtmpConnection();

public:
    void SendAudio(UInt32 timestamp, const std::string &data, UInt32 lifetime);
    void SendVideo(UInt32 timestamp, const std::string &data, UInt32 lifetime);
    void Close();
    void ReleaseService();
    
    MEQos *getQos();
public:
    virtual void OnConnected(tincan::NetConnection *connection);
    virtual void OnCall(const std::string &command, tincan::Response *response, amf::Array &params, tincan::NetConnection *connection);
    virtual void OnNetStatus(const std::string &code, const std::string &description, amf::Object &extra, tincan::NetConnection *connection);
    virtual void OnCreateStream(tincan::NetStream *stream, tincan::NetConnection *connection);
    virtual void OnClose(tincan::NetConnection *connection, amf::Array &params);

public:
    virtual void OnCreate(tincan::NetStream *netStream);
    virtual void OnPlay(amf::Array &params, tincan::NetStream *netStream);
    virtual void OnPublish(amf::Array &params, tincan::NetStream *netStream);
    virtual void OnStatus(UInt8 status, tincan::NetStream *netStream);
    virtual void OnSend(const std::string &handlerName, amf::Array &params, tincan::NetStream *netStream);
    virtual void OnVideo(UInt32 timestamp, const std::string &data, tincan::NetStream *netStream);
    virtual void OnAudio(UInt32 timestamp, const std::string &data, tincan::NetStream *netStream);
    virtual void OnClose(tincan::NetStream *netStream);

private:
    bool publish_;
    tincan::NetConnection *connection_;
    tincan::NetStream *stream_;
    //jobject object_;
    std::string streamName_;
    
    FBRtmpOpenLiveService *service_;
};

}

#endif /* MIRAEYEJ_RTMPCONNECTION_HPP */
