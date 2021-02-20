#ifndef TINCANI_API_HPP
#define TINCANI_API_HPP
namespace tincani {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file tincani/tincani.h
 * @author 喻扬
 */
#include "arc.h"
#endif /* API */
#ifndef TINCANI_API_HPP
#include "connection.hpp"
#include "connectionhandler.hpp"
#include "protocol.hpp"
#include "qos.hpp"
#include "server.hpp"
#include "serverhandler.hpp"
#include "stream.hpp"
#include "streamhandler.hpp"
#endif /* TINCANI_API_HPP */
namespace tincani {
class ConnectionHandler;
class Message;
class Protocol;
class Stream;
class Qos;
/**
 * 链接对象
 */
class Connection {
public:
    /**
     * 获取协议对象
     * @return 协议对象
     */
    virtual Protocol *GetProtocol() = 0;
    /**
     * 获取状态
     * @return 状态
     */
    virtual UInt8 GetStatus() const = 0;
    /**
     * 获取链接的标识
     * @return 链接的标识
     */
    virtual std::string GetIdentity() const = 0;
    /**
     * 获取远端地址
     * @return 远端地址
     */
    virtual arc::SocketAddress GetRemoteAddress() const = 0;
    /**
     * 获取近端地址
     * @return 近端地址
     */
    virtual arc::SocketAddress GetLocalAddress() const = 0;
    /**
     * 设置回调处理对象
     * @param handler 回调处理对象
     */
    virtual void SetHandler(ConnectionHandler *handler) = 0;
    /**
     * 发送消息数据
     * @param type 数据包类型
     * @param packet 数据包
     */
    virtual void Send(UInt8 type, const arc::Packet &packet) = 0;
    /**
     * 发送消息数据
     * @param type 数据包类型
     * @param payload 数据包内容
     */
    virtual void Send(UInt8 type, const std::string &payload) = 0;
    /**
     * 设置对端信息 
     * @param address 地址
     */
    virtual void SetPeerInfo(const arc::SocketAddress &address) = 0;
    /**
     * 创建流对象
     * @param streamId 流ID
     * @return 流对象
     */
    virtual Stream *CreateStream(UInt32 streamId) = 0;
    /**
     * 关闭链接对象,关闭后不再可用,不会回调OnClose
     */
    virtual void Close() = 0;
    /**
     * 接受此链接,用于服务端接收到新的链接对象时调用
     */
    virtual void Accept() = 0;
    /**
     * 获取此连接的服务质量信息
     * @return 此连接的服务质量信息
     */
    virtual Qos *GetQos(UInt8 type) = 0;
};
}
namespace tincani {
class Connection;
/**
 * 链接处理对象
 */
class ConnectionHandler {
public:
    /**
     * 链接成功回调
     * @param connection 链接对象
     */
    virtual void OnConnected(Connection *connection) = 0;
    /**
     * 接收到消息回调
     * @param type 消息类型
     * @param payload 消息内容
     * @param connection 链接对象
     */
    virtual void OnMessage(UInt8 type, const std::string &payload, Connection *connection) = 0;
    /**
     * 链接对象被关闭回调
     * @param connection 链接对象
     */
    virtual void OnClose(Connection *connection) = 0;
};
}
namespace tincani {
class Connection;
class Server;
/**
 * 协议对象
 */
class Protocol {
public:
    /**
     * 获取协议的名称
     * @return 协议的名称
     */
    virtual std::string GetName() const = 0;
    /**
     * 创建服务端对象
     * @param address 监听的地址 
     * @return 服务器对象指针
     */
    virtual Server *Listen(const arc::SocketAddress &address) = 0;
    /**
     * 创建到服务端的连接对象
     * @param uri 连接服务端的地址
     * @return 连接对象指针
     */
    virtual Connection *Connect(const std::string &uri) = 0;
};
}
namespace tincani {
/**
 * 此类用于获取连接的服务质量信息
 */
class Qos {
public:
    typedef enum {AUDIO = 0, VIDEO = 1, TOTAL = 2} QosType;
public:
    /**
     * 获取传入的字节数
     * @return 此连接总共收到的字节数
     */
    virtual UInt64 GetIncomingBytes() const = 0;
    /**
     * 获取传入的包数
     * @return 此连接收到的数据包的总数
     */
    virtual UInt32 GetIncomingPackets() const = 0;
    /**
     * 获取传出的字节数
     * @return 此连接向对端发送的数据总字节数
     */
    virtual UInt64 GetOutgoingBytes() const = 0;
    /**
     * 获取传出的包数
     * @return 此连接向对端发送的数据包的总数
     */
    virtual UInt32 GetOutgoingPackets() const = 0;
    /**
     * 获取丢弃的字节数
     * @return 此连接因为发送超时而丢弃的数据的总字节数
     */
    virtual UInt64 GetDroppedBytes() const = 0;
    /**
     * 获取丢弃的包数
     * @return 此连接因为发送超时而丢弃的数据包的总数
     */
    virtual UInt32 GetDroppedPackets() const = 0;
    /**
     * 获取总共发送的字节数
     * @return 此连接中总共发送的字节数
     */
    virtual UInt64 GetTotalBytes() const = 0;
    /**
     * 获取总共发送的包数
     * @return 此连接中总共发送的包数
     */
    virtual UInt32 GetTotalPackets() const = 0;
    /**
     * 获取此连接的一次往返时间
     * @return 此连接的一次往返时间
     */
    virtual UInt32 GetRoundTripTime() const = 0;
};
}
namespace tincani {
class Protocol;
class ServerHandler;
/**
 * 服务端对象
 */
class Server {
public:
    /**
     * 获取协议对象
     * @return 协议对象
     */
    virtual Protocol *GetProtocol() = 0;
    /**
     * 设置回调处理对象
     * @param handler 回调处理对象
     */
    virtual void SetHandler(ServerHandler *handler) = 0;
    /**
     * 主动关闭服务端对象,不会回调OnShutdown
     */
    virtual void Shutdown() = 0;
};
}
namespace tincani {
class Connection;
class Server;
/**
 * 服务端处理对象
 */
class ServerHandler {
public:
    /**
     * 接收到新链接回调
     * @param connection 链接对象
     * @param server 服务端对象
     */
    virtual void OnConnection(Connection *connection, Server *server) = 0;
    /**
     * 服务端对象被关闭回调
     * @param server 服务端对象
     */
    virtual void OnShutdown(Server *server) = 0;
};
}
namespace tincani {
class Connection;
class StreamHandler;
/**
 * 流对象
 */
class Stream {
public:
    /**
     * 获取链接对象
     * @return 链接对象
     */
    virtual Connection *GetConnection() = 0;
    /**
     * 设置回调处理对象
     * @param handler 回调处理对象
     */
    virtual void SetStreamHandler(StreamHandler *handler) = 0;
    /**
     * 发送消息数据
     * @param type 消息类型
     * @param timestamp 时间戳
     * @param packet 数据包
     * @param lifetime 存活期,0-永不过期,除非流被销毁
     */
    virtual void Send(UInt8 type, UInt32 timestamp, const arc::Packet &packet, UInt32 lifetime = 0) = 0;
    /**
     * 发送消息数据
     * @param type 消息类型
     * @param timestamp 时间戳
     * @param payload 数据包内容
     * @param lifetime 存活期,0-永不过期,除非流被销毁
     */
    virtual void Send(UInt8 type, UInt32 timestamp, const std::string &payload, UInt32 lifetime = 0) = 0;
    /**
     * 关闭流对象
     */
    virtual void Close() = 0;
    /**
     * 获取流ID
     * @return 流ID
     */
    virtual UInt32 GetStreamId() const = 0;
};
}
namespace tincani {
class Stream;
/**
 * 流处理对象
 */
class StreamHandler {
public:
    /**
     * 接收到消息回调
     * @param type 消息类型
     * @param timestamp 时间戳
     * @param payload 消息内容
     * @param stream 流对象
     */
    virtual void OnMessage(UInt8 type, UInt32 timestamp, const std::string &payload, Stream *stream) = 0;
    /**
     * 流对象被关闭回调
     * @param stream 流对象
     */
    virtual void OnClose(Stream *stream) = 0;
};
}
#endif /* TINCANI_API_HPP */
