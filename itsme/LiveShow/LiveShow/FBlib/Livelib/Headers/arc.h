#ifndef ARC_API_HPP
#define ARC_API_HPP
namespace arc {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file arc/arc.h
 * @author 喻扬
 */
#include <cassert>
#include <cstdarg>
#include <list>
#include <set>
#include <string>
#include "json.h"
#endif /* API */
#ifndef ARC_API_HPP
#include "base64.hpp"
#include "buffer.hpp"
#include "bufferpool.hpp"
#include "classloader.hpp"
#include "clock.hpp"
#include "configfile.hpp"
#include "endian.hpp"
#include "entrypoint.hpp"
#include "eventcallback.hpp"
#include "export.hpp"
#include "externallogger.hpp"
#include "fileutils.hpp"
#include "inbuffer.hpp"
#include "inputbuffer.hpp"
#include "library.hpp"
#include "librarymanager.hpp"
#include "listentrypoint.hpp"
#include "logger.hpp"
#include "loggercontext.hpp"
#include "loggerholder.hpp"
#include "loggerlevel.hpp"
#include "loggermanager.hpp"
#include "objectcounter.hpp"
#include "outbuffer.hpp"
#include "outputbuffer.hpp"
#include "packet.hpp"
#include "pathmanager.hpp"
#include "propertyutils.hpp"
#include "reader.hpp"
#include "scope.hpp"
#include "scopeguard.hpp"
#include "service.hpp"
#include "signal.hpp"
#include "singleton.hpp"
#include "slot.hpp"
#include "socketaddress.hpp"
#include "stringbuffer.hpp"
#include "system.hpp"
#include "tcpacceptor.hpp"
#include "tcpacceptorhandler.hpp"
#include "tcpsocket.hpp"
#include "tcpsockethandler.hpp"
#include "time.hpp"
#include "timer.hpp"
#include "timercallback.hpp"
#include "timertask.hpp"
#include "tracker.hpp"
#include "trackermanager.hpp"
#include "udpsocket.hpp"
#include "udpsockethandler.hpp"
#include "writer.hpp"
#endif /* ARC_API_HPP */
#ifndef API
/**
 * 创建指定名称的日志
 * @param package 日志所属的包名
 * @param className 日志所属的类名
 */
#define LOG(package, className) namespace { arc::Logger *_0_log_0_ = arc::GetLoggerManager()->CreateLogger(package, className); } class NullClass

#ifdef OS_WIN32
#define _TOKEN_PASTE_(x, y) x ## y
#define _TOKEN_PASTE_EX_(x, y) _TOKEN_PASTE_(x, y)
#define LogTrace \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_TRACE, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogDebug \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_DEBUG, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogInfo \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_INFO, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogNotice \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_NOTICE, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogWarn \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_WARN, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogAlert \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_ALERT, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogError \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_ERROR, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogCrit \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_CRIT, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogEmerg \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_EMERG, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define LogFatal \
    static arc::LoggerHolder _TOKEN_PASTE_EX_(_holder_, __LINE__)(arc::LoggerLevel::LEVEL_FATAL, __FUNCTION__, __LINE__, _0_log_0_);\
    _TOKEN_PASTE_EX_(_holder_, __LINE__)
#define Track arc::PrintTrack
#else
#define LogTrace(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_TRACE, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_TRACE) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_TRACE, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogDebug(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_DEBUG, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_DEBUG) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_DEBUG, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogInfo(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_INFO, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_INFO) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_INFO, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogNotice(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_NOTICE, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_NOTICE) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_NOTICE, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogWarn(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_WARN, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_WARN) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_WARN, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogAlert(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_ALERT, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_ALERT) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_ALERT, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogError(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_ERROR, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_ERROR) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_ERROR, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogCrit(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_CRIT, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_CRIT) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_CRIT, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogEmerg(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_EMERG, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_EMERG) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_EMERG, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
#define LogFatal(...) \
{\
    static arc::LoggerContext *_0_context_0_ = _0_log_0_->CreateContext(__FUNCTION__, __LINE__, arc::LoggerLevel::LEVEL_FATAL, #__VA_ARGS__);\
    if (_0_context_0_->GetLevel() <= arc::LoggerLevel::LEVEL_FATAL) {\
        _0_log_0_->Print(arc::LoggerLevel::LEVEL_FATAL, _0_context_0_, __VA_ARGS__);\
    }\
} class NullClass
/**
 * 创建指定名称的跟踪日志
 * @param name 日志名
 */
#define Track(name, ...) \
{\
    static arc::Tracker *_0_tracker_0_ = arc::GetTrackerManager()->CreateTracker(name);\
    _0_tracker_0_->Print(__VA_ARGS__);\
} class NullClass
#endif
#endif /* API */
namespace arc {
/**
 * 此类实现Base64的编解码
 */
class Base64 {
public:
    /**
     * 对数据进行Base64编码，并返回编码后的字符串
     * @param data 要进行编码的数据
     * @param length 要进行编码的数据的长度
     * @return 编码后的字符串
     */
    static std::string Encode(const char *data, UInt32 length);
    /**
     * 对数据进行Base64编码，并返回编码后的字符串
     * @param data 要进行编码的数据
     * @return 编码后的字符串
     */
    static std::string Encode(const std::string &data);
    /**
     * 对字符串用Base64解码，并返回解码后的数据
     * @param data 要解码的字符串
     * @param length 字符串的长度
     * @return 解码后的数据
     */
    static std::string Decode(const char *data, UInt32 length);
    /**
     * 对字符串用Base64解码，并返回解码后的数据
     * @param data 要解码的字符串
     * @return 解码后的数据
     */
    static std::string Decode(const std::string &data);
};
}
namespace arc {
/**
 * 此类表示一块缓冲区
 * @see BufferPool
 */
class Buffer {
public:
    /**
     * 获取缓冲区的数据
     * @return 缓冲区的数据
     */
    virtual char *Data() = 0;
    /**
     * 获取缓冲区的长度
     * @return 缓冲区的长度
     */
    virtual UInt32 Length() = 0;
};
}
namespace arc {
class Buffer;
/**
 * 此类表示缓冲区的池
 */
class BufferPool {
public:
    /**
     * 获取指定长度的缓冲区
     * @param length 缓冲区的长度
     * @return 分配的缓冲区（一定不为NULL）
     */
    virtual Buffer *Get(UInt32 length) = 0;
    /**
     * 回收指定的缓冲区
     * @param buffer 要回收的缓冲区
     */
    virtual void Put(Buffer *buffer) = 0;
};
}
namespace arc {
/**
 * 创建指定类的单例
 * @return 类的单例
 */
template <typename T>
T *Singleton() {
    static T instance;
    return &instance;
}
}
using arc::Singleton;
namespace arc {
/**
 * 此类为负责加载类的类加载器
 */
template <typename TypeT>
class ClassLoader {
public:
    /**
     * 创建类加载器
     */
    ClassLoader();
    /**
     * 析构函数
     */
    virtual ~ClassLoader();
    /**
     * 类加载函数，创建类单例
     * @return 类单例
     */
    template <typename ClassT>
    static TypeT *Loader();
    /**
     * 用指定名称注册一个类
     * @param name 类的注册名
     */
    template <typename ClassT>
    static void AddClass(const std::string &name);
    /**
     * 获得指定名称的类的单例
     * 如果没找到，则返回默认类，如果没有默认类，则返回空
     */
    static TypeT *GetClass(const std::string &name);
private:
    typedef TypeT *(*LoaderFunction)();
    typedef std::map<std::string, LoaderFunction> LoaderMap;
private:
    int priority_;
    LoaderFunction loader_;
    LoaderMap loaders_;
};
}
using arc::ClassLoader;
namespace arc {
template <typename TypeT>
ClassLoader<TypeT>::ClassLoader() {
    loader_ = NULL;
    priority_ = -1;
}
template <typename TypeT>
ClassLoader<TypeT>::~ClassLoader() {
}
template <typename TypeT>
template <typename ClassT>
TypeT *ClassLoader<TypeT>::Loader() {
    return (TypeT *) Singleton<ClassT>();
}
template <typename TypeT>
template <typename ClassT>
void ClassLoader<TypeT>::AddClass(const std::string &name) {
    ClassLoader *instance = Singleton<ClassLoader>();
    if (ClassT::Priority > instance->priority_) {
        instance->loader_ = Loader<ClassT>;
        instance->priority_ = ClassT::Priority;
    }
    instance->loaders_[name] = Loader<ClassT>;
}
template <typename TypeT>
TypeT *ClassLoader<TypeT>::GetClass(const std::string &name) {
    ClassLoader *instance = Singleton<ClassLoader>();
    if (instance->loaders_.find(name) != instance->loaders_.end()) {
        return instance->loaders_[name]();
    } else if (instance->loader_ != NULL) {
        return instance->loader_();
    } else {
        return NULL;
    }
}
}
namespace arc {
/**
 * 此类表示系统的时钟
 * @see Service
 */
class Clock {
public:
    enum ClockType {
        REALTIME,
        UPTIME
    };
public:
    /**
     * 获取此时钟当前的时间戳
     * @return 当前的时间戳
     */
    virtual UInt32 Timestamp() const = 0;
    /**
     * 获取此时钟当前的秒数
     * @return 当前的秒数
     */
    virtual UInt32 Seconds() const = 0;
    /**
     * 获取此时钟当前的毫秒数
     * @return 当前的毫秒数
     */
    virtual UInt32 Milliseconds() const = 0;
    /**
     * 获取此时钟的纳秒数
     * @return 当前的纳秒数
     */
    virtual UInt32 Nanoseconds() const = 0;
};
}
namespace arc {
/**
 * 用于读写配置文件
 */
namespace ConfigFile {
    /**
     * 读取指定的配置文件
     * @param name 配置文件的名称，如name为app，则对应文件名conf/app.ini
     * @param variant 存放读取的配置内容，必须为json::Object
     * @return 文件存在，json解析成功且为json::Object，则返回true，否则返回false
     */
    bool Read(const std::string &name, json::Variant &variant);
    /**
     * 向配置文件写入配置内容
     * @param name 配置文件的名称，如name为app，则对应文件名conf/app.ini
     * @param variant 要写入的配置项，必须为json::Object
     * @return 如果variant不是json::Object，则返回false，否则返回文件是否写入成功
     */
    bool Write(const std::string &name, json::Variant &variant);
}
}
namespace arc {
/**
 * 此类用于整数的字节序转换
 */
class Endian {
public:
    /**
     * 将整数从大端字节序转换为机器的字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt64 FromBig(UInt64 value);
    /**
     * 将整数从大端字节序转换为机器的字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt32 FromBig(UInt32 value);
    /**
     * 将整数从大端字节序转换为机器的字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt16 FromBig(UInt16 value);
    /**
     * 将整数从小端字节序转换为机器的字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt64 FromLittle(UInt64 value);
    /**
     * 将整数从小端字节序转换为机器的字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt32 FromLittle(UInt32 value);
    /**
     * 将整数从小端字节序转换为机器的字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt16 FromLittle(UInt16 value);
    /**
     * 将整数从机器的字节序转换为大端字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt64 ToBig(UInt64 value);
    /**
     * 将整数从机器的字节序转换为大端字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt32 ToBig(UInt32 value);
    /**
     * 将整数从机器的字节序转换为大端字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt16 ToBig(UInt16 value);
    /**
     * 将整数从机器的字节序转换为小端字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt64 ToLittle(UInt64 value);
    /**
     * 将整数从机器的字节序转换为小端字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt32 ToLittle(UInt32 value);
    /**
     * 将整数从机器的字节序转换为小端字节序
     * @param value 要转换的整数
     * @return 转换的结果
     */
    static UInt16 ToLittle(UInt16 value);
};
}
using arc::Endian;
namespace arc {
/**
 * 此类用于保存对象在集合中的位置，提升删除时的效率
 */
class Entrypoint {
public:
    /**
     * 将此对象从集合中删除
     */
    virtual void Erase() = 0;
};
}
namespace arc {
/**
 * 此类表示加入到事件队列中的事件
 * @see EventLoop
 */
class Event {
public:
    /**
     * 此事件触发时的处理函数
     */
    virtual void Trigger() = 0;
};
}
namespace arc {
template <typename T>
class CallbackEvent_0 : public Event {
public:
    typedef void (T::*Callback)();
public:
    CallbackEvent_0(T *object, Callback callback);
    virtual ~CallbackEvent_0();
public:
    virtual void Trigger();
private:
    T *object_;
    Callback callback_;
};
template <typename T, typename A1>
class CallbackEvent_1 : public Event {
public:
    typedef void (T::*Callback)(A1);
public:
    CallbackEvent_1(T *object, Callback callback, A1 a1);
    virtual ~CallbackEvent_1();
public:
    virtual void Trigger();
private:
    T *object_;
    Callback callback_;
    A1 a1_;
};
template <typename T, typename A1, typename A2>
class CallbackEvent_2 : public Event {
public:
    typedef void (T::*Callback)(A1, A2);
public:
    CallbackEvent_2(T *object, Callback callback, A1 a1, A2 a2);
    virtual ~CallbackEvent_2();
public:
    virtual void Trigger();
private:
    T *object_;
    Callback callback_;
    A1 a1_;
    A2 a2_;
};
template <typename T, typename A1, typename A2, typename A3>
class CallbackEvent_3 : public Event {
public:
    typedef void (T::*Callback)(A1, A2, A3);
public:
    CallbackEvent_3(T *object, Callback callback, A1 a1, A2 a2, A3 a3);
    virtual ~CallbackEvent_3();
public:
    virtual void Trigger();
private:
    T *object_;
    Callback callback_;
    A1 a1_;
    A2 a2_;
    A3 a3_;
};
template <typename T, typename A1, typename A2, typename A3, typename A4>
class CallbackEvent_4 : public Event {
public:
    typedef void (T::*Callback)(A1, A2, A3, A4);
public:
    CallbackEvent_4(T *object, Callback callback, A1 a1, A2 a2, A3 a3, A4 a4);
    virtual ~CallbackEvent_4();
public:
    virtual void Trigger();
private:
    T *object_;
    Callback callback_;
    A1 a1_;
    A2 a2_;
    A3 a3_;
    A4 a4_;
};
template <typename T>
Event *EventCallback(T *object, void (T::*callback)()) {
    return new CallbackEvent_0<T>(object, callback);
}
template <typename T, typename A1>
Event *EventCallback(T *object, void (T::*callback)(A1), A1 a1) {
    return new CallbackEvent_1<T, A1>(object, callback, a1);
}
template <typename T, typename A1, typename A2>
Event *EventCallback(T *object, void (T::*callback)(A1, A2), A1 a1, A2 a2) {
    return new CallbackEvent_2<T, A1, A2>(object, callback, a1, a2);
}
template <typename T, typename A1, typename A2, typename A3>
Event *EventCallback(T *object, void (T::*callback)(A1, A2, A3), A1 a1, A2 a2, A3 a3) {
    return new CallbackEvent_3<T, A1, A2, A3>(object, callback, a1, a2, a3);
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
Event *EventCallback(T *object, void (T::*callback)(A1, A2, A3, A4), A1 a1, A2 a2, A3 a3, A4 a4) {
    return new CallbackEvent_4<T, A1, A2, A3, A4>(object, callback, a1, a2, a3, a4);
}
}
namespace arc {
template <typename T>
inline CallbackEvent_0<T>::CallbackEvent_0(T *object, Callback callback) {
    object_ = object;
    callback_ = callback;
}
template <typename T>
inline CallbackEvent_0<T>::~CallbackEvent_0() {
}
template <typename T>
inline void CallbackEvent_0<T>::Trigger() {
    (object_->*callback_)();
    delete this;
}
template <typename T, typename A1>
inline CallbackEvent_1<T,A1>::CallbackEvent_1(T *object, Callback callback, A1 a1) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
}
template <typename T, typename A1>
inline CallbackEvent_1<T,A1>::~CallbackEvent_1() {
}
template <typename T, typename A1>
inline void CallbackEvent_1<T,A1>::Trigger() {
    (object_->*callback_)(a1_);
    delete this;
}
template <typename T, typename A1, typename A2>
inline CallbackEvent_2<T,A1,A2>::CallbackEvent_2(T *object, Callback callback, A1 a1, A2 a2) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
    a2_ = a2;
}
template <typename T, typename A1, typename A2>
inline CallbackEvent_2<T,A1,A2>::~CallbackEvent_2() {
}
template <typename T, typename A1, typename A2>
inline void CallbackEvent_2<T,A1,A2>::Trigger() {
    (object_->*callback_)(a1_, a2_);
    delete this;
}
template <typename T, typename A1, typename A2, typename A3>
inline CallbackEvent_3<T,A1,A2,A3>::CallbackEvent_3(T *object, Callback callback, A1 a1, A2 a2, A3 a3) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
    a2_ = a2;
    a3_ = a3;
}
template <typename T, typename A1, typename A2, typename A3>
inline CallbackEvent_3<T,A1,A2,A3>::~CallbackEvent_3() {
}
template <typename T, typename A1, typename A2, typename A3>
inline void CallbackEvent_3<T,A1,A2,A3>::Trigger() {
    (object_->*callback_)(a1_, a2_, a3_);
    delete this;
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline CallbackEvent_4<T,A1,A2,A3,A4>::CallbackEvent_4(T *object, Callback callback, A1 a1, A2 a2, A3 a3, A4 a4) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
    a2_ = a2;
    a3_ = a3;
    a4_ = a4;
    object_->Retain();
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline CallbackEvent_4<T,A1,A2,A3,A4>::~CallbackEvent_4() {
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline void CallbackEvent_4<T,A1,A2,A3,A4>::Trigger() {
    (object_->*callback_)(a1_, a2_, a3_, a4_);
    delete this;
}
}
/**
 * 基础网络库
 */
namespace arc {
class BufferPool;
class Clock;
class Event;
class LibraryManager;
class LoggerManager;
class PathManager;
class Service;
class System;
class TcpAcceptor;
class TcpSocket;
class Timer;
class TimerTask;
class TrackerManager;
class UdpSocket;
/**
 * 创建指定名称的跟踪日志
 * @param name 日志名
 * @param format 输出格式
 */
void PrintTrack(const std::string &name, const char *format, ...);
/**
 * 获取日志管理器
 * @return 日志管理器对象
 */
LoggerManager *GetLoggerManager();
/**
 * 获取跟踪日志管理器
 * @return 跟踪日志管理器对象
 */
TrackerManager *GetTrackerManager();
/**
 * 获取路径管理器
 * @return 路径管理器对象
 */
PathManager *GetPathManager();
/**
 * 获取库管理器，用于加载动态库
 * @return 库管理器
 */
LibraryManager *GetLibraryManager();
/**
 * 获取网络服务实例
 * @return 网络服务对象
 */
Service *GetService();
/**
 * 获取系统相关信息
 * @return 系统相关信息的类
 */
System *GetSystem();
/**
 * 创建TCP服务器套接字
 * @return 创建的服务器套接字
 */
TcpAcceptor *CreateTcpAcceptor();
/**
 * 创建TCP套接字
 * @return 创建的套接字
 */
TcpSocket *CreateTcpSocket();
/**
 * 创建UDP套接字
 * @return 创建的套接字
 */
UdpSocket *CreateUdpSocket();
/**
 * 启动一个定时器
 * @param timeout 定时器的超时时间
 * @param repeat 定时器超时后是否重复启动
 * @param task 定时器超时的处理函数
 * @return 创建的定时器的实例
 */
Timer *ScheduleTimer(UInt32 timeout, bool repeat, TimerTask *task);
/**
 * 向事件循环中添加一个事件
 * @param event 添加的事件
 */
void ScheduleEvent(Event *event);
/**
 * 获取指定类型的时钟
 * @param id 指定的时钟类型
 * @return 指定类型的时钟
 */
Clock *GetClock(int id);
/**
 * 获取缓冲区池
 * @return 缓冲区池
 */
BufferPool *GetBufferPool();
/**
 * 创建并启动一个定时器
 * @param timeout 超时时间
 * @param repeat 指定定时器是否重复触发
 * @param object 定时器事件回调函数所属的对象
 * @param callback 定时器事件回调函数
 * @return 新创建的定时器的指针
 */
template <typename T>
Timer *Schedule(UInt32 timeout, bool repeat, T *object, void (T::*callback)(Timer *)) {
    return ScheduleTimer(timeout, repeat, TimerCallback(object, callback));
}
/**
 * 创建并启动一个定时器
 * @param timeout 超时时间
 * @param repeat 指定定时器是否重复触发
 * @param object 定时器事件回调函数所属的对象
 * @param callback 定时器事件回调函数
 * @param a1 传递给回调函数的额外参数
 * @return 新创建的定时器的指针
 */
template <typename T, typename A1>
Timer *Schedule(UInt32 timeout, bool repeat, T *object, void (T::*callback)(Timer *, A1), A1 a1) {
    return ScheduleTimer(TimerCallback(object, callback, a1));
}
/**
 * 创建并启动一个定时器
 * @param timeout 超时时间
 * @param repeat 指定定时器是否重复触发
 * @param object 定时器事件回调函数所属的对象
 * @param callback 定时器事件回调函数
 * @param a1 传递给回调函数的额外参数
 * @param a2 传递给回调函数的额外参数
 * @return 新创建的定时器的指针
 */
template <typename T, typename A1, typename A2>
Timer *Schedule(UInt32 timeout, bool repeat, T *object, void (T::*callback)(Timer *, A1, A2), A1 a1, A2 a2) {
    return ScheduleTimer(timeout, repeat, TimerCallback(object, callback, a1, a2));
}
/**
 * 创建并启动一个定时器
 * @param timeout 超时时间
 * @param repeat 指定定时器是否重复触发
 * @param object 定时器事件回调函数所属的对象
 * @param callback 定时器事件回调函数
 * @param a1 传递给回调函数的额外参数
 * @param a2 传递给回调函数的额外参数
 * @param a3 传递给回调函数的额外参数
 * @return 新创建的定时器的指针
 */
template <typename T, typename A1, typename A2, typename A3>
Timer *Schedule(UInt32 timeout, bool repeat, T *object, void (T::*callback)(Timer *, A1, A2, A3), A1 a1, A2 a2, A3 a3) {
    return ScheduleTimer(timeout, repeat, TimerCallback(object, callback, a1, a2, a3));
}
/**
 * 创建并启动一个定时器
 * @param timeout 超时时间
 * @param repeat 指定定时器是否重复触发
 * @param object 定时器事件回调函数所属的对象
 * @param callback 定时器事件回调函数
 * @param a1 传递给回调函数的额外参数
 * @param a2 传递给回调函数的额外参数
 * @param a3 传递给回调函数的额外参数
 * @return 新创建的定时器的指针
 */
template <typename T, typename A1, typename A2, typename A3, typename A4>
Timer *Schedule(UInt32 timeout, bool repeat, T *object, void (T::*callback)(Timer *, A1, A2, A3, A4), A1 a1, A2 a2, A3 a3, A4 a4) {
    return ScheduleTimer(timeout, repeat, TimerCallback(object, callback, a1, a2, a3, a4));
}
/**
 * 向事件循环中添加一个事件
 * @param object 回调函数所属的对象
 * @param callback 回调函数
 */
template <typename T>
void Schedule(T *object, void (T::*callback)()) {
    return ScheduleEvent(EventCallback(object, callback));
}
/**
 * 向事件循环中添加一个事件
 * @param object 回调函数所属的对象
 * @param callback 回调函数
 * @param a1 传递给回调函数的额外参数
 */
template <typename T, typename A1>
void Schedule(T *object, void (T::*callback)(A1), A1 a1) {
    return ScheduleEvent(EventCallback(object, callback, a1));
}
/**
 * 向事件循环中添加一个事件
 * @param object 回调函数所属的对象
 * @param callback 回调函数
 * @param a1 传递给回调函数的额外参数
 * @param a2 传递给回调函数的额外参数
 * @param a3 传递给回调函数的额外参数
 */
template <typename T, typename A1, typename A2>
void Schedule(T *object, void (T::*callback)(A1, A2), A1 a1, A2 a2) {
    return ScheduleEvent(EventCallback(object, callback, a1, a2));
}
/**
 * 向事件循环中添加一个事件
 * @param object 回调函数所属的对象
 * @param callback 回调函数
 * @param a1 传递给回调函数的额外参数
 * @param a2 传递给回调函数的额外参数
 * @param a3 传递给回调函数的额外参数
 */
template <typename T, typename A1, typename A2, typename A3>
void Schedule(T *object, void (T::*callback)(A1, A2, A3), A1 a1, A2 a2, A3 a3) {
    return ScheduleEvent(EventCallback(object, callback, a1, a2, a3));
}
/**
 * 向事件循环中添加一个事件
 * @param object 回调函数所属的对象
 * @param callback 回调函数
 * @param a1 传递给回调函数的额外参数
 * @param a2 传递给回调函数的额外参数
 * @param a3 传递给回调函数的额外参数
 * @param a4 传递给回调函数的额外参数
 */
template <typename T, typename A1, typename A2, typename A3, typename A4>
void Schedule(T *object, void (T::*callback)(A1, A2, A3, A4), A1 a1, A2 a2, A3 a3, A4 a4) {
    return ScheduleEvent(EventCallback(object, callback, a1, a2, a3, a4));
}
}
namespace arc {
/**
 * 外部日志类，用于替换arc库中默认的日志函数
 */
class ExternalLogger {
public:
    /**
     * 设置外部日志函数
     * @param logger 要设置的外部日志函数
     */
    static void Set(void (*logger)(const std::string &name, const std::string &level, const std::string &context, const char *format, va_list args));
    /**
     * 重置默认的日志函数
     */
    static void Reset();
};
}
namespace arc {
/**
 * 包含一些简单的文件操作
 */
namespace FileUtils {
    /**
     * 读取指定的文件
     * @param filename 要读取的文件名
     * @param data 用于存放读取的数据
     * @param size data的大小
     * @return 是否读取成功
     */
    bool Read(const std::string &filename, char *data, UInt32 size);
    /**
     * 读取指定的文件
     * @param filename 要读取的文件名
     * @param content 用于存放读取的数据
     * @return 是否读取成功
     */
    bool Read(const std::string &filename, std::string &content);
    /**
     * 向指定的文件写入内容
     * @param filename 要操作的文件名
     * @param data 要写入的数据
     * @param size data的大小
     * @return 是否写入成功
     */
    bool Write(const std::string &filename, const char *data, UInt32 size);
    /**
     * 向指定的文件写入内容
     * @param filename 要操作的文件名
     * @param content 要写入的数据
     * @return 是否写入成功
     */
    bool Write(const std::string &filename, const std::string &content);
    /**
     * 删除指定的文件
     * @param filename 要删除的文件名
     * @return 是否成功删除，如果文件不存在，也返回true
     */
    bool Remove(const std::string &filename);
}
}
namespace arc {
/**
 * 此类表示用于读取数据的输入缓冲区
 * @see Reader
 * @see TcpSocket
 */
class InputBuffer {
public:
    /**
     * 从缓冲区读取数据
     * 被读取的数据仍在缓冲区中，直到Mark函数被调用
     * @param data 存放数据的内存地址
     * @param bytes 要读取的字节数
     * @return 如果读取成功，则返回true；否则，返回false
     */
    virtual bool Read(char *data, UInt32 bytes) = 0;
    /**
     * 返回缓冲区中可供读取的数据的总字节数
     * @return 缓冲区中可供读取的数据的总字节数
     */
    virtual UInt32 Available() const = 0;
    /**
     * 标记缓冲区，已读取的数据会从缓冲区移除
     */
    virtual void Mark() = 0;
    /**
     * 重置缓冲区，读取指针会移到上次标记的位置
     */
    virtual void Reset() = 0;
    /**
     * 销毁此缓冲区
     */
    virtual void Close() = 0;
};
}
namespace arc {
/**
 * 此类实现内存的输入缓冲区
 */
class InBuffer : public InputBuffer {
public:
    /**
     * 根据指定的内存块创建输入缓冲区
     * @param data 指定的内存地址
     * @param size 内存块的大小
     */
    InBuffer(const char *data, UInt32 size);
    /**
     * 析构函数
     */
    virtual ~InBuffer();
public:
    virtual bool Read(char *data, UInt32 bytes);
    virtual UInt32 Available() const;
    virtual void Mark();
    virtual void Reset();
    virtual void Close();
private:
    const char *begin_;
    const char *cursor_;
    const char *end_;
};
}
namespace arc {
/**
 * 此类表示动态库
 */
class Library {
public:
    /**
     * 获取最近的错误消息
     * @return 错误消息
     */
    virtual const char *GetErrorMessage() const = 0;
    /**
     * 获取此对象的副本，副本可以用来控制此对象的生存期
     * @return 此对象的副本
     */
    virtual Library *Retain() = 0;
    /**
     * 解析指定名称的符号
     * @param symbol 指定的符号名
     * @return 若成功，则返回符号的地址，否则返回NULL
     */
    virtual void *Resolve(const std::string &symbol) = 0;
    /**
     * 释放此对象，只有当所有副本都释放时才会真正销毁对象
     */
    virtual void Release() = 0;
};
}
namespace arc {
class Library;
/**
 * 库管理器，用于加载动态库
 */
class LibraryManager {
public:
    /**
     * 加载指定的动态库
     * @param filename 动态库的文件路径
     * @param message 失败时用于保存错误信息，如果为NULL，则错误信息不返回
     * @return 返回加载的动态库，如果失败则返回NULL
     */
    virtual Library *Load(const std::string &filename, const char **message = NULL) = 0;
};
}
namespace arc {
/**
 * 此类用于保存对象在列表中的位置
 */
template <typename OwnerT, typename ListT>
class ListEntrypoint : public Entrypoint {
private:
    typedef typename ListT::iterator Iterator;
    typedef void (OwnerT::*Callback)(Iterator position);
public:
    /**
     * 构造函数
     * @param position 列表中的位置
     * @param owner 列表所属的对象
     * @param callback 删除此对象时的回调函数
     */
    ListEntrypoint(Iterator position, OwnerT *owner, Callback callback);
    /**
     * 析构函数
     */
    virtual ~ListEntrypoint();
public:
    /**
     * 将此对象从列表中删除
     */
    virtual void Erase();
private:
    OwnerT *owner_;
    Iterator position_;
    Callback callback_;
};
}
namespace arc {
template <typename OwnerT, typename ListT>
inline ListEntrypoint<OwnerT, ListT>::ListEntrypoint(Iterator position, OwnerT *owner, Callback callback) {
    position_ = position;
    owner_ = owner;
    callback_ = callback;
}
template <typename OwnerT, typename ListT>
inline ListEntrypoint<OwnerT, ListT>::~ListEntrypoint() {
    (owner_->*callback_)(position_);
}
template <typename OwnerT, typename ListT>
inline void ListEntrypoint<OwnerT, ListT>::Erase() {
    delete this;
}
}
namespace arc {
class LoggerContext;
/**
 * 此类表示用于输出日志的工具类
 * @see LoggerManager
 */
class Logger {
public:
    /**
     * 获取当前的日志级别
     * @see LoggerLevel
     * @return 日志级别
     */
    virtual UInt8 GetLevel() const = 0;
    /**
     * 设置日志级别
     * @see LoggerLevel
     * @param level 日志级别
     */
    virtual void SetLevel(UInt8 level) = 0;
    /**
     * 获取日志所属的包的名称
     * @return 日志所属的包的名称
     */
    virtual const std::string &GetPackage() const = 0;
    /**
     * 获取日志所属的类的名称
     * @return 日志所属的类的名称
     */
    virtual const std::string &GetClass() const = 0;
    /**
     * 创建日志上下文
     * @param function 上下文的函数名
     * @param codeLine 上下文的代码行号
     * @param outputLevel 上下文的输出级别
     */
    virtual LoggerContext *CreateContext(const std::string &function, UInt32 codeLine, UInt8 outputLevel) = 0;
    /**
     * 获取指定的上下文
     * @return 指定的上下文，如果未找到，则返回NULL
     */
    virtual LoggerContext *GetContext(UInt32 contextId) = 0;
    /**
     * 获取上下文的总数
     * @return 上下文的总数
     */
    virtual UInt32 GetContextCount() const = 0;
    /**
     * 获取指定范围的上下文
     * @param contexts 用于保存获取的上下文
     * @param from 指定上下文的起始索引
     * @param to 指定上下文的终止索引
     * @return 成功获取的上下文数目
     */
    virtual UInt32 GetContexts(LoggerContext *contexts[], UInt32 from, UInt32 to) = 0;
    /**
     * 获取此日志类输出的日志总行数
     * @return 此日志类输出的日志总行数
     */
    virtual UInt64 GetTotalOutputLine() const = 0;
    /**
     * 输出一条日志
     * @param level 日志级别
     * @param context 上下文
     * @param format 输出文本
     */
    virtual void Print(UInt8 level, LoggerContext *context, const char *format, ...) = 0;
    /**
     * 输出一条日志
     * @param level 日志级别
     * @param context 上下文
     * @param format 输出文本
     * @param arguments 可变长参数
     */
    virtual void PrintV(UInt8 level, LoggerContext *context, const char *format, va_list arguments) = 0;
    /**
     * 创建日志上下文
     * @param function 上下文的函数名
     * @param codeLine 上下文的代码行号
     * @param outputLevel 上下文的输出级别
     * @param signature 日志上下文的签名
     */
    virtual LoggerContext *CreateContext(const std::string &function, UInt32 codeLine, UInt8 outputLevel, const std::string &signature) = 0;
};
}
namespace arc {
class Logger;
/**
 * 日志上下文
 */
class LoggerContext {
public:
    /**
     * 获取此上下文对应的日志类
     * @return 此上下文对应的日志类
     */
    virtual Logger *GetLogger() = 0;
    /**
     * 获取上下文的ID
     * @return 此上下文的ID
     */
    virtual UInt32 GetContextId() const = 0;
    /**
     * 获取此上下文的显示名称
     * @return 此上下文的显示名称
     */
    virtual const std::string &GetDisplayName() const = 0;
    /**
     * 获取此上下文的函数名
     * @return 此上下文的函数名
     */
    virtual const std::string &GetFunction() const = 0;
    /**
     * 获取此上下文的行号
     * @return 此上下文的行号
     */
    virtual UInt32 GetCodeLine() const = 0;
    /**
     * 获取日志上下文的输出级别
     * @return 此日志上下文的输出级别
     */
    virtual UInt8 GetOutputLevel() const = 0;
    /**
     * 获取日志级别
     * @return 当前上下文的日志级别
     */
    virtual UInt8 GetLevel() const = 0;
    /**
     * 设置日志级别
     * @param 要设置的日志级别
     */
    virtual void SetLevel(UInt8 level) = 0;
    /**
     * 获取此上下文输出的日志总行数
     * @return 此上下文输出的日志总行数
     */
    virtual UInt64 GetTotalOutputLine() const = 0;
    /**
     * 获取此上下文的签名
     * @return 此上下文的签名
     */
    virtual const std::string &GetSignature() const = 0;
};
}
namespace arc {
class Logger;
class LoggerContext;
/**
 * 此类用于初始化LoggerContext，并为打印日志提供便利
 */
class LoggerHolder {
public:
    /**
     * 构造函数
     */
    LoggerHolder(UInt8 level, const char *function, UInt32 line, Logger *logger);
    /**
     * 析构函数
     */
    virtual ~LoggerHolder();
public:
    /**
     * 打印一条日志
     * @param format
     */
    void operator()(const char *format, ...);
private:
    UInt8 level_;
    Logger *logger_;
    LoggerContext *context_;
};
}
namespace arc {
/**
 * 枚举日志级别
 */
namespace LoggerLevel {
    /**
     * 跟踪
     */
    const UInt8 LEVEL_TRACE = 0x00;
    /**
     * 调试
     */
    const UInt8 LEVEL_DEBUG = 0x01;
    /**
     * 信息
     */
    const UInt8 LEVEL_INFO = 0x02;
    /**
     * 注意
     */
    const UInt8 LEVEL_NOTICE = 0x03;
    /**
     * 警告
     */
    const UInt8 LEVEL_WARN = 0x04;
    /**
     * 警报
     */
    const UInt8 LEVEL_ALERT = 0x05;
    /**
     * 错误
     */
    const UInt8 LEVEL_ERROR = 0x06;
    /**
     * 关键错误
     */
    const UInt8 LEVEL_CRIT = 0x07;
    /**
     * 紧急错误
     */
    const UInt8 LEVEL_EMERG = 0x08;
    /**
     * 致命错误
     */
    const UInt8 LEVEL_FATAL = 0x09;
    /**
     * 继承自上层的日志级别
     */
    const UInt8 LEVEL_INHERIT = 0xFF;
    /**
     * 获取日志级别的显示名称
     * @param level 指定的日志级别
     * @return 指定日志级别的显示名称
     */
    const char *GetLevelName(UInt8 level);
    const char *GetLevelColor(UInt8 level);
    const char *GetContentColor(UInt8 level);
    const char *GetClearColor();
}
}
namespace arc {
class Logger;
/**
 * 此类用于创建和管理日志
 */
class LoggerManager {
public:
    /**
     * 获取全局的日志级别
     * @see LoggerLevel
     * @return 设置全局的日志级别
     */
    virtual UInt8 GetGlobalLevel() const = 0;
    /**
     * 设置全局的日志级别
     * @see LoggerLevel
     * @param 要设置的日志级别
     */
    virtual void SetGlobalLevel(UInt8 level) = 0;
    /**
     * 创建指定的日志对象，如已存在，则返回已有对象
     * @param package 日志所属的package，通常为对应的工程名
     * @param className 日志所属的类名
     * @return 创建的日志对象，或已有的日志对象（一定不为NULL）
     */
    virtual Logger *CreateLogger(const std::string &package, const std::string &className) = 0;
    /**
     * 获取指定的日志对象，如不存在，则返回NULL
     * @param package 日志所属的package，通常为对应的工程名
     * @param className 日志所属的类名
     * @return 获取到的日志对象，如不存在，则返回NULL
     */
    virtual Logger *GetLogger(const std::string &package, const std::string &className) = 0;
    /**
     * 获取日志对象的总数
     * @return 日志对象的总数
     */
    virtual UInt32 GetLoggerCount() const = 0;
    /**
     * 获取指定范围的日志对象
     * @param loggers 用于保存获取的日志对象
     * @param from 指定日志的起始索引
     * @param to 指定日志的终止索引
     * @return 成功获取的日志对象数目
     */
    virtual UInt32 GetLoggers(Logger *loggers[], UInt32 from, UInt32 to) = 0;
};
}
namespace arc {
template <typename T>
class ObjectCounter {
public:
    ObjectCounter();
    ObjectCounter(const ObjectCounter &counter);
    ~ObjectCounter();
public:
    static Int32 GetCount();
private:
    static Int32 count_;
};
}
using arc::ObjectCounter;
namespace arc {
template <typename T>
Int32 ObjectCounter<T>::count_ = 0;
template <typename T>
inline ObjectCounter<T>::ObjectCounter() {
    ++count_;
}
template <typename T>
inline ObjectCounter<T>::ObjectCounter(const ObjectCounter &counter) {
    ++count_;
}
template <typename T>
inline ObjectCounter<T>::~ObjectCounter() {
    --count_;
}
template <typename T>
inline Int32 ObjectCounter<T>::GetCount() {
    return count_;
}
}
namespace arc {
/**
 * 此类表示用于写入数据的输出缓冲区
 * @see TcpSocket
 * @see Writer
 */
class OutputBuffer {
public:
    /**
     * 向缓冲区写入数据
     * 写入操作不会马上转到底层的输出流，直到Flush函数被调用
     * @param data 要写入的数据
     * @param bytes 要写入的字节数
     * @return 如果写入成功，则返回true；否则，返回false
     */
    virtual bool Write(const char *data, UInt32 bytes) = 0;
    /**
     * 刷新此缓冲区的输出流。所有缓冲的输出字节被写出到底层输出流中
     */
    virtual void Flush() = 0;
    /**
     * 缓冲区中的字节数
     */
    virtual UInt32 Size() const = 0;
    /**
     * 销毁此缓冲区
     */
    virtual void Close() = 0;
};
}
namespace arc {
/**
 * 此类实现内存的输出缓冲区
 */
class OutBuffer : public OutputBuffer {
public:
    /**
     * 根据指定内存地址创建输出缓冲区
     * @param data 指定的内存地址
     * @param size 缓冲区的大小
     */
    OutBuffer(char *data, UInt32 size);
    /**
     * 析构函数
     */
    virtual ~OutBuffer();
public:
    virtual bool Write(const char *data, UInt32 bytes);
    virtual void Flush();
    virtual UInt32 Size() const;
    virtual void Close();
private:
    char *begin_;
    char *end_;
    char *cursor_;
};
}
namespace arc {
class Reader;
class Writer;
/**
 * 此类表示可以在缓冲区中读写的数据包
 * @see Reader
 * @see Writer
 */
class Packet {
public:
    /**
     * 将此数据包打包进输出缓冲区中
     * @param writer 输出缓冲区的Writer
     * @return 如果写入成功，则返回true；否则返回false
     */
    virtual bool Pack(Writer &writer) const = 0;
    /**
     * 从输入缓冲区读取数据包
     * @param reader 输入缓冲区的Reader
     * @return 如果读取成功，则返回true；否则返回false
     */
    virtual bool Unpack(Reader &reader) = 0;
    /**
     * 格式化此数据包以便打印其内容
     * @return 此数据包的字符串表示
     */
    virtual std::string Dump() const = 0;
};
}
namespace arc {
/**
 * 此类用于管理程序的路径
 */
class PathManager {
public:
    /**
     * 获取指定名称的路径
     * @param name 路径名
     * @return 路径
     */
    virtual std::string GetPath(const std::string &name) const = 0;
};
}
namespace arc {
/**
 * 此类用于管理全局的属性
 */
class PropertyUtils {
public:
    /**
     * 设置一个指定的属性值
     * @param section 属性的分类
     * @param name 属性的名称
     * @param value 属性值
     */
    template <typename T>
    static void SetValue(const std::string &section, const std::string &name, const T &value);
    /**
     * 读取一个指定的属性值
     * @param section 属性的分类
     * @param name 属性的名称
     * @param value 属性值
     * @return 如果读取成功，则返回true；否则，返回false
     */
    template <typename T>
    static bool GetValue(const std::string &section, const std::string &name, T &value);
    /**
     * 读取一个指定的属性值
     * @param section 属性的分类
     * @param name 属性的名称
     * @return 如果读取成功，则返回该属性；否则，返回空属性（json::Null）
     */
    static const json::Variant &GetValue(const std::string &section, const std::string &name);
    /**
     * 设置一个指定的属性值
     * @param section 属性的分类
     * @param name 属性的名称
     * @param value 属性值
     */
    static void SetValue(const std::string &section, const std::string &name, const json::Variant &value);
};
}
using arc::PropertyUtils;
namespace arc {
template <typename T>
inline void PropertyUtils::SetValue(const std::string &section, const std::string &name, const T &value) {
    json::Variant variant;
    variant.As<T>() = value;
    SetValue(section, name, variant);
}
template <typename T>
inline bool PropertyUtils::GetValue(const std::string &section, const std::string &name, T &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<T>()) {
        value = variant.As<T>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<bool>(const std::string &section, const std::string &name, bool &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Boolean>()) {
        value = variant.As<json::Boolean>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<Int8>(const std::string &section, const std::string &name, Int8 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<UInt8>(const std::string &section, const std::string &name, UInt8 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<Int16>(const std::string &section, const std::string &name, Int16 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<UInt16>(const std::string &section, const std::string &name, UInt16 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<Int32>(const std::string &section, const std::string &name, Int32 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<UInt32>(const std::string &section, const std::string &name, UInt32 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<Int64>(const std::string &section, const std::string &name, Int64 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<UInt64>(const std::string &section, const std::string &name, UInt64 &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<float>(const std::string &section, const std::string &name, float &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<double>(const std::string &section, const std::string &name, double &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::Number>()) {
        value = variant.As<json::Number>();
        return true;
    }
    return false;
}
template <>
inline bool PropertyUtils::GetValue<std::string>(const std::string &section, const std::string &name, std::string &value) {
    const json::Variant &variant = GetValue(section, name);
    if (variant.Is<json::String>()) {
        value = variant.As<json::String>();
        return true;
    }
    return false;
}
}
namespace arc {
class InputBuffer;
class Packet;
/**
 * 此类用于从输入缓冲区读取指定格式的数据
 * @see InputBuffer
 */
class Reader {
public:
    /**
     * 创建Reader，并将其绑定到指定的输入缓冲区
     * param buffer 要绑定的输入缓冲区
     */
    Reader(InputBuffer *buffer);
    /**
     * 析构函数
     * 如果Reader的读取操作全部成功，那么会调用缓冲区的Mark函数
     * 如果读取失败，则析构时会调用Reset函数
     */
    virtual ~Reader();
public:
    /**
     * 返回Reader的读取状态，如果读取全部成功，则返回true，否则，返回false
     * @return 如果读取全部成功，则返回true，否则，返回false
     */
    operator bool() const;
public:
    /**
     * 返回输入缓冲区可读取的数据字节数
     * @return 输入缓冲区可读取的数据字节数
     */
    UInt32 GetSize() const;
    /**
     * 将此reader与当前的输入缓冲区分离，方便输入缓冲区失效时的处理
     * @param flush 是否应用对输入缓冲区的变更，默认为false
     */
    void Detach(bool flush = false);
    /**
     * 将此reader绑定到新的输入缓冲区
     * @param flush 是否对当前的缓冲区应用变更，默认为false
     */
    void Attach(InputBuffer *buffer, bool flush = false);
public:
    /**
     * 从缓冲区读取一个Packet
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(Packet &value);
    /**
     * 从缓冲区读取一个布尔值
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(bool &value);
    /**
     * 从缓冲区读取一个64位无符号整数
     * @param value 要读取的值
     * @param bigEndian 字节序是否为大端
     * @return 此Reader的引用
     */
    Reader &operator()(UInt64 &value, bool bigEndian = false);
    /**
     * 从缓冲区读取一个64位有符号整数
     * @param value 要读取的值
     * @param bigEndian 字节序是否为大端
     * @return 此Reader的引用
     */
    Reader &operator()(Int64 &value, bool bigEndian = false);
    /**
     * 从缓冲区读取一个32位无符号整数
     * @param value 要读取的值
     * @param bigEndian 字节序是否为大端
     * @return 此Reader的引用
     */
    Reader &operator()(UInt32 &value, bool bigEndian = false);
    /**
     * 从缓冲区读取一个32位有符号整数
     * @param value 要读取的值
     * @param bigEndian 字节序是否为大端
     * @return 此Reader的引用
     */
    Reader &operator()(Int32 &value, bool bigEndian = false);
    /**
     * 从缓冲区读取一个16位无符号整数
     * @param value 要读取的值
     * @param bigEndian 字节序是否为大端
     * @return 此Reader的引用
     */
    Reader &operator()(UInt16 &value, bool bigEndian = false);
    /**
     * 从缓冲区读取一个16位有符号整数
     * @param value 要读取的值
     * @param bigEndian 字节序是否为大端
     * @return 此Reader的引用
     */
    Reader &operator()(Int16 &value, bool bigEndian = false);
    /**
     * 从缓冲区读取一个8位无符号整数
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(UInt8 &value);
    /**
     * 从缓冲区读取一个8位有符号整数
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(Int8 &value);
    /**
     * 从缓冲区读取一个字符串，字符串长度最多为2^16
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(std::string &value);
    /**
     * 从缓冲区读取一个字符串，字符串长度最多为2^32
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(std::string &value, bool);
    /**
     * 从缓冲区读取指定长度的数据
     * @param size 指定长度
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(UInt32 size, std::string &value);
    /**
     * 从缓冲区读取指定长度的数据
     * @param size 指定长度
     * @param value 要读取的值
     * @return 此Reader的引用
     */
    Reader &operator()(UInt32 size, char *value);
    /**
     * 从缓冲区读取一个列表
     * @param container 要读取的列表
     * @return 此Reader的引用
     */
    template <typename ValueT>
    Reader &operator()(std::list<ValueT> &container);
    /**
     * 从缓冲区读取一个Map
     * @param container 要读取的Map
     * @return 此Reader的引用
     */
    template <typename KeyT, typename ValueT>
    Reader &operator()(std::map<KeyT, ValueT> &container);
    /**
     * 从缓冲区读取一个Set
     * @param container 要读取的Set
     * @return 此Reader的引用
     */
    template <typename ValueT>
    Reader &operator()(std::set<ValueT> &container);
private:
    void Flush();
private:
    bool good_;
    InputBuffer *buffer_;
};
template <typename ValueT>
Reader &Reader::operator()(std::list<ValueT> &container) {
    container.clear();
    UInt32 size;
    if (this->operator()(size)) {
        for (UInt32 i = 0; i < size; ++i) {
            ValueT value;
            if (!this->operator()(value)) {
                good_ = false;
                break;
            }
            container.push_back(value);
        }
    } else {
        good_ = false;
    }
    return *this;
}
template <typename KeyT, typename ValueT>
Reader &Reader::operator()(std::map<KeyT, ValueT> &container) {
    container.clear();
    UInt32 size;
    if (this->operator()(size)) {
        for (UInt32 i = 0; i < size; ++i) {
            std::pair<KeyT, ValueT> pair;
            if (!this->operator()(pair.first)) {
                good_ = false;
                break;
            }
            if (!this->operator()(pair.second)) {
                good_ = false;
                break;
            }
            container.insert(pair);
        }
    } else {
        good_ = false;
    }
    return *this;
}
template <typename ValueT>
Reader &Reader::operator()(std::set<ValueT> &container) {
    UInt32 size;
    container.clear();
    if (this->operator()(size)) {
        for (UInt32 i = 0; i < size; ++i) {
            ValueT v;
            if (!this->operator()(v)) {
                good_ = false;
                break;
            }
            container.insert(v);
        }
    } else {
        good_ = false;
    }
    return *this;
}
}
namespace arc {
class Scope;
class ScopeWatcher;
/**
 * 此类用于观察对象的生存期
 * @see Scope
 */
class ScopeGuard {
public:
    /**
     * 构造函数，不观察任何对象的生存期
     */
    ScopeGuard();
    /**
     * 构造函数
     * @param scope 要观察的生存期
     */
    ScopeGuard(Scope &scope);
    /**
     * 构造函数
     * @param watcher 生存期观察者
     */
    ScopeGuard(ScopeWatcher *watcher);
    /**
     * 拷贝构造函数
     * @param other 要拷贝的对象
     */
    ScopeGuard(const ScopeGuard &other);
    /**
     * 析构函数
     */
    virtual ~ScopeGuard();
public:
    /**
     * 赋值函数
     * @param other 要拷贝的对象
     * @return 此对象的引用
     */
    ScopeGuard &operator=(const ScopeGuard &other);
    /**
     * 监控指定对象的生存期
     * @param scope 指定的监控对象
     */
    void Bind(Scope &scope);
    /**
     * 判断对象是否还有效
     * @return 对象是否还有效
     */
    bool Valid() const;
    /**
     * 判断对象是否失效
     * @return 对象是否失效
     */
    bool Invalid() const;
private:
    ScopeWatcher *watcher_;
};
}
using arc::ScopeGuard;
namespace arc {
class ScopeWatcher;
/**
 * 此类用于维护对象的生存期
 * @see ScopeGuard
 */
class Scope {
public:
    /**
     * 构造函数
     */
    Scope();
    /**
     * 默认拷贝函数
     */
    Scope(const Scope &other);
    /**
     * 析构函数
     */
    virtual ~Scope();
public:
    Scope &operator=(const Scope &other);
public:
    ScopeGuard Watch();
    ScopeGuard Watch() const;
private:
    mutable ScopeWatcher *watcher_;
};
}
using arc::Scope;
namespace arc {
class Entrypoint;
/**
 * 信号槽机制中的槽
 */
class Slot {
public:
    /**
     * 断开与信号的连接
     */
    virtual void Disconnect() = 0;
};
template <typename Signature>
class SlotT {
};
template <>
class SlotT<void()> : public Slot {
public:
    virtual void OnEmit() = 0;
    virtual void OnDisconnect() = 0;
};
template <typename A1>
class SlotT<void(A1)> : public Slot {
public:
    virtual void OnEmit(A1 a1) = 0;
    virtual void OnDisconnect() = 0;
};
template <typename A1, typename A2>
class SlotT<void(A1,A2)> : public Slot {
public:
    virtual void OnEmit(A1 a1, A2 a2) = 0;
    virtual void OnDisconnect() = 0;
};
template <typename A1, typename A2, typename A3>
class SlotT<void(A1,A2,A3)> : public Slot {
public:
    virtual void OnEmit(A1 a1, A2 a2, A3 a3) = 0;
    virtual void OnDisconnect() = 0;
};
template <typename A1, typename A2, typename A3, typename A4>
class SlotT<void(A1,A2,A3,A4)> : public Slot {
public:
    virtual void OnEmit(A1 a1, A2 a2, A3 a3, A4 a4) = 0;
    virtual void OnDisconnect() = 0;
};
template <typename T>
class Slot_0 : public SlotT<void()> {
public:
    typedef void (T::*Callback)();
public:
    Slot_0(T *object, Callback callback, Entrypoint *entrypoint);
    virtual ~Slot_0();
public:
    virtual void OnEmit();
    virtual void OnDisconnect();
public:
    virtual void Disconnect();
private:
    T *object_;
    Callback callback_;
    Entrypoint *entrypoint_;
};
template <typename T, typename A1>
class Slot_1 : public SlotT<void(A1)> {
public:
    typedef void (T::*Callback)(A1);
public:
    Slot_1(T *object, Callback callback, Entrypoint *entrypoint);
    virtual ~Slot_1();
public:
    virtual void OnEmit(A1 a1);
    virtual void OnDisconnect();
public:
    virtual void Disconnect();
private:
    T *object_;
    Callback callback_;
    Entrypoint *entrypoint_;
};
template <typename T, typename A1, typename A2>
class Slot_2 : public SlotT<void(A1,A2)> {
public:
    typedef void (T::*Callback)(A1,A2);
public:
    Slot_2(T *object, Callback callback, Entrypoint *entrypoint);
    virtual ~Slot_2();
public:
    virtual void OnEmit(A1 a1, A2 a2);
    virtual void OnDisconnect();
public:
    virtual void Disconnect();
private:
    T *object_;
    Callback callback_;
    Entrypoint *entrypoint_;
};
template <typename T, typename A1, typename A2, typename A3>
class Slot_3 : public SlotT<void(A1,A2,A3)> {
public:
    typedef void (T::*Callback)(A1,A2,A3);
public:
    Slot_3(T *object, Callback callback, Entrypoint *entrypoint);
    virtual ~Slot_3();
public:
    virtual void OnEmit(A1 a1, A2 a2, A3 a3);
    virtual void OnDisconnect();
public:
    virtual void Disconnect();
private:
    T *object_;
    Callback callback_;
    Entrypoint *entrypoint_;
};
template <typename T, typename A1, typename A2, typename A3, typename A4>
class Slot_4 : public SlotT<void(A1,A2,A3,A4)> {
public:
    typedef void (T::*Callback)(A1,A2,A3,A4);
public:
    Slot_4(T *object, Callback callback, Entrypoint *entrypoint);
    virtual ~Slot_4();
public:
    virtual void OnEmit(A1 a1, A2 a2, A3 a3, A4 a4);
    virtual void OnDisconnect();
public:
    virtual void Disconnect();
private:
    T *object_;
    Callback callback_;
    Entrypoint *entrypoint_;
};
}
namespace arc {
template <typename T>
inline Slot_0<T>::Slot_0(T *object, Callback callback, Entrypoint *entrypoint) {
    object_ = object;
    callback_ = callback;
    entrypoint_ = entrypoint;
}
template <typename T>
inline Slot_0<T>::~Slot_0() {
    OnDisconnect();
}
template <typename T>
inline void Slot_0<T>::OnEmit() {
    (object_->*callback_)();
}
template <typename T>
inline void Slot_0<T>::OnDisconnect() {
    if (entrypoint_ != NULL) {
        entrypoint_->Erase();
        entrypoint_ = NULL;
    }
}
template <typename T>
inline void Slot_0<T>::Disconnect() {
    delete this;
}
template <typename T, typename A1>
inline Slot_1<T,A1>::Slot_1(T *object, Callback callback, Entrypoint *entrypoint) {
    object_ = object;
    callback_ = callback;
    entrypoint_ = entrypoint;
}
template <typename T, typename A1>
inline Slot_1<T,A1>::~Slot_1() {
    OnDisconnect();
}
template <typename T, typename A1>
inline void Slot_1<T,A1>::OnEmit(A1 a1) {
    (object_->*callback_)(a1);
}
template <typename T, typename A1>
inline void Slot_1<T,A1>::OnDisconnect() {
    if (entrypoint_ != NULL) {
        entrypoint_->Erase();
        entrypoint_ = NULL;
    }
}
template <typename T, typename A1>
inline void Slot_1<T,A1>::Disconnect() {
    delete this;
}
template <typename T, typename A1, typename A2>
inline Slot_2<T,A1,A2>::Slot_2(T *object, Callback callback, Entrypoint *entrypoint) {
    object_ = object;
    callback_ = callback;
    entrypoint_ = entrypoint;
}
template <typename T, typename A1, typename A2>
inline Slot_2<T,A1,A2>::~Slot_2() {
    OnDisconnect();
}
template <typename T, typename A1, typename A2>
inline void Slot_2<T,A1,A2>::OnEmit(A1 a1, A2 a2) {
    (object_->*callback_)(a1, a2);
}
template <typename T, typename A1, typename A2>
inline void Slot_2<T,A1,A2>::OnDisconnect() {
    if (entrypoint_ != NULL) {
        entrypoint_->Erase();
        entrypoint_ = NULL;
    }
}
template <typename T, typename A1, typename A2>
inline void Slot_2<T,A1,A2>::Disconnect() {
    delete this;
}
template <typename T, typename A1, typename A2, typename A3>
inline Slot_3<T,A1,A2,A3>::Slot_3(T *object, Callback callback, Entrypoint *entrypoint) {
    object_ = object;
    callback_ = callback;
    entrypoint_ = entrypoint;
}
template <typename T, typename A1, typename A2, typename A3>
inline Slot_3<T,A1,A2,A3>::~Slot_3() {
    OnDisconnect();
}
template <typename T, typename A1, typename A2, typename A3>
inline void Slot_3<T,A1,A2,A3>::OnEmit(A1 a1, A2 a2, A3 a3) {
    (object_->*callback_)(a1, a2, a3);
}
template <typename T, typename A1, typename A2, typename A3>
inline void Slot_3<T,A1,A2,A3>::OnDisconnect() {
    if (entrypoint_ != NULL) {
        entrypoint_->Erase();
        entrypoint_ = NULL;
    }
}
template <typename T, typename A1, typename A2, typename A3>
inline void Slot_3<T,A1,A2,A3>::Disconnect() {
    delete this;
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline Slot_4<T,A1,A2,A3,A4>::Slot_4(T *object, Callback callback, Entrypoint *entrypoint) {
    object_ = object;
    callback_ = callback;
    entrypoint_ = entrypoint;
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline Slot_4<T,A1,A2,A3,A4>::~Slot_4() {
    OnDisconnect();
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline void Slot_4<T,A1,A2,A3,A4>::OnEmit(A1 a1, A2 a2, A3 a3, A4 a4) {
    (object_->*callback_)(a1, a2, a3, a4);
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline void Slot_4<T,A1,A2,A3,A4>::OnDisconnect() {
    if (entrypoint_ != NULL) {
        entrypoint_->Erase();
        entrypoint_ = NULL;
    }
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline void Slot_4<T,A1,A2,A3,A4>::Disconnect() {
    delete this;
}
}
using arc::Slot;
namespace arc {
class Entrypoint;
/**
 * 此类用于实现信号槽机制
 */
template <typename Signature>
class Signal {
};
/**
 * 无参数的信号
 */
template <typename Void>
class Signal<Void()> {
public:
    /**
     * 构造函数
     */
    Signal();
    /**
     * 析构函数
     */
    virtual ~Signal();
public:
    /**
     * 触发此信号，会回调所有连接的Slot
     */
    void Emit();
    /**
     * 将此信号连接到对应的槽（回调函数）
     * @param object 回调函数所属的对象
     * @param callback 回调函数
     * @return 创建的槽，可用于断开此连接
     */
    template <typename T>
    Slot *Connect(T *object, void (T::*callback)());
private:
    typedef std::list<SlotT<void()> *> Slots;
    typedef typename Slots::iterator Iterator;
private:
    void OnDisconnect(Iterator position);
private:
    Scope scope_;
    Slots slots_;
    Iterator *iterator_;
};
/**
 * 带1个参数的信号
 */
template <typename Void, typename A1>
class Signal<Void(A1)> {
public:
    /**
     * 构造函数
     */
    Signal();
    /**
     * 析构函数
     */
    virtual ~Signal();
public:
    /**
     * 触发此信号，会回调所有连接的Slot
     * @param a1 参数1
     */
    void Emit(A1 a1);
    /**
     * 将此信号连接到对应的槽（回调函数）
     * @param object 回调函数所属的对象
     * @param callback 回调函数
     * @return 创建的槽，可用于断开此连接
     */
    template <typename T>
    Slot *Connect(T *object, void (T::*callback)(A1 a1));
private:
    typedef std::list<SlotT<void(A1)> *> Slots;
    typedef typename Slots::iterator Iterator;
private:
    void OnDisconnect(Iterator position);
private:
    Scope scope_;
    Slots slots_;
    Iterator *iterator_;
};
/**
 * 带2个参数的信号
 */
template <typename Void, typename A1, typename A2>
class Signal<Void(A1,A2)> {
public:
    /**
     * 构造函数
     */
    Signal();
    /**
     * 析构函数
     */
    virtual ~Signal();
public:
    /**
     * 触发此信号，会回调所有连接的Slot
     * @param a1 参数1
     * @param a2 参数2
     */
    void Emit(A1 a1, A2 a2);
    /**
     * 将此信号连接到对应的槽（回调函数）
     * @param object 回调函数所属的对象
     * @param callback 回调函数
     * @return 创建的槽，可用于断开此连接
     */
    template <typename T>
    Slot *Connect(T *object, void (T::*callback)(A1,A2));
private:
    typedef std::list<SlotT<void(A1,A2)> *> Slots;
    typedef typename Slots::iterator Iterator;
private:
    void OnDisconnect(Iterator position);
private:
    Scope scope_;
    Slots slots_;
    Iterator *iterator_;
};
/**
 * 带3个参数的信号
 */
template <typename Void, typename A1, typename A2, typename A3>
class Signal<Void(A1,A2,A3)> {
public:
    /**
     * 构造函数
     */
    Signal();
    /**
     * 析构函数
     */
    virtual ~Signal();
public:
    /**
     * 触发此信号，会回调所有连接的Slot
     * @param a1 参数1
     * @param a2 参数2
     * @param a3 参数3
     */
    void Emit(A1 a1, A2 a2, A3 a3);
    /**
     * 将此信号连接到对应的槽（回调函数）
     * @param object 回调函数所属的对象
     * @param callback 回调函数
     * @return 创建的槽，可用于断开此连接
     */
    template <typename T>
    Slot *Connect(T *object, void (T::*callback)(A1,A2,A3));
private:
    typedef std::list<SlotT<void(A1,A2,A3)> *> Slots;
    typedef typename Slots::iterator Iterator;
private:
    void OnDisconnect(Iterator position);
private:
    Scope scope_;
    Slots slots_;
    Iterator *iterator_;
};
/**
 * 带4个参数的信号
 */
template <typename Void, typename A1, typename A2, typename A3, typename A4>
class Signal<Void(A1,A2,A3,A4)> {
public:
    /**
     * 构造函数
     */
    Signal();
    /**
     * 析构函数
     */
    virtual ~Signal();
public:
    /**
     * 触发此信号，会回调所有连接的Slot
     * @param a1 参数1
     * @param a2 参数2
     * @param a3 参数3
     * @param a4 参数4
     */
    void Emit(A1 a1, A2 a2, A3 a3, A4 a4);
    /**
     * 将此信号连接到对应的槽（回调函数）
     * @param object 回调函数所属的对象
     * @param callback 回调函数
     * @return 创建的槽，可用于断开此连接
     */
    template <typename T>
    Slot *Connect(T *object, void (T::*callback)(A1,A2,A3,A4));
private:
    typedef std::list<SlotT<void(A1,A2,A3,A4)> *> Slots;
    typedef typename Slots::iterator Iterator;
private:
    void OnDisconnect(Iterator position);
private:
    Scope scope_;
    Slots slots_;
    Iterator *iterator_;
};
}
namespace arc {
template <typename Void>
inline Signal<Void()>::Signal() {
    iterator_ = NULL;
}
template <typename Void>
inline Signal<Void()>::~Signal() {
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
    while (!slots_.empty()) {
        slots_.front()->OnDisconnect();
    }
}
template <typename Void>
inline void Signal<Void()>::Emit() {
    assert(iterator_ == NULL);
    ScopeGuard guard(scope_);
    iterator_ = new Iterator(slots_.begin());
    while (guard.Valid() && *iterator_ != slots_.end()) {
        SlotT<void()> *slot = **iterator_;
        ++*iterator_;
        slot->OnEmit();
    }
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
}
template <typename Void>
template <typename T>
inline Slot *Signal<Void()>::Connect(T *object, void (T::*callback)()) {
    slots_.push_front(NULL);
    Entrypoint *entrypoint = new ListEntrypoint<Signal, Slots>(slots_.begin(), this, &Signal::OnDisconnect);
    SlotT<void()> *slot = new Slot_0<T>(object, callback, entrypoint);
    slots_.front() = slot;
    return slot;
}
template <typename Void>
inline void Signal<Void()>::OnDisconnect(Iterator position) {
    if (iterator_ != NULL && *iterator_ == position) {
        ++*iterator_;
    }
    slots_.erase(position);
}
template <typename Void, typename A1>
inline Signal<Void(A1)>::Signal() {
    iterator_ = NULL;
}
template <typename Void, typename A1>
inline Signal<Void(A1)>::~Signal() {
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
    while (!slots_.empty()) {
        slots_.front()->OnDisconnect();
    }
}
template <typename Void, typename A1>
inline void Signal<Void(A1)>::Emit(A1 a1) {
    assert(iterator_ == NULL);
    ScopeGuard guard(scope_);
    iterator_ = new Iterator(slots_.begin());
    while (guard.Valid() && *iterator_ != slots_.end()) {
        SlotT<void(A1)> *slot = **iterator_;
        ++*iterator_;
        slot->OnEmit(a1);
    }
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
}
template <typename Void, typename A1>
template <typename T>
inline Slot *Signal<Void(A1)>::Connect(T *object, void (T::*callback)(A1)) {
    slots_.push_front(NULL);
    Entrypoint *entrypoint = new ListEntrypoint<Signal, Slots>(slots_.begin(), this, &Signal::OnDisconnect);
    SlotT<void(A1)> *slot = new Slot_1<T,A1>(object, callback, entrypoint);
    slots_.front() = slot;
    return slot;
}
template <typename Void, typename A1>
inline void Signal<Void(A1)>::OnDisconnect(Iterator position) {
    if (iterator_ != NULL && *iterator_ == position) {
        ++*iterator_;
    }
    slots_.erase(position);
}
template <typename Void, typename A1, typename A2>
inline Signal<Void(A1,A2)>::Signal() {
    iterator_ = NULL;
}
template <typename Void, typename A1, typename A2>
inline Signal<Void(A1,A2)>::~Signal() {
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
    while (!slots_.empty()) {
        slots_.front()->OnDisconnect();
    }
}
template <typename Void, typename A1, typename A2>
inline void Signal<Void(A1,A2)>::Emit(A1 a1, A2 a2) {
    assert(iterator_ == NULL);
    ScopeGuard guard(scope_);
    iterator_ = new Iterator(slots_.begin());
    while (guard.Valid() && *iterator_ != slots_.end()) {
        SlotT<void(A1,A2)> *slot = **iterator_;
        ++*iterator_;
        slot->OnEmit(a1, a2);
    }
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
}
template <typename Void, typename A1, typename A2>
template <typename T>
inline Slot *Signal<Void(A1,A2)>::Connect(T *object, void (T::*callback)(A1,A2)) {
    slots_.push_front(NULL);
    Entrypoint *entrypoint = new ListEntrypoint<Signal, Slots>(slots_.begin(), this, &Signal::OnDisconnect);
    SlotT<void(A1,A2)> *slot = new Slot_2<T,A1,A2>(object, callback, entrypoint);
    slots_.front() = slot;
    return slot;
}
template <typename Void, typename A1, typename A2>
inline void Signal<Void(A1,A2)>::OnDisconnect(Iterator position) {
    if (iterator_ != NULL && *iterator_ == position) {
        ++*iterator_;
    }
    slots_.erase(position);
}
template <typename Void, typename A1, typename A2, typename A3>
inline Signal<Void(A1,A2,A3)>::Signal() {
    iterator_ = NULL;
}
template <typename Void, typename A1, typename A2, typename A3>
inline Signal<Void(A1,A2,A3)>::~Signal() {
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
    while (!slots_.empty()) {
        slots_.front()->OnDisconnect();
    }
}
template <typename Void, typename A1, typename A2, typename A3>
inline void Signal<Void(A1,A2,A3)>::Emit(A1 a1, A2 a2, A3 a3) {
    assert(iterator_ == NULL);
    ScopeGuard guard(scope_);
    iterator_ = new Iterator(slots_.begin());
    while (guard.Valid() && *iterator_ != slots_.end()) {
        SlotT<void(A1,A2,A3)> *slot = **iterator_;
        ++*iterator_;
        slot->OnEmit(a1, a2, a3);
    }
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
}
template <typename Void, typename A1, typename A2, typename A3>
template <typename T>
inline Slot *Signal<Void(A1,A2,A3)>::Connect(T *object, void (T::*callback)(A1,A2,A3)) {
    slots_.push_front(NULL);
    Entrypoint *entrypoint = new ListEntrypoint<Signal, Slots>(slots_.begin(), this, &Signal::OnDisconnect);
    SlotT<void(A1,A2,A3)> *slot = new Slot_3<T,A1,A2,A3>(object, callback, entrypoint);
    slots_.front() = slot;
    return slot;
}
template <typename Void, typename A1, typename A2, typename A3>
inline void Signal<Void(A1,A2,A3)>::OnDisconnect(Iterator position) {
    if (iterator_ != NULL && *iterator_ == position) {
        ++*iterator_;
    }
    slots_.erase(position);
}
template <typename Void, typename A1, typename A2, typename A3, typename A4>
inline Signal<Void(A1,A2,A3,A4)>::Signal() {
    iterator_ = NULL;
}
template <typename Void, typename A1, typename A2, typename A3, typename A4>
inline Signal<Void(A1,A2,A3,A4)>::~Signal() {
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
    while (!slots_.empty()) {
        slots_.front()->OnDisconnect();
    }
}
template <typename Void, typename A1, typename A2, typename A3, typename A4>
inline void Signal<Void(A1,A2,A3,A4)>::Emit(A1 a1, A2 a2, A3 a3, A4 a4) {
    assert(iterator_ == NULL);
    ScopeGuard guard(scope_);
    iterator_ = new Iterator(slots_.begin());
    while (guard.Valid() && *iterator_ != slots_.end()) {
        SlotT<void(A1,A2,A3,A4)> *slot = **iterator_;
        ++*iterator_;
        slot->OnEmit(a1, a2, a3, a4);
    }
    if (iterator_ != NULL) {
        delete iterator_;
        iterator_ = NULL;
    }
}
template <typename Void, typename A1, typename A2, typename A3, typename A4>
template <typename T>
inline Slot *Signal<Void(A1,A2,A3,A4)>::Connect(T *object, void (T::*callback)(A1,A2,A3,A4)) {
    slots_.push_front(NULL);
    Entrypoint *entrypoint = new ListEntrypoint<Signal, Slots>(slots_.begin(), this, &Signal::OnDisconnect);
    SlotT<void(A1,A2,A3,A4)> *slot = new Slot_4<T,A1,A2,A3,A4>(object, callback, entrypoint);
    slots_.front() = slot;
    return slot;
}
template <typename Void, typename A1, typename A2, typename A3, typename A4>
inline void Signal<Void(A1,A2,A3,A4)>::OnDisconnect(Iterator position) {
    if (iterator_ != NULL && *iterator_ == position) {
        ++*iterator_;
    }
    slots_.erase(position);
}
}
using arc::Signal;
namespace arc {
class Clock;
class Event;
class TcpAcceptor;
class TcpSocket;
class Timer;
class TimerTask;
class UdpSocket;
/**
 * 此类表示网络IO相关的服务
 */
class Service {
public:
    /**
     * 初始化服务
     */
    virtual void Init() = 0;
    /**
     * 启动服务，此后程序将进入事件循环中
     */
    virtual void Run() = 0;
    /**
     * 停止服务，退出事件循环，并销毁对象（只用于Run模式）
     */
    virtual void Stop() = 0;
    /**
     * 触发服务，进行一次消息循环（只能在消息循环外部调用）
     * @return 返回此次消息循环是否处理了事件，如果有事件处理，则返回true，否则为空循环，此时外层可以sleep进行等待
     */
    virtual bool Pulse() = 0;
    /**
     * 销毁服务（只适用于Pulse模式，且只能在消息循环外部调用）
     */
    virtual void Destroy() = 0;
    /**
     * 判断服务是否正在运行（调用Stop后Running变为false）
     * @return 服务是否运行
     */
    virtual bool Running() const = 0;
    /**
     * 创建服务器TCP套接字
     * @return 创建的套接字
     */
    virtual TcpAcceptor *CreateTcpAcceptor() = 0;
    /*
     * 创建TCP套接字
     * @return 创建的套接字
     */
    virtual TcpSocket *CreateTcpSocket() = 0;
    /**
     * 创建UDP套接字
     * @return 创建的套接字
     */
    virtual UdpSocket *CreateUdpSocket() = 0;
    /**
     * 获取指定类型的时钟
     * @param id 指定的时钟类型
     * @return 指定类型的时钟
     */
    virtual Clock *GetClock(int id) = 0;
    /**
     * 启动一个定时器
     * @param timeout 定时器的超时时间
     * @param interval 定时器的超时间隔，如果不为0，则会一定时器超时后会以此间隔重新启动
     * @param task 定时器超时的处理函数
     * @return 创建的定时器的实例
     */
    virtual Timer *ScheduleTimer(UInt32 timeout, UInt32 interval, TimerTask *task) = 0;
    /**
     * 向事件循环中添加一个事件，添加的事件无法撤销，即事件一定会触发
     * @param event 添加的事件
     */
    virtual void ScheduleEvent(Event *event) = 0;
    /**
     * 获取服务停止事件的信号
     * @return 服务停止的信号
     */
    virtual Signal<void()> &StopEvent() = 0;
    /**
     * 将程序切到后台运行
     */
    virtual void Daemon() = 0;
};
}
namespace arc {
/**
 * 此类实现套接字地址（IP 地址 + 端口号）
 * @see TcpSocket
 * @see TcpAcceptor
 * @see UdpSocket
 */
class SocketAddress {
public:
    /**
     * 创建套接字地址，IP地址与端口号均为0
     */
    SocketAddress();
    /**
     * 根据IP地址和端口号创建套接字地址
     * @param ip IP地址
     * @param port 端口号
     */
    SocketAddress(UInt32 ip, UInt16 port);
    /**
     * 根据主机名和端口号创建套接字地址
     * @param hostname 主机名
     * @param port 端口号
     */
    SocketAddress(const std::string &hostname, UInt16 port);
    /**
     * 析构函数
     */
    virtual ~SocketAddress();
public:
    /**
     * 将此地址与指定地址比较。当此地址与参数表示相同地址时，结果为true
     * @param other 要与之比较的地址
     * @return 如果地址相同，则返回true；否则，返回false
     */
    bool operator==(const SocketAddress &other) const;
    /**
     * 将此地址与指定地址比较。当此地址与参数表示不同地址时，结果为true
     * @param other 要与之比较的地址
     * @return 如果地址不同，则返回true；否则，返回false
     */
    bool operator!=(const SocketAddress &other) const;
    /**
     * 将此地址与指定地址比较。当此地址较大时，结果为true。比较方式为先比较IP再比较端口号
     * @param other 要与之比较的地址
     * @return 如果此地址较大时，返回true；否则，返回false
     */
    bool operator>(const SocketAddress &other) const;
    /**
     * 将此地址与指定地址比较。当此地址较小时，结果为true。比较方式为先比较IP再比较端口号
     * @param other 要与之比较的地址
     * @return 如果此地址较小时，返回true；否则，返回false
     */
    bool operator<(const SocketAddress &other) const;
    /**
     * 将此地址与指定地址比较。当此地址较大或两者相等时，结果为true。比较方式为先比较IP再比较端口号
     * @param other 要与之比较的地址
     * @return 当此地址较大或两者相等时，结果为true；否则，返回false
     */
    bool operator>=(const SocketAddress &other) const;
    /**
     * 将此地址与指定地址比较。当此地址较小或两者相等时，结果为true。比较方式为先比较IP再比较端口号
     * @param other 要与之比较的地址
     * @return 当此地址较小或两者相等时，结果为true；否则，返回false
     */
    bool operator<=(const SocketAddress &other) const;
public:
    /**
     * 设置套接字地址的IP地址和端口号
     * @param ip IP地址
     * @param port 端口号
     */
    void Set(UInt32 ip, UInt16 port);
    /**
     * 根据主机名和端口号设置套接字地址
     * @param hostname 主机名
     * @param port 端口号
     */
    void Set(const std::string &hostname, UInt16 port);
    /**
     * 获取IP地址
     * @return ip IP地址
     */
    UInt32 GetIp() const;
    /**
     * 获取端口号
     * @return port 端口号
     */
    UInt16 GetPort() const;
public:
    /**
     * 将IP地址转换为点分十进制表示法
     * @param ip IP地址
     * @return 点分十进制表示法的IP地址
     */
    static std::string ToInetAddress(UInt32 ip);
    /**
     * 将IP地址由点分十进制表示法转换为整型
     * @param hostname 点分十进制表示法的IP地址
     * @return IP地址
     */
    static UInt32 FromInetAddress(const std::string &hostname);
private:
    UInt32 ip_;
    UInt16 port_;
};
}
namespace arc {
/**
 * 用字符串实现的输入输出缓冲区
 */
class StringBuffer : virtual public InputBuffer, virtual public OutputBuffer {
public:
    /**
     * 创建缓冲区，并将缓冲区绑定到指定的字符串
     * @param buffer 绑定到缓冲区的字符串，在此缓冲区的读取和写入操作都会同步到此字符串中
     */
    StringBuffer(std::string &buffer);
    /**
     * 析构函数
     */
    virtual ~StringBuffer();
public:
    virtual bool Read(char *data, UInt32 bytes);
    virtual UInt32 Available() const;
    virtual void Mark();
    virtual void Reset();
    virtual void Close();
public:
    virtual bool Write(const char *data, UInt32 bytes);
    virtual void Flush();
    virtual UInt32 Size() const;
private:
    std::string &buffer_;
    UInt32 position_;
};
}
namespace arc {
/*
 * 获取系统相关信息的类
 */
class System {
public:
    /**
     * 获取进程的PID
     * @return 进程的PID
     */
    virtual UInt64 GetPid() const = 0;
    /**
     * 获取进程的PID（字符串）
     * @return 进程的PID
     */
    virtual const std::string &GetPidString() const = 0;
    /**
     * 获取CPU时间
     * @return 进程使用的CPU时间
     */
    virtual UInt64 GetCpuTime() const = 0;
    /**
     * 获取程序使用的内存总数
     * @return 程序使用的内存总数
     */
    virtual UInt64 GetMemoryUsed() const = 0;
};
}
namespace arc {
class SocketAddress;
class TcpAcceptorHandler;
/**
 * 此类实现服务器套接字。服务器套接字绑定指定端口并等待传入的连接请求
 * @see TcpSocket
 * @see SocketAddress
 * @see TcpAcceptorHandler
 */
class TcpAcceptor {
public:
    /**
     * 绑定服务器套接字到特定地址（IP地址和端口号）
     * @param endpoint 要绑定的IP地址和端口号
     * @return 如果绑定成功，则返回true；否则，返回false
     */
    virtual bool Listen(const SocketAddress &endpoint) = 0;
    /**
     * 关闭此套接字
     */
    virtual void Close() = 0;
    /**
     * 设置此服务器套接字的处理程序
     * @param handler 套接字的处理程序
     */
    virtual void SetHandler(TcpAcceptorHandler *handler) = 0;
};
}
namespace arc {
class TcpAcceptor;
class TcpSocket;
/**
 * 此类表示服务器套接字的处理程序
 * @see TcpAcceptor
 */
class TcpAcceptorHandler {
public:
    /**
     * 当有远程套接字连接时的处理函数
     * @param acceptor 服务器套接字
     * @param socket 远程套接字
     */
    virtual void OnAccept(TcpAcceptor *acceptor, TcpSocket *socket) = 0;
    /**
     * 当服务器套接字关闭时的处理函数
     * @param acceptor 服务器套接字
     */
    virtual void OnClose(TcpAcceptor *acceptor) = 0;
};
}
namespace arc {
class InputBuffer;
class OutputBuffer;
class SocketAddress;
class TcpSocketHandler;
/**
 * 此类实现客户端套接字
 * @see InputBuffer
 * @see OutputBuffer
 * @see SocketAddress
 * @see TcpSocketHandler
 **/
class TcpSocket {
public:
    /**
     * 将此套接字连接到服务器，并指定一个超时值
     * @param endpoint 套接字地址
     * @param timeout 要使用的超时值（以毫秒为单位）
     */
    virtual void Connect(const SocketAddress &endpoint, UInt32 timeout) = 0;
    /**
     * 将此套接字连接到服务器
     * @param endpoint 套接字地址
     */
    virtual void Connect(const SocketAddress &endpoint) = 0;
    /**
     * 关闭此套接字。套接字会将所有数据发送完后自己销毁。在调用此函数后，不要再使用此套接字
     */
    virtual void Close() = 0;
    /**
     * 立即关闭此套接字，未发送的数据会被丢弃
     */
    virtual void Shutdown() = 0;
    /**
     * 获取最近一次错误的描述
     * @return 最近一次错误的描述
     */
    virtual const char *GetLastError() const = 0;
    /**
     * 返回此套接字绑定的端点的地址
     * @return 此套接字的本地端点地址
     */
    virtual SocketAddress GetLocalAddress() const = 0;
    /**
     * 返回此套接字连接的端点的地址
     * @return 此套接字的远程端点地址
     */
    virtual SocketAddress GetRemoteAddress() const = 0;
    /**
     * 返回此套接字是否可写
     * @return 如果此套接字可写，返回true；否则返回false
     */
    virtual bool IsWritable() const = 0;
    /**
     * 返回此套接字是否可读
     * @return 如果此套接字可读，返回true；否则返回false
     */
    virtual bool IsReadable() const = 0;
    /**
     * 向此套接字写入数据，并返回是否成功
     * 如果只写入了部分数据，那么也返回成功，并将未写入的数据缓存，可写时自动发送
     * @param data 要写入的数据
     * @param size 要写入的数据长度
     * @return 如果操作成功，则返回true，否则，返回false
     */
    virtual bool Write(const char *data, UInt32 size) = 0;
    /**
     * 从套接字读取数据，并返回成功读取的字节数
     * @param buffer 读取缓冲区
     * @param capacity 缓冲区大小
     * @return 读取的字节数，如果返回0，则表示没有更多数据了
     */
    virtual UInt32 Read(char *buffer, UInt32 capacity) = 0;
    /**
     * 返回此套接字的输入缓冲区，从套接字读取的数据会自动填充到此缓冲区
     * @return 此套接字的输入缓冲区
     */
    virtual InputBuffer *In() = 0;
    /**
     * 返回此套接字的输出缓冲区，向此缓冲区写入的数据会自动写入到套接字
     * @return 此套接字的输出缓冲区
     */
    virtual OutputBuffer *Out() = 0;
    /**
     * 设置此套接字的处理程序
     * @param handler 套接字处理程序
     */
    virtual void SetHandler(TcpSocketHandler *handler) = 0;
};
}
namespace arc {
class TcpSocket;
/**
 * 此接口为套接字的处理程序
 * @see TcpSocket
 */
class TcpSocketHandler {
public:
    /**
     * 套接字与远端连接成功时的处理函数
     * @param socket 套接字
     */
    virtual void OnConnected(TcpSocket *socket) = 0;
    /**
     * 套接字接收到数据时的处理函数
     * @param socket 套接字
     */
    virtual void OnRead(TcpSocket *socket) = 0;
    /**
     * 套接字向对端写入数据后的处理函数
     * @param socket 套接字
     */
    virtual void OnWrite(TcpSocket *socket) = 0;
    /**
     * 当套接字检测到错误时的处理函数
     * @param socket 套接字
     */
    virtual void OnError(TcpSocket *socket) = 0;
    /**
     * 套接字与远端连接关闭时的处理函数
     * @param socket 套接字
     */
    virtual void OnClose(TcpSocket *socket) = 0;
};
}
namespace arc {
/**
 * 此类表示本地时间，并提供时间的一些运算函数
 */
class Time {
public:
    /**
     * 以当前时间创建实例
     */
    Time();
    /**
     * 从另一实例创建
     * @param other 另一实例
     */
    Time(const Time &other);
    /**
     * 析构函数
     */
    virtual ~Time();
public:
    /**
     * 拷贝另一实例
     * @param other 另一实例
     * @return 此实例的引用
     */
    Time &operator=(const Time &other);
    /**
     * 判断此实例表示的时间是否晚于另一实例
     * @param other 另一实例
     * @return 如果此实例表示的时间晚于参数表示的时间，则返回true；否则返回false
     */
    bool operator>(const Time &other) const;
    /**
     * 判断此实例表示的时间是否早于另一实例
     * @param other 另一实例
     * @return 如果此实例表示的时间早于参数表示的时间，则返回true；否则返回false
     */
    bool operator<(const Time &other) const;
    /**
     * 判断此实例表示的时间是否不早于另一实例
     * @param other 另一实例
     * @return 如果此实例表示的时间不早于参数表示的时间，则返回true；否则返回false
     */
    bool operator>=(const Time &other) const;
    /**
     * 判断此实例表示的时间是否不晚于另一实例
     * @param other 另一实例
     * @return 如果此实例表示的时间不晚于参数表示的时间，则返回true；否则返回false
     */
    bool operator<=(const Time &other) const ;
    /**
     * 判断此实例表示的时间是否与另一实例相同
     * @param other 另一实例
     * @return 如果此实例表示的时间与参数表示的时间相同，则返回true；否则返回false
     */
    bool operator==(const Time &other) const;
    /**
     * 将此实例表示的时间加上指定的毫秒数
     * @param milliseconds 毫秒数
     * @return 此实例的引用
     */
    Time &operator+=(UInt64 milliseconds);
    /**
     * 将此实例表示的时间减去指定的毫秒数
     * @param milliseconds 毫秒数
     * @return 此实例的引用
     */
    Time &operator-=(UInt64 milliseconds);
    /**
     * 返回Time的时间加上指定毫秒数的新Time
     * @param time 要操作的Time实例
     * @param milliseconds 毫秒数
     * @return Time的时间加上指定毫秒数的新Time
     */
    friend Time operator+(const Time &time, UInt64 milliseconds);
    /**
     * 返回Time的时间减去指定毫秒数的新Time
     * @param time 要操作的Time实例
     * @param milliseconds 毫秒数
     * @return Time的时间减去指定毫秒数的新Time
     */
    friend Time operator-(const Time &time, UInt64 milliseconds);
    /**
     * 返回两个Time的时间差，用毫秒数表示
     * @param time1 时间1
     * @param time2 时间2
     * @return 两个Time的时间差，用毫秒数表示
     */
    friend UInt64 operator-(const Time &time1, const Time &time2);
public:
    /**
     * 此时间的时间戳
     * @return 时间戳
     */
    UInt32 Timestamp() const;
    /**
     * 此时间的毫秒数
     * @return 此时间的毫秒数
     */
    UInt64 Milliseconds() const;
private:
    UInt64 milliseconds_;
};
}
namespace arc {
/**
 * 此类表示定时器
 * @see TimerTask
 */
class Timer {
public:
    /**
     * 取消此定时器，调用后定时器不会再触发
     */
    virtual void Cancel() = 0;
};
}
namespace arc {
class Timer;
/**
 * 此类表示定时器任务
 * @see Timer
 */
class TimerTask {
public:
    /**
     * 定时器超时的处理函数
     * @param timer 超时的定时器
     */
    virtual void OnTimer(Timer *timer) = 0;
    /**
     * 定时器完成时的处理函数，此后该定时器不会再触发
     * @param timer 完成的定时器
     */
    virtual void OnFinish(Timer *timer) = 0;
};
}
namespace arc {
template <typename T>
class CallbackTimerTask_0 : public TimerTask {
public:
    typedef void (T::*Callback)(Timer *);
public:
    CallbackTimerTask_0(T *object, Callback callback);
    virtual ~CallbackTimerTask_0();
public:
    virtual void OnTimer(Timer *timer);
    virtual void OnFinish(Timer *timer);
private:
    T *object_;
    Callback callback_;
};
template <typename T, typename A1>
class CallbackTimerTask_1 : public TimerTask {
public:
    typedef void (T::*Callback)(Timer *, A1);
public:
    CallbackTimerTask_1(T *object, Callback callback, A1 a1);
    virtual ~CallbackTimerTask_1();
public:
    virtual void OnTimer(Timer *timer);
    virtual void OnFinish(Timer *timer);
private:
    T *object_;
    Callback callback_;
    A1 a1_;
};
template <typename T, typename A1, typename A2>
class CallbackTimerTask_2 : public TimerTask {
public:
    typedef void (T::*Callback)(Timer *, A1, A2);
public:
    CallbackTimerTask_2(T *object, Callback callback, A1 a1, A2 a2);
    virtual ~CallbackTimerTask_2();
public:
    virtual void OnTimer(Timer *timer);
    virtual void OnFinish(Timer *timer);
private:
    T *object_;
    Callback callback_;
    A1 a1_;
    A2 a2_;
};
template <typename T, typename A1, typename A2, typename A3>
class CallbackTimerTask_3 : public TimerTask {
public:
    typedef void (T::*Callback)(Timer *, A1, A2, A3);
public:
    CallbackTimerTask_3(T *object, Callback callback, A1 a1, A2 a2, A3 a3);
    virtual ~CallbackTimerTask_3();
public:
    virtual void OnTimer(Timer *timer);
    virtual void OnFinish(Timer *timer);
private:
    T *object_;
    Callback callback_;
    A1 a1_;
    A2 a2_;
    A3 a3_;
};
template <typename T, typename A1, typename A2, typename A3, typename A4>
class CallbackTimerTask_4 : public TimerTask {
public:
    typedef void (T::*Callback)(Timer *, A1, A2, A3, A4);
public:
    CallbackTimerTask_4(T *object, Callback callback, A1 a1, A2 a2, A3 a3, A4 a4);
    virtual ~CallbackTimerTask_4();
public:
    virtual void OnTimer(Timer *timer);
    virtual void OnFinish(Timer *timer);
private:
    T *object_;
    Callback callback_;
    A1 a1_;
    A2 a2_;
    A3 a3_;
    A4 a4_;
};
template <typename T>
TimerTask *TimerCallback(T *object, void (T::*callback)(Timer *)) {
    return new CallbackTimerTask_0<T>(object, callback);
}
template <typename T, typename A1>
TimerTask *TimerCallback(T *object, void (T::*callback)(Timer *, A1), A1 a1) {
    return new CallbackTimerTask_1<T, A1>(object, callback, a1);
}
template <typename T, typename A1, typename A2>
TimerTask *TimerCallback(T *object, void (T::*callback)(Timer *, A1, A2), A1 a1, A2 a2) {
    return new CallbackTimerTask_2<T, A1, A2>(object, callback, a1, a2);
}
template <typename T, typename A1, typename A2, typename A3>
TimerTask *TimerCallback(T *object, void (T::*callback)(Timer *, A1, A2, A3), A1 a1, A2 a2, A3 a3) {
    return new CallbackTimerTask_3<T, A1, A2, A3>(object, callback, a1, a2, a3);
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
TimerTask *TimerCallback(T *object, void (T::*callback)(Timer *, A1, A2, A3, A4), A1 a1, A2 a2, A3 a3, A4 a4) {
    return new CallbackTimerTask_4<T, A1, A2, A3, A4>(object, callback, a1, a2, a3, a4);
}
}
namespace arc {
template <typename T>
inline CallbackTimerTask_0<T>::CallbackTimerTask_0(T *object, Callback callback) {
    object_ = object;
    callback_ = callback;
}
template <typename T>
inline CallbackTimerTask_0<T>::~CallbackTimerTask_0() {
}
template <typename T>
inline void CallbackTimerTask_0<T>::OnTimer(Timer *timer) {
    (object_->*callback_)(timer);
}
template <typename T>
inline void CallbackTimerTask_0<T>::OnFinish(Timer *timer) {
    delete this;
}
template <typename T, typename A1>
inline CallbackTimerTask_1<T,A1>::CallbackTimerTask_1(T *object, Callback callback, A1 a1) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
}
template <typename T, typename A1>
inline CallbackTimerTask_1<T,A1>::~CallbackTimerTask_1() {
}
template <typename T, typename A1>
inline void CallbackTimerTask_1<T,A1>::OnTimer(Timer *timer) {
    (object_->*callback_)(timer, a1_);
}
template <typename T, typename A1>
inline void CallbackTimerTask_1<T,A1>::OnFinish(Timer *timer) {
    delete this;
}
template <typename T, typename A1, typename A2>
inline CallbackTimerTask_2<T,A1,A2>::CallbackTimerTask_2(T *object, Callback callback, A1 a1, A2 a2) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
    a2_ = a2;
}
template <typename T, typename A1, typename A2>
inline CallbackTimerTask_2<T,A1,A2>::~CallbackTimerTask_2() {
}
template <typename T, typename A1, typename A2>
inline void CallbackTimerTask_2<T,A1,A2>::OnTimer(Timer *timer) {
    (object_->*callback_)(timer, a1_, a2_);
}
template <typename T, typename A1, typename A2>
inline void CallbackTimerTask_2<T,A1,A2>::OnFinish(Timer *timer) {
    delete this;
}
template <typename T, typename A1, typename A2, typename A3>
inline CallbackTimerTask_3<T,A1,A2,A3>::CallbackTimerTask_3(T *object, Callback callback, A1 a1, A2 a2, A3 a3) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
    a2_ = a2;
    a3_ = a3;
}
template <typename T, typename A1, typename A2, typename A3>
inline CallbackTimerTask_3<T,A1,A2,A3>::~CallbackTimerTask_3() {
}
template <typename T, typename A1, typename A2, typename A3>
inline void CallbackTimerTask_3<T,A1,A2,A3>::OnTimer(Timer *timer) {
    (object_->*callback_)(timer, a1_, a2_, a3_);
}
template <typename T, typename A1, typename A2, typename A3>
inline void CallbackTimerTask_3<T,A1,A2,A3>::OnFinish(Timer *timer) {
    delete this;
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline CallbackTimerTask_4<T,A1,A2,A3,A4>::CallbackTimerTask_4(T *object, Callback callback, A1 a1, A2 a2, A3 a3, A4 a4) {
    object_ = object;
    callback_ = callback;
    a1_ = a1;
    a2_ = a2;
    a3_ = a3;
    a4_ = a4;
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline CallbackTimerTask_4<T,A1,A2,A3,A4>::~CallbackTimerTask_4() {
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline void CallbackTimerTask_4<T,A1,A2,A3,A4>::OnTimer(Timer *timer) {
    (object_->*callback_)(timer, a1_, a2_, a3_, a4_);
}
template <typename T, typename A1, typename A2, typename A3, typename A4>
inline void CallbackTimerTask_4<T,A1,A2,A3,A4>::OnFinish(Timer *timer) {
    delete this;
}
}
namespace arc {
/**
 * 跟踪日志，用于记录服务器的一些操作或状态，其输出格式便于使用脚本
 * 解析
 * @see TrackerManager
 */
class Tracker {
public:
    /**
     * 打印一条跟踪日志
     * @param format 输出文本
     */
    virtual void Print(const char *format, ...) = 0;
    /**
     * 打印一条跟踪日志
     * @param format 输出文本
     * @param arguments 可变长参数
     */
    virtual void PrintV(const char *format, va_list arguments) = 0;
};
}
namespace arc {
class Tracker;
/**
 * 跟踪日志管理器
 */
class TrackerManager {
public:
    /**
     * 创建跟踪日志
     * @param name 跟踪日志的名称
     * @return 创建的跟踪日志，或已有的日志对象（一定不为NULL）
     */
    virtual Tracker *CreateTracker(const std::string &name) = 0;
};
}
namespace arc {
class SocketAddress;
class UdpSocketHandler;
/**
 * 此类表示用来发送和接收数据报包的套接字
 * @see UdpSocketHandler
 */
class UdpSocket {
public:
    /**
     * 设置此套接字的处理程序
     * @param handler 此套接字的处理程序
     */
    virtual void SetHandler(UdpSocketHandler *handler) = 0;
    /**
     * 关闭此套接字
     */
    virtual void Close() = 0;
    /**
     * 将此套接字绑定到特定的地址和端口
     * @param endpoint 绑定的端点地址
     * @return 是否绑定成功
     */
    virtual bool Bind(const SocketAddress &endpoint) = 0;
    /**
     * 通过此套接字向指定端点发送数据
     * @param data 要发送的数据
     * @param size 要发送的数据长度
     * @param endpoint 要发送的端点地址
     */
    virtual void Send(const char *data, UInt32 size, const SocketAddress &endpoint) = 0;
    /**
     * 返回此套接字绑定的端点的地址
     * @return 此套接字的本地端点地址
     */
    virtual SocketAddress GetLocalAddress() const = 0;
};
}
namespace arc {
class SocketAddress;
class UdpSocket;
/**
 * 此接口为数据报套接字的处理程序
 * @see UdpSocket
 * @see SocketAddress
 */
class UdpSocketHandler {
public:
    /**
     * 数据报套接字接收到数据时的处理函数
     * @param socket 接收数据的套接字
     * @param data 接收到的数据
     * @param size 接收到的数据长度
     * @param endpoint 发送数据的端点地址
     */
    virtual void OnData(UdpSocket *socket, char *data, UInt32 size, const SocketAddress &endpoint) = 0;
};
}
namespace arc {
class OutputBuffer;
class Packet;
/**
 * 此类用于向输出缓冲区写入指定格式的数据
 * @see OutputBuffer
 * @see Packet
 */
class Writer {
public:
    /**
     * 创建Writer，并将其绑定到指定的输出缓冲区
     * param buffer 要绑定的输出缓冲区
     */
    Writer(OutputBuffer *buffer);
    /**
     * 析构函数
     * 析构时会自动调用缓冲区的Flush函数
     */
    virtual ~Writer();
public:
    /**
     * 返回Writer的状态，如果写入操作全部成功，则返回true，否则，返回false
     * @return 如果写入全部成功，则返回true，否则，返回false
     */
    operator bool() const;
public:
    /**
     * 将此writer与当前的输出缓冲区分离，方便输出缓冲区失效时的处理
     * @param flush 是否应用对输出缓冲区的变更，默认为false
     */
    void Detach(bool flush = true);
    /**
     * 将此writer绑定到新的输出缓冲区
     * @param flush 是否对当前的缓冲区应用变更，默认为false
     */
    void Attach(OutputBuffer *buffer, bool flush = false);
    /**
     * 向缓冲区写入一个Packet
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(const Packet &value);
    /**
     * 向缓冲区写入一个布尔值
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(bool value);
    /**
     * 向缓冲区写入一个64位无符号整数
     * @param value 要写入的值
     * @param bigEndian 字节序是否为大端
     * @return 此Writer的引用
     */
    Writer &operator()(UInt64 value, bool bigEndian = false);
    /**
     * 向缓冲区写入一个64位有符号整数
     * @param value 要写入的值
     * @param bigEndian 字节序是否为大端
     * @return 此Writer的引用
     */
    Writer &operator()(Int64 value, bool bigEndian = false);
    /**
     * 向缓冲区写入一个32位无符号整数
     * @param value 要写入的值
     * @param bigEndian 字节序是否为大端
     * @return 此Writer的引用
     */
    Writer &operator()(UInt32 value, bool bigEndian = false);
    /**
     * 向缓冲区写入一个32位有符号整数
     * @param value 要写入的值
     * @param bigEndian 字节序是否为大端
     * @return 此Writer的引用
     */
    Writer &operator()(Int32 value, bool bigEndian = false);
    /**
     * 向缓冲区写入一个16位无符号整数
     * @param value 要写入的值
     * @param bigEndian 字节序是否为大端
     * @return 此Writer的引用
     */
    Writer &operator()(UInt16 value, bool bigEndian = false);
    /**
     * 向缓冲区写入一个16位有符号整数
     * @param value 要写入的值
     * @param bigEndian 字节序是否为大端
     * @return 此Writer的引用
     */
    Writer &operator()(Int16 value, bool bigEndian = false);
    /**
     * 向缓冲区写入一个8位无符号整数
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(UInt8 value);
    /**
     * 向缓冲区写入一个8位有符号整数
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(Int8 value);
    /**
     * 向缓冲区写入一个字符串，字符串长度最多为2^16
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(const std::string &value);
    /**
     * 向缓冲区写入一个字符串，字符串长度最多为2^32
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(const std::string &value, bool);
    /**
     * 向缓冲区写入指定长度的数据
     * @param size 指定长度
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(UInt32 size, const std::string &value);
    /**
     * 向缓冲区写入指定长度的数据
     * @param size 指定长度
     * @param value 要写入的值
     * @return 此Writer的引用
     */
    Writer &operator()(UInt32 size, const char *value);
    /**
     * 向缓冲区写入一个列表
     * @param container 要写入的列表
     * @return 此Writer的引用
     */
    template <typename ValueT>
    Writer &operator()(const std::list<ValueT> &container);
    /**
     * 向缓冲区写入一个Map
     * @param container 要写入的Map
     * @return 此Writer的引用
     */
    template <typename KeyT, typename ValueT>
    Writer &operator()(const std::map<KeyT, ValueT> &container);
    /**
     * 向缓冲区写入一个Set
     * @param container 要写入的Set
     * @return 此Writer的引用
     */
    template <typename ValueT>
    Writer &operator()(const std::set<ValueT> &container);
private:
    void Flush();
private:
    bool good_;
    OutputBuffer *buffer_;
};
template <typename ValueT>
Writer &Writer::operator()(const std::list<ValueT> &container) {
    UInt32 size = container.size();
    if (this->operator()(size)) {
        for (typename std::list<ValueT>::const_iterator i = container.begin(); i != container.end(); ++i) {
            if (!this->operator()(*i)) {
                break;
            }
        }
    }
    return *this;
}
template <typename KeyT, typename ValueT>
Writer &Writer::operator()(const std::map<KeyT, ValueT> &container) {
    UInt32 size = container.size();
    if (this->operator()(size)) {
        for (typename std::map<KeyT, ValueT>::const_iterator i = container.begin(); i != container.end(); ++i) {
            if (!this->operator()(i->first)) {
                break;
            }
            if (!this->operator()(i->second)) {
                break;
            }
        }
    }
    return *this;
}
template <typename ValueT>
Writer &Writer::operator()(const std::set<ValueT> &container) {
    UInt32 size = container.size();
    if (this->operator()(size)) {
        for (typename std::set<ValueT>::const_iterator i = container.begin(); i != container.end(); ++i) {
            if (!this->operator()(*i)) {
                break;
            }
        }
    }
    return *this;
}
}
#endif /* ARC_API_HPP */
