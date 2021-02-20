#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int bitrate;
    int samplerate;
    int channels;
    CGSize dimension;
    int framerate;
    int keyframeInterval;
} MEMediaFormat;

MEMediaFormat MEMediaFormatMakeVideo(int bitrate, CGSize dimension, int framerate, int keyframeInterval);
MEMediaFormat MEMediaFormatMakeAudio(int bitrate, int samplerate, int channels);
    
#ifdef __cplusplus
}
#endif