#import <Foundation/Foundation.h>

#import "MEDataSink.h"

#import "MEFlvHeader.h"
#import "MEFlvTagHeader.h"
#import "MEFlvVideoDataHeader.h"
#import "MEFlvAudioDataHeader.h"

@protocol MEFlvDataSinkOutput <NSObject>
- (void)onHeader:(MEFlvHeader *)header;
- (void)onVideoTag:(MEFlvTagHeader *)tagHeader dataHeader:(MEFlvVideoDataHeader *)dataHeader tagData:(NSData *)tagData;
- (void)onAudioTag:(MEFlvTagHeader *)tagHeader dataHeader:(MEFlvAudioDataHeader *)dataHeader tagData:(NSData *)tagData;
- (void)onComplete;
@end

@interface MEFlvDataSink : NSObject<MEDataSink>
- (id)initWithOutput:(id<MEFlvDataSinkOutput>)output audio:(BOOL)audio video:(BOOL)video;
- (void)write:(MEMediaFormat *)format flags:(int)flags time:(int64_t)time data:(BytePtr)data length:(UInt32)length;
- (void)flush:(MEMediaFormat *)format;
@end
