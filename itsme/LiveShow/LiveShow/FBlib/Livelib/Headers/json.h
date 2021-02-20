#ifndef JSON_API_HPP
#define JSON_API_HPP
namespace json {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API

typedef char                    Int8;
typedef short                   Int16;
typedef int                     Int32;
typedef long long               Int64;

/**
 * @file json/json.h
 * @author 喻扬
 */
#include <map>
#include <string>
#include <vector>
#endif /* API */
#ifndef JSON_API_HPP
#include "array.hpp"
#include "boolean.hpp"
#include "empty.hpp"
#include "null.hpp"
#include "number.hpp"
#include "object.hpp"
#include "string.hpp"
#include "value.hpp"
#include "variant.hpp"
#endif /* JSON_API_HPP */
namespace json {
/**
 * 此类表示json的数据。
 */
class Value {
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
};
}
namespace json {
class Variant;
/**
 * 此类表示json的数组。
 */
class Array : public Value {
public:
    typedef Array OriginType;
public:
    static const UInt8 Type;
public:
    /**
     * 构造一个空数组。
     */
    Array();
    /**
     * 析构函数。
     */
    virtual ~Array();
public:
    /**
     * 从另一对象拷贝数组。
     * @param other 要拷贝的对象
     * @return 此对象的引用
     */
    Array &operator=(const Array &other);
public:
    /**
     * 返回数组中的值的个数。
     * @return 数组中的值的数目
     */
    UInt32 Count() const;
    /**
     * 获取指定索引对应的值。
     * @param index 指定的索引
     * @return index对应的值
     */
    Variant &operator[](UInt32 index);
    /**
     * 获取指定索引对应的值。
     * @param index 指定的索引
     * @return index对应的值
     */
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
private:
    typedef std::vector<Variant> Values;
private:
     mutable Values values_;
};
}
namespace json {
/**
 * 此类表示json的布尔值。
 */
class Boolean : public Value {
public:
    static const UInt8 Type;
public:
    typedef bool OriginType;
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
    virtual~Boolean();
public:
    /**
     * 将对象转换为布尔值。
     */
    operator OriginType &();
    /**
     * 将对象转换为布尔值。
     */
    operator const OriginType &() const;
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
private:
    bool value_;
};
}
namespace json {
/**
 * 此类表示空类型，即不代表任何json类型。
 */
class Empty : public Value {
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
};
}
namespace json {
/**
 * 此类表示json的Null。
 */
class Null : public Value {
public:
    static const UInt8 Type;
public:
    typedef Null OriginType;
public:
    /**
     * 构造函数。
     */
    Null();
    /**
     * 析构函数。
     */
    virtual~Null();
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
};
}
namespace json {
/**
 * 此类表示json的Number类型。
 */
class Number : public Value {
public:
    static const UInt8 Type;
public:
    typedef double OriginType;
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
    virtual~Number();
public:
    /**
     * 将对象转换为double值。
     */
    operator OriginType &();
    /**
     * 将对象转换为double值。
     */
    operator const OriginType &() const;
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
private:
    double value_;
};
}
namespace json {
class Any;
class Value;
/**
 * 此类用于JSON数据的存取、解析等。
 * 它可以表示任何JSON数据类型。
 */
class Variant {
public:
    /**
     * 构造函数，初始化为Null类型。
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
    /**
     * 将此Variant赋值为Null。
     * @param null null指针
     * @return 此对象的引用
     */
    Variant &operator=(void *null);
    /**
     * 将此Variant赋值为布尔值。
     * @param boolean 指定的布尔值
     * @return 此对象的引用
     */
    Variant &operator=(bool boolean);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(Int8 integer);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(UInt8 integer);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(Int16 integer);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(UInt16 integer);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(Int32 integer);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(UInt32 integer);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(Int64 integer);
    /**
     * 将此Variant赋值为整数。
     * @param integer 指定的整数值
     * @return 此对象的引用
     */
    Variant &operator=(UInt64 integer);
    /**
     * 将此Variant赋值为浮点值。
     * @param boolean 指定的浮点值
     * @return 此对象的引用
     */
    Variant &operator=(float number);
    /**
     * 将此Variant赋值为double值。
     * @param number 指定的double值
     * @return 此对象的引用
     */
    Variant &operator=(double number);
    /**
     * 将此Variant赋值为字符串。
     * @param text 指定的字符串
     * @return 此对象的引用
     */
    Variant &operator=(const std::string &text);
    /**
     * 将此Variant赋值为字符串。
     * @param boolean 布尔值
     * @return 此对象的引用
     */
    Variant &operator=(const char *text);
    /**
     * 将此Variant转换为Object，并获取指定Key对应的值。
     * @param key 指定的Key
     * @return Key对应的值
     */
    Variant &operator[](const std::string &key);
    /**
     * 将此Variant转换为Array，并获取指定索引对应的值。
     * @param index 指定的索引
     * @return index对应的值
     */
    Variant &operator[](UInt32 index);
    /**
     * 将此Variant转换为Array，并从数组开头读取一个值。
     * @param[out] variant 要读取的值
     * @return 此对象的引用
     */
    Variant &operator>>(Variant &variant);
    /**
     * 将此Variant转换为Array，并将指定的值追加到数组。
     * @param variant 指定的值
     * @return 此对象的引用
     */
    Variant &operator<<(const Variant &variant);
    /**
     * 将此Variant转换为Object，并获取指定Key对应的值。
     * @param key 指定的Key
     * @return Key对应的值
     */
    const Variant &operator[](const std::string &key) const;
    /**
     * 将此Variant转换为Array，并获取指定索引对应的值。
     * @param index 指定的索引
     * @return index对应的值
     */
    const Variant &operator[](UInt32 index) const;
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
    Value &As(UInt8 type) const;
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
public:
    /**
     * 将Variant输出为json字符串。
     * @return json字符串
     */
    std::string ToString() const;
    /**
     * 将Variant编码为json字符串。
     * @param data 保存编码后的字符串
     * @return 如果编码成功，则返回true；否则，返回false。
     */
    bool Encode(std::string &data) const;
    /**
     * 将json字符串解码为Variant。
     * @param data json字符串
     * @return 如果解码成功，则返回true；否则，返回false。
     */
    bool Decode(const std::string &data);
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
    return (const typename T::OriginType &) value;
}
template <typename T>
bool Variant::Is() const {
    return GetType() == T::Type;
}
}
namespace json {
/**
 * 此类表示json的对象。
 */
class Object : public Value {
public:
    typedef Object OriginType;
    typedef std::map<std::string, Variant> Values;
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
    /**
     * 获取指定Key对应的值。
     * @param key 指定的Key
     * @return Key对应的值
     */
    const Variant &operator[](const std::string &key) const;
public:
    /**
     * 获取此对象内部的Map。
     * @param 此对象内部的Map
     */
    Values &GetValues();
    /**
     * 获取此对象内部的Map。
     * @param 此对象内部的Map
     */
    const Values &GetValues() const;
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
private:
     mutable Values values_;
};
}
namespace json {
/**
 * 此类表示json的字符串类型。
 */
class String : public Value {
public:
    static const UInt8 Type;
public:
    typedef std::string OriginType;
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
    String(const char* value);
    /**
     * 析构函数。
     */
    virtual ~String();
public:
    /**
     * 将对象转换为字符串值。
     */
    operator OriginType &();
    /**
     * 将对象转换为字符串值。
     */
    operator const OriginType &() const;
public:
    virtual UInt8 GetType() const;
    virtual void Dispose();
private:
    std::string value_;
};
}
#endif /* JSON_API_HPP */
