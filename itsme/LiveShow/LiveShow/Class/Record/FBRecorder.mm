//
//  FBRecorder.m
//  CaptureTestDemo
//
//  Created by chenfanshun on 01/03/16.
//  Copyright © 2016年 chenfanshun. All rights reserved.
//

#import "FBRecorder.h"

#import "FBCaptureVideoCoordinator.h"
#import "FBCaptureAudioCoordinator.h"
//#import "FBSoupOpenLiveServie.h"
#import "FBRtmpOpenLiveService.h"

#import "CoreImageView.h"
#import "FBContextManager.h"

//#import "KFH264Encoder.h"
#import "KFAACEncoder.h"

#import "mopi.h"

#import "FBWritFileStream.h"

#import "UIDevice+HardwareName.h"


#define VIDEO_HEIGHT    640
#define VIDEO_WIDTH     368


typedef NS_ENUM(NSInteger, RecordingStatus)
{
    RecordingStatusIdle = 0,
    RecordingStatusRecording,
};

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface FBRecorder()<FBCaptureDataComingDelegate, FBRtmpOpenLiveServiceDelegate, KFEncoderDelegate>

{
    mopi::Filters*      _beautyFilters;
    UInt8*              _beautyBuffer;
}

@property(nonatomic, strong)AVCaptureSession*   captureSession;

@property (nonatomic, strong)dispatch_queue_t sessionQueue;

@property(nonatomic, strong)FBCaptureAudioCoordinator*  audioCoordinator;
@property(nonatomic, strong)FBCaptureVideoCoordinator*  videoCoordinator;

@property(nonatomic, strong)CIContext * coreImageContext;
@property(nonatomic, strong)CoreImageView * preView;

@property(nonatomic, assign)RecordingStatus    recordStatus;

@property(nonatomic, strong)FBRtmpOpenLiveService*   protolService;

@property(nonatomic, strong)KFH264Encoder*          h264Encoder;       //视频编码
@property(nonatomic, strong)KFAACEncoder*           aacEncoder;        //音频编码

@property(nonatomic, assign)BOOL                    isFontCamera;     //是否前置摄像头

@property(nonatomic, assign)BOOL                    useBeauty;        //是否使用美颜功能

//for test
@property(nonatomic, assign)BOOL                    isTestRecoringFile; //把flv写到文件
@property(nonatomic, strong)FBWritFileStream*       writeStream;
@property (nonatomic, strong)dispatch_queue_t       writeQueue;

@end

@implementation FBRecorder

-(id)init
{
    if(self = [super init]) {
        [self configCaptureSession];
        [self setupEncoder];
        
        //暂时iphone6以上才开启美颜
        NSUInteger type = [[UIDevice currentDevice] platformType];
        if(type >= UIDevice6iPhone && type <= UIDevice6SPlusiPhone) {
            _useBeauty = NO;
        } else {
            _useBeauty = NO;
        }
        
        _isTestRecoringFile = NO;
        
        _beautyFilters = NULL;
        _beautyBuffer = NULL;
//        _writeStream = [[FBWritFileStream alloc] initWithPath:@"test.flv"];
//        _writeQueue = dispatch_queue_create("write_queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)dealloc
{
    if(_beautyBuffer) {
        free(_beautyBuffer);
        _beautyBuffer = NULL;
    }
    
    if(_beautyFilters) {
        _beautyFilters->Dispose();
        _beautyFilters = NULL;
    }
    _captureSession = nil;
    _sessionQueue = nil;
    _writeQueue = nil;
    NSLog(@"FBRecorder dealloc...");
}

/**
 *  配置session
 */
-(void)configCaptureSession
{
    if(nil == _captureSession) {
        //create queues
        _sessionQueue = dispatch_queue_create("session_queue", DISPATCH_QUEUE_SERIAL);
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession beginConfiguration];
        //        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetMedium]) { // 设置分辨率
        //            _captureSession.sessionPreset = AVCaptureSessionPresetMedium;
        //        }
        _audioCoordinator = [[FBCaptureAudioCoordinator alloc] initWithDelegate:self];
        [_audioCoordinator setUpCoordinatorWithSession:_captureSession];
        
        _videoCoordinator = [[FBCaptureVideoCoordinator alloc] initWithDelegate:self];
        [_videoCoordinator setUpCoordinatorWithSession:_captureSession];
        _isFontCamera = YES;
        
        [_captureSession commitConfiguration];
        
        [[AVAudioSession sharedInstance] setPreferredSampleRate:44100 error:nil];
        
        _recordStatus = RecordingStatusIdle;
    }
    
    dispatch_async(_sessionQueue, ^{
        [self initImageContext];
    });
}

/**
 *  设置编码
 */
-(void)setupEncoder
{
    int audioSampleRate = 44100;
    int videoHeight = VIDEO_HEIGHT;
    int videoWidth = VIDEO_WIDTH;
    int audioBitrate = 32 * 1000; // 32 Kbps
    int videoBitrate = 512*1000; // 512kbps
    _h264Encoder = [[KFH264Encoder alloc] initWithBitrate:videoBitrate width:videoWidth height:videoHeight];
    _h264Encoder.delegate = self;
    
    _aacEncoder = [[KFAACEncoder alloc] initWithBitrate:audioBitrate sampleRate:audioSampleRate channels:1];
    _aacEncoder.delegate = self;
    _aacEncoder.addADTSHeader = YES;
}

- (void)initImageContext {
    _coreImageContext = [FBContextManager sharedInstance].ciContext;
}

-(void)startPreview
{
    dispatch_async(_sessionQueue, ^{
        [_captureSession startRunning];
    });
}

-(void)stopPreview
{
    @synchronized(self) {
        [_audioCoordinator releaseDelegate];
        [_videoCoordinator releaseDelegate];
        
        [_preView removeFromSuperview];
        _preView = nil;
        
        dispatch_async(_sessionQueue, ^{
            [_captureSession stopRunning];
        });
    }
}

-(void)startRecord
{
    @synchronized(self) {
        _isTestRecoringFile = YES;
    }
}

-(void)stopRecord
{
    @synchronized(self) {
        _isTestRecoringFile = NO;
        [_writeStream closeFile];
    }
}

-(void)startWithUrl:(NSString*)url andToken:(NSString*)token
{
    if(nil == _protolService) {
        _protolService = [[FBRtmpOpenLiveService alloc] initWithUrl:url andToken:token];
        _protolService.delegate = self;
        [_protolService start];
    }
}

-(void)stopOpenLive
{
    if(_protolService) {
        [_protolService stop];
        _protolService.delegate = nil;
        _protolService = nil;
    }
}

#define RECORD_FILE 0

#pragma mark - 视频编码成功后的通知
- (void)encoder:(KFEncoder*)encoder encodedData:(NSData*)data time:(UInt32)timeStamp
{
#if RECORD_FILE
    if(_isTestRecoringFile) {
        dispatch_async(_writeQueue, ^{
            [_writeStream writeDataToFile:data];
        });
    }
#else
    if(RecordingStatusRecording == _recordStatus) {
        if(_h264Encoder == encoder) {
            [_protolService sendVideoTimeStamp:timeStamp withData:data andLeftTime:0];
            NSLog(@"send video: %zd", data.length);
        } else if(_aacEncoder == encoder) {
            [_protolService sendAudioTimeStamp:timeStamp withData:data andLeftTime:0];
            NSLog(@"send audio: %zd", data.length);
        }
    }
#endif
}

#pragma mark - 视频音频数据通知
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection mediaType:(NSString*)type
{
    if(AVMediaTypeVideo == type) { //视频
        @synchronized(self) {
            //NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
            CIImage* preImage = [self getPreImageFromSampleBuffer:sampleBuffer];
            //NSTimeInterval timeCount = [[NSDate date] timeIntervalSince1970] - timeBegin;
            //NSLog(@"time use: %.3f", timeCount);

            [_preView updateImage:preImage];
#if RECORD_FILE
            if(_isTestRecoringFile) {
                CGImageRef ref = [_coreImageContext createCGImage:transFromImage fromRect:[transFromImage extent]];
                
                [_h264Encoder encodeSampleBuffer:sampleBuffer tranformImg:ref];
                
                CFRelease(ref);
            }
            
#else
            if(RecordingStatusRecording == _recordStatus) {
                
                @autoreleasepool {
                    //缩放
                    CGRect preRect = [preImage extent];
                    CGAffineTransform transFormScale = CGAffineTransformMakeScale(VIDEO_WIDTH/CGRectGetWidth(preRect), VIDEO_HEIGHT/CGRectGetHeight(preRect));
                    //平移
                    CGAffineTransform transFormTranslate = CGAffineTransformMakeTranslation(VIDEO_WIDTH, VIDEO_HEIGHT);
                    //合并
                    CGAffineTransform tansFormResult = CGAffineTransformConcat(transFormScale, transFormTranslate);
                    
                    CIImage * transFromImage = [preImage imageByApplyingTransform:tansFormResult];
                    
                    CGImageRef ref = [_coreImageContext createCGImage:transFromImage fromRect:[transFromImage extent]];
                    //转换成flv并发送
                    [_h264Encoder encodeSampleBuffer:sampleBuffer tranformImg:ref];
                    
                    CFRelease(ref);
                }
            }
#endif
        }
    } else {
#if RECORD_FILE
        if(_isTestRecoringFile) {
            [_aacEncoder encodeSampleBuffer:sampleBuffer tranformImg:nil];
        }
#else
        if(RecordingStatusRecording == _recordStatus) {
            //转换成flv并发送
            [_aacEncoder encodeSampleBuffer:sampleBuffer tranformImg:nil];
        }
#endif
    }
}

-(CIImage*)getPreImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef imgBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage* soucreImage = [CIImage imageWithCVPixelBuffer:imgBuffer];
    
    CGAffineTransform transForm;
    if(_isFontCamera) { //前置摄像头
        transForm = CGAffineTransformMakeScale(-1, 1); // 先左右对调
        transForm = CGAffineTransformRotate(transForm, -M_PI_2); // 再旋转90度
    } else { //后置摄像头
        transForm = CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    //预览
    CIImage* preImage = [soucreImage imageByApplyingTransform:transForm];
    if(_useBeauty) {
        preImage = [self getBeautyImage:preImage];
    }

    return preImage;
}

-(CIImage*)getBeautyImage:(CIImage*)source
{
    CIImage *beautyImg = source;
    @autoreleasepool {
        CGRect rect = [source extent];
        CGImageRef ref = [_coreImageContext createCGImage:source fromRect:rect];
        //rgba数据
        UInt8* rgbaData = (UInt8*)[self manipulateImagePixelData:ref];
        if(rgbaData) {
            //NSTimeInterval timeBegin = [[NSDate date] timeIntervalSince1970];
            //开始美颜
            mopi::Filters* filter = [self getBeautyFilterWithWidth:rect.size.width andHeight:rect.size.height];
            NSInteger length = rect.size.width*rect.size.height*4;
            UInt8 *output = [self getBeautyBufferWithLength:length];
            filter->Process(rgbaData, output);
            
            //NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] - timeBegin;
            //NSLog(@"time use: %.3f", interval);
            /*filter->Dequeue(output);
            filter->Enqueue(rgbaData);
             filter->Flush();*/
            NSData* dateOut = [[NSData alloc] initWithBytes:output length:length];
            free(rgbaData);
            
            int bitmapBytesPerRow   = (rect.size.width * 4);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            beautyImg = [CIImage imageWithBitmapData:dateOut bytesPerRow:bitmapBytesPerRow size:rect.size format:kCIFormatRGBA8 colorSpace:colorSpace];
            CGColorSpaceRelease( colorSpace );
        }
        CFRelease(ref);
    }
    
    return beautyImg;
}

-(UInt8*)getBeautyBufferWithLength:(NSInteger)length
{
    if(NULL == _beautyBuffer) {
        _beautyBuffer = (UInt8*)malloc(length*sizeof(UInt8));
    }
    return _beautyBuffer;
}

-(mopi::Filters*)getBeautyFilterWithWidth:(CGFloat)width andHeight:(CGFloat)height
{
    if(NULL == _beautyFilters) {
        UInt32 type[1];
        type[0] = mopi::FilterType::BEAUTIFY_FILTER;
        _beautyFilters = mopi::CreateFilters(width, height, 1, type);
        _beautyFilters->SetOption(0, mopi::FilterOption::Beautify::LEVEL, 5);
//        UInt32 type[2];
//        type[0] = mopi::FilterType::BILATERAL_FILTER;
//        type[1] = mopi::FilterType::BILATERAL_FILTER;
//        _beautyFilters = mopi::CreateFilters(width, height, 2, type);
//        _beautyFilters->SetOption(0, mopi::FilterOption::Bilateral::HORIZONTAL);
//        _beautyFilters->SetOption(1, mopi::FilterOption::Bilateral::VERTICAL);
//        _beautyFilters->SetOption(0, mopi::FilterOption::Bilateral::DISTANCE, (double) 10);
//        _beautyFilters->SetOption(1, mopi::FilterOption::Bilateral::DISTANCE, (double) 10);
    }
    return _beautyFilters;
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



/** 过滤*/
- (NSArray *)filtersName {
    return @[
             // @"CIColorInvert", // 反色
             // @"CIPhotoEffectMono", // 单色
             @"CIPhotoEffectChrome",
             @"CIPhotoEffectInstant", // 自然
             @"CIPhotoEffectTransfer", // 怀旧
             @"CISepiaTone", // 老照片
             ];
}

//- (CIFilter *)filter {
//    if (_filter == nil) {
//        _filter = [CIFilter filterWithName:[self filtersName][0]];
//    }
//    return _filter;
//}

#pragma mark - 视频预览图
-(UIView* )getPreView
{
    if(nil == _preView) {
        _preView = [[CoreImageView alloc] initWithFrame:CGRectZero];
    }
    return _preView;
}

-(UIImage*)getLastFrame
{
    CIImage* iImage = [_preView getLastFrame];
    if(iImage) {
        CIContext *context = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [context createCGImage:iImage fromRect:[iImage extent]];
        
        UIImage* uiImage = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        return uiImage;
    }
    return nil;
}

#pragma mark - 开播状态通知
-(void)onOpenLiveConnected
{
    @synchronized(self) {
        self.recordStatus = RecordingStatusRecording;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
          [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenLiveConnected object:nil];
    });
}

-(void)onOpenLiveClosed
{
    @synchronized(self) {
        self.recordStatus = RecordingStatusIdle;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOpenLiveClosed object:nil];
    });
}

/**
 *  设置闪光灯
 *
 *  @param flashMode 闪光灯模式（AVCaptureFlashModeOff/AVCaptureFlashModeOn）
 */
-(void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
        AVCaptureTorchMode torchMode;
        if(AVCaptureFlashModeOff == flashMode) {
            torchMode = AVCaptureTorchModeOff;
        } else if(AVCaptureFlashModeOn == flashMode) {
            torchMode = AVCaptureTorchModeOn;
        } else {
            torchMode = AVCaptureTorchModeAuto;
        }
        if([captureDevice isTorchModeSupported:torchMode]) {
            [captureDevice setTorchMode:torchMode];
        }
    }];
}

/**
 *  切换摄像头（默认为前置）
 */
-(void)changeCamera
{
    AVCaptureDevice * currentDevice = [_videoCoordinator.cameraDeviceInput device];
    AVCaptureDevicePosition currentPosition=[currentDevice position];
    
    AVCaptureDevice * toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    BOOL isFont = YES;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition=AVCaptureDevicePositionBack;
        isFont = NO;
    }
    toChangeDevice = [_videoCoordinator getCameraDeviceWithPosition:toChangePosition];
    
    // 获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:toChangeDevice error:nil];
    
    // 改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [_captureSession beginConfiguration];
    // 移除原有输入对象
    [_captureSession removeInput:_videoCoordinator.cameraDeviceInput];
    // 添加新的输入对象
    if ([_captureSession canAddInput:toChangeDeviceInput]) {
        [_captureSession addInput:toChangeDeviceInput];
        _videoCoordinator.cameraDeviceInput = toChangeDeviceInput;
    }
    // 提交会话配置
    [_captureSession commitConfiguration];

    //小延迟一下
    dispatch_async(dispatch_get_main_queue(), ^{
        _isFontCamera = isFont;
    });
}

-(void)enableBeauty:(BOOL)useBeauty
{
    @synchronized(self) {
        _useBeauty = useBeauty;
    }
}

-(BOOL)isUsingBeauty
{
    return _useBeauty;
}

/**
 *  改变设备属性的操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    //_videoCoordinator getCameraDevice
    AVCaptureDevice * captureDevice = [_videoCoordinator.cameraDeviceInput device];
    NSError * error;
    // 改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}

@end

