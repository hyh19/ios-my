//
//  KFH264Encoder.m
//  Kickflip
//
//  Created by Christopher Ballinger on 2/11/14.
//  Copyright (c) 2014 Kickflip. All rights reserved.
//

#import "KFH264Encoder.h"
#import "AVEncoder.h"
#import "NALUnit.h"
#import "KFVideoFrame.h"
#import "flv.h"
#import "json.h"
#import "avc.h"

#import "FBLibLog.h"

@interface KFH264Encoder()
@property (nonatomic, strong) AVEncoder* encoder;
@property (nonatomic, strong) NSData *naluStartCode;
@property (nonatomic, strong) NSMutableData *videoSPSandPPS;
@property (nonatomic) CMTimeScale timescale;
@property (nonatomic, strong) NSMutableArray *orphanedFrames;
@property (nonatomic, strong) NSMutableArray *orphanedSEIFrames;
@property (nonatomic) CMTime lastPTS;

@property (nonatomic) UInt64 timeBegin; //记录初始时间，用于计算时间戳
@property (nonatomic, strong) NSData* videoSpecific; //音频信息
@property (nonatomic, strong) NSMutableData *videoSPS;
@property (nonatomic, strong) NSMutableData *videoPPS;


@end

@implementation KFH264Encoder

- (void) dealloc {
    [_encoder shutdown];
}

- (instancetype) initWithBitrate:(NSUInteger)bitrate width:(int)width height:(int)height {
    if (self = [super initWithBitrate:bitrate]) {
        
        [self initializeNALUnitStartCode];
        _lastPTS = kCMTimeInvalid;
        _timescale = 0;
        self.orphanedFrames = [NSMutableArray arrayWithCapacity:2];
        self.orphanedSEIFrames = [NSMutableArray arrayWithCapacity:2];
        _encoder = [AVEncoder encoderForHeight:height andWidth:width bitrate:bitrate];
        
        __weak typeof(self)wSelf = self;
        [_encoder encodeWithBlock:^int(NSArray* dataArray, CMTimeValue ptsValue) {
            [wSelf incomingVideoFrames:dataArray ptsValue:ptsValue];
            return 0;
        } onParams:^int(NSData *data) {
            return 0;
        }];
    }
    return self;
}

- (void) initializeNALUnitStartCode {
    NSUInteger naluLength = 4;
    uint8_t *nalu = (uint8_t*)malloc(naluLength * sizeof(uint8_t));
    nalu[0] = 0x00;
    nalu[1] = 0x00;
    nalu[2] = 0x00;
    nalu[3] = 0x01;
    _naluStartCode = [NSData dataWithBytesNoCopy:nalu length:naluLength freeWhenDone:YES];
}

- (void) setBitrate:(NSUInteger)bitrate {
    [super setBitrate:bitrate];
    _encoder.bitrate = self.bitrate;
}

- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer tranformImg:(CGImageRef)img {
    CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (!_timescale) {
        _timescale = pts.timescale;
    }
    [_encoder encodeFrame:sampleBuffer tranformImg:img];
}

-(CVPixelBufferPoolRef)getBufferPool
{
    return nil;
}

- (void) generateSPSandPPS {
    NSData* config = _encoder.getConfigData;
    if (!config) {
        return;
    }
    avcCHeader avcC((const BYTE*)[config bytes], [config length]);
    SeqParamSet seqParams;
    seqParams.Parse(avcC.sps());
    
    NSData* spsData = [NSData dataWithBytes:avcC.sps()->Start() length:avcC.sps()->Length()];
    NSData *ppsData = [NSData dataWithBytes:avcC.pps()->Start() length:avcC.pps()->Length()];
    
    _videoSPSandPPS = [NSMutableData dataWithCapacity:avcC.sps()->Length() + avcC.pps()->Length() + _naluStartCode.length * 2];
    [_videoSPSandPPS appendData:_naluStartCode];
    [_videoSPSandPPS appendData:spsData];
    [_videoSPSandPPS appendData:_naluStartCode];
    [_videoSPSandPPS appendData:ppsData];
    
    
    //FIX_ME(add by chenfanshun)
    //sps
    _videoSPS = [NSMutableData dataWithCapacity:avcC.sps()->Length() + _naluStartCode.length];
    [_videoSPS appendData:_naluStartCode];
    [_videoSPS appendData:spsData];
    
    //pps
    _videoPPS = [NSMutableData dataWithCapacity:avcC.pps()->Length() + _naluStartCode.length];
    [_videoPPS appendData:_naluStartCode];
    [_videoPPS appendData:ppsData];
}

- (void) addOrphanedFramesFromArray:(NSArray*)frames {
    for (NSData *data in frames) {
        unsigned char* pNal = (unsigned char*)[data bytes];
        int idc = pNal[0] & 0x60;
        int naltype = pNal[0] & 0x1f;
        if (idc == 0 && naltype == 6) { // SEI
            FBLIBLOG(@"Orphaned SEI frame: idc(%d) naltype(%d) size(%lu)", idc, naltype, (unsigned long)data.length);
            [self.orphanedSEIFrames addObject:data];
        } else {
            FBLIBLOG(@"Orphaned frame: lastPTS:(%lld) idc(%d) naltype(%d) size(%lu)", _lastPTS.value, idc, naltype, (unsigned long)data.length);
            [self.orphanedFrames addObject:data];
        }
    }
}

- (void) writeVideoFrames:(NSArray*)frames pts:(CMTime)pts {
    NSMutableArray *totalFrames = [NSMutableArray array];
    if (self.orphanedSEIFrames.count > 0) {
        [totalFrames addObjectsFromArray:self.orphanedSEIFrames];
        [self.orphanedSEIFrames removeAllObjects];
    }
    [totalFrames addObjectsFromArray:frames];
    
    NSMutableData *aggregateFrameData = [NSMutableData data];
    NSData *sei = nil; // Supplemental enhancement information
    BOOL hasKeyframe = NO;
    
    for (NSData *data in totalFrames) {
        unsigned char* pNal = (unsigned char*)[data bytes];
        int idc = pNal[0] & 0x60;
        int naltype = pNal[0] & 0x1f;
        NSData *videoData = nil;
        
        if (idc == 0 && naltype == 6) { // SEI
            sei = data;
            continue;
        } else if (naltype == 5) { // IDR
            hasKeyframe = YES;
            NSMutableData *IDRData = [NSMutableData dataWithData:_videoSPSandPPS];
            if (sei) {
                [IDRData appendData:_naluStartCode];
                [IDRData appendData:sei];
                sei = nil;
            }
            [IDRData appendData:_naluStartCode];
            [IDRData appendData:data];
            videoData = IDRData;
        } else {
            NSMutableData *regularData = [NSMutableData dataWithData:_naluStartCode];
            [regularData appendData:data];
            videoData = regularData;
        }
        [aggregateFrameData appendData:videoData];
    }
    
    if(0 == _timeBegin){
        _timeBegin = pts.value;
    }
    
    UInt32 timeStamp = (UInt32)((pts.value - _timeBegin)/(pts.timescale/1000));
    //先填充视频信息
    if(nil == _videoSpecific) {
        [self praseVideoSpecific:aggregateFrameData time:timeStamp];
    } else {
        if(hasKeyframe) {
            [self onOutPutH264Data:_videoSpecific isKeyFrame:YES isSequence:YES time:timeStamp];
        }
        
        NSData* resultData = [self makeSampleFromData:aggregateFrameData];
        [self onOutPutH264Data:resultData isKeyFrame:hasKeyframe isSequence:NO time:timeStamp];
    }
}

-(NSData*)makeSampleFromData:(NSData*)data
{
    //h264
    char* bytes = (char*)[data bytes];
    std::string h264(bytes, data.length);
    
    avc::ByteStream stream;
    stream.Decode(h264, YES);
    
    avc::Sample sample(4);
    while (stream.GetNaluCount()) {
        std::string nalu;
        stream.PopNalu(nalu);
        sample.PutNalu(nalu);
    }
    
    std::string strResult;
    sample.Encode(strResult);
    
    NSData* resultData = [NSData dataWithBytes:strResult.c_str() length:strResult.length()];
    return resultData;
}

-(void)praseVideoSpecific:(NSData*)data time:(UInt32)timeStamp
{
    std::string sps((char*)[_videoSPS bytes], _videoSPS.length);
    std::string pps((char*)[_videoPPS bytes], _videoPPS.length);
    
    avc::ByteStream spsStream;
    spsStream.Decode(sps, YES);
    UInt32 nSpsNal = spsStream.GetNaluCount();
    
    avc::ByteStream ppsStream;
    ppsStream.Decode(pps, YES);
    UInt32 nPpsNal = ppsStream.GetNaluCount();
    
    std::string spsDecode;
    std::string ppsDecode;
    
    if(nSpsNal) {
       spsStream.PopNalu(spsDecode);
    }
    
    if(nPpsNal) {
        ppsStream.PopNalu(ppsDecode);
    }
    
    if(0 == spsDecode.length() || 0 == ppsDecode.length()) {
        return;
    }
    
    avc::DecoderConfigurationRecord record;
    record.SetConfigurationVersion(1);
    record.SetProfileIndicator(spsDecode[1] & 0xFF);
    record.SetProfileCompatibility(spsDecode[2] & 0xFF);
    record.SetLevelIndicator(sps[3] & 0xFF);
    record.SetLengthSize(4);
    record.PutPictureParameterSet(ppsDecode);
    record.PutSequenceParameterSet(spsDecode);
    
    std::string recordEncode;
    record.Encode(recordEncode);
    _videoSpecific = [NSData dataWithBytes:recordEncode.c_str() length:recordEncode.length()];
}

-(void)onOutPutH264Data:(NSData*)data isKeyFrame:(BOOL)bKeyFrame isSequence:(BOOL)bSequence time:(UInt32)timeStamp
{
    //h264
    char* bytes = (char*)[data bytes];
    std::string h264(bytes, data.length);

    //to flv
    flv::VideoData videoData;
    UInt8 frameType;
    if (bKeyFrame) {
        frameType = flv::VideoFrameType::AVC_KEY_FRAME;
    } else {
        frameType = flv::VideoFrameType::AVC_INTER_FRAME;
    }
    videoData.GetHeader().SetFrameType(frameType);
    videoData.GetHeader().SetCodecId(flv::VideoCodecId::AVC);
    videoData.GetHeader().SetAvcPacketType(bSequence ? flv::AvcPacketType::AVC_SEQUENCE_HEADER :
                                           flv::AvcPacketType::AVC_NALU);
    videoData.GetHeader().SetCompositionTime(0);
    videoData.SetBody(h264);
    
    std::string video;
    videoData.Encode(video);
    
    //tag只用于本地测试，最终传输要传data
//    flv::Tag tag(flv::TagType::VIDEO, timeStamp, video);
//    std::string outputData;
//    tag.Encode(outputData);
//    NSData* resultData = [NSData dataWithBytes:outputData.c_str() length:outputData.length()];
    
    NSData* resultData = [NSData dataWithBytes:video.c_str() length:video.length()];
    dispatch_async(self.callbackQueue, ^{
        [self.delegate encoder:self encodedData:resultData time:timeStamp];
    });
}

- (void) incomingVideoFrames:(NSArray*)frames ptsValue:(CMTimeValue)ptsValue {
    if (ptsValue == 0) {
        [self addOrphanedFramesFromArray:frames];
        return;
    }
    if (!_videoSPSandPPS) {
        [self generateSPSandPPS];
    }
    CMTime pts = CMTimeMake(ptsValue, _timescale);
    if (self.orphanedFrames.count > 0) {
        CMTime ptsDiff = CMTimeSubtract(pts, _lastPTS);
        NSUInteger orphanedFramesCount = self.orphanedFrames.count;
        FBLIBLOG(@"lastPTS before first orphaned frame: %lld", _lastPTS.value);
        for (NSData *frame in self.orphanedFrames) {
            CMTime fakePTSDiff = CMTimeMultiplyByFloat64(ptsDiff, 1.0/(orphanedFramesCount + 1));
            CMTime fakePTS = CMTimeAdd(_lastPTS, fakePTSDiff);
            FBLIBLOG(@"orphan frame fakePTS: %lld", fakePTS.value);
            [self writeVideoFrames:@[frame] pts:fakePTS];
        }
        FBLIBLOG(@"pts after orphaned frame: %lld", pts.value);
        [self.orphanedFrames removeAllObjects];
    }
    
    [self writeVideoFrames:frames pts:pts];
    _lastPTS = pts;
}


@end
