#ifndef MOPI_API_HPP
#define MOPI_API_HPP
namespace mopi {
    extern const char *MAJOR_VERSION;
    extern const char *MINOR_VERSION;
    extern const char *BUILD_VERSION;
    extern const char *VERSION;
}
#ifndef API
/**
 * @file mopi/mopi.h
 * @author 喻扬
 */
#include <cstdarg>
#include <string>
#endif /* API */
#ifndef MOPI_API_HPP
#include "context.hpp"
#include "contextfactory.hpp"
#include "export.hpp"
#include "filteroption.hpp"
#include "filters.hpp"
#include "filtertype.hpp"
#include "loglevel.hpp"
#endif /* MOPI_API_HPP */
namespace mopi {
class Context {
public:
    virtual void Replace() = 0;
    virtual void Restore() = 0;
    virtual void Release() = 0;
};
}
namespace mopi {
class Context;
class ContextFactory {
public:
    virtual Context *Generate() = 0;
};
}
namespace mopi {
class Context;
class ContextFactory;
class Filters;
typedef void (*Printer)(UInt8 level, const std::string &tag, const std::string &message);
void BindPrinter(Printer printer);
void BindContextFactory(ContextFactory *factory);
/**
 * 创建滤镜链
 *
 * @param width 图像的宽度
 * @param height 图像的高度
 * @param count 要添加的滤镜的个数
 * @param types 要添加的滤镜类型，数组长度由count决定
 * @param context 可以由外部传递GLES的Context，可以扩展OpenGL的渲染管线，注意，GL_TEXTURE1到GL_TEXTURE7为mopi库保留，其中GL_TEXTURE1作为输入，当render为false时，GL_TEXTURE2作为输出
 * @param render 设置是否渲染，如果为true，则会渲染到renderbuffer，并且可以通过Process或者Dequeue获取处理后的数据，否则，会输出到GL_TEXTURE2，并且通过Process和Dequeue获取数据无效
 **/
Filters *CreateFilters(UInt32 width, UInt32 height, UInt32 count, const UInt32 types[], Context *context = NULL, bool render = true);
}
namespace mopi {
/**
 * 滤镜的设置选项类型
 */
namespace FilterOption {
    /**
     * Bilateral 滤镜相关设置选项
     */
    namespace Bilateral {
        /**
         * 设置distance
         * @params distance [double] 颜色差值系数，此值越小，效果越强烈。取值范围[2,10]，默认值为6
         */
        const UInt8 DISTANCE = 0;
        /**
         * 设置此滤镜为水平滤镜
         */
        const UInt8 HORIZONTAL = 1;
        /**
         * 设置此滤镜为垂直滤镜
         */
        const UInt8 VERTICAL = 2;
    }
    /**
     * BlendAlpha 滤镜相关设置选项
     */
    namespace BlendAlpha {
        /**
         * 设置水印的alpha值，即透明度
         * @params alpha [double] 水印的透明度，取值范围[0,1]，默认值为1，即不透明
         */
        const UInt8 ALPHA = 0;
        /**
         * 设置水印图片及摆放位置
         * @params x [UInt32] 水印摆放的橫座标位置
         * @params y [UInt32] 水印摆放的纵座标位置
         * @params width [UInt32] 水印的宽度
         * @params height [UInt32] 水印的高度
         * @params image [UInt8 *] 水印的图片内容
         */
        const UInt8 WATERMARK = 1;
    }
    /**
     * Collage 滤镜相关设置选项
     */
    namespace Collage {
        /**
         * 设置拼接图片的摆放位置
         * @params origin [Int32] 原始图片的顶点位置，0表示原始位置，负数表示左移，正数表示右移
         * @params coverOrigin [Int32] 附加图片的顶点位置，意义同origin
         * @params coverLeft [UInt32] 附加图片的左边位置，附加前会将此位置的左边裁掉
         * @params coverRight [UInt32] 附加图片的右边位置，附加前会将此位置的右边裁掉
         */
        const UInt8 PLACEMENT = 0;
        /**
         * 设置拼接时的附加图片
         * @params width [UInt32] 附加图片的宽度
         * @params height [UInt32] 附加图片的高度
         * @params cover [UInt8 *] 附加图片的内容
         */
        const UInt8 COVER = 1;
    }
    /**
     * Luminance 滤镜相关设置选项
     */
    namespace Luminance {
        /**
         * 设置图片亮度
         * @params brightness [double] 图片亮度，取值范围[0,100]，默认值为50，表示原始亮度
         */
        const UInt8 BRIGHTNESS = 0;
        /**
         * 设置图片对比度
         * @params contrast [double] 图片对比度，取值范围[0,100]，默认值为50，表示原始对比度
         */
        const UInt8 CONTRAST = 1;
    }
    /**
     * GaussianBlur滤镜相关设置选项
     */
    namespace GaussianBlur {
        /**
         * 设置此滤镜为水平滤镜
         */
        const UInt8 HORIZONTAL = 0;
        /**
         * 设置此滤镜为垂直滤镜
         */
        const UInt8 VERTICAL = 1;
        /**
         * 设置此滤镜的半径，值越大越模糊
         */
        const UInt8 RADIUS = 2;
    }
    /**
     * Beautify滤镜相关设置选项
     */
    namespace Beautify {
        /**
         * 设置此滤镜的级别,1~5,值越大越美颜
         */
        const UInt8 LEVEL = 0;
    }
    /**
     * Flip滤镜相关设置选项
     */
    namespace Flip {
        /**
         * 设置此滤镜的垂直翻转
         */
        const UInt8 VERTICAL = 0;
        /**
         * 设置此滤镜的水平翻转
         */
        const UInt8 HORIZONTAL = 1;
    }
}
}
namespace mopi {
class Filters {
public:
    typedef void (*FilterCallback)(UInt32 sequence, void *context);
public:
    virtual void Resize(UInt32 width, UInt32 height) = 0;
    virtual void Add(UInt32 position, UInt32 type) = 0;
    virtual void Remove(UInt32 position) = 0;
    virtual void Enable(UInt32 index, bool enable = true) = 0;
    virtual void SetOption(UInt32 index, UInt8 type, ...) = 0;
    virtual void Process(const UInt8 *input, UInt8 *output) = 0;
    virtual void Enqueue(const UInt8 *input) = 0;
    virtual void Flush(bool wait = true) = 0;
    virtual void Dequeue(UInt8 *input) = 0;
    virtual void Dispose() = 0;
};
}
namespace mopi {
namespace FilterType {
    const UInt8 NO_FILTER = 0;
    const UInt8 BILATERAL_FILTER = 1;
    const UInt8 BLENDALPHA_FILTER = 2;
    const UInt8 RETRO_FILTER = 3;
    const UInt8 LORDKELVIN_FILTER = 4;
    const UInt8 WALDEN_FILTER = 5;
    const UInt8 INKWELL_FILTER = 6;
    const UInt8 NASHVILLE_FILTER = 7;
    const UInt8 COLLAGE_FILTER = 8;
    const UInt8 LUMINANCE_FILTER = 9;
    const UInt8 GAUSSIANBLUR_FILTER = 10;
    const UInt8 BEAUTIFY_FILTER = 11;
    const UInt8 TRANSFORM_FILTER = 12;
    const UInt8 FLIP_FILTER = 13;
}
}
namespace mopi {
namespace LogLevel {
    const UInt8 LOG_DEBUG = 0;
    const UInt8 LOG_INFO = 0;
    const UInt8 LOG_WARNING = 0;
    const UInt8 LOG_ERROR = 0;
    const UInt8 LOG_FATAL = 0;
}
}
#endif /* MOPI_API_HPP */
