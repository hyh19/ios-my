#ifndef KAX_API_HPP
#define KAX_API_HPP
namespace kax {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file kax/kax.h
 * @author 古原辉
 */
#endif /* API */
#ifndef KAX_API_HPP
#include "export.hpp"
#endif /* KAX_API_HPP */
namespace kax {
void Initialize(UInt32 maxPlaylistPuller, UInt32 maxSegmentPuller);
void Deinitialize();
}
#endif /* KAX_API_HPP */
