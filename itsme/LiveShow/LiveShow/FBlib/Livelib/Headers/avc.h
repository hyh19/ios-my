#ifndef AVC_API_HPP
#define AVC_API_HPP
namespace avc {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file avc/avc.h
 * @author 喻扬
 */
#include <deque>
#include <list>
#include <string>
#include <vector>
#endif /* API */
#ifndef AVC_API_HPP
#include "aspectratioindicator.hpp"
#include "bytestream.hpp"
#include "decoderconfigurationrecord.hpp"
#include "hrdparameters.hpp"
#include "levelindicator.hpp"
#include "nalu.hpp"
#include "naluheader.hpp"
#include "nalutype.hpp"
#include "pictureparameterset.hpp"
#include "profileindicator.hpp"
#include "sample.hpp"
#include "sequenceparameterset.hpp"
#include "vuiparameters.hpp"
#endif /* AVC_API_HPP */
namespace avc {
/**
 * Meaning of sample aspect ratio indicator
 */
namespace AspectRatioIndicator {
    /**
     * Unspecified
     */
    const UInt8 UNSPECIFIED = 0x00;
    /**
     * 1:1 ("square").
     */
    const UInt8 SQUARE = 0x01;
    /**
     * 1:1 ("square").
     */
    const UInt8 RATIO_1_1 = 0x01;
    /**
     * 12:11
     */
    const UInt8 RATIO_12_11 = 0x02;
    /**
     * 10:11
     */
    const UInt8 RATIO_10_11 = 0x03;
    /**
     * 16:11
     */
    const UInt8 RATIO_16_11 = 0x04;
    /**
     * 40:33
     */
    const UInt8 RATIO_40_33 = 0x05;
    /**
     * 24:11
     */
    const UInt8 RATIO_24_11 = 0x06;
    /**
     * 20:11
     */
    const UInt8 RATIO_20_11 = 0x07;
    /**
     * 32:11
     */
    const UInt8 RATIO_32_11 = 0x08;
    /**
     * 80:33
     */
    const UInt8 RATIO_80_33 = 0x09;
    /**
     * 18:11
     */
    const UInt8 RATIO_18_11 = 0x0A;
    /**
     * 15:11
     */
    const UInt8 RATIO_15_11 = 0x0B;
    /**
     * 64:33
     */
    const UInt8 RATIO_64_33 = 0x0C;
    /**
     * 160:99
     */
    const UInt8 RATIO_160_99 = 0x0D;
    /**
     * Extended_SAR
     */
    const UInt8 EXTENDED_SAR = 0xFF;
}
}
/**
 * AVC文件格式库
 */
namespace avc {
/**
 * 此类用于H264字节流的编码和解码
 */
class ByteStream {
public:
    /**
     * 构造函数
     */
    ByteStream();
    /**
     * 析构函数
     */
    virtual ~ByteStream();
public:
    /**
     * 获取此字节流编码后的长度
     * @return 此字节流编码后的长度
     */
    UInt32 GetEncodingBytes() const;
    /**
     * 获取此字节流中包含的nalu数目
     * @return 此字节流中包含的nalu数目
     */
    UInt32 GetNaluCount() const;
    /**
     * 向此字节流中追加nalu，默认此nalu不为Access Unit的起始nalu
     * @param nalu 要追加的nalu
     */
    void PutNalu(const std::string &nalu);
    /**
     * 向此字节流中追加nalu
     * @param nalu 要追加的nalu
     * @param startOfAccessUnit 标识此nalu是否为Access Unit的起始nalu
     */
    void PutNalu(const std::string &nalu, bool startOfAccessUnit);
    /**
     * 从此字节流中获取第一个nalu，并将其删除
     * @param nalu 用于保存获取的nalu
     * @return 如果此字节流没有nalu，则返回false，否则返回true
     */
    bool PopNalu(std::string &nalu);
    /**
     * 从此字节流中获取第一个nalu，并将其删除
     * @param nalu 用于保存获取的nalu
     * @param startOfAccessUnit 用于获取此nalu是否为Access Unit的起始nalu
     * @return 如果此字节流没有nalu，则返回false，否则返回true
     */
    bool PopNalu(std::string &nalu, bool &startOfAccessUnit);
    /**
     * 从此字节流中获取第一个nalu，但是不会删除
     * @param nalu 用于保存获取的nalu
     * @return 如果此字节流没有nalu，则返回false，否则返回true
     */
    bool PeekNalu(std::string &nalu);
    /**
     * 从此字节流中获取第一个nalu，但是不会删除
     * @param nalu 用于保存获取的nalu
     * @param startOfAccessUnit 用于获取此nalu是否为Access Unit的起始nalu
     * @return 如果此字节流没有nalu，则返回false，否则返回true
     */
    bool PeekNalu(std::string &nalu, bool &startOfAccessUnit);
    /**
     * 清除此字节流中的所有nalu
     */
    void ClearNalus();
    /**
     * 编码此字节流
     * @param data 保存编码后的数据的缓冲区
     * @param size 缓冲区的大小
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 编码此字节流
     * @param encoding 保存编码后的字节流
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解码字节流，解析会在nalu结束时终止，如果未解析出任何nalu，则返回0
     * @param data 字节流数据
     * @param size 数据的大小
     * @param complete 指示此数据是否以一个完整的nalu结尾
     * @return 如果解码成功，则返回解码使用的数据长度，否则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size, bool complete = false);
    /**
     * 从数据中解码字节流，解析会在nalu结束时终止，如果未解析出任何nalu，则返回0
     * @param data 字节流数据
     * @param size 数据的大小
     * @param complete 指示此数据是否以一个完整的nalu结尾
     * @return 如果解码成功，则返回解码使用的数据长度，出错则返回size + 1
     */
    UInt32 Decode(const std::string &encoding, bool complete = false);
private:
    typedef std::pair<bool, std::string> NaluRecord;
    typedef std::list<NaluRecord> Nalus;
private:
    UInt32 bytes_;
    Nalus nalus_;
};
}
namespace avc {
/**
 * AVC解码信息记录
 */
class DecoderConfigurationRecord {
public:
    /**
     * 构造函数
     */
    DecoderConfigurationRecord();
    /**
     * 析构函数
     */
    virtual ~DecoderConfigurationRecord();
public:
    /**
     * 获取此解码信息记录编码后占用的字节数
     * @return 此解码信息记录编码后占用的字节数
     */
    UInt32 GetEncodingBytes() const;
    /**
     * 获取配置版本
     * @return 配置版本
     */
    UInt8 GetConfigurationVersion() const;
    /**
     * 设置配置版本
     * @param configurationVersion 配置版本
     */
    void SetConfigurationVersion(UInt8 configurationVersion);
    /**
     * 获取profile code
     * @return profile code as defined in ISO/IEC 14496-10
     */
    UInt8 GetProfileIndicator() const;
    /**
     * 设置profile code
     * @param profileIndicator 要设置的profile code
     */
    void SetProfileIndicator(UInt8 profileIndicator);
    /**
     * 获取profile compatibility
     * @return profile compatibility
     */
    UInt8 GetProfileCompatibility() const;
    /**
     * 设置profile compatibility
     * @param profileCompatibility 要设置的profile compatibility
     */
    void SetProfileCompatibility(UInt8 profileCompatibility);
    /**
     * 获取level code
     * @return level code as defined in ISO/IEC 14496-10
     */
    UInt8 GetLevelIndicator() const;
    /**
     * 设置level code
     * @param levelIndicator 要设置的level code
     */
    void SetLevelIndicator(UInt8 levelIndicator);
    /**
     * 获取NAL Unit长度字段的字节数
     * @return NAL Unit长度字段的字节数
     */
    UInt8 GetLengthSize() const;
    /**
     * 设置NAL Unit长度字段的字节数
     * @param lengthSize NAL Unit长度字段的字节数
     */
    void SetLengthSize(UInt8 lengthSize);
    /**
     * 获取SPS的数目
     * @return SPS的数目
     */
    UInt8 GetNumberOfSequenceParameterSets() const;
    /**
     * 获取PPS的数目
     * @return PPS的数目
     */
    UInt8 GetNumberOfPictureParameterSets() const;
    /**
     * 获取第index个SPS
     * @param index 指定获取第index个SPS
     * @param sequenceParameterSet 保存获取的SPS
     * @return 如果获取成功，则返回true，如果index超出范围，返回false
     */
    bool GetSequenceParameterSet(UInt32 index, std::string &sequenceParameterSet) const;
    /**
     * 获取第index个PPS
     * @param index 指定获取第index个PPS
     * @param pictureParameterSet 保存获取的PPS
     * @return 如果获取成功，则返回true，如果index超出范围，返回false
     */
    bool GetPictureParameterSet(UInt32 index, std::string &pictureParameterSet) const;
    /**
     * 增加一个SPS
     * @param sequenceParameterSet 增加的SPS
     */
    void PutSequenceParameterSet(const std::string &sequenceParameterSet);
    /**
     * 增加一个PPS
     * @param pictureParameterSet 增加的PPS
     */
    void PutPictureParameterSet(const std::string &pictureParameterSet);
    /**
     * 清除所有SPS
     */
    void ClearSequenceParameterSet();
    /**
     * 清除所有PPS
     */
    void ClearPictureParameterSet();
    /**
     * 编码此解码器配置记录到指定的缓冲区，缓冲区大小需不小于GetEncodingBytes获取的值
     * @param data 用于保存编码数据
     * @param size data的大小
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(UInt8 *data, UInt32 size);
    /**
     * 编码此解码器配置记录
     * @param encoding 保存编码数据
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(std::string &encoding);
    /**
     * 从数据中解码此解码器配置记录，如果数据不足，返回0
     * @param data 解码器配置记录的数据
     * @param size data的大小
     * @return 如果解码成功，则返回解码使用的数据长度，否则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 从数据中解码此解码器配置记录，如果数据不足，返回0
     * @param encoding 解码器配置记录的数据
     * @return 如果解码成功，则返回解码使用的数据长度，出错则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    typedef std::vector<std::string> ParameterSet;
private:
    UInt8 configurationVersion_;
    UInt8 profileIndicator_;
    UInt8 profileCompatibility_;
    UInt8 levelIndicator_;
    UInt8 lengthSize_;
    ParameterSet sequenceParameterSets_;
    ParameterSet pictureParameterSets_;
};
}
namespace avc {
class BitReader;
class BitWriter;
/**
 * 此类用于HRD参数的编码和解码
 */
class HrdParameters {
public:
    /**
     * 构造函数
     */
    HrdParameters();
    /**
     * 析构函数
     */
    virtual ~HrdParameters();
public:
    /**
     * 获取编码后的比特数
     * @return 编码后的比特数
     */
    UInt32 GetEncodingBits() const;
    /**
     * 获取比特流中可选的CPB规范的数量(cpb_cnt_minus1)
     * @note 取值范围为[1,32]
     * @return 比特流中可选的CPB规范的数量
     */
    UInt32 GetCpbCount() const;
    /**
     * 设置比特流中可选的CPB规范的数量(cpb_cnt_minus1)
     * @note 取值范围为[1,32]
     * @param cpbCount 比特流中可选的CPB规范的数量，默认为1
     */
    void SetCpbCount(UInt32 cpbCount);
    /**
     * 获取CPB输入比特率的最大值的倍数(bit_rate_scale)
     * @note 取值范围为[0,16]
     * @return CPB输入比特率的最大值的倍数
     */
    UInt8 GetBitrateScale() const;
    /**
     * 设置CPB输入比特率的最大值的倍数(bit_rate_scale)
     * @note 取值范围为[0,16]
     * @param bitrateScale CPB输入比特率的最大值的倍数，默认为0
     */
    void SetBitrateScale(UInt8 bitrateScale);
    /**
     * 获取CPB缓冲空间大小的倍数(cpb_size_scale)
     * @note 取值范围为[0,16]
     * @return CPB缓冲空间大小的倍数
     */
    UInt8 GetCpbSizeScale() const;
    /**
     * 设置CPB缓冲空间大小的倍数(cpb_size_scale)
     * @note 取值范围为[0,16]
     * @param cpbSizeScale CPB缓冲空间大小的倍数，默认为0
     */
    void SetCpbSizeScale(UInt8 cpbSizeScale);
    /**
     * 获取第index个CPB输入比特率的最大值的基数(bit_rate_value_minus1)
     * @note 取值范围为[1,2^32-1]
     * @param index 指定索引
     * @return 第index个CPB输入比特率的最大值的基数
     */
    UInt32 GetBitrateValue(UInt32 index) const;
    /**
     * 设置第index个CPB输入比特率的最大值的基数(bit_rate_value_minus1)
     * @note 取值范围为[1,2^32-1]
     * @param value 第index个CPB输入比特率的最大值的基数，默认值为1
     * @param index 指定索引
     */
    void SetBitrateValue(UInt32 value, UInt32 index);
    /**
     * 获取第index个CPB缓冲空间大小的基数(cpb_size_value_minus1)
     * @note 取值范围为[1,2^32-1]
     * @param index 指定索引
     * @return 第index个CPB缓冲空间大小的基数
     */
    UInt32 GetCpbSizeValue(UInt32 index) const;
    /**
     * 设置第index个CPB缓冲空间大小的基数(cpb_size_value_minus1)
     * @note 取值范围为[1,2^32-1]
     * @param value 第index个CPB缓冲空间大小的基数，默认值为1
     * @param index 指定索引
     */
    void SetCpbSizeValue(UInt32 value, UInt32 index);
    /**
     * 获取第index个CPB是否工作在固定比特率模式(cbr_flag)
     * @param index 指定索引
     * @return 第index个CPB是否工作在固定比特率模式
     */
    bool GetCbrFlag(UInt32 index) const;
    /**
     * 设置第index个CPB是否工作在固定比特率模式(cbr_flag)
     * @param flag 第index个CPB是否工作在固定比特率模式，默认为false
     * @param index 指定索引
     */
    void SetCbrFlag(bool flag, UInt32 index);
    /**
     * 获取initial_cpb_removal_delay语法元素的比特长度(initial_cpb_removal_delay_length_minus1)
     * @note 取值范围为[1,32]
     * @return initial_cpb_removal_delay语法元素的比特长度
     */
    UInt8 GetInitialCbpRemovalDelayLength() const;
    /**
     * 设置initial_cpb_removal_delay语法元素的比特长度(initial_cpb_removal_delay_length_minus1)
     * @note 取值范围为[1,32]
     * @param length initial_cpb_removal_delay语法元素的比特长度，默认值为24
     */
    void SetInitialCbpRemovalDelayLength(UInt8 length);
    /**
     * 获取cpb_removal_delay语法元素的比特长度(cpb_removal_delay_length_minus1)
     * @note 取值范围为[1,32]
     * @return cpb_removal_delay语法元素的比特长度
     */
    UInt8 GetCpbRemovalDelayLength() const;
    /**
     * 设置cpb_removal_delay语法元素的比特长度(cpb_removal_delay_length_minus1)
     * @note 取值范围为[1,32]
     * @param length cpb_removal_delay语法元素的比特长度，默认值为24
     */
    void SetCpbRemovalDelayLength(UInt8 length);
    /**
     * 获取dpb_output_delay语法元素的比特长度(dpb_output_delay_length_minus1)
     * @note 取值范围为[1,32]
     * @return dpb_output_delay语法元素的比特长度
     */
    UInt8 GetDpbOutputDelayLength() const;
    /**
     * 设置dpb_output_delay语法元素的比特长度(dpb_output_delay_length_minus1)
     * @note 取值范围为[1,32]
     * @param length dpb_output_delay语法元素的比特长度，默认值为24
     */
    void SetDpbOutputDelayLength(UInt8 length);
    /**
     * 获取time_offset语法元素的比特长度(time_offset_length)
     * @note 取值范围为[0,31]
     * @return time_offset语法元素的比特长度
     */
    UInt8 GetTimeOffsetLength() const;
    /**
     * 设置time_offset语法元素的比特长度(time_offset_length)
     * @note 取值范围为[0,31]
     * @param length time_offset语法元素的比特长度，默认值为24
     */
    void SetTimeOffsetLength(UInt8 length);
    /**
     * 向BitWriter中编码此HRD参数
     * @param writer BitWriter对象，用于位域的写操作
     * @return 如果缓冲区不够，则返回0，如果数据有错，则返回1，如果解析成功，则返回2
     */
    UInt32 Encode(BitWriter &writer) const;
    /**
     * 从BitReader中解析此HRD参数
     * @param reader BitReader对象，用于位域的读操作
     * @return 如果数据不够，则返回0，如果数据有错，则返回1，如果解析成功，则返回2
     */
    UInt32 Decode(BitReader &reader);
private:
    /* ue(v): cpb_cnt_minus1 */
    UInt32 cpbCount_;
    /* u(4): bit_rate_scale */
    UInt8 bitrateScale_;
    /* u(4): cpb_size_scale */
    UInt8 cpbSizeScale_;
    /* ue(v): bit_rate_value_minus1 */
    std::vector<UInt32> bitrateValue_;
    /* ue(v): cpb_size_value_minus1 */
    std::vector<UInt32> cpbSizeValue_;
    /* u(1): cbr_flag */
    std::deque<bool> cbrFlag_;
    /* u(5): initial_cpb_removal_delay_length_minus1 */
    UInt8 initialCpbRemovalDelayLength_;
    /* u(5): cpb_removal_delay_length_minus1 */
    UInt8 cpbRemovalDelayLength_;
    /* u(5): dpb_output_delay_length_minus1 */
    UInt8 dpbOutputDelayLength_;
    /* u(5): time_offset_length */
    UInt8 timeOffsetLength_;
};
}
namespace avc {
/**
 * H264级别标识
 */
namespace LevelIndicator {
    /**
     * Level 1
     */
    const UInt8 LEVEL_1 = 10;
    /**
     * Level 1.1
     */
    const UInt8 LEVEL_11 = 11;
    /**
     * Level 1.2
     */
    const UInt8 LEVEL_12 = 12;
    /**
     * Level 1.3
     */
    const UInt8 LEVEL_13 = 13;
    /**
     * Level 2
     */
    const UInt8 LEVEL_2 = 20;
    /**
     * Level 2.1
     */
    const UInt8 LEVEL_21 = 21;
    /**
     * Level 2.2
     */
    const UInt8 LEVEL_22 = 22;
    /**
     * Level 3
     */
    const UInt8 LEVEL_3 = 30;
    /**
     * Level 3.1
     */
    const UInt8 LEVEL_31 = 31;
    /**
     * Level 3.2
     */
    const UInt8 LEVEL_32 = 32;
    /**
     * Level 4
     */
    const UInt8 LEVEL_4 = 40;
    /**
     * Level 4.1
     */
    const UInt8 LEVEL_41 = 41;
    /**
     * Level 4.2
     */
    const UInt8 LEVEL_42 = 42;
    /**
     * Level 5
     */
    const UInt8 LEVEL_5 = 50;
    /**
     * Level 5.1
     */
    const UInt8 LEVEL_51 = 51;
}
}
namespace avc {
/**
 * 此类用于NAL unit到RBSP的编码和解码
 */
class Nalu {
public:
    /**
     * 构造函数
     */
    Nalu();
    /**
     * 析构函数
     */
    virtual ~Nalu();
public:
    /**
     * 获取此NAL单元编码后的长度
     * @return 此NAL单元编码后的长度
     */
    UInt32 GetLength() const;
    /**
     * 获取此NAL单元的头域
     * @return 此NAL单元的头域
     */
    UInt8 GetHeader() const;
    /**
     * 设置此NAL单元的头域
     * @param header 此NAL单元的头域
     */
    void SetHeader(UInt8 header);
    /**
     * 获取此NAL中的原始字节序列数据(RBSP)
     * @return 原始字节序列数据(RBSP)
     */
    const std::string &GetPayload() const;
    /**
     * 设置此NAL中的原始字节序列数据(RBSP)
     * @param payload 原始字节序列数据(RBSP)
     */
    void SetPayload(const std::string &payload);
    /**
     * 编码此NAL单元，可以通过GetLength确定编码后的长度
     * @param data 用于保存编码数据
     * @param size data的大小
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(UInt8 *data, UInt32 size);
    /**
     * 编码此NAL单元
     * @param encoding 保存编码数据
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(std::string &encoding);
    /**
     * 从数据中解码此NAL单元，如果数据不足，返回0
     * @param data NAL单元的数据
     * @param size data的大小
     * @return 如果解码成功，则返回解码使用的数据长度，否则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 从数据中解码此NAL单元，如果数据不足，返回0
     * @param encoding NAL单元的数据
     * @return 如果解码成功，则返回解码使用的数据长度，否则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    UInt8 header_;
    UInt32 length_;
    std::string payload_;
};
}
namespace avc {
/**
 * 用于解析NAL单元头域的相关函数
 */
namespace NaluHeader {
    /**
     * 读取NAL参考标识(nal_ref_idc)
     * @param header nalu头域，1个字节
     * @return NAL参考标识(nal_ref_idc)
     */
    UInt8 GetReferenceIndicator(UInt8 header);
    /**
     * 向nalu头写入NAL参考标识(nal_ref_idc)
     * @param indicator NAL参考标识(nal_ref_idc)
     * @param header nalu头域
     */
    void SetReferenceIndicator(UInt8 indicator, UInt8 &header);
    /**
     * 读取NAL类型(nal_type)
     * @param header nalu头域，1个字节
     * @return NAL类型(nal_type)
     */
    UInt8 GetType(UInt8 header);
    /**
     * 设置NAL类型(nal_type)
     * @param NAL类型(nal_type)
     * @param header nalu头域
     */
    void SetType(UInt8 type, UInt8 &header);
}
}
namespace avc {
/**
 * 枚举Nal单元类型
 */
namespace NaluType {
    /**
     * 非IDR的片 - Coded slice of a non-IDR picture 
     */
    const UInt8 NON_IDR_PICTURE = 0x01;
    /**
     * 片数据A分区 - Coded slice data partition A
     */
    const UInt8 DATA_PARTITION_A = 0x02;
    /**
     * 片数据B分区 - Coded slice data partition B
     */
    const UInt8 DATA_PARTITION_B = 0x03;
    /**
     * 片数据C分区 - Coded slice data partition C
     */
    const UInt8 DATA_PARTITION_C = 0x04;
    /**
     * IDR图像的片 - Coded slice of an IDR picture 
     */
    const UInt8 IDR_PICTURE = 0x05;
    /**
     * 补充增强信息单元 - Supplemental enhancement information (SEI) 
     */
    const UInt8 SEI = 0x06;
    /**
     * 序列参数集 - Sequence parameter set
     */
    const UInt8 SPS = 0x07;
    /**
     * 图像参数集 - Picture parameter set
     */
    const UInt8 PPS = 0x08;
    /**
     * 分界符 - Access unit delimiter
     */
    const UInt8 ACCESS_UNIT_DELIMITER = 0x09;
    /**
     * 序列结束 - End of sequence
     */
    const UInt8 END_OF_SEQUENCE = 0x0A;
    /**
     * 码流结束 - End of stream
     */
    const UInt8 END_OF_STREAM = 0x0B;
    /**
     * 填充 - Filter data
     */
    const UInt8 FILTER_DATA = 0x0C;
}
}
namespace avc {
/**
 * 此类用于图像参数集的编码和解码
 */
class PictureParameterSet {
public:
    /**
     * 构造函数
     */
    PictureParameterSet();
    /**
     * 析构函数
     */
    virtual ~PictureParameterSet();
public:
    /**
     * 获取编码后的字节数
     * @return 编码后的字节数
     */
    UInt32 GetEncodingBytes() const;
    /**
     * 获取图像参数集的标识(pic_parameter_set_id)
     * @note 取值范围为[0,255]
     * @return 图像参数集的标识
     */
    UInt32 GetPictureParameterSetId() const;
    /**
     * 设置图像参数集的标识(pic_parameter_set_id)
     * @note 取值范围为[0,255]
     * @return 图像参数集的标识，默认值为0
     */
    void SetPictureParameterSetId(UInt32 id);
    /**
     * 获取序列参数集标识
     * @note 取值范围为[0,31]
     * @return 序列参数集的标识
     */
    UInt32 GetSequenceParameterSetId() const;
    /**
     * 设置序列参数集标识
     * @note 取值范围为[0,31]
     * @return 序列参数集的标识，默认值为0
     */
    void SetSequenceParameterSetId(UInt32 id);
    /**
     * 获取语法元素的熵编码方式是否为CABAC(entropy_coding_mod_flag)
     * @return 语法元素的熵编码方式是否为CABAC
     */
    bool GetEntropyCodingModeFlag() const;
    /**
     * 设置语法元素的熵编码方式是否为Exp-Golomb(entropy_coding_mod_flag)
     * @param flag 语法元素的熵编码方式是否为CABAC，默认为false
     */
    void SetEntropyCodingModeFlag(bool flag);
    /**
     * 获取是否与图像顺序数有关的语法元素将出现于条带中(pic_order_present_flag)
     * @return 是否与图像顺序数有关的语法元素将出现于条带中
     */
    bool GetPictureOrderPresentFlag() const;
    /**
     * 设置是否与图像顺序数有关的语法元素将出现于条带中(pic_order_present_flag)
     * @param flag 是否与图像顺序数有关的语法元素将出现于条带中，默认为false
     */
    void SetPictureOrderPresentFlag(bool flag);
    /**
     * 获取一个图像中的条带组数(num_slice_groups_minus1)
     * @return 一个图像中的条带组数
     */
    UInt32 GetNumberSliceGroups() const;
    /**
     * 设置一个图像中的条带组数(num_slice_groups_minus1)
     * @param number 一个图像中的条带组数，默认值为1
     */
    void SetNumberSliceGroups(UInt32 number);
    /**
     * 获取条带组映射单元的映射方式(slice_group_map_type)
     * @note 取值范围为[0,6]
     * @return 条带组映射单元的映射方式
     */
    UInt32 GetSliceGroupMapType() const;
    /**
     * 设置条带组映射单元的映射方式(slice_group_map_type)
     * @note 取值范围为[0,6]
     * @param type 条带组映射单元的映射方式，默认为0
     */
    void SetSliceGroupMapType(UInt32 type);
    /**
     * 获取指定条带组映射单元的光栅扫描顺序中分配给第i个条带组的连续条带组映射单元的数目(run_length_minus1)
     * @note 取值范围为[1,PicSizeInMapUnits]
     * @param group 指定的索引
     * @return 指定条带组映射单元的光栅扫描顺序中分配给第i个条带组的连续条带组映射单元的数目
     */
    UInt32 GetRunLength(UInt32 group) const;
    /**
     * 设置指定条带组映射单元的光栅扫描顺序中分配给第i个条带组的连续条带组映射单元的数目(run_length_minus1)
     * @note 取值范围为[1,PicSizeInMapUnits]
     * @param runLength  指定条带组映射单元的光栅扫描顺序中分配给第i个条带组的连续条带组映射单元的数目，默认为1
     * @param group 指定的索引
     */
    void SetRunLength(UInt32 runLength, UInt32 group);
    /**
     * 获取第i个条带组的矩形左上角(top_left)
     * @param group 指定的索引
     * @return 第i个条带组的矩形左上角
     */
    UInt32 GetTopLeft(UInt32 group) const;
    /**
     * 设置第i个条带组的矩形左上角(top_left)
     * @param group 指定的索引
     * @return 第i个条带组的矩形左上角，默认为0
     */
    void SetTopLeft(UInt32 topLeft, UInt32 group);
    /**
     * 获取第i个条带组的矩形右下角(top_left)
     * @param group 指定的索引
     * @return 第i个条带组的矩形右下角
     */
    UInt32 GetBottomRight(UInt32 group) const;
    /**
     * 设置第i个条带组的矩形右下角(top_left)
     * @param group 指定的索引
     * @return 第i个条带组的矩形右下角，默认为0
     */
    void SetBottomRight(UInt32 bottomRight, UInt32 group);
    /**
     * 获取条带组改变方向的标志(slice_group_change_direction_flag)
     * @return 条带组改变方向的标志
     */
    bool GetSliceGroupChangeDirectionFlag() const;
    /**
     * 设置条带组改变方向的标志(slice_group_change_direction_flag)
     * @param flag 条带组改变方向的标志，默认为false
     */
    void SetSliceGroupChangeDirectionFlag(bool flag);
    /**
     * 获取条带组大小从一个图像到下一个的改变倍数(slice_group_change_rate_minus1)
     * @note 取值范围为[1,PicSizeInMapUnits]
     * @return 条带组大小从一个图像到下一个的改变倍数
     */
    UInt32 GetSliceGroupChangeRate() const;
    /**
     * 设置条带组大小从一个图像到下一个的改变倍数(slice_group_change_rate_minus1)
     * @note 取值范围为[1,PicSizeInMapUnits]
     * @param rate 条带组大小从一个图像到下一个的改变倍数，默认值为1
     */
    void SetSliceGroupChangeRate(UInt32 rate);
    /**
     * 获取图像中的条带组映射单元数(pic_size_in_map_units_minus1)
     * @return 图像中的条带组映射单元数
     */
    UInt32 GetPictureSizeInMapUnits() const;
    /**
     * 设置图像中的条带组映射单元数(pic_size_in_map_units_minus1)
     * @param size 图像中的条带组映射单元数，默认为266
     */
    void SetPictureSizeInMapUnits(UInt32 size);
    /**
     * 获取第i个条带组映射单元的一个条带组(slice_group_id)
     * @param unit 指定的索引
     * @note 取值范围为[0,num_slice_groups_minus1]
     * @return 第i个条带组映射单元的一个条带组
     */
    UInt32 GetSliceGroupId(UInt32 unit) const;
    /**
     * 设置第i个条带组映射单元的一个条带组(slice_group_id)
     * @note 取值范围为[0,num_slice_groups_minus1]
     * @param id 第i个条带组映射单元的一个条带组，默认值为1
     * @param unit 指定的索引
     */
    void SetSliceGroupId(UInt32 id, UInt32 unit);
    /**
     * 获取参考图像列表的最大参考索引号(num_ref_idx_l0_active_minus1, num_ref_idx_l1_active_minus1)
     * @note 取值范围为[0,31]
     * @param level指定级别
     * @return 参考图像列表的最大参考索引号
     */
    UInt32 GetNumberReferenceIndexActive(UInt8 level) const;
    /**
     * 设置参考图像列表的最大参考索引号(num_ref_idx_l0_active_minus1, num_ref_idx_l1_active_minus1)
     * @note 取值范围为[0,31]
     * @param number 参考图像列表的最大参考索引号，l0默认值为2，l1默认值为1
     * @param level指定级别
     */
    void SetNumberReferenceIndexActive(UInt32 number, UInt8 level);
    /**
     * 获取加权的预测是否应用于P和SP条带(weighted_pred_flag)
     * @return 加权的预测是否应用于P和SP条带
     */
    bool GetWeightedPredictionFlag() const;
    /**
     * 设置加权的预测是否应用于P和SP条带(weighted_pred_flag)
     * @param flag 加权的预测是否应用于P和SP条带，默认为false
     */
    void SetWeightedPredictionFlag(bool flag);
    /**
     * 获取B条带的加权预测的类型(weighted_bipred_idc)
     * @note 取值范围为[0,2]
     * @return B条带的加权预测的类型
     */
    UInt8 GetWeightedBiPredictionIndicator() const;
    /**
     * 设置B条带的加权预测的类型(weighted_bipred_idc)
     * @note 取值范围为[0,2]
     * @param indicator B条带的加权预测的类型，默认值为0
     */
    void SetWeightedBiPredictionIndicator(UInt8 indicator);
    /**
     * 获取条带SliceQPY的初始值(pic_init_qp_minus26)
     * @note 取值范围为[-QpBdOffsetY,+51]
     * @return 条带SliceQPY的初始值
     */
    Int32 GetPictureInitQp() const;
    /**
     * 设置条带SliceQPY的初始值(pic_init_qp_minus26)
     * @note 取值范围为[-QpBdOffsetY,+51]
     * @param qp 条带SliceQPY的初始值，默认为25
     */
    void SetPictureInitQp(Int32 qp);
    /**
     * 获取SP或SI条带中所有宏块的SliceQSY的初始值(pic_init_qs_minus26)
     * @note 取值范围为[0,+51]
     * @reutrn SP或SI条带中所有宏块的SliceQSY的初始值
     */
    Int32 GetPictureInitQs() const;
    /**
     * 设置SP或SI条带中所有宏块的SliceQSY的初始值(pic_init_qs_minus26)
     * @note 取值范围为[0,+51]
     * @param qs SP或SI条带中所有宏块的SliceQSY的初始值，默认为26
     */
    void SetPictureInitQs(Int32 qs);
    /**
     * 获取在QPC值的表格中寻找Cb色度分量而应加到参数QPY和QSY上的偏移(chroma_qp_index_offset)
     * @note 取值范围为[-12,+12]
     * @return 在QPC值的表格中寻找Cb色度分量而应加到参数QPY和QSY上的偏移
     */
    Int32 GetChromaQpIndexOffset() const;
    /**
     * 设置在QPC值的表格中寻找Cb色度分量而应加到参数QPY和QSY上的偏移(chroma_qp_index_offset)
     * @note 取值范围为[-12,+12]
     * @param offset 在QPC值的表格中寻找Cb色度分量而应加到参数QPY和QSY上的偏移，默认值为-2
     */
    void SetChromaQpIndexOffset(Int32 offset);
    /**
     * 获取控制去块效应滤波器的特征的一组语法元素是否将出现在条带头中(deblocking_filter_control_present_flag)
     * @return 控制去块效应滤波器的特征的一组语法元素是否将出现在条带头中
     */
    bool GetDeblockingFilterControlPresentFlag() const;
    /**
     * 设置控制去块效应滤波器的特征的一组语法元素是否将出现在条带头中(deblocking_filter_control_present_flag)
     * @param flag 控制去块效应滤波器的特征的一组语法元素是否将出现在条带头中，默认为true
     */
    void SetDeblockingFilterControlPresentFlag(bool flag);
    /**
     * 获取是否为受限制的帧内预测(constrained_intra_pred_flag)
     * @return 是否为受限制的帧内预测
     */
    bool GetConstrainedIntraPredictionFlag() const;
    /**
     * 设置是否为受限制的帧内预测(constrained_intra_pred_flag)
     * @param flag 是否为受限制的帧内预测，默认为false
     */
    void SetConstrainedIntraPredictionFlag(bool flag);
    /**
     * 获取redundant_pic_cnt语法元素是否将出现在条带头(redundant_pic_cnt_present_flag)
     * @return redundant_pic_cnt语法元素是否将出现在条带头
     */
    bool GetRedundantPictureCountPresentFlag() const;
    /**
     * 设置redundant_pic_cnt语法元素是否将出现在条带头(redundant_pic_cnt_present_flag)
     * @param flag redundant_pic_cnt语法元素是否将出现在条带头，默认为false
     */
    void SetRedundantPictureCountPresentFlag(bool flag);
    /**
     * 编码此图像参数集到指定的缓冲区，缓冲区大小需不小于GetEncodingBytes获取的值
     * @param data 用于保存编码数据
     * @param size data的大小
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 编码此图像参数集
     * @param encoding 保存编码数据
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解码此图像参数集，如果数据不足，返回0
     * @param data 此图像参数集的数据
     * @param size data的大小
     * @return 如果解码成功，则返回解码使用的数据长度，否则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 从数据中解码此图像参数集，如果数据不足，返回0
     * @param encoding 此图像参数集的数据
     * @return 如果解码成功，则返回解码使用的数据长度，出错则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    /* ue(v): pic_parameter_set_id */
    UInt32 pictureParameterSetId_;
    /* ue(v): seq_parameter_set_id */
    UInt32 sequenceParameterSetId_;
    /* u(1): entropy_coding_mod_flag */
    bool entropyCodingModeFlag_;
    /* u(1): pic_order_present_flag */
    bool pictureOrderPresentFlag_;
    /* ue(v): num_slice_groups_minus1 */
    UInt32 numberSliceGroups_;
    /* ue(v): slice_group_map_type */
    UInt32 sliceGroupMapType_;
    /* ue(v): run_length_minus1 */
    std::vector<UInt32> runLength_;
    /* ue(v): top_left */
    std::vector<UInt32> topLeft_;
    /* ue(v): bottom_right */
    std::vector<UInt32> bottomRight_;
    /* u(1): slice_group_change_direction_flag */
    bool sliceGroupChangeDirectionFlag_;
    /* ue(v): slice_group_change_rate_minus1 */
    UInt32 sliceGroupChangeRate_;
    /* ue(v): pic_size_in_map_units_minus1 */
    UInt32 pictureSizeInMapUnits_;
    /* u(v): slice_group_id */
    std::vector<UInt32> sliceGroupId_;
    /**
     * ue(v): num_ref_idx_l0_active_minus1
     * ue(v): num_ref_idx_l1_active_minus1
     */
    UInt32 numberReferenceIndexActive_[2];
    /* u(1): weighted_pred_flag */
    bool weightedPredictionFlag_;
    /* u(2): weighted_bipred_idc */
    UInt8 weightedBiPredictionIndicator_;
    /* se(v): pic_init_qp_minus26 */
    Int32 pictureInitQp_;
    /* se(v): pic_init_qs_minus26 */
    Int32 pictureInitQs_;
    /* se(v): chroma_qp_index_offset */
    Int32 chromaQpIndexOffset_;
    /* u(1): deblocking_filter_control_present_flag */
    bool deblockingFilterControlPresentFlag_;
    /* u(1): constrained_intra_pred_flag */
    bool constrainedIntraPredictionFlag_;
    /* u(1): redundant_pic_cnt_present_flag */
    bool redundantPictureCountPresentFlag_;
};
}
namespace avc {
/**
 * H.264的画质标识
 */
namespace ProfileIndicator {
    /**
     * 基本画质(Baseline profile)
     */
    const UInt8 BASELINE = 66;
    /**
     * 主流画质(Main profile)
     */
    const UInt8 MAIN = 77;
    /**
     * 进阶画质(Extended profile)
     */
    const UInt8 EXTENDED = 88;
}
}
namespace avc {
/**
 * 表示AVC的一个采样，即一个完整的帧，参考ISO-IEC 14496-15 5.3.4.2
 */
class Sample {
public:
    /**
     * 构造函数
     * @param lengthSize NAL单元长度占用的字节数，从DecoderConfigurationRecord获得
     */
    Sample(UInt32 lengthSize);
    /**
     * 析构函数
     */
    virtual ~Sample();
public:
    /**
     * 获取此采样编码后占用的字节数
     * @return 此采样编码后的大小
     */
    UInt32 GetEncodingBytes() const;
    /**
     * 获取此采样中的NAL单元数目
     * @return 此采样中的NAL单元数目
     */
    UInt32 GetNaluCount() const;
    /**
     * 向此采样中增加一个NAL单元
     * @param nalu 要增加的NAL单元
     */
    void PutNalu(const std::string &nalu);
    /**
     * 获取此采样中的第index个NAL单元
     * @param index 要获取的NAL单元所在的位置
     * @param nalu 保存获取到的NAL单元
     * @return 如果index处存在NAL单元，则返回true，并将其保存到nalu中；否则返回false
     */
    bool GetNalu(UInt32 index, std::string &nalu) const;
    /**
     * 清除此采样中的所有NAL单元
     */
    void ClearNalus();
    /**
     * 编码此采样到指定的缓冲区，缓冲区大小需不小于GetLength获取的值
     * @param data 用于保存编码数据
     * @param size data的大小
     * @return 如果编码成功，则返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 编码此采样
     * @param encoding 保存编码数据
     * @return 如果编码成功，则返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解码此采样
     * @param data 采样的数据
     * @param size data的大小
     * @return 如果解码成功，则返回解码使用的数据长度，如果出错返回size + 1，如果数据不足，则返回0
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 从数据中解码此采样
     * @param data 采样的数据
     * @param size data的大小
     * @return 如果解码成功，则返回解码使用的数据长度，如果出错返回size + 1，如果数据不足，则返回0
     */
    UInt32 Decode(const std::string &encoding);
private:
    typedef std::vector<std::string> Nalus;
private:
    UInt32 lengthSize_;
    UInt32 naluLength_;
    Nalus nalus_;
};
}
namespace avc {
/**
 * 此类用于VUI参数的编码和解码
 */
class VuiParameters {
public:
    /**
     * 构造函数
     */
    VuiParameters();
    /**
     * 析构函数
     */
    virtual ~VuiParameters();
public:
    /**
     * 获取编码后的比特数
     * @return 编码后的比特数
     */
    UInt32 GetEncodingBits() const;
    /**
     * 获取是否存在aspect_radio_idc(aspect_ratio_info_present_flag)
     * @return 是否存在aspect_radio_idc
     */
    bool GetAspectRatioInfoPresentFlag() const;
    /**
     * 设置是否存在aspect_radio_idc(aspect_ratio_info_present_flag)
     * @param flag 是否存在aspect_radio_idc，默认为false
     */
    void SetAspectRatioInfoPresentFlag(bool flag);
    /**
     * 获取亮度样值的样点高宽比的取值(aspect_ratio_idc)
     * @see AspectRatioIndicator
     * @note 取值范围为[0,255]
     * @return 亮度样值的样点高宽比的取值
     */
    UInt8 GetAspectRatioIndicator() const;
    /**
     * 设置亮度样值的样点高宽比的取值(aspect_ratio_idc)
     * @see AspectRatioIndicator
     * @note 取值范围为[0,255]
     * @param indicator 亮度样值的样点高宽比的取值，默认为AspectRatioIndicator::UNSPECIFIED
     */
    void SetAspectRatioIndicator(UInt8 indicator);
    /**
     * 获取样点高宽比的水平尺寸(sar_width)
     * @return 样点高宽比的水平尺寸
     */
    UInt16 GetSarWidth() const;
    /**
     * 设置样点高宽比的水平尺寸(sar_width)
     * @param sarWidth 样点高宽比的水平尺寸，默认值为0
     */
    void SetSarWidth(UInt16 sarWidth);
    /**
     * 获取样点高宽比的垂直尺寸(sar_height)
     * @return 样点高宽比的垂直尺寸
     */
    UInt16 GetSarHeight() const;
    /**
     * 获取样点高宽比的垂直尺寸(sar_height)
     * @param sarHeight 样点高宽比的垂直尺寸，默认为0
     */
    void SetSarHeight(UInt16 sarHeight);
    /**
     * 获取overscan_appropriate_flag是否存在(overscan_info_present_flag)
     * @return overscan_appropriate_flag是否存在
     */
    bool GetOverscanInfoPresentFlag() const;
    /**
     * 获取overscan_appropriate_flag是否存在(overscan_info_present_flag)
     * @param flag overscan_appropriate_flag是否存在，默认为false
     */
    void SetOverscanInfoPresentFlag(bool flag);
    /**
     * 获取被剪切的解码图像输出是否以过扫描显示(overscan_appropriate_flag)
     * @return 被剪切的解码图像输出是否以过扫描显示
     */
    bool GetOverscanAppropriateFlag() const;
    /**
     * 设置被剪切的解码图像输出是否以过扫描显示(overscan_appropriate_flag)
     * @param flag 被剪切的解码图像输出是否以过扫描显示，默认为false
     */
    void SetOverscanAppropriateFlag(bool flag);
    /**
     * 获取video_format, video_full_range_flag和colour_description_present_flag是否存在(video_signal_type_present_flag)
     * @return video_format, video_full_range_flag和colour_description_present_flag是否存在
     */
    bool GetVideoSignalTypePresentFlag() const;
    /**
     * 设置video_format, video_full_range_flag和colour_description_present_flag是否存在(video_signal_type_present_flag)
     * @param flag video_format, video_full_range_flag和colour_description_present_flag是否存在，默认为false
     */
    void SetVideoSignalTypePresentFlag(bool flag);
    /**
     * 获取视频制式(video_format)
     * @return 视频制式
     */
    UInt8 GetVideoFormat() const;
    /**
     * 设置视频制式(video_format)
     * @param videoFormat 视频制式，默认为5
     */
    void SetVideoFormat(UInt8 videoFormat);
    /**
     * 获取黑电平和亮度与色度信号的范围是否由模拟信号分量得到(video_full_range_flag)
     * @return 黑电平和亮度与色度信号的范围是否由模拟信号分量得到
     */
    bool GetVideoFullRangeFlag() const;
    /**
     * 设置黑电平和亮度与色度信号的范围是否由模拟信号分量得到(video_full_range_flag)
     * @param flag 黑电平和亮度与色度信号的范围是否由模拟信号分量得到，默认为false
     */
    void SetVideoFullRangeFlag(bool flag);
    /**
     * 获取colour_primaries, transfer_characteristics和matrix_coefficients是否存在(colour_description_present_flag)
     * @return colour_primaries, transfer_characteristics和matrix_coefficients是否存在
     */
    bool GetColourDescriptionPresentFlag() const;
    /**
     * 设置colour_primaries, transfer_characteristics和matrix_coefficients是否存在(colour_description_present_flag)
     * @param flag colour_primaries, transfer_characteristics和matrix_coefficients是否存在，默认为false
     */
    void SetColourDescriptionPresentFlag(bool flag);
    /**
     * 获取最初的原色的色度坐标(colour_primaries)
     * @return 最初的原色的色度坐标
     */
    UInt8 GetColourPrimaries() const;
    /**
     * 设置最初的原色的色度坐标(colour_primaries)
     * @param colourPrimaries 最初的原色的色度坐标，默认值为2
     */
    void SetColourPrimaries(UInt8 colourPrimaries);
    /**
     * 获取源图像的光电转换特性(transfer_characteristics)
     * @return 源图像的光电转换特性
     */
    UInt8 GetTransferCharacteristics() const;
    /**
     * 设置源图像的光电转换特性(transfer_characteristics)
     * @param transferCharacteristics 源图像的光电转换特性，默认为2
     */
    void SetTransferCharacteristics(UInt8 transferCharacteristics);
    /**
     * 获取亮度和色度信号的矩阵系数(matrix_coefficients)
     * @return 亮度和色度信号的矩阵系数
     */
    UInt8 GetMatrixCoefficients() const;
    /**
     * 设置亮度和色度信号的矩阵系数(matrix_coefficients)
     * @param matrixCoefficients 亮度和色度信号的矩阵系数，默认值为2
     */
    void SetMatrixCoefficients(UInt8 matrixCoefficients);
    /**
     * 获取色度样值位置信息是否存在(chroma_loc_info_present_flag)
     * @return 色度样值位置信息是否存在
     */
    bool GetChromaLocInfoPresentFlag() const;
    /**
     * 设置色度样值位置信息是否存在(chroma_loc_info_present_flag)
     * @param flag 色度样值位置信息是否存在，默认为false
     */
    void SetChromaLocInfoPresentFlag(bool flag);
    /**
     * 获取色度样值在顶场中的位置(chroma_sample_loc_type_top_field)
     * @return 色度样值在顶场中的位置
     */
    UInt32 GetChromaSampleLocTypeTopField() const;
    /**
     * 设置色度样值在顶场中的位置(chroma_sample_loc_type_top_field)
     * @param chromaSampleLocTypeTopField 色度样值在顶场中的位置，默认值为0
     */
    void SetChromaSampleLocTypeTopField(UInt32 chromaSampleLocTypeTopField);
    /**
     * 获取色度样值在底场中的位置(chroma_sample_loc_type_bottom_field)
     * @return 色度样值在底场中的位置
     */
    UInt32 GetChromaSampleLocTypeBottomField() const;
    /**
     * 设置色度样值在底场中的位置(chroma_sample_loc_type_bottom_field)
     * @param chromaSampleLocTypeBottomField 色度样值在底场中的位置，默认值为0
     */
    void SetChromaSampleLocTypeBottomField(UInt32 chromaSampleLocTypeBottomField);
    /**
     * 获取时钟信息是否存在(timing_info_present_flag)
     * @return 时钟信息是否存在
     */
    bool GetTimingInfoPresentFlag() const;
    /**
     * 设置时钟信息是否存在(timing_info_present_flag)
     * @param flag 时钟信息是否存在，默认值为true
     */
    void SetTimingInfoPresentFlag(bool flag);
    /**
     * 获取在time_scale Hz的频率下的时钟的时间单元的数量(num_units_in_tick)
     * @note num_units_in_tick应大于0
     * @return 在time_scale Hz的频率下的时钟的时间单元的数量
     */
    UInt32 GetNumberUnitsInTick() const;
    /**
     * 设置在time_scale Hz的频率下的时钟的时间单元的数量(num_units_in_tick)
     * @note num_units_in_tick应大于0
     * @param numberUnitsInTick 在time_scale Hz的频率下的时钟的时间单元的数量，默认值为1
     */
    void SetNumberUnitsInTick(UInt32 numberUnitsInTick);
    /**
     * 获取一秒钟内的时间单元的数量(time_scale)
     * @note time_scale应大于0
     * @return 一秒钟内的时间单元的数量
     */
    UInt32 GetTimeScale() const;
    /**
     * 设置一秒钟内的时间单元的数量(time_scale)
     * @note time_scale应大于0
     * @param timeScale 一秒钟内的时间单元的数量，默认为50
     */
    void SetTimeScale(UInt32 timeScale);
    /**
     * 获取是否为固定帧率(fixed_frame_rate_flag)
     * @return 是否为固定帧率
     */
    bool GetFixedFrameRateFlag() const;
    /**
     * 设置是否为固定帧率(fixed_frame_rate_flag)
     * @param flag 是否为固定帧率，默认为false
     */
    void SetFixedFrameRateFlag(bool flag);
    /**
     * 获取是否存在NAL HRD参数(nal_hrd_parameters_present_flag)
     * @return 是否存在NAL HRD参数
     */
    bool GetNalHrdParametersPresentFlag() const;
    /**
     * 设置是否存在NAL HRD参数(nal_hrd_parameters_present_flag)
     * @param flag 是否存在NAL HRD参数，默认为false
     */
    void SetNalHrdParametersPresentFlag(bool flag);
    /**
     * 获取NAL HRD参数(nal_hrd_parameters)
     * @return NAL HRD参数
     */
    HrdParameters &GetNalHrdParameters();
    /**
     * 获取NAL HRD参数(nal_hrd_parameters)
     * @return NAL HRD参数
     */
    const HrdParameters &GetNalHrdParameters() const;
    /**
     * 获取是否存在VCL HRD参数(vcl_hrd_parameters_present_flag)
     * @return 是否存在VCL HRD参数
     */
    bool GetVclHrdParametersPresentFlag() const;
    /**
     * 设置是否存在VCL HRD参数(vcl_hrd_parameters_present_flag)
     * @param flag 是否存在VCL HRD参数，默认为false
     */
    void SetVclHrdParametersPresentFlag(bool flag);
    /**
     * 获取VCL HRD参数(vcl_hrd_parameters)
     * @return VCL HRD参数
     */
    HrdParameters &GetVclHrdParameters();
    /**
     * 获取VCL HRD参数(vcl_hrd_parameters)
     * @return VCL HRD参数
     */
    const HrdParameters &GetVclHrdParameters() const;
    /**
     * 获取是否允许低延时HRD操作模式(low_delay_hrd_flag)
     * @return 是否允许低延时HRD操作模式
     */
    bool GetLowDelayHrdFlag() const;
    /**
     * 设置是否允许低延时HRD操作模式(low_delay_hrd_flag)
     * @param flag 是否允许低延时HRD操作模式，默认为false
     */
    void SetLowDelayHrdFlag(bool flag);
    /**
     * 获取图像定时SEI消息中是否包含pic_struct语法元素(pic_struct_present_flag)
     * @return 图像定时SEI消息中是否包含pic_struct语法元素
     */
    bool GetPictureStructPresentFlag() const;
    /**
     * 设置图像定时SEI消息中是否包含pic_struct语法元素(pic_struct_present_flag)
     * @param flag 图像定时SEI消息中是否包含pic_struct语法元素，默认为false
     */
    void SetPictureStructPresentFlag(bool flag);
    /**
     * 获取是否存在视频编码序列比特流限制参数(bitstream_restriction_flag)
     * @return 是否存在视频编码序列比特流限制参数
     */
    bool GetBitstreamRestrictionFlag() const;
    /**
     * 设置是否存在视频编码序列比特流限制参数(bitstream_restriction_flag)
     * @param flag 是否存在视频编码序列比特流限制参数，默认为false
     */
    void SetBitstreamRestrictionFlag(bool flag);
    /**
     * 获取是否样值在图像边界以外(motion_vectors_over_pic_boundaries_flag)
     * @return 是否样值在图像边界以外
     */
    bool GetMotionVectorsOverPictureBoundariesFlag() const;
    /**
     * 设置是否样值在图像边界以外(motion_vectors_over_pic_boundaries_flag)
     * @param flag 是否样值在图像边界以外，默认为true
     */
    void SetMotionVectorsOverPictureBoundariesFlag(bool flag);
    /**
     * 获取视频编码序列中与任何编码图像关联的VCL NAL单元的最大字节数(max_bytes_per_pic_denom)
     * @note 取值范围为[0,16]
     * @return 视频编码序列中与任何编码图像关联的VCL NAL单元的最大字节数
     */
    UInt32 GetMaxBytesPerPictureDenom() const;
    /**
     * 设置视频编码序列中与任何编码图像关联的VCL NAL单元的最大字节数(max_bytes_per_pic_denom)
     * @note 取值范围为[0,16]
     * @param maxBytesPerPictureDenom 视频编码序列中与任何编码图像关联的VCL NAL单元的最大字节数，默认为2
     */
    void SetMaxBytesPerPictureDenom(UInt32 maxBytesPerPictureDenom);
    /**
     * 获取视频编码序列中任何图像的任何宏块的数据编码的最大比特数(max_bits_per_mb_denom)
     * @note 取值范围为[0,16]
     * @return 视频编码序列中任何图像的任何宏块的数据编码的最大比特数
     */
    UInt32 GetMaxBitsPerMbDenom() const;
    /**
     * 设置视频编码序列中任何图像的任何宏块的数据编码的最大比特数(max_bits_per_mb_denom)
     * @note 取值范围为[0,16]
     * @param maxBitsPerMbDenom 视频编码序列中任何图像的任何宏块的数据编码的最大比特数，默认为1
     */
    void SetMaxBitsPerMbDenom(UInt32 maxBitsPerMbDenom);
    /**
     * 获取解码水平运动矢量分量的最大绝对值的对数(log2_max_mv_length_horizontal)
     * @note 取值范围为[0,16]
     * @return 解码水平运动矢量分量的最大绝对值的对数
     */
    UInt32 GetLog2MaxMvLengthHorizontal() const;
    /**
     * 设置解码水平运动矢量分量的最大绝对值的对数(log2_max_mv_length_horizontal)
     * @note 取值范围为[0,16]
     * @param log2MaxMvLengthHorizontal 解码水平运动矢量分量的最大绝对值的对数，默认值为16
     */
    void SetLog2MaxMvLengthHorizontal(UInt32 log2MaxMvLengthHorizontal);
    /**
     * 获取解码垂直运动矢量分量的最大绝对值的对数(log2_max_mv_length_horizontal)
     * @note 取值范围为[0,16]
     * @return 解码垂直运动矢量分量的最大绝对值的对数
     */
    UInt32 GetLog2MaxMvLengthVertical() const;
    /**
     * 设置解码垂直运动矢量分量的最大绝对值的对数(log2_max_mv_length_horizontal)
     * @note 取值范围为[0,16]
     * @param log2MaxMvLengthHorizontal 解码垂直运动矢量分量的最大绝对值的对数，默认值为16
     */
    void SetLog2MaxMvLengthVertical(UInt32 log2MaxMvLengthVertical);
    /**
     * 获取重新排序的帧的数量(num_reorder_frames)
     * @note 取值范围为[0, max_dec_frame_buffering]
     * @return 重新排序的帧的数量
     */
    UInt32 GetNumberReorderFrames() const;
    /**
     * 设置重新排序的帧的数量(num_reorder_frames)
     * @note 取值范围为[0, max_dec_frame_buffering]
     * @param numberReorderFrames 重新排序的帧的数量，默认为max_dec_frame_buffering
     */
    void SetNumberReorderFrames(UInt32 numberReorderFrames);
    /**
     * 获取HRD解码图像缓冲区(DPB)所需的大小，以缓冲帧数为单位(max_dec_frame_buffering)
     * @note 取值范围为[num_ref_frames, MaxDpbSize]
     * @return HRD解码图像缓冲区(DPB)所需的大小
     */
    UInt32 GetMaxDecodeFrameBuffering() const;
    /**
     * 设置HRD解码图像缓冲区(DPB)所需的大小，以缓冲帧数为单位(max_dec_frame_buffering)
     * @note 取值范围为[num_ref_frames, MaxDpbSize]
     * @param maxDecodeFrameBuffering HRD解码图像缓冲区(DPB)所需的大小，默认为MaxDpbSize
     */
    void SetMaxDecodeFrameBuffering(UInt32 maxDecodeFrameBuffering);
    /**
     * 向BitWriter中编码此VUI参数
     * @param writer BitWriter对象，用于位域的写操作
     * @return 如果缓冲区不够，则返回0，如果数据有错，则返回1，如果解析成功，则返回2
     */
    UInt32 Encode(BitWriter &writer) const;
    /**
     * 从BitReader中解析此VUI参数
     * @param reader BitReader对象，用于位域的读操作
     * @return 如果数据不够，则返回0，如果数据有错，则返回1，如果解析成功，则返回2
     */
    UInt32 Decode(BitReader &reader);
private:
    /* u(1): aspect_ratio_info_present_flag */
    bool aspectRatioInfoPresentFlag_;
    /* u(8): aspect_ratio_idc */
    UInt8 aspectRatioIndicator_;
    /* u(16): sar_width */
    UInt16 sarWidth_;
    /* u(16): sar_height */
    UInt16 sarHeight_;
    /* u(1): overscan_info_present_flag */
    bool overscanInfoPresentFlag_;
    /* u(1): overscan_appropriate_flag */
    bool overscanAppropriateFlag_;
    /* u(1): video_signal_type_present_flag */
    bool videoSignalTypePresentFlag_;
    /* u(3): video_format */
    UInt8 videoFormat_;
    /* u(1): video_full_range_flag */
    bool videoFullRangeFlag_;
    /* u(1): colour_description_present_flag */
    bool colourDescriptionPresentFlag_;
    /* u(8): colour_primaries */
    UInt8 colourPrimaries_;
    /* u(8): transfer_characteristics */
    UInt8 transferCharacteristics_;
    /* u(8): matrix_coefficients */
    UInt8 matrixCoefficients_;
    /* u(1): chroma_loc_info_present_flag */
    bool chromaLocInfoPresentFlag_;
    /* ue(v): chroma_sample_loc_type_top_field */
    UInt32 chromaSampleLocTypeTopField_;
    /* ue(v): chroma_sample_loc_type_bottom_field */
    UInt32 chromaSampleLocTypeBottomField_;
    /* u(1): timing_info_present_flag */
    bool timingInfoPresentFlag_;
    /* u(32): num_units_in_tick */
    UInt32 numberUnitsInTick_;
    /* u(32): time_scale */
    UInt32 timeScale_;
    /* u(1): fixed_frame_rate_flag */
    bool fixedFrameRateFlag_;
    /* u(1): nal_hrd_parameters_present_flag */
    bool nalHrdParametersPresentFlag_;
    /* hrd_parameters() */
    HrdParameters nalHrdParameters_;
    /* u(1): vcl_hrd_parameters_present_flag */
    bool vclHrdParametersPresentFlag_;
    /* hrd_parameters() */
    HrdParameters vclHrdParameters_;
    /* u(1): low_delay_hrd_flag */
    bool lowDelayHrdFlag_;
    /* u(1): pic_struct_present_flag */
    bool pictureStructPresentFlag_;
    /* u(1): bitstream_restriction_flag */
    bool bitstreamRestrictionFlag_;
    /* u(1): motion_vectors_over_pic_boundaries_flag */
    bool motionVectorsOverPictureBoundariesFlag_;
    /* ue(v): max_bytes_per_pic_denom */
    UInt32 maxBytesPerPictureDenom_;
    /* ue(v): max_bits_per_mb_denom */
    UInt32 maxBitsPerMbDenom_;
    /* ue(v): log2_max_mv_length_horizontal */
    UInt32 log2MaxMvLengthHorizontal_;
    /* ue(v): log2_max_mv_length_vertical */
    UInt32 log2MaxMvLengthVertical_;
    /* ue(v): num_reorder_frames */
    UInt32 numberReorderFrames_;
    /* ue(v): max_dec_frame_buffering */
    UInt32 maxDecodeFrameBuffering_;
};
}
namespace avc {
/**
 * 此类用于序列参数集的编码和解码
 */
class SequenceParameterSet {
public:
    /**
     * 构造函数
     */
    SequenceParameterSet();
    /**
     * 析构函数
     */
    virtual ~SequenceParameterSet();
public:
    /**
     * 获取编码后的字节数
     * @return 编码后的字节数
     */
    UInt32 GetEncodingBytes() const;
    /**
     * 获取画质标识(profile_idc)
     * @see ProfileIndicator
     * @return 画质标识
     */
    UInt8 GetProfileIndicator() const;
    /**
     * 设置画质标识(profile_idc)
     * @see ProfileIndicator
     * @param indicator 画质标识，默认值为ProfileIndicator::BASELINE
     */
    void SetProfileIndicator(UInt8 indicator);
    /**
     * 获取制约条件集标志(constraint_set0_flag, constraint_set1_flag, constraint_set2_flag)
     * @param index 表示对应的画质，0 - Baseline，1 - Main，2 - Extended
     * @return 对应的制约条件集标志
     */
    bool GetConstraintSetFlag(UInt8 index);
    /**
     * 获取制约条件集标志(constraint_set0_flag, constraint_set1_flag, constraint_set2_flag)
     * @param flag 对应的制约条件集标志，默认为{true, true, false}
     * @param index 表示对应的画质，0 - Baseline，1 - Main，2 - Extended
     */
    void SetConstraintSetFlag(bool flag, UInt8 index);
    /**
     * 获取级别标识(level_idc)
     * @see LevelIndicator
     * @return 级别标识
     */
    UInt8 GetLevelIndicator() const;
    /**
     * 设置级别标识(level_idc)
     * @see LevelIndicator
     * @param indicator 级别标识，默认为LevelIndicator::LEVEL_3
     */
    void SetLevelIndicator(UInt8 indicator);
    /**
     * 获取序列参数集标识(seq_parameter_set_id)
     * @note 取值范围为[0,31]
     * @return 序列参数集标识
     */
    UInt32 GetSequenceParameterSetId() const;
    /**
     * 设置序列参数集标识(seq_parameter_set_id)
     * @note 取值范围为[0,31]
     * @param id 序列参数集标识，默认值为0
     */
    void SetSequenceParameterSetId(UInt32 id);
    /**
     * 获取最大帧数的对数(log2_max_frame_num_minus4)
     * @note 取值范围为[4,16]
     * @return 最大帧数的对数
     */
    UInt32 GetLog2MaxFrameNumber() const;
    /**
     * 设置最大帧数的对数(log2_max_frame_num_minus4)
     * @note 取值范围为[4,16]
     * @param log2MaxFrameNumber 最大帧数的对数，默认值为4
     */
    void SetLog2MaxFrameNumber(UInt32 log2MaxFrameNumber);
    /**
     * 获取解码图像顺序的计数方法(pic_order_cnt_type)
     * @note 取值范围为[0,2]
     * @return 解码图像顺序的计数方法
     */
    UInt32 GetPictureOrderCountType() const;
    /**
     * 设置解码图像顺序的计数方法(pic_order_cnt_type)
     * @note 取值范围为[0,2]
     * @param pictureOrderCountType 解码图像顺序的计数方法，默认值为2
     */
    void SetPictureOrderCountType(UInt32 pictureOrderCountType);
    /**
     * 获取图像顺序数解码过程中的变量MaxPicOrderCntLsb的对数(log2_max_pic_order_cnt_lsb_minus4).
     * @note 取值范围为[4,16]
     * @return 图像顺序数解码过程中的变量MaxPicOrderCntLsb的对数
     */
    UInt32 GetLog2MaxPictureOrderCountLsb() const;
    /**
     * 设置图像顺序数解码过程中的变量MaxPicOrderCntLsb的对数(log2_max_pic_order_cnt_lsb_minus4).
     * @note 取值范围为[4,16]
     * @param log2MaxPictureOrderCountLsb 图像顺序数解码过程中的变量MaxPicOrderCntLsb的对数，默认为4
     */
    void SetLog2MaxPictureOrderCountLsb(UInt32 log2MaxPictureOrderCountLsb);
    /**
     * 获取delta_pic_order_cnt是否全为0(delta_pic_order_always_zero_flag)
     * @return delta_pic_order_cnt是否全为0
     */
    bool GetDeltaPictureOrderAlwaysZeroFlag() const;
    /**
     * 设置delta_pic_order_cnt是否全为0(delta_pic_order_always_zero_flag)
     * @param flag delta_pic_order_cnt是否全为0，默认为false
     */
    void SetDeltaPictureOrderAlwaysZeroFlag(bool flag);
    /**
     * 获取用于计算非参考图像的图像顺序号时的偏移量(offset_for_non_ref_pic)
     * @note 取值范围为[-2^31,2^31-1]
     * @return 用于计算非参考图像的图像顺序号时的偏移量
     */
    Int32 GetOffsetForNonReferencePicture() const;
    /**
     * 设置用于计算非参考图像的图像顺序号时的偏移量(offset_for_non_ref_pic)
     * @note 取值范围为[-2^31,2^31-1]
     * @param offset 用于计算非参考图像的图像顺序号时的偏移量，默认值为0
     */
    void SetOffsetForNonReferencePicture(Int32 offset);
    /**
     * 获取用于计算帧的底场图像顺序号时的偏移量(offset_for_top_to_bottom_field)
     * @note 取值范围为[-2^31,2^31-1]
     * @return 用于计算帧的底场图像顺序号时的偏移量
     */
    Int32 GetOffsetForTopToBottomField() const;
    /**
     * 设置用于计算帧的底场图像顺序号时的偏移量(offset_for_top_to_bottom_field)
     * @note 取值范围为[-2^31,2^31-1]
     * @param offset 用于计算帧的底场图像顺序号时的偏移量，默认值为0
     */
    void SetOffsetForTopToBottomField(Int32 offset);
    /**
     * 获取解码过程中的参考帧数目(num_ref_frames_in_pic_order_cnt_cycle)
     * @note 取值范围为[0,255]
     * @return 图像顺序号的解码过程中的参考帧数目
     */
    UInt32 GetNumberReferenceFramesInPictureOrderCountCycle() const;
    /**
     * 设置指定图像顺序号的解码过程中的参考帧数目(num_ref_frames_in_pic_order_cnt_cycle)
     * @note 取值范围为[0,255]
     * @param number 图像顺序号的解码过程中的参考帧数目，默认值为0
     */
    void SetNumberReferenceFramesInPictureOrderCountCycle(UInt32 number);
    /**
     * 获取指定图像顺序号的解码过程中的参考帧偏移量(offset_for_ref_frame)
     * @note 取值范围为[-2^31,2^31-1]
     * @param index 指定索引，此索引小于参考帧数目
     * @return 解码过程中的参考帧偏移量
     */
    Int32 GetOffsetForReferenceFrame(UInt32 index);
    /**
     * 设置指定图像顺序号的解码过程中的参考帧偏移量(offset_for_ref_frame)
     * @note 取值范围为[-2^31,2^31-1]
     * @param offset 解码过程中的参考帧偏移量，默认值为0
     * @param index 指定索引，此索引小于指定图像顺序号的解码过程中的参考帧数目(num_ref_frames_in_pic_order_cnt_cycle)
     */
    void SetOffsetForReferenceFrame(Int32 offset, UInt32 index);
    /**
     * 获取图像帧间预测的解码过程中参考帧的最大数量(num_ref_frames)
     * @note 取值范围为[0,MaxDpbSize]
     * @return 图像帧间预测的解码过程中参考帧的最大数量
     */
    UInt32 GetNumberReferenceFrames() const;
    /**
     * 设置图像帧间预测的解码过程中参考帧的最大数量(num_ref_frames)
     * @note 取值范围为[0,MaxDpbSize]
     * @param number 图像帧间预测的解码过程中参考帧的最大数量，默认值为2
     */
    void SetNumberReferenceFrames(UInt32 number);
    /**
     * 获取是否允许在frame_num值之间存在推测的差异的情况下进行解码过程(gaps_in_frame_num_value_allowed_flag)
     * @return 是否允许在frame_num值之间存在推测的差异的情况下进行解码过程(gaps_in_frame_num_value_allowed_flag)
     */
    bool GetGapsInFrameNumberValueAllowedFlag() const;
    /**
     * 设置是否允许在frame_num值之间存在推测的差异的情况下进行解码过程(gaps_in_frame_num_value_allowed_flag)
     * @param flag 是否允许在frame_num值之间存在推测的差异的情况下进行解码过程(gaps_in_frame_num_value_allowed_flag)，默认为false
     */
    void SetGapsInFrameNumberValueAllowedFlag(bool flag);
    /**
     * 获取以宏块为单元的每个解码图像的宽度(pic_width_in_mbs_minus1)
     * @return 宏块为单元的每个解码图像的宽度
     */
    UInt32 GetPictureWidthInMbs() const;
    /**
     * 设置以宏块为单元的每个解码图像的宽度(pic_width_in_mbs_minus1)
     * @param pictureWidthInMbs 宏块为单元的每个解码图像的宽度，默认是19[320]
     */
    void SetPictureWidthInMbs(UInt32 pictureWidthInMbs);
    /**
     * 获取以条带组映射为单位的一个解码帧或场的高度(pic_height_in_map_units_minus1)
     * @return 以条带组映射为单位的一个解码帧或场的高度
     */
    UInt32 GetPictureHeightInMapUnits() const;
    /**
     * 设置以条带组映射为单位的一个解码帧或场的高度(pic_height_in_map_units_minus1)
     * @param pictureHeightInMapUnits 以条带组映射为单位的一个解码帧或场的高度，默认是14[240]
     */
    void SetPictureHeightInMapUnits(UInt32 pictureHeightInMapUnits);
    /**
     * 获取是否编码视频序列的每个编码图像都是一个仅包含帧宏块的编码帧(frame_mbs_only_flag)
     * @return 是否编码视频序列的每个编码图像都是一个仅包含帧宏块的编码帧
     */
    bool GetFrameMbsOnlyFlag() const;
    /**
     * 设置是否编码视频序列的每个编码图像都是一个仅包含帧宏块的编码帧(frame_mbs_only_flag)
     * @param flag 是否编码视频序列的每个编码图像都是一个仅包含帧宏块的编码帧，默认为true
     */
    void SetFrameMbsOnlyFlag(bool flag);
    /**
     * 获取是否在帧和帧内的场宏块之间可能会有交换(mb_adaptive_frame_field_flag)
     * @return 是否在帧和帧内的场宏块之间可能会有交换
     */
    bool GetMbAdaptiveFrameFieldFlag() const;
    /**
     * 设置是否在帧和帧内的场宏块之间可能会有交换(mb_adaptive_frame_field_flag)
     * @param flag 是否在帧和帧内的场宏块之间可能会有交换，默认为false
     */
    void SetMbAdaptiveFrameFieldFlag(bool flag);
    /**
     * 获取亮度运动矢量的计算过程中使用的方法(direct_8x8_inference_flag)
     * @return 亮度运动矢量的计算过程中使用的方法
     */
    bool GetDirect8x8InferenceFlag() const;
    /**
     * 设置亮度运动矢量的计算过程中使用的方法(direct_8x8_inference_flag)
     * @param flag 亮度运动矢量的计算过程中使用的方法，默认为true
     */
    void SetDirect8x8InferenceFlag(bool flag);
    /**
     * 获取是否存在帧剪切偏移参数(frame_cropping_flag)
     * @return 是否存在帧剪切偏移参数
     */
    bool GetFrameCroppingFlag() const;
    /**
     * 设置是否存在帧剪切偏移参数(frame_cropping_flag)
     * @param flag 是否存在帧剪切偏移参数，默认为false
     */
    void SetFrameCroppingFlag(bool flag);
    /**
     * 获取帧剪切的左偏移量(frame_crop_left_offset)
     * @return 帧剪切的左偏移量
     */
    UInt32 GetFrameCropLeftOffset() const;
    /**
     * 设置帧剪切的左偏移量(frame_crop_left_offset)
     * @param offset 帧剪切的左偏移量，默认为0
     */
    void SetFrameCropLeftOffset(UInt32 offset);
    /**
     * 获取帧剪切的右偏移量(frame_crop_right_offset)
     * @return 帧剪切的右偏移量
     */
    UInt32 GetFrameCropRightOffset() const;
    /**
     * 获取帧剪切的右偏移量(frame_crop_right_offset)
     * @return 帧剪切的右偏移量，默认为0
     */
    void SetFrameCropRightOffset(UInt32 offset);
    /**
     * 获取帧剪切的上偏移量(frame_crop_top_offset)
     * @return 帧剪切的上偏移量
     */
    UInt32 GetFrameCropTopOffset() const;
    /**
     * 获取帧剪切的上偏移量(frame_crop_top_offset)
     * @return 帧剪切的上偏移量，默认为0
     */
    void SetFrameCropTopOffset(UInt32 offset);
    /**
     * 获取帧剪切的下偏移量(frame_crop_bottom_offset)
     * @return 帧剪切的下偏移量
     */
    UInt32 GetFrameCropBottomOffset() const;
    /**
     * 获取帧剪切的下偏移量(frame_crop_bottom_offset)
     * @return 帧剪切的下偏移量，默认为0
     */
    void SetFrameCropBottomOffset(UInt32 offset);
    /**
     * 获取是否存在VUI参数(vui_parameters_present_flag)
     * @return 是否存在VUI参数
     */
    bool GetVuiParameterPresentFlag() const;
    /**
     * 设置是否存在VUI参数(vui_parameters_present_flag)
     * @param flag 是否存在VUI参数，默认为true
     */
    void SetVuiParameterPresentFlag(bool flag);
    /**
     * 获取VUI参数(vui_parameters)
     * @return VUI参数
     */
    VuiParameters &GetVuiParameter();
    /**
     * 获取VUI参数(vui_parameters)
     * @return VUI参数
     */
    const VuiParameters &GetVuiParameter() const;
    /**
     * 编码此序列参数集到指定的缓冲区，缓冲区大小需不小于GetEncodingBytes获取的值
     * @param data 用于保存编码数据
     * @param size data的大小
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(UInt8 *data, UInt32 size) const;
    /**
     * 编码此序列参数集
     * @param encoding 保存编码数据
     * @return 如果编码成功，返回编码后的大小，否则返回size + 1
     */
    UInt32 Encode(std::string &encoding) const;
    /**
     * 从数据中解码此序列参数集，如果数据不足，返回0
     * @param data 此序列参数集的数据
     * @param size data的大小
     * @return 如果解码成功，则返回解码使用的数据长度，否则返回size + 1
     */
    UInt32 Decode(const UInt8 *data, UInt32 size);
    /**
     * 从数据中解码此序列参数集，如果数据不足，返回0
     * @param encoding 此序列参数集的数据
     * @return 如果解码成功，则返回解码使用的数据长度，出错则返回size + 1
     */
    UInt32 Decode(const std::string &encoding);
private:
    /* u(8): profile_idc */
    UInt8 profileIndicator_;
    /**
     * u(1): constraint_set0_flag
     * u(1): constraint_set1_flag
     * u(1): constraint_set2_flag
     */
    bool constraintSetFlag_[3];
    /* u(8): level_idc */
    UInt8 levelIndicator_;
    /* ue(v): seq_parameter_set_id */
    UInt32 sequenceParameterSetId_;
    /* ue(v): log2_max_frame_num_minus4 */
    UInt32 log2MaxFrameNumber_;
    /* ue(v): pic_order_cnt_type */
    UInt32 pictureOrderCountType_;
    /* ue(v): log2_max_pic_order_cnt_lsb_minus4 */
    UInt32 log2MaxPictureOrderCountLsb_;
    /* u(1): delta_pic_order_always_zero_flag */
    bool deltaPictureOrderAlwaysZeroFlag_;
    /* se(v): offset_for_non_ref_pic */
    Int32 offsetForNonReferencePicture_;
    /* se(v): offset_for_top_to_bottom_field */
    Int32 offsetForTopToBottomField_;
    /* ue(v): num_ref_frames_in_pic_order_cnt_cycle */
    UInt32 numberReferenceFramesInPictureOrderCountCycle_;
    /* se(v): offset_for_ref_frame */
    std::vector<Int32> offsetForReferenceFrame_;
    /* ue(v): num_ref_frames */
    UInt32 numberReferenceFrames_;
    /* u(1): gaps_in_frame_num_value_allowed_flag */
    bool gapsInFrameNumberValueAllowedFlag_;
    /* ue(v): pic_width_in_mbs_minus1 */
    UInt32 pictureWidthInMbs_;
    /* ue(v): pic_height_in_map_units_minus1 */
    UInt32 pictureHeightInMapUnits_;
    /* u(1): frame_mbs_only_flag */
    bool frameMbsOnlyFlag_;
    /* u(1): mb_adaptive_frame_field_flag */
    bool mbAdaptiveFrameFieldFlag_;
    /* u(1): direct_8x8_inference_flag */
    bool direct8x8InferenceFlag_;
    /* u(1): frame_cropping_flag */
    bool frameCroppingFlag_;
    /* ue(v): frame_crop_left_offset */
    UInt32 frameCropLeftOffset_;
    /* ue(v): frame_crop_right_offset */
    UInt32 frameCropRightOffset_;
    /* ue(v): frame_crop_top_offset */
    UInt32 frameCropTopOffset_;
    /* ue(v): frame_crop_bottom_offset */
    UInt32 frameCropBottomOffset_;
    /* u(1): vui_parameters_present_flag */
    bool vuiParametersPresentFlag_;
    /* vui_parameters() */
    VuiParameters vuiParameters_;
};
}
#endif /* AVC_API_HPP */
