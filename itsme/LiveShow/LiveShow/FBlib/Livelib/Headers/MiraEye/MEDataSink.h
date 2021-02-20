#import <Foundation/Foundation.h>

#import "MEMediaFormat.h"

@protocol MEDataSink <NSObject>
- (void)write:(MEMediaFormat *)format flags:(int)flags time:(int64_t)time data:(BytePtr)data length:(UInt32)length;
- (void)flush:(MEMediaFormat *)format;
@end
