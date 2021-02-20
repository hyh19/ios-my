#ifndef RTMP_API_HPP
#define RTMP_API_HPP
namespace rtmp {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file rtmp/rtmp.h
 * @author 喻扬
 */
#endif /* API */
#ifndef RTMP_API_HPP
#include "export.hpp"
#endif /* RTMP_API_HPP */
namespace rtmp {
/**
 * 获取RTMP协议对象
 */
void *GetProtocol();
}
#endif /* RTMP_API_HPP */
