//
//  FBFilters.m
//  LiveShow
//
//  Created by chenfanshun on 29/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBFilters.h"
#import "FBContextManager.h"
#import "mopi.h"

const int QUEUE_COUNT = 3;

@interface FBFilters()

{
    mopi::Filters*     filters[QUEUE_COUNT];
}

@property(nonatomic, strong)NSMutableArray* queuces;
@property(nonatomic, strong)CIContext* coreImageContext;

@property(nonatomic, assign)NSInteger       index;

@property(nonatomic, assign)CGFloat         width;
@property(nonatomic, assign)CGFloat         height;

@property(nonatomic, weak)id<FBFilterResult> delegate;

@end

@implementation FBFilters

-(id)initWithWitdh:(CGFloat)width andHeight:(CGFloat)height delegate:(id<FBFilterResult>)delegate
{
    if(self = [super init]) {
        _width = width;
        _height = height;
        _delegate = delegate;
        
        //4条线程队列
        self.queuces = [[NSMutableArray alloc] initWithCapacity:QUEUE_COUNT];
        for(NSInteger i = 0; i < QUEUE_COUNT; i++)
        {
            NSString* quName = [NSString stringWithFormat:@"filtersqueue%d", i];
            dispatch_queue_t qu = dispatch_queue_create([quName UTF8String], DISPATCH_QUEUE_SERIAL);
            dispatch_set_target_queue(qu, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ));
            [self.queuces addObject:qu];
            
            filters[i] = NULL;
        }
        
        _index = 0;
        _coreImageContext = [FBContextManager sharedInstance].ciContext;
    }
    return self;
}

-(void)dealloc
{
//
}

-(void)enque:(UInt8*)rgbaData sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    NSInteger count = self.queuces.count;
    if(_index < count) {
        NSInteger theIndex = _index;
        dispatch_queue_t qu = self.queuces[theIndex];
        _index++;
        _index %= count;
        __weak typeof(self)wSelf = self;
        dispatch_async(qu, ^{
            @autoreleasepool {
                if(rgbaData) {
                    //开始美颜
                    mopi::Filters* filter = [wSelf getFilterFromIndex:theIndex];
                    //NSInteger length = rect.size.width*rect.size.height*4;
                    //放到静态变量，一次分配？
                    //UInt8 *output = (UInt8*)malloc(length*sizeof(UInt8));
                    //filter->Process(rgbaData, output);
                    //filter->Dequeue(output);
                    filter->Enqueue(rgbaData);
                    filter->Flush();
                    //NSData* dateOut = [[NSData alloc] initWithBytes:output length:length];
                    //free(output);
                    //free(rgbaData);
                    
                    
//                    int bitmapBytesPerRow   = (rect.size.width * 4);
//                    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
//                    CIImage* desImg = [CIImage imageWithBitmapData:dateOut bytesPerRow:bitmapBytesPerRow size:rect.size format:kCIFormatRGBA8 colorSpace:colorSpace];
//                    CGColorSpaceRelease( colorSpace );
//                    
//                    [wSelf onFinish:desImg sampleBuffer:sampleBuffer];
                    [wSelf onFinish:filter sampleBuffer:sampleBuffer];
                }
            }
        });
    }
}

-(void)onFinish:(mopi::Filters*)filter sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    NSInteger length = _width*_height*4;
    UInt8 *output = (UInt8*)malloc(length*sizeof(UInt8));
    filter->Dequeue(output);
    
    NSData* dateOut = [[NSData alloc] initWithBytes:output length:length];
    free(output);
    
    int bitmapBytesPerRow   = (_width * 4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CIImage* desImg = [CIImage imageWithBitmapData:dateOut bytesPerRow:bitmapBytesPerRow size:CGSizeMake(_width, _height) format:kCIFormatRGBA8 colorSpace:colorSpace];
    CGColorSpaceRelease( colorSpace );

    if(self.delegate) {
        [self.delegate onFinish:desImg sampleBuffer:sampleBuffer];
    }
//    __weak typeof(self)wSelf = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if(wSelf.delegate) {
//            [wSelf.delegate onFinish:destImg sampleBuffer:sampleBuffer];
//        }
//    });
}

-(mopi::Filters*)getFilterFromIndex:(NSInteger)index
{
    if(index < QUEUE_COUNT) {
        mopi::Filters* filter = filters[index];
        if(NULL == filter) {
            UInt32 type[2];
            type[0] = mopi::FilterType::BILATERAL_FILTER;
            type[1] = mopi::FilterType::BILATERAL_FILTER;
            filter = mopi::CreateFilters(_width, _height, 2, type);
            filter->SetOption(0, mopi::FilterOption::Bilateral::HORIZONTAL);
            filter->SetOption(1, mopi::FilterOption::Bilateral::VERTICAL);
            filter->SetOption(0, mopi::FilterOption::Bilateral::DISTANCE, (double) 10);
            filter->SetOption(1, mopi::FilterOption::Bilateral::DISTANCE, (double) 10);
            filters[index] = filter;
        }
        return filter;
    }
    return NULL;
}

/***  转换成rgba数据 */
-(void*)manipulateImagePixelData:(CGImageRef)inImage
{
    // Create the bitmap context
    CGContextRef cgctx = [self CreateRGBABitmapContext:inImage]; //CreateARGBBitmapContext(inImage);
    if (cgctx == NULL)
    {
        // error creating context
        return NULL;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{static_cast<CGFloat>(w),static_cast<CGFloat>(h)}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    void *data = CGBitmapContextGetData (cgctx);
    
    // When finished, release the context
    CGContextRelease(cgctx);
    return data;
}

-(CGContextRef)CreateRGBABitmapContext:(CGImageRef )inImage
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    if (colorSpace == NULL)
    {
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
