#import <UIKit/UIKit.h>

#import <CoreVideo/CoreVideo.h>

@class MEImageFilter;

@interface MEVideoView : UIControl <NSCoding>

- (void)prepare;
- (void)clear;
- (void)render:(CVPixelBufferRef)pixels;

@property(nonatomic,retain) MEImageFilter *filters;
@property(nonatomic) CGSize dimension;
@property(nonatomic) BOOL flipHorizontal;
@property(nonatomic) BOOL flipVertical;
@property(nonatomic) BOOL rotate;
@property(nonatomic) BOOL displayFlipHorizontal;
@property(nonatomic) BOOL displayFlipVertical;
@property(nonatomic) OSType inputFormat;
@property(nonatomic) OSType outputFormat;
@property(nonatomic) CVPixelBufferRef pixels;

@end
