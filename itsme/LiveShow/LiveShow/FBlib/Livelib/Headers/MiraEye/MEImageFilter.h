#import <Foundation/Foundation.h>

#import <OpenGLES/EAGL.h>
#import <CoreGraphics/CoreGraphics.h>

typedef NS_ENUM(int, MEImageFilterType) {
    kMEFilterNo,
    kMEFilterBilateral,
    kMEFilterBlendAlpha,
    kMEFilterRetro,
    kMEFilterLordKelvin,
    kMEFilterWalden,
    kMEFilterInkWell,
    kMEFilterNashVille,
    kMEFilterCollage,
    kMEFilterLuminance,
    kMEFilterGaussianBlur,
    kMEFilterBeautify,
    kMEFilterColorSwizzle,
    kMEFilterFlip
};

@interface MEImageFilter : NSObject

- (instancetype)initWithTypes:(const UInt32 *)types count:(int)count size:(CGSize)size;
- (instancetype)initWithContext:(EAGLContext *)context types:(const UInt32 *)types count:(int)count size:(CGSize)size;
- (void)add:(int)position type:(int)type;
- (void)remove:(int)position;
- (void)enable:(int)position;
- (void)disable:(int)position;
- (void)resize:(CGSize)size;
- (void)process:(const UInt8 *)input output:(UInt8 *)output;
- (void)flush;
- (void)setBilateralDistance:(int)index distance:(double)distance;
- (void)setBilateralHorizontal:(int)index;
- (void)setBilateralVertical:(int)index;
- (void)setBlendAlphaAlpha:(int)index alpha:(double)alpha;
- (void)setBlendAlphaWaterMark:(int)index rect:(CGRect)rect watermark:(const UInt8 *)watermark;
- (void)setLuminanceBrightness:(int)index brightness:(double)brightness;
- (void)setLuminanceContrast:(int)index contrast:(double)contrast;
- (void)setBeautifyLevel:(int)index level:(int)level;

@end
