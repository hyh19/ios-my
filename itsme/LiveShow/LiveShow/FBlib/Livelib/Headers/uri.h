#ifndef URI_API_HPP
#define URI_API_HPP
namespace uri {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file uri/uri.h
 * @author 喻扬
 */
#include <iostream>
#include <list>
#include <string>
#include <vector>
#endif /* API */
#ifndef URI_API_HPP
#include "authority.hpp"
#include "domainname.hpp"
#include "export.hpp"
#include "fragment.hpp"
#include "hosttype.hpp"
#include "ipaddress.hpp"
#include "ipv6address.hpp"
#include "parsable.hpp"
#include "path.hpp"
#include "printable.hpp"
#include "query.hpp"
#include "scheme.hpp"
#include "uri.hpp"
#endif /* URI_API_HPP */
namespace uri {
class Parsable {
public:
    virtual bool Parse(std::string::const_iterator &from, std::string::const_iterator to, void *arg = NULL) = 0;
    virtual bool Parse(const std::string &text, void *arg = NULL) = 0;
};
}
namespace uri {
class Printable {
public:
    virtual void Print(std::ostream &stream) const = 0;
    virtual std::string Print() const = 0;
};
std::ostream &operator<<(std::ostream &stream, const Printable &printable);
}
namespace uri {
class Authority : public Printable, public Parsable {
public:
    Authority();
    virtual ~Authority();
public:
    bool IsEmpty() const;
    bool IsNull() const;
    const std::string &GetHost() const;
    UInt8 GetHostType() const;
    UInt16 GetPort() const;
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &from, std::string::const_iterator to, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    UInt8 hostType_;
    std::string host_;
    UInt16 port_;
};
}
namespace uri {
class DomainName : public Printable, public Parsable {
public:
    DomainName();
    virtual ~DomainName();
public:
    DomainName operator+(const DomainName &rhs) const;
    DomainName &operator+=(const DomainName &rhs);
public:
    bool IsNull() const;
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &first, std::string::const_iterator last, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    std::string string_;
};
}
namespace uri {
std::string UrlEncode(const std::string &input);
std::string UrlDecode(const std::string &input);
}
namespace uri {
class Fragment : public Printable, public Parsable {
public:
    Fragment();
    virtual ~Fragment();
public:
    bool IsEmpty() const;
    bool IsNull() const;
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &first, std::string::const_iterator last, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    std::string string_;
};
}
namespace uri {
namespace HostType {
    const UInt8 NONE = 0x00;
    const UInt8 DOMAIN_NAME = 0x01;
    const UInt8 IP_ADDRESS = 0x02;
    const UInt8 IPV6_ADDRESS = 0x03;
}
}
namespace uri {
class IpAddress : public Printable, public Parsable {
public:
    IpAddress();
    virtual ~IpAddress();
public:
    bool IsNull() const;
    UInt32 GetIp() const;
    void SetIp(UInt32 value);
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &first, std::string::const_iterator last, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    UInt8 octets_[4];
};
}
namespace uri {
class Ipv6Address : public Printable, public Parsable {
public:
    Ipv6Address();
    virtual ~Ipv6Address();
public:
    bool IsNull() const;
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    bool Parse(std::string::const_iterator &from, std::string::const_iterator to, void *arg = NULL);
    bool Parse(const std::string &text, void *arg = NULL);
private:
    bool Parse(std::string::const_iterator &from, std::string::const_iterator to, UInt16 &value);
private:
    UInt16 hextets_[8];
};
}
namespace uri {
class Path : public Printable, public Parsable {
public:
    typedef std::list<std::string> Segments;
    typedef Segments::const_iterator Iterator;
public:
    Path();
    virtual ~Path();
public:
    bool operator==(const Path &rhs) const;
    bool operator!=(const Path &rhs) const;
    bool operator<(const Path &rhs) const;
    Path operator+(const std::string &rhs) const;
    Path operator+(const Path &rhs) const;
    Path &operator+=(const std::string &rhs);
    Path &operator+=(const Path &rhs);
public:
    bool IsEmpty() const;
    bool IsAbsolute() const;
    void IsAbsolute(bool absolute);
    bool IsDirectory() const;
    void IsDirectory(bool directory);
    Iterator Begin() const;
    Iterator End() const;
    const std::string &Front() const;
    const std::string &Back() const;
    void PopFront();
    bool PopBack(const Path &back);
    void Clear();
    UInt32 Depth() const;
    bool MatchPrefix(const Path &rhs) const;
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &first, std::string::const_iterator last, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    bool absolute_;
    bool directory_;
    Segments segments_;
};
}
namespace uri {
class Query : public Printable , public Parsable {
public:
    typedef std::pair<std::string, std::string> KeyValue;
    typedef std::vector<KeyValue> Params;
public:
    Query();
    virtual ~Query();
public:
    bool IsEmpty() const;
    UInt32 Count() const;
    bool Sorted() const;
    void Sort();
    std::string Find(const std::string &key) const;
    void Append(const std::string &key, const std::string &value);
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &first, std::string::const_iterator last, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    bool sorted_;
    Params params_;
};
}
namespace uri {
class Scheme : public Printable, public Parsable {
public:
    Scheme();
    virtual ~Scheme();
public:
    bool IsEmpty() const;
    bool IsNull() const;
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &first, std::string::const_iterator last, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    std::string string_;
};
}
namespace uri {
class Uri : public Printable, public Parsable {
public:
    Uri();
    virtual ~Uri();
public:
    bool IsEmpty() const;
    bool IsNull() const;
    bool IsRelative() const;
    const Scheme &GetScheme() const;
    Scheme &GetScheme();
    const Authority &GetAuthority() const;
    Authority &GetAuthority();
    const Path &GetPath() const;
    Path &GetPath();
    const Query &GetQuery() const;
    Query &GetQuery();
    const Fragment &GetFragment() const;
    Fragment &GetFragment();
public:
    virtual void Print(std::ostream &stream) const;
    virtual std::string Print() const;
public:
    virtual bool Parse(std::string::const_iterator &first, std::string::const_iterator last, void *arg = NULL);
    virtual bool Parse(const std::string &text, void *arg = NULL);
private:
    Scheme scheme_;
    Authority authority_;
    Path path_;
    Query query_;
    Fragment fragment_;
};
}
#endif /* URI_API_HPP */
