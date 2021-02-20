#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "MEDataSink.h"
#import "MEMediaFormat.h"

typedef NS_ENUM(int, MEMediaEncoderType) {
    kMEAVVideoEncoder,
    kMEAVAudioEncoder,
    kMEATAudioEncoder
};

typedef NS_OPTIONS(int, MEMediaEncoderFlag) {
    kMEEncoderFlagConfigFrame = 1,
    kMEEncoderFlagKeyFrame = 2,
    kMEEncoderFlagEndOfStream = 4,
    kMEEncoderFlagVideo = 8,
    kMEEncoderFlagAudio = 16,
};

extern const NSString *kMEAVEncoderUseHwaccel;
extern const NSString *kMEAVEncoderThreadCount;
extern const NSString *kMEAVEncoderBitrate;

@interface MEMediaEncoder : NSObject

+ (OSType)pixelFormatForType:(MEMediaEncoderType)type format:(MEMediaFormat)format attributes:(NSDictionary *)attributes;
+ (MEMediaEncoder *)encoderWithType:(MEMediaEncoderType)type format:(MEMediaFormat)format attributes:(NSDictionary *)attributes sink:(id<MEDataSink>)sink;

- (BOOL)prepare;
- (BOOL)setParameters:(NSDictionary *)params;
- (void)write:(CMSampleBufferRef)sampleBuffer;
- (void)flush;
- (void)dispose;

@end
