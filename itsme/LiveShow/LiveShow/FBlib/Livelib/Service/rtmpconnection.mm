#include "rtmpconnection.hpp"
#include "FBRtmpOpenLiveService.h"
#include "tincani.h"
#include <string>

namespace miraeyej {

RtmpConnection::RtmpConnection(FBRtmpOpenLiveService* service, tincan::NetConnection *connection, bool publish, const std::string &streamName) {
    service_ = service;
    connection_ = connection;
    stream_ = NULL;
    publish_ = publish;
    streamName_ = streamName;
    connection_->SetHandler(this);
}

RtmpConnection::~RtmpConnection() {
    Close();
    NSLog(@"~RtmpConnection()");
}

void RtmpConnection::SendAudio(UInt32 timestamp, const std::string &data, UInt32 lifetime) {
    if (stream_ != NULL) {
        stream_->SendAudio(timestamp, data, lifetime);
    }
}

void RtmpConnection::SendVideo(UInt32 timestamp, const std::string &data, UInt32 lifetime) {
    if (stream_ != NULL) {
        stream_->SendVideo(timestamp, data, lifetime);
    }
}

void RtmpConnection::Close() {
    if (stream_ != NULL) {
        stream_->Close();
        stream_ = NULL;
    }
    if (connection_ != NULL) {
        connection_->Close();
        connection_ = NULL;
    }
}
    
void RtmpConnection::ReleaseService()
{
    service_ = nil;
}

MEQos *RtmpConnection::getQos()
{
    if(connection_) {
        if(tincani::Qos *qos = connection_->GetQos(tincani::Qos::TOTAL)) {
            MEQos *result = [[MEQos alloc] init];
            [result setIncomingBytes:qos->GetIncomingBytes()];
            [result setIncomingPackets:qos->GetIncomingPackets()];
            [result setOutgoingBytes:qos->GetOutgoingBytes()];
            [result setOutgoingPackets:qos->GetOutgoingPackets()];
            [result setDroppedBytes:qos->GetDroppedBytes()];
            [result setDroppedPackets:qos->GetDroppedPackets()];
            [result setTotalBytes:qos->GetTotalBytes()];
            [result setTotalPackets:qos->GetTotalPackets()];
            
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
            [result setTimestamp:timeStamp];
            return result;
        }
    }
    return nil;
}

void RtmpConnection::OnConnected(tincan::NetConnection *connection) {
    stream_ = connection_->CreateStream();
    stream_->SetHandler(this);
}

void RtmpConnection::OnCall(const std::string &command, tincan::Response *response, amf::Array &params, tincan::NetConnection *connection) {
}

void RtmpConnection::OnNetStatus(const std::string &code, const std::string &description, amf::Object &extra, tincan::NetConnection *connection) {
}

void RtmpConnection::OnCreateStream(tincan::NetStream *stream, tincan::NetConnection *connection) {
}

void RtmpConnection::OnClose(tincan::NetConnection *connection, amf::Array &params) {
    connection_ = NULL;
    Close();

    if([service_ respondsToSelector:@selector(onClose)]) {
        [service_ onClose];
        
        //onclose后这里置空
        service_ = nil;
    }
}

void RtmpConnection::OnCreate(tincan::NetStream *netStream) {
    amf::Array params;
    params[0] = streamName_;
    if (publish_) {
        stream_->Publish(params);
    } else {
        stream_->Play(params);
    }
}

void RtmpConnection::OnPlay(amf::Array &params, tincan::NetStream *netStream) {
}

void RtmpConnection::OnPublish(amf::Array &params, tincan::NetStream *netStream) {
}

void RtmpConnection::OnStatus(UInt8 status, tincan::NetStream *netStream) {
    if (publish_ && status == tincan::NetStreamStatus::PUBLISH_START) {
        if([service_ respondsToSelector:@selector(onConnected)]) {
            [service_ onConnected];
        }
    } else if (status == tincan::NetStreamStatus::PLAY_START) {
    }
}

void RtmpConnection::OnSend(const std::string &handlerName, amf::Array &params, tincan::NetStream *netStream) {
}

void RtmpConnection::OnVideo(UInt32 timestamp, const std::string &data, tincan::NetStream *netStream) {
}

void RtmpConnection::OnAudio(UInt32 timestamp, const std::string &data, tincan::NetStream *netStream) {
}

void RtmpConnection::OnClose(tincan::NetStream *netStream) {
    stream_ = NULL;
    Close();
    
    if([service_ respondsToSelector:@selector(onClose)]) {
        [service_ onClose];
        
        //onclose后这里置空
        service_ = nil;
    }
}

}
