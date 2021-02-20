#ifndef AMF_API_HPP
#define AMF_API_HPP
namespace amf {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file amf/amf.h
 * @author 喻扬
 */
#include "arc.h"
#endif /* API */
#ifndef AMF_API_HPP
#include "array.hpp"
#include "boolean.hpp"
#include "bytearray.hpp"
#include "data.hpp"
#include "datatype.hpp"
#include "empty.hpp"
#include "encoding.hpp"
#include "export.hpp"
#include "null.hpp"
#include "number.hpp"
#include "object.hpp"
#include "reader.hpp"
#include "string.hpp"
#include "unsupported.hpp"
#include "variant.hpp"
#include "writer.hpp"
#endif /* AMF_API_HPP */
namespace amf {
/**
 * 此类表示AMF的数据。
 */
class Data {
public:
    /**
     * 获取数据类型。
     * @return 数据类型
     */
    virtual UInt8 GetType() const = 0;
    /**
     * 销毁此对象。
     */
    virtual void Dispose() = 0;
    /**
     * 将此对象内容dump到字符串。
     * @return 生成的字符串
     */
    virtual std::string Dump() const = 0;
};
}
namespace amf {
class Variant;
/**
 * 此类表示AMF的数组。
 */
class Array : public Data , public std::vector<Variant> {
public:
    typedef std::vector<Variant> OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造一个空数组。
     */
    Array();
    Array(const Variant &a1);
    Array(const Variant &a1, const Variant &a2);
    Array(const Variant &a1, const Variant &a2, const Variant &a3);
    Array(const Variant &a1, const Variant &a2, const Variant &a3, const Variant &a4);
    Array(const Variant &a1, const Variant &a2, const Variant &a3, const Variant &a4, const Variant &a5);
    Array(const Variant &a1, const Variant &a2, const Variant &a3, const Variant &a4, const Variant &a5, const Variant &a6);
    Array(const Variant &a1, const Variant &a2, const Variant &a3, const Variant &a4, const Variant &a5, const Variant &a6, const Variant &a7);
    Array(const Variant &a1, const Variant &a2, const Variant &a3, const Variant &a4, const Variant &a5, const Variant &a6, const Variant &a7, const Variant &a8);
    Array(const Variant &a1, const Variant &a2, const Variant &a3, const Variant &a4, const Variant &a5, const Variant &a6, const Variant &a7, const Variant &a8, const Variant &a9);
    Array(const Variant &a1, const Variant &a2, const Variant &a3, const Variant &a4, const Variant &a5, const Variant &a6, const Variant &a7, const Variant &a8, const Variant &a9, const Variant &a10);
    /**
     * 析构函数。
     */
    virtual ~Array();
public:
    Variant &operator[](UInt32 index);
    const Variant &operator[](UInt32 index) const;
    /**
     * 从数组末尾读取一个值。
     * @param[out] variant 要读取的值
     * @return 此对象的引用
     */
    Array &operator>>(Variant &value);
    /**
     * 将指定的值追加到数组。
     * @param variant 指定的值
     * @return 此对象的引用
     */
    Array &operator<<(const Variant &value);
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
};
}
namespace amf {
/**
 * 此类表示AMF的布尔值。
 */
class Boolean : public Data {
public:
    typedef bool OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造函数。
     */
    Boolean();
    /**
     * 用指定布尔值构造对象。
     * @param value 指定的布尔值
     */
    Boolean(bool value);
    /**
     * 析构函数。
     */
    virtual ~Boolean();
public:
    /**
     * 将对象转换为布尔值。
     */
    operator bool &();
    /**
     * 将对象转换为布尔值。
     */
    operator const bool &() const;
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
private:
    bool value_;
};
}
namespace amf {
/**
 * 此类表示AMF的字节数组类型。
 */
class ByteArray : public Data, public std::string {
public:
    typedef std::string OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造一个空的字符数组。
     */
    ByteArray();
    /**
     * 根据指定字符串构造对象。
     * @param value 指定字符串
     */
    ByteArray(const std::string &value);
    /**
     * 根据指定字符串构造对象。
     * @param value 指定字符串
     */
    ByteArray(const char *value);
    /**
     * 析构函数。
     */
    virtual ~ByteArray();
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
};
}
namespace amf {
/**
 * AMF的数据类型。
 */
namespace DataType {
    /**
     * AMF的Null类型
     */
    const UInt8 Null = 0x00;
    /**
     * AMF的布尔类型
     */
    const UInt8 Boolean = 0x01;
    /**
     * AMF的数字类型
     */
    const UInt8 Number = 0x02;
    /**
     * AMF的字符串类型
     */
    const UInt8 String = 0x03;
    /**
     * AMF的数组类型
     */
    const UInt8 Array = 0x04;
    /**
     * AMF的对象类型
     */
    const UInt8 Object = 0x05;
    /**
     * AMF的字节数组类型
     */
    const UInt8 ByteArray = 0x06;
    /**
     * AMF的Unsupported类型
     */
    const UInt8 Unsupported = 0x07;
    /**
     * 空类型
     */
    const UInt8 Empty = 0xFF;
}
}
namespace amf {
/**
 * 此类表示空类型，即不代表任何AMF类型。
 */
class Empty : public Data {
public:
    typedef Empty OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造函数。
     */
    Empty();
    /**
     * 析构函数。
     */
    virtual ~Empty();
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
};
}
namespace amf {
class Reader;
class Writer;
/**
 * 此类表示AMF的编码器。
 */
class Encoding {
public:
    /**
     * 空编码类型。
     */
    static const UInt32 None;
    /**
     * AMF0编码类型。
     */
    static const UInt32 AMF0;
    /**
     * AMF3编码类型。
     */
    static const UInt32 AMF3;
public:
    /**
     * 获取编码类型。
     * @return 编码类型
     */
    virtual UInt32 GetType() const = 0;
    /**
     * 创建当前编码的Reader对象。
     * @return 创建的Reader对象，用于当前AMF类型的解码。
     */
    virtual Reader *CreateReader() = 0;
    /**
     * 销毁Reader对象。
     * @param reader 要销毁的Reader对象
     */
    virtual void DisposeReader(Reader *reader) = 0;
    /**
     * 创建当前编码的Writer对象。
     * @return 创建的Writer对象，用于当前AMF类型的编码。
     */
    virtual Writer *CreateWriter() = 0;
    /**
     * 销毁Writer对象。
     * @param writer 要销毁的Writer对象
     */
    virtual void DisposeWriter(Writer *writer) = 0;
};
}
namespace amf {
class Encoding;
/**
 * 获取指定AMF类型的编码器。
 * @param type 指定的AMF类型
 * @return 对应的编码器
 */
extern Encoding *GetEncoding(UInt32 type);
}
namespace amf {
/**
 * 此类表示AMF的Null。
 */
class Null : public Data {
public:
    typedef Null OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造函数。
     */
    Null();
    /**
     * 析构函数。
     */
    virtual ~Null();
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
};
}
namespace amf {
/**
 * 此类表示AMF的Number类型。
 */
class Number : public Data {
public:
    typedef double OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造一个Number。
     */
    Number();
    /**
     * 根据指定的double值构造对象。
     * @param value 指定的double值
     */
    Number(double value);
    /**
     * 析构函数。
     */
    virtual ~Number();
public:
    /**
     * 将对象转换为double值。
     */
    operator double &();
    /**
     * 将对象转换为double值。
     */
    operator const double &() const;
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
private:
    double value_;
};
}
namespace amf {
class Any;
class Data;
/**
 * 此类用于AMF数据的存取。
 * 它可以表示任何AMF数据类型。
 */
class Variant {
public:
    /**
     * 构造函数，初始化为Empty类型。
     */
    Variant();
    /**
     * 拷贝构造函数。注意此处为按引用拷贝。
     * @param other 要拷贝的对象。
     */
    Variant(const Variant &other);
    /**
     * 析构函数。
     */
    virtual ~Variant();
public:
    /**
     * 拷贝Variant。注意此处为按引用拷贝。
     * @param other 要拷贝的对象
     * @return 此对象的引用
     */
    Variant &operator=(const Variant &other);
    Variant &operator=(const Data &data);
    Variant &operator=(void *null);
    Variant &operator=(bool boolean);
    Variant &operator=(Int8 integer);
    Variant &operator=(UInt8 integer);
    Variant &operator=(Int16 integer);
    Variant &operator=(UInt16 integer);
    Variant &operator=(Int32 integer);
    Variant &operator=(UInt32 integer);
    Variant &operator=(Int64 integer);
    Variant &operator=(UInt64 integer);
    Variant &operator=(float number);
    Variant &operator=(double number);
    Variant &operator=(const std::string &text);
    Variant &operator=(const char *text);
    Variant &operator[](const std::string &key);
    const Variant &operator[](const std::string &key) const;
    Variant &operator[](UInt32 index);
    const Variant &operator[](UInt32 index) const;
    Variant &operator>>(Variant &variant);
    Variant &operator<<(const Variant &variant);
public:
    /**
     * 获取此Variant的数据类型。
     * @return 数据类型
     */
    UInt8 GetType() const;
    /**
     * 将Variant转换为指定类型。
     * @param type 指定的数据类型
     * @return 指定类型的值
     */
    Data &As(UInt8 type) const;
    /**
     * 将AMF数据输出成字符串。
     * @return 输出的字符串
     */
    std::string Dump() const;
    /**
     * 将Variant转换为指定类型。
     * @return 指定类型的值
     */
    template <typename T>
    T &As();
    /**
     * 将Variant转换为指定类型。
     * @return 指定类型的值
     */
    template <typename T>
    const T &As() const;
    /**
     * 将Variant转换为指定类型，并返回指定类型的原始值。
     * @return 指定类型的原始值
     */
    template <typename T>
    typename T::OriginType &ValueOf();
    /**
     * 将Variant转换为指定类型，并返回指定类型的原始值。
     * @return 指定类型的原始值
     */
    template <typename T>
    const typename T::OriginType &ValueOf() const;
    /**
     * 判断Variant是否为指定类型。
     * @return 如果Variant为指定的类型，返回true；否则，返回false。
     */
    template <typename T>
    bool Is() const;
private:
    mutable Any *value_;
};
template <typename T>
T &Variant::As() {
    return dynamic_cast<T &>(As(T::Type));
}
template <typename T>
const T &Variant::As() const {
    return dynamic_cast<T &>(As(T::Type));
}
template <typename T>
typename T::OriginType &Variant::ValueOf() {
    T &value = dynamic_cast<T &>(As(T::Type));
    return (typename T::OriginType &) value;
}
template <typename T>
const typename T::OriginType &Variant::ValueOf() const {
    T &value = dynamic_cast<T &>(As(T::Type));
    return (typename T::OriginType &) value;
}
template <typename T>
bool Variant::Is() const {
    return GetType() == T::Type;
}
}
namespace amf {
/**
 * 此类表示AMF的对象。
 */
class Object : public Data, public std::map<std::string, Variant> {
public:
    typedef std::map<std::string, Variant> OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造一个空对象。
     */
    Object();
    /**
     * 析构函数。
     */
    virtual ~Object();
public:
    /**
     * 获取指定Key对应的值。
     * @param key 指定的Key
     * @return Key对应的值
     */
    Variant &operator[](const std::string &key);
    const Variant &operator[](const std::string &key) const;
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
};
}
namespace amf {
class Variant;
/**
 * 此类用于AMF的解码。
 */
class Reader {
public:
    /**
     * 对数据进行解码，并保存得到的AMF数据。
     * @param[out] variant 用来保存解码得到的AMF数据
     * @param reader 包含要解码的数据
     * @return 如果解码成功，则返回true；否则，返回false。
     */
    virtual bool Read(Variant &variant, arc::Reader &reader) = 0;
};
}
namespace amf {
/**
 * 此类表示AMF的字符串类型。
 */
class String : public Data, public std::string {
public:
    typedef std::string OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造一个空字符串。
     */
    String();
    /**
     * 根据指定字符串构造对象。
     * @param value 指定字符串
     */
    String(const std::string &value);
    /**
     * 根据指定字符串构造对象。
     * @param value 指定字符串
     */
    String(const char *value);
    /**
     * 析构函数。
     */
    virtual ~String();
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
};
}
namespace amf {
/**
 * 此类表示AMF中的Unsupport类型。
 */
class Unsupported : public Data {
public:
    typedef Unsupported OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造函数。
     */
    Unsupported();
    /**
     * 析构函数。
     */
    virtual ~Unsupported();
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
    virtual std::string Dump() const;
};
}
namespace amf {
class Variant;
/**
 * 此类用于AMF数据的编码。
 */
class Writer {
public:
    /**
     * 对指定的AMF数据进行编码。
     * @param variant 要编码的AMF数据
     * @param writer 保存编码的输出缓冲区
     * @return 如果编码成功，则返回true；否则，返回false。
     */
    virtual bool Write(const Variant &variant, arc::Writer &writer) = 0;
};
}
#endif /* AMF_API_HPP */
