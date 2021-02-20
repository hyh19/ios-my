#ifndef FLV_API_HPP
#define FLV_API_HPP
namespace flv {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file flv/flv.h
 * @author 喻扬
 */
#include <string>
#endif /* API */
#ifndef FLV_API_HPP
#include "aacpackettype.hpp"
#include "audiodata.hpp"
#include "audiotagheader.hpp"
#include "avcpackettype.hpp"
#include "header.hpp"
#include "soundformat.hpp"
#include "soundrate.hpp"
#include "soundsize.hpp"
#include "soundtype.hpp"
#include "tag.hpp"
#include "tagheader.hpp"
#include "tagtype.hpp"
#include "videocodecid.hpp"
#include "videodata.hpp"
#include "videoframetype.hpp"
#include "videotagheader.hpp"
#endif /* FLV_API_HPP */
/**
 * FLV文件解析库
 */
namespace flv {
/**
 * 枚举AACPacketType
 */
namespace AacPacketType {
    /**
     * AAC sequence header
     */
    const UInt8 AAC_SEQUENCE_HEADER = 0x00;
    /**
     * AAC raw
     */
    const UInt8 AAC_RAW = 0x01;
}
}
namespace flv {
/**
 * 音频帧的头域
 */
class AudioTagHeader {
public:
    /**
     * 构造函数
     */
    AudioTagHeader();
    /**
     * 析构函数
     */
    virtual ~AudioTagHeader();
public:
    /**
     * 获取此头域的编码长度
     * @return 此头域的编码长度
     */
    UInt32 GetLength() const;
    /**
     * 获取声音格式
     * @see SoundFormat
     * @return 声音格式
     */
    UInt8 GetSoundFormat() const;
    /**
     * 设置声音格式
     * @see SoundFormat
     * @param soundFormat 声音格式
     */
    void SetSoundFormat(UInt8 soundFormat);
    /**
     * 获取声音采样率
     * @see SoundRate
     * @return 声音采样率
     */
    UInt8 GetSoundRate() const;
    /**
     * 设置声音采样率
     * @see SoundRate
     * @param soundRate 声音采样率
     */
    void SetSoundRate(UInt8 soundRate);
    /**
     * 获取声音采样大小
     * @see SoundSize
     * @return 声音采样大小
     */
    UInt8 GetSoundSize() const;
    /**
     * 设置声音采样大小
     * @see SoundSize
     * @param soundSize 声音采样大小
     */
    void SetSoundSize(UInt8 soundSize);
    /**
     * 获取声音声道类型
     * @see SoundType
     * @return 声音声道类型
     */
    UInt8 GetSoundType() const;
    /**
     * 设置声音声道类型
     * @see SoundType
     * @param soundType 声音声道类型
     */
    void SetSoundType(UInt8 soundType);
    /**
     * 获取AAC数据包类型
     * @see AacPacketType
     * @return AAC数据包类型
     */
    UInt8 GetAacPacketType() const;
    /**
     * 设置AAC数据包类型
     * @see AacPacketType
     * @param aacPacketType AAC数据包类型
     */
    void SetAacPacketType(UInt8 aacPacketType);
    /**
     * 向数据中写入音频头
     * @param data 用于保存输出的数据
     * @param size 输出数据的长度，通过GetLength可以获取此音频头需要的字节数
     * @return 如果成功，返回写入的字节数，否则返回0
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析音频头
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 如果成功，返回此音频头占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入音频头
     * @param encoding 用于保存输出的数据，会在其后追加数据
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解析音频头
     * @param encoding 输入的数据
     * @return 如果成功，返回此音频头占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    UInt8 soundFormat_;
    UInt8 soundRate_;
    UInt8 soundSize_;
    UInt8 soundType_;
    UInt8 aacPacketType_;
};
}
namespace flv {
/**
 * 表示一个音频帧，包含AudioTagHeader
 */
class AudioData {
public:
    /**
     * 构造函数
     */
    AudioData();
    /**
     * 析构函数
     */
    virtual ~AudioData();
public:
    /**
     * 获取此音频帧占用的字节数，可用于Encode时确定预先分配的缓冲区大小
     * @return 此音频数据占用的字节数
     */
    UInt32 GetLength() const;
    /**
     * 获取AudioTagHeader
     * @return 此音频帧对应的TagHeader
     */
    AudioTagHeader &GetHeader();
    /**
     * 获取AudioTagHeader
     * @return 此音频帧对应的TagHeader
     */
    const AudioTagHeader &GetHeader() const;
    /**
     * 获取音频数据
     * @return 此音频帧包含的数据
     */
    const std::string &GetBody() const;
    /**
     * 设置音频数据
     * @param body 音频数据
     */
    void SetBody(const std::string &body);
    /**
     * 将此音频帧编码到指定的缓冲区
     * @param data 用于保存输出的数据
     * @param size 缓冲区的长度，通过GetLength可以获取此音频帧需要的字节数
     * @return 如果成功，返回写入的字节数，否则返回0
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析音频帧
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 返回此音频帧是否解析成功
     */
    bool Decode(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入音频帧
     * @param encoding 用于保存输出的数据，会在其后追加数据
     * @return 编码后的大小
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解析音频帧
     * @param encoding 输入的数据
     * @return 返回此音频帧是否解析成功
     */
    bool Decode(const std::string &encoding);
private:
    AudioTagHeader header_;
    std::string body_;
};
}
namespace flv {
/**
 * 枚举AVCPacketType
 */
namespace AvcPacketType {
    /**
     * AVC sequence header
     */
    const UInt8 AVC_SEQUENCE_HEADER = 0x00;
    /**
     * AVC NALU
     */
    const UInt8 AVC_NALU = 0x01;
    /**
     * AVC end of sequence (lower level NALU sequence ender is not required or supported)
     */
    const UInt8 AVC_END_OF_SEQUENCE = 0x02;
}
}
namespace flv {
/**
 * 表示FLV的文件头
 */
class Header {
public:
    /**
     * 构造函数，版本号默认为1，AudioPresent和VideoPresent默认为true
     */
    Header();
    /**
     * 析构函数
     */
    virtual ~Header();
public:
    /**
     * 获取Header的长度（包含PreviousTagSize0）
     * @return Header的长度
     */
    UInt32 GetLength() const;
    /**
     * 获取FLV版本号
     * @return FLV版本号
     */
    UInt8 GetVersion() const;
    /**
     * 设置FLV版本号，一般不要改变
     * @param version 要设置的FLV版本号
     */
    void SetVersion(UInt8 version);
    /**
     * 返回此FLV中是否存在音频帧
     * @return 此FLV中是否存在音频帧
     */
    bool IsAudioPresent() const;
    /**
     * 设置此FLV中是否存在音频帧
     * @param audioPresent 标识此FLV中是否存在音频帧
     */
    void SetAudioPresent(bool audioPresent);
    /**
     * 返回此FLV中是否存在视频帧
     * @return 此FLV中是否存在视频帧
     */
    bool IsVideoPresent() const;
    /**
     * 设置此FLV中是否存在视频帧
     * @param videoPresent 标识此FLV中是否存在视频帧
     */
    void SetVideoPresent(bool videoPresent);
    /**
     * 向数据中写入FLV头
     * @param data 用于保存输出的数据
     * @param size 输出数据的长度，通过GetLength可以获取此FLV头需要的字节数
     * @return 如果成功，返回写入的字节数，否则返回0
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析FLV头
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 如果成功，返回此FLV头占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入FLV头
     * @param encoding 用于保存输出的数据，会在其后追加数据
     * @return 编码后的大小
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解析FLV头
     * @param encoding 输入的数据
     * @return 如果成功，返回此FLV头占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    UInt8 version_;
    bool audioPresent_;
    bool videoPresent_;
};
}
namespace flv {
/**
 * 枚举声音格式
 */
namespace SoundFormat {
    /**
     * Linear PCM, platform endian
     */
    const UInt8 LINEAR_PCM_PLATFORM_ENDIAN = 0x00;
    /**
     * ADPCM
     */
    const UInt8 ADPCM = 0x01;
    /**
     * MP3
     */
    const UInt8 MP3 = 0x02;
    /**
     * Linear PCM, little endian
     */
    const UInt8 LINEAR_PCM_LITTLE_ENDIAN = 0x03;
    /**
     * Nellymoser 16kHz mono
     */
    const UInt8 NELLYMOSER_16KHZ_MONO = 0x04;
    /**
     * Nellymoser 8kHz mono
     */
    const UInt8 NELLYMOSER_8KHZ_MONO = 0x05;
    /**
     * Nellymoser
     */
    const UInt8 NELLYMOSER = 0x06;
    /**
     * G.711 A-law logarithmic PCM
     */
    const UInt8 G711_A_LAW_LOGARITHMIC_PCM = 0x07;
    /**
     * G.711 mu-law logarithmic PCM
     */
    const UInt8 G711_MU_LAW_LOGARITHMIC_PCM = 0x08;
    /**
     * AAC
     */
    const UInt8 AAC = 0x0A;
    /**
     * Speex
     */
    const UInt8 SPEEX = 0x0B;
    /**
     * MP3 8kHz
     */
    const UInt8 MP3_8KHZ = 0x0E;
    /**
     * Device-specific sound
     */
    const UInt8 DEVICE_SPECIFIC_SOUND = 0x0F;
}
}
namespace flv {
/**
 * 枚举声音采样率
 */
namespace SoundRate {
    /**
     * 5.5 kHz
     */
    const UInt8 HZ_5500 = 0x00;
    /**
     * 11 kHz
     */
    const UInt8 HZ_11000 = 0x01;
    /**
     * 22 kHz
     */
    const UInt8 HZ_22000 = 0x02;
    /**
     * 44 kHz
     */
    const UInt8 HZ_44000 = 0x03;
}
}
namespace flv {
/**
 * 枚举声音采样大小，此参数只影响非压缩格式。压缩格式始终解码为16 bits
 */
namespace SoundSize {
    /**
     * 8-bit samples
     */
    const UInt8 SAMPLES_8_BIT = 0x00;
    /**
     * 16-bit samples
     */
    const UInt8 SAMPLES_16_BIT =0x01;
}
}
namespace flv {
/**
 * 枚举声音声道类型
 */
namespace SoundType {
    /**
     * Mono sound
     */
    const UInt8 MONO_SOUND = 0x00;
    /**
     * Stereo sound
     */
    const UInt8 STEREO_SOUND = 0x01;
}
}
namespace flv {
/**
 * FLV的帧头
 */
class TagHeader {
public:
    /**
     * 构造函数
     */
    TagHeader();
    /**
     * 构造函数
     * @param tagType 帧类型
     * @param timestamp 时间戳
     * @param dataSize 数据大小
     */
    TagHeader(UInt8 tagType, UInt32 timestamp, UInt32 dataSize);
    /**
     * 析构函数
     */
    virtual ~TagHeader();
public:
    /**
     * 获取此头域的编码长度
     * @return 此头域的编码长度
     */
    UInt32 GetLength() const;
    /**
     * Indicates if packets are filtered.
     * 0 = No pre-processing required
     * 1 = Pre-processing (such as decryption) of the packet is required before it can be rendered.
     * Shall be 0 in unencrypted files, and 1 for encrypted tags.
     * @return 此FLV帧是否需要预处理
     */
    bool IsFiltered() const;
    /**
     * 设置此FLV帧是否需要预处理
     * @param filtered 此FLV帧是否需要预处理
     */
    void SetFiltered(bool filtered);
    /**
     * 获取帧类型
     * @return 帧类型
     */
    UInt8 GetTagType() const;
    /**
     * 设置帧类型
     * @param tagType 帧类型
     */
    void SetTagType(UInt8 tagType);
    /**
     * 获取数据大小
     * @return 数据大小
     */
    UInt32 GetDataSize() const;
    /**
     * 设置数据大小
     * @param dataSize 数据大小
     */
    void SetDataSize(UInt32 dataSize);
    /**
     * 获取时间戳
     * @return 时间戳
     */
    UInt32 GetTimestamp() const;
    /**
     * 设置时间戳
     * @param timestamp 时间戳
     */
    void SetTimestamp(UInt32 timestamp);
    /**
     * 向数据中写入此头域
     * @param data 用于保存输出的数据
     * @param size 输出数据的长度，通过GetLength可以获取此头域需要的字节数
     * @return 如果成功，返回写入的字节数，否则返回0
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析头域
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 如果成功，返回此头域占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入头域
     * @param encoding 用于保存输出的数据，会在其后追加数据
     * @return 编码后的大小
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解析头域
     * @param encoding 输入的数据
     * @return 如果成功，返回此头域占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
    /**
     * 向数据中写入前一帧大小，数据需要4字节
     * @param data 用于保存输出的数据
     * @param size 数据的长度
     * @return 如果成功，返回写入的字节数，否则返回0
     */
    UInt32 EncodeTagSize(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析前一帧大小，并验证
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 如果成功，返回占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 DecodeTagSize(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入前一帧大小
     * @param encoding 用于保存输出的数据，会在其后追加数据
     * @return 编码后的大小
     */
    UInt32 EncodeTagSize(std::string &encoding) const;
    /**
     * 从数据中解析前一帧大小，并验证
     * @param encoding 输入的数据
     * @return 如果成功，返回占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 DecodeTagSize(const std::string &encoding);
private:
    bool filtered_;
    UInt8 tagType_;
    UInt32 timestamp_;
    UInt32 dataSize_;
};
}
namespace flv {
/**
 * FLV中的一帧数据
 */
class Tag {
public:
    /**
     * 构造函数
     */
    Tag();
    /**
     * 构造函数
     * @param tagType 指定帧类型
     * @param timestamp 时间戳
     * @param data 帧数据
     */
    Tag(UInt8 tagType, UInt32 timestamp, const std::string &data);
    /**
     * 析构函数
     */
    virtual ~Tag();
public:
    /**
     * 获取此帧的编码长度
     * @return 此帧的编码长度
     */
    UInt32 GetLength() const;
    /**
     * 获取帧的头域
     * @return 帧的头域
     */
    TagHeader &GetTagHeader();
    /**
     * 获取帧的头域
     * @return 帧的头域
     */
    const TagHeader &GetTagHeader() const;
    /**
     * 获取帧的数据
     * @return 帧的数据
     */
    const std::string &GetData() const;
    /**
     * 设置帧的数据
     * @param data 帧的数据
     */
    void SetData(const std::string &data);
    /**
     * 向数据中写入FLV帧
     * @param data 用于保存输出的数据
     * @param size 输出数据的长度，通过GetLength可以获取此FLV帧需要的字节数
     * @return 如果成功，返回写入的字节数，否则返回size + 1
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析帧
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 如果成功，返回此FLV帧占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入帧
     * @param encoding 用于保存输出的数据，会在其后追加数据
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解析帧
     * @param encoding 输入的数据
     * @return 如果成功，返回此FLV帧占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    mutable TagHeader header_;
    std::string data_;
};
}
namespace flv {
/**
 * 枚举FLV的帧类型
 */
namespace TagType {
    /**
     * 音频
     */
    const UInt8 AUDIO = 0x08;
    /**
     * 视频
     */
    const UInt8 VIDEO = 0x09;
    /**
     * 脚本数据
     */
    const UInt8 SCRIPT_DATA = 0x12;
}
}
namespace flv {
/**
 * 枚举视频编码标识
 */
namespace VideoCodecId {
    /**
     * Seorenson H.263
     */
    const UInt8 SORENSON_H263 = 0x02;
    /**
     * Screen video
     */
    const UInt8 SCREEN_VIDEO = 0x03;
    /**
     * On2 VP6
     */
    const UInt8 ON2_VP6 = 0x04;
    /**
     * On2 VP6 with alpha channel
     */
    const UInt8 ON2_VP6_WITH_ALPHA_CHANNEL = 0x05;
    /**
     * Screen video version 2
     */
    const UInt8 SCREEN_VIDEO_VERSION_2 = 0x06;
    /**
     * AVC
     */
    const UInt8 AVC = 0x07;
}
}
namespace flv {
/**
 * 视频帧的头域
 */
class VideoTagHeader {
public:
    /**
     * 构造函数
     */
    VideoTagHeader();
    /**
     * 析构函数
     */
    virtual ~VideoTagHeader();
public:
    /**
     * 获取此头域的编码长度
     * @return 此头域的编码长度
     */
    UInt32 GetLength() const;
    /**
     * 获取帧类型
     * @see VideoFrameType
     * @return 帧类型
     */
    UInt8 GetFrameType() const;
    /**
     * 设置帧类型
     * @see VideoFrameType
     * @param frameType 帧类型
     */
    void SetFrameType(UInt8 frameType);
    /**
     * 获取编码标识
     * @see VideoCodecId
     * @return 编码标识
     */
    UInt8 GetCodecId() const;
    /**
     * 设置编码标识
     * @see VideoCodecId
     * @param codecId 编码标识
     */
    void SetCodecId(UInt8 codecId);
    /**
     * 获取AVC数据包类型
     * @see AvcPacketType
     * @return AVC数据包类型
     */
    UInt8 GetAvcPacketType() const;
    /**
     * 设置AVC数据包类型
     * @see AvcPacketType
     * @param avcPacketType AVC数据包类型
     */
    void SetAvcPacketType(UInt8 avcPacketType);
    /**
     * 获取编码时间
     * @return 编码时间
     */
    UInt32 GetCompositionTime() const;
    /**
     * 设置编码时间
     * @param compositionTime 编码时间
     */
    void SetCompositionTime(UInt32 compositionTime);
    /**
     * 向数据中写入视频头
     * @param data 用于保存输出的数据
     * @param size 输出数据的长度，通过GetLength可以获取此视频头需要的字节数
     * @return 如果成功，返回写入的字节数，否则返回0
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析视频头
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 如果成功，返回此视频头占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入视频头
     * @param encoding 用于保存输出的数据，会在其后追加数据
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解析视频头
     * @param encoding 输入的数据
     * @return 如果成功，返回此视频头占用的字节数，如果数据不够，则返回0，如果解析失败，则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    UInt8 frameType_;
    UInt8 codecId_;
    UInt8 avcPacketType_;
    UInt32 compositionTime_;
};
}
namespace flv {
/**
 * 表示一个视频帧，包含VideoTagHeader
 */
class VideoData {
public:
    /**
     * 构造函数
     */
    VideoData();
    /**
     * 析构函数
     */
    virtual ~VideoData();
public:
    /**
     * 获取此视频帧占用的字节数，可用于Encode时确定预先分配的缓冲区大小
     * @return 此视频数据占用的字节数
     */
    UInt32 GetLength() const;
    /**
     * 获取VideoTagHeader
     * @return 此视频帧对应的TagHeader
     */
    VideoTagHeader &GetHeader();
    /**
     * 获取VideoTagHeader
     * @return 此视频帧对应的TagHeader
     */
    const VideoTagHeader &GetHeader() const;
    /**
     * 获取视频数据
     * @return 此视频帧包含的数据
     */
    const std::string &GetBody() const;
    /**
     * 设置视频数据
     * @param body 此视频帧包含的数据
     */
    void SetBody(const std::string &body);
    /**
     * 将此视频帧编码到指定的缓冲区
     * @param data 用于保存输出的数据
     * @param size 缓冲区的长度，通过GetLength可以获取此视频帧需要的字节数
     * @return 如果成功，返回写入的字节数，否则返回0
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 从数据中解析视频帧
     * @param data 输入的数据
     * @param size 数据的长度
     * @return 返回此视频帧是否解析成功
     */
    bool Decode(const UInt8 *data, UInt32 size);
    /**
     * 向数据中写入视频帧
     * @param encoding 用于保存输出的数据，会在其后追加数据
     * @return 编码后的大小
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解析视频帧
     * @param encoding 输入的数据
     * @return 返回此视频帧是否解析成功
     */
    bool Decode(const std::string &encoding);
private:
    VideoTagHeader header_;
    std::string body_;
};
}
namespace flv {
/**
 * 枚举视频帧类型
 */
namespace VideoFrameType {
    /**
     * key frame (for AVC, a seekable frame)
     */
    const UInt8 AVC_KEY_FRAME = 0x01;
    /**
     * inter frame (for AVC, a non-seekable frame)
     */
    const UInt8 AVC_INTER_FRAME = 0x02;
    /**
     * disposable inter frame (H.263 only)
     */
    const UInt8 H263_DISPOSABLE_INTER_FRAME = 0x03;
    /**
     * generated key frame (reserved for server use only)
     */
    const UInt8 GENERATED_KEY_FRAME = 0x04;
    /**
     * video info/command frame
     */
    const UInt8 VIDEO_INFO = 0x05;
}
}
#endif /* FLV_API_HPP */
