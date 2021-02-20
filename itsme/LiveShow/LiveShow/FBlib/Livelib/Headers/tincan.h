#ifndef TINCAN_API_HPP
#define TINCAN_API_HPP
namespace tincan {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file tincan/tincan.h
 * @author 喻扬
 */
#include "amf.h"
#include "arc.h"
#include "tincani.h"
#endif /* API */
#ifndef TINCAN_API_HPP
#include "clientinfo.hpp"
#include "export.hpp"
#include "instance.hpp"
#include "netconnection.hpp"
#include "netconnectionhandler.hpp"
#include "response.hpp"
#include "responder.hpp"
#include "serverinfo.hpp"
#include "application.hpp"
#include "commandtype.hpp"
#include "netstream.hpp"
#include "netstreamhandler.hpp"
#include "netstreamstatus.hpp"
#endif /* TINCAN_API_HPP */
namespace tincan {
class ClientInfo {
public:
    ClientInfo();
    virtual ~ClientInfo();
public:
    const std::string &GetApp() const;
    void SetApp(const std::string &app);
    const std::string &GetVersion() const;
    void SetVersion(const std::string version);
    const std::string &GetFlashUrl() const;
    void SetFlashUrl(const std::string &flashUrl);
    const std::string &GetServerUrl() const;
    void SetServerUrl(const std::string &serverUrl);
    bool GetProxyUsed() const;
    void SetProxyUsed(bool proxyUsed);
    UInt32 GetAudioCodecs() const;
    void SetAudioCodecs(UInt32 audioCodecs);
    UInt32 GetVideoCodecs() const;
    void SetVideoCodecs(UInt32 videoCodecs);
    UInt32 GetVideoFunction() const;
    void SetVideoFunction(UInt32 videoFunction);
    const std::string &GetPageUrl() const;
    void SetPageUrl(const std::string &pageUrl);
    UInt32 GetObjectEncoding() const;
    void SetObjectEncoding(UInt32 objectEncoding);
private:
    std::string app_;
    std::string version_;
    std::string flashUrl_;
    std::string serverUrl_;
    bool proxyUsed_;
    UInt32 audioCodecs_;
    UInt32 videoCodecs_;
    UInt32 videoFunction_;
    std::string pageUrl_;
    UInt32 objectEncoding_;
};
}
namespace tincan {
class Instance;
class NetConnection;
/**
 * 创建tincan实例对象,用于服务端
 * @return 实例对象
 */
Instance *CreateInstance();
/**
 * 创建连接对象,用于客户端
 * @return 连接对象
 */
NetConnection *CreateNetConnection();
}
namespace tincan {
class Application;
/**
 * tincan实例对象
 */
class Instance {
public:
    /**
     * 绑定地址和协议
     * @param endpoint 地址
     * @param protocol 协议对象
     * @return 结果,true-成功
     */
    virtual bool Bind(const arc::SocketAddress &endpoint, void *protocol) = 0;
    /**
     * 解除绑定
     * @param endpoint 地址
     * @param protocol 协议对象
     * @return 结果,true-成功
     */
    virtual bool Unbind(const arc::SocketAddress &endpoint, void *protocol) = 0;
    /**
     * 注册应用
     * @param name 应用名称
     * @param application 应用对象
     */
    virtual void RegisterApplication(const std::string &name, Application *application) = 0;
    /**
     * 解除注册应用
     * @param name 应用名称
     * @param application 应用对象
     */
    virtual void UnregisterApplication(const std::string &name, Application *application) = 0;
    /**
     * 关闭实例
     */
    virtual void Close() = 0;
};
}
namespace tincan {
class ClientInfo;
class NetConnectionHandler;
class Responder;
class ServerInfo;
class NetStream;
/**
 * 链接对象
 */
class NetConnection {
public:
    /**
     * 获取客户端信息
     * @return 客户端信息
     */
    virtual const ClientInfo &GetClientInfo() const = 0;
    /**
     * 设置客户端信息
     * @param clientInfo 客户端信息
     */
    virtual void SetClientInfo(const ClientInfo &clientInfo) = 0;
    /**
     * 获取服务端信息
     * @return 服务端信息
     */
    virtual const ServerInfo &GetServerInfo() const = 0;
    /**
     * 设置服务端信息
     * @param serverInfo 服务端信息
     */
    virtual void SetServerInfo(const ServerInfo &serverInfo) = 0;
    /**
     * 设置默认的播放缓冲区长度，创建流时会按此长度填充缓冲区
     * @param bufferLength 播放缓冲区的长度，以毫秒为单位，默认为100
     */
    virtual void SetBufferLength(UInt32 bufferLength) = 0;
    /**
     * 设置回调处理者
     * @param handler 回调处理者
     */
    virtual void SetHandler(NetConnectionHandler *handler) = 0;
    /**
     * 发起连接,用于客户端
     * @param url 地址
     * @param params 参数
     * @param protocol 协议对象
     */
    virtual void Connect(const std::string &url, amf::Array &params, void *protocol) = 0;
    /**
     * 关闭连接
     */
    virtual void Close() = 0;
    /**
     * 远程调用
     * @param name 名称 
     * @param responder 应答通知对象
     * @param params 参数
     * @return transcation id
     */
    virtual UInt32 Invoke(const std::string &name, Responder *responder, amf::Array &params) = 0;
    /**
     * 撤销远程调用
     * @param invokeId transcation id
     */
    virtual void Revoke(UInt32 invokeId) = 0;
    /**
     * 通知NetStatus事件
     * @param code 操作码
     * @param description 描述
     * @param extra 参数
     */
    virtual void OnNetStatus(const std::string &code, const std::string &description, const amf::Object &extra = amf::Object()) = 0;
    /**
     * 获取编码格式 
     * @return 编码格式
     */
    virtual UInt32 GetObjectEncoding() const = 0;
    /**
     * 获取是否连接状态 
     * @return 连接状态,true-连接
     */
    virtual bool Connected() const = 0;
    /**
     * 获取协议名称 
     * @return 协议名称
     */
    virtual std::string GetProtocol() const = 0;
    /**
     * 主动创建流,客户端链接才能主动创建流
     * @return 流的指针
     */
    virtual NetStream *CreateStream() = 0;
    /**
     * 获取此连接的服务质量信息
     * @return 此连接的服务质量信息,未连接时返回NULL
     */
    virtual tincani::Qos *GetQos(UInt8 type) = 0;
};
}
namespace tincan {
class NetConnection;
class Responder;
class Response;
class NetStream;
/**
 * 连接回调处理对象
 */
class NetConnectionHandler {
public:
    /**
     * 链接建立回调
     * @param connection 连接对象
     */
    virtual void OnConnected(NetConnection *connection) = 0;
    /**
     * 接收到对方的Invoke回调
     * @param command 命令
     * @param response 应答对象
     * @param params 参数
     * @param connection 连接对象
     */
    virtual void OnCall(const std::string &command, tincan::Response *response, amf::Array &params, NetConnection *connection) = 0;
    /**
     * 接收NetStatus事件回调
     * @param code 操作码
     * @param description 描述
     * @param extra 参数
     * @param connection 连接对象
     */
    virtual void OnNetStatus(const std::string &code, const std::string &description, amf::Object &extra, NetConnection *connection) = 0;
    /**
     * 服务端接收到创建流的回调
     * @params stream 流指针
     * @params connection 连接对象
     */
    virtual void OnCreateStream(NetStream *stream, NetConnection *connection) = 0;
    /**
     * 连接被关闭回调
     * @params connection 连接对象
     * @params arguments 断开原因
     */
    virtual void OnClose(NetConnection *connection, amf::Array &arguments) = 0;
};
}
namespace tincan {
/**
 * 应答对象
 */
class Response {
public:
    /**
     * 应答成功
     * @param array 参数
     */
    virtual void Ok(const amf::Array &array) = 0;
    /**
     * 应答错误
     * @param array 参数
     */
    virtual void Error(const amf::Array &array) = 0;
};
}
namespace tincan {
/**
 * 应答通知对象
 */
class Responder {
public:
    /**
     * 接收到成功应答
     * @param params 参数
     */
    virtual void OnResult(UInt32 invokeId, amf::Array &params) = 0;
    /**
     * 接收到错误应答
     * @param params 参数
     */
    virtual void OnError(UInt32 invokeId, amf::Array &params) = 0;
    /**
     * 接收超时
     */
    virtual void OnExpire(UInt32 invokeId) = 0;
};
}
namespace tincan {
class ServerInfo {
public:
    ServerInfo();
    virtual ~ServerInfo();
public:
    const std::string &GetVersion() const;
    void SetVersion(const std::string &version);
    UInt8 GetCapabilities() const;
    void SetCapabilities(UInt8 capabilities);
    UInt8 GetMode() const;
    void SetMode(UInt8 mode);
private:
    std::string version_;
    UInt8 capabilities_;
    UInt8 mode_;
};
}
namespace tincan {
class NetConnection;
/**
 * 应用对象
 */
class Application {
public:
    /**
     * 接收到新的链接请求
     * @param connection 链接对象
     * @param options 参数
     */
    virtual void OnConnection(NetConnection *connection, const amf::Array &options) = 0;
};
}
namespace tincan {
/**
 * 枚举RTMP中的命令类型
 */
namespace CommandType {
    /**
     * unknown
     */
    const UInt8 UNKNOWN = 0x00;
    /**
     * connect (NetConnection)
     */
    const UInt8 CONNECT = 0x01;
    /**
     * close (NetConnection)
     */
    const UInt8 CLOSE = 0x02;
    /**
     * createStream (NetConnection)
     */
    const UInt8 CREATESTREAM = 0x03;
    /**
     * play (NetStream)
     */
    const UInt8 PLAY = 0x04;
    /**
     * play2 (NetStream)
     */
    const UInt8 PLAY2 = 0x05;
    /**
     * deleteStream (NetStream)
     */
    const UInt8 DELETESTREAM = 0x06;
    /**
     * closeStream (NetStream)
     */
    const UInt8 CLOSESTREAM = 0x07;
    /**
     * receiveAudio (NetStream)
     */
    const UInt8 RECEIVEAUDIO = 0x08;
    /**
     * receiveVideo (NetStream)
     */
    const UInt8 RECEIVEVIDEO = 0x09;
    /**
     * publish (NetStream)
     */
    const UInt8 PUBLISH = 0x0A;
    /**
     * seek (NetStream)
     */
    const UInt8 SEEK = 0x0B;
    /**
     * pause (NetStream)
     */
    const UInt8 PAUSE = 0x0C;
    /**
     * _result (Response)
     */
    const UInt8 _RESULT = 0x0D;
    /**
     * _error (Response)
     */
    const UInt8 _ERROR = 0x0E;
    /**
     * onStatus (Response)
     */
    const UInt8 ONSTATUS = 0x0F;
    /**
     * setPeerInfo (NetGroup)
     */
    const UInt8 SETPEERINFO = 0x10;
    /**
     * releaseStream (NetConnection)
     */
    const UInt8 RELEASESTREAM = 0x11;
    /**
     * FCPublish (NetConnection)
     */
    const UInt8 FCPUBLISH = 0x12;
    /**
     * onFCPublish (NetConnection)
     */
    const UInt8 ONFCPUBLISH = 0x13;
    /**
     * onFCSubscribe (NetStream)
     */
    const UInt8 ONFCSUBSCRIBE = 0x14;
    /**
     * FCSubscribe (NetStream)
     */
    const UInt8 FCSUBSCRIBE = 0x15;
    /**
     * 将命令名称转换为命令类型
     * @param name 指定的命令名称
     * @return 对应的命令类型，如果未定义，则返回UNKNOWN
     */
    UInt8 Translate(const std::string &name);
    /**
     * 从命令类型获取对应的名称
     * @param type 指定的命令类型
     * @return 对应的命令名称，如果类型非法，返回空字符串
     */
    const std::string &Translate(UInt8 type);
}
}
namespace tincan {
class NetConnection;
class NetStreamHandler;
/**
 * 流对象
 */
class NetStream {
public:
    /**
     * 获取连接对象
     * @return 连接对象
     */
    virtual NetConnection *GetNetConnection() = 0;
    /**
     * 获取缓冲时间
     * @return 缓冲时间
     */
    virtual UInt32 GetBufferTime() const = 0;
    /**
     * 设置缓冲时间
     * @param bufferTime 缓冲时间
     */
    virtual void SetBufferTime(UInt32 bufferTime) = 0;
    /**
     * 获取最大缓冲时间
     * @return 最大缓冲时间
     */
    virtual UInt32 GetBufferTimeMax() const = 0;
    /**
     * 设置最大缓冲时间
     * @param bufferTimeMax 最大缓冲时间
     */
    virtual void SetBufferTimeMax(UInt32 bufferTimeMax) = 0;
    /**
     * 设置处理对象
     * @param handler 处理对象
     */
    virtual void SetHandler(NetStreamHandler *handler) = 0;
    /**
     * 关闭流对象
     */
    virtual void Close() = 0;
    /**
     * 播放
     * @param params 参数
     */
    virtual void Play(amf::Array &params) = 0;
    /**
     * 发布
     * @param params 参数
     */
    virtual void Publish(amf::Array &params) = 0;
    /**
     * 远程调用
     * @param handlerName 参数
     * @param params 参数
     */
    virtual void Send(const std::string &handlerName, amf::Array &params) = 0;
    /**
     * 向该流发送音频数据。
     * @param timestamp 音频的时间戳
     * @param data 音频数据
     * @param lifetime 此数据的生存期，为0表示此数据不会过期
     */
    virtual void SendAudio(UInt32 timestamp, const std::string &data, UInt32 lifetime = 0) = 0;
    /**
     * 向该流发送视频数据。
     * @param timestamp 视频的时间戳
     * @param data 视频数据
     * @param lifetime 此数据的生存期，为0表示此数据不会过期
     */
    virtual void SendVideo(UInt32 timestamp, const std::string &data, UInt32 lifetime = 0) = 0;
    /**
     * 向该流发送状态通知
     * @param status 状态码
     */
    virtual void SendStatus(UInt8 status) = 0;
};
}
namespace tincan {
class NetStream;
/**
 * 流处理对象
 */
class NetStreamHandler {
public:
    /**
     * 客户端连接创建成功回调
     * @params netstream 流对象
     */
    virtual void OnCreate(NetStream *netStream) = 0;
    /**
     * 服务端接收到播放回调
     * @params params 参数
     * @params netstream 流对象
     */
    virtual void OnPlay(amf::Array &params, NetStream *netStream) = 0;
    /**
     * 服务端接收到发布回调
     * @params params 参数
     * @params netstream 流对象
     */
    virtual void OnPublish(amf::Array &params, NetStream *netStream) = 0;
    /**
     * 接收到状态通知回调
     * @params status 状态
     * @params netstream 流对象
     */
    virtual void OnStatus(UInt8 status, NetStream *netStream) = 0;
    /**
     * 接收到远程调用回调
     * @params handlerName 命令
     * @params params 参数
     * @params netstream 流对象
     */
    virtual void OnSend(const std::string &handlerName, amf::Array &params, NetStream *netStream) = 0;
    /**
     * 接收到视频数据。
     * @param timestamp 视频的时间戳
     * @param data 视频数据
     * @params netstream 流对象
     */
    virtual void OnVideo(UInt32 timestamp, const std::string &data, NetStream *netStream) = 0;
    /**
     * 接收到音频数据。
     * @param timestamp 音频的时间戳
     * @param data 音频数据
     * @params netstream 流对象
     */
    virtual void OnAudio(UInt32 timestamp, const std::string &data, NetStream *netStream) = 0;
    /**
     * 流被关闭回调
     * @params netstream 流对象
     */
    virtual void OnClose(NetStream *netStream) = 0;
};
}
namespace tincan {
/**
 * 流的状态
 */
namespace NetStreamStatus {
    /**
     * 流开始。
     */
    const UInt8 STREAM_BEGIN = 0;
    /**
     * 流结束。
     */
    const UInt8 STREAM_EOF = 1;
    /**
     * 流空数据。
     */
    const UInt8 STREAM_DRY = 2;
    /**
     * 流被录制。
     */
    const UInt8 STREAM_IS_RECORDED = 3;
    /**
     * 播放开始。
     */
    const UInt8 PLAY_START = 4;
    /**
     * 播放重置。
     */
    const UInt8 PLAY_RESET = 5;
    /**
     * 发布开始。
     */
    const UInt8 PUBLISH_START = 6;
    /**
     * 发布重置。
     */
    const UInt8 PUBLISH_RESET = 7;
    /**
     * 发布失败，可能名字已经存在。
     */
    const UInt8 PUBLISH_BAD_NAME = 8;
    /**
     * 发布通告。
     */
    const UInt8 PUBLISH_NOTIFY = 9;
    /**
     * 发布通告取消。
     */
    const UInt8 PUBLISH_UN_NOTIFY = 10;
    /**
     * Unknown
     */
    const UInt8 UNKNOWN = 255;
    /**
     * NetStatus字符串转换成UInt8
     * @param status NetStatus string
     * @return NetStatus UInt8
     */
    UInt8 FromNetStatus(const std::string &status);
    /**
     * NetStatus转换成字符串
     * @param status NetStatus
     * @return NetStatus string
     */
    std::string ToNetStatus(UInt8 status);
}
}
#endif /* TINCAN_API_HPP */
