//
//  KFAACEncoder.m
//  Kickflip
//
//  Created by Christopher Ballinger on 12/18/13.
//  Copyright (c) 2013 Christopher Ballinger. All rights reserved.
//
//  http://stackoverflow.com/questions/10817036/can-i-use-avcapturesession-to-encode-an-aac-stream-to-memory

#import "KFAACEncoder.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "FBLibLog.h"
#import "KFFrame.h"
#import "flv.h"

#import "FBLiveStreamNetworkManager.h"

#define CONFIG_COUNT_DOWN   20

@interface KFAACEncoder()
@property (nonatomic) AudioConverterRef audioConverter;
@property (nonatomic) uint8_t *aacBuffer;
@property (nonatomic) NSUInteger aacBufferSize;
@property (nonatomic) char *pcmBuffer;
@property (nonatomic) size_t pcmBufferSize;
@property (nonatomic) UInt64 timeBegin; //记录初始时间，用于计算时间戳
@property (nonatomic, strong) NSData* audioSpecific; //音频信息
@property (nonatomic) BOOL  hasAddSpecific;
@property (nonatomic, assign) NSInteger configCount;

@end

@implementation KFAACEncoder

- (void) dealloc {
    AudioConverterDispose(_audioConverter);
    free(_aacBuffer);
}

- (instancetype) initWithBitrate:(NSUInteger)bitrate sampleRate:(NSUInteger)sampleRate channels:(NSUInteger)channels {
    if (self = [super initWithBitrate:bitrate sampleRate:sampleRate channels:channels]) {
        self.encoderQueue = dispatch_queue_create("KF Encoder Queue", DISPATCH_QUEUE_SERIAL);
        _audioConverter = NULL;
        _pcmBufferSize = 0;
        _pcmBuffer = NULL;
        _aacBufferSize = 1024;
        _addADTSHeader = NO;
        _aacBuffer = (uint8_t *)malloc(_aacBufferSize * sizeof(uint8_t));
        memset(_aacBuffer, 0, _aacBufferSize);
        
        _timeBegin = 0;
        _configCount = 0;
        _audioSpecific = nil;
    }
    return self;
}

-(NSString*) formatASBD: (AudioStreamBasicDescription) asbd {
    
    char formatIDString[5];
    UInt32 formatID = CFSwapInt32HostToBig (asbd.mFormatID);
    bcopy (&formatID, formatIDString, 4);
    formatIDString[4] = '\0';
    
    NSMutableString* flag = [[NSMutableString alloc] init];
    if(asbd.mFormatFlags & kAudioFormatFlagIsFloat)
        [flag appendFormat:@"kAudioFormatFlagIsFloat|"];
    if(asbd.mFormatFlags & kAudioFormatFlagIsSignedInteger)
        [flag appendFormat:@"kAudioFormatFlagIsSignedInteger|"];
    if(asbd.mFormatFlags & kAudioFormatFlagIsNonInterleaved)
        [flag appendFormat:@"kAudioFormatFlagIsNonInterleaved|"];
    if(asbd.mFormatFlags & kAudioFormatFlagIsBigEndian)
        [flag appendFormat:@"kAudioFormatFlagIsBigEndian|"];
    if(asbd.mFormatFlags & kAudioFormatFlagIsPacked)
        [flag appendFormat:@"kAudioFormatFlagIsPacked|"];
    if(asbd.mFormatFlags & kAudioFormatFlagIsAlignedHigh)
        [flag appendFormat:@"kAudioFormatFlagIsAlignedHigh|"];
    if(asbd.mFormatFlags & kAudioFormatFlagIsNonMixable)
        [flag appendFormat:@"kAudioFormatFlagIsNonMixable"];
    
    
    
    NSMutableString* format = [[NSMutableString alloc] init];
    [format appendFormat:@"    Sample Rate:         %10.0f\n",  asbd.mSampleRate];
    [format appendFormat:@"    Format ID:           %10s\n",    formatIDString];
    [format appendFormat:@"    Format Flags:        %10u(%@)\n",  (unsigned int)asbd.mFormatFlags,flag];
    [format appendFormat:@"    Bytes per Packet:    %10u\n",    (unsigned int)asbd.mBytesPerPacket];
    [format appendFormat:@"    Frames per Packet:   %10u\n",    (unsigned int)asbd.mFramesPerPacket];
    [format appendFormat:@"    Bytes per Frame:     %10u\n",    (unsigned int)asbd.mBytesPerFrame];
    [format appendFormat:@"    Channels per Frame:  %10u\n",    (unsigned int)asbd.mChannelsPerFrame];
    [format appendFormat:@"    Bits per Channel:    %10u\n",    (unsigned int)asbd.mBitsPerChannel];
    return format;
}

- (void) setupAACEncoderFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    AudioStreamBasicDescription inAudioStreamBasicDescription = *CMAudioFormatDescriptionGetStreamBasicDescription((CMAudioFormatDescriptionRef)CMSampleBufferGetFormatDescription(sampleBuffer));
    
    NSString* audiodDescription = [self formatASBD:inAudioStreamBasicDescription];
    
    [[FBLiveStreamNetworkManager sharedInstance] reportDataLog:audiodDescription success:^(id result) {
        NSLog(@"success audiodescription log");
    } failure:^(NSString *errorString) {
        NSLog(@"failure audiodescription log");
    } finally:^{
        
    }];
    
    AudioStreamBasicDescription outAudioStreamBasicDescription = {0}; // Always initialize the fields of a new audio stream basic description structure to zero, as shown here: ...
    
    // The number of frames per second of the data in the stream, when the stream is played at normal speed. For compressed formats, this field indicates the number of frames per second of equivalent decompressed data. The mSampleRate field must be nonzero, except when this structure is used in a listing of supported formats (see “kAudioStreamAnyRate”).
    if (self.sampleRate != 0) {
        outAudioStreamBasicDescription.mSampleRate = self.sampleRate;
    } else {
        outAudioStreamBasicDescription.mSampleRate = inAudioStreamBasicDescription.mSampleRate;

    }
    outAudioStreamBasicDescription.mFormatID = kAudioFormatMPEG4AAC; // kAudioFormatMPEG4AAC_HE does not work. Can't find `AudioClassDescription`. `mFormatFlags` is set to 0.
    outAudioStreamBasicDescription.mFormatFlags = kMPEG4Object_AAC_LC; // Format-specific flags to specify details of the format. Set to 0 to indicate no format flags. See “Audio Data Format Identifiers” for the flags that apply to each format.
    outAudioStreamBasicDescription.mBytesPerPacket = 0; // The number of bytes in a packet of audio data. To indicate variable packet size, set this field to 0. For a format that uses variable packet size, specify the size of each packet using an AudioStreamPacketDescription structure.
    outAudioStreamBasicDescription.mFramesPerPacket = 1024; // The number of frames in a packet of audio data. For uncompressed audio, the value is 1. For variable bit-rate formats, the value is a larger fixed number, such as 1024 for AAC. For formats with a variable number of frames per packet, such as Ogg Vorbis, set this field to 0.
    outAudioStreamBasicDescription.mBytesPerFrame = 0; // The number of bytes from the start of one frame to the start of the next frame in an audio buffer. Set this field to 0 for compressed formats. ...
    
    // The number of channels in each frame of audio data. This value must be nonzero.
    if (self.channels != 0) {
        outAudioStreamBasicDescription.mChannelsPerFrame = inAudioStreamBasicDescription.mChannelsPerFrame;
    } else {
        outAudioStreamBasicDescription.mChannelsPerFrame = self.channels;
    }
    
    outAudioStreamBasicDescription.mBitsPerChannel = 0; // ... Set this field to 0 for compressed formats.
    outAudioStreamBasicDescription.mReserved = 0; // Pads the structure out to force an even 8-byte alignment. Must be set to 0.
    AudioClassDescription *description = [self
                                          getAudioClassDescriptionWithType:kAudioFormatMPEG4AAC
                                          fromManufacturer:kAppleSoftwareAudioCodecManufacturer];

    OSStatus status = AudioConverterNewSpecific(&inAudioStreamBasicDescription, &outAudioStreamBasicDescription, 1, description, &_audioConverter);
    if (status != 0) {
        FBLIBLOG(@"setup converter: %d", (int)status);
    }
    
    if (self.bitrate != 0) {
        UInt32 ulBitRate = (UInt32)self.bitrate;
        UInt32 ulSize = sizeof(ulBitRate);
        AudioConverterSetProperty(_audioConverter, kAudioConverterEncodeBitRate, ulSize, & ulBitRate);
    }
}

- (AudioClassDescription *)getAudioClassDescriptionWithType:(UInt32)type
                                           fromManufacturer:(UInt32)manufacturer
{
    static AudioClassDescription desc;
    
    UInt32 encoderSpecifier = type;
    OSStatus st;
    
    UInt32 size;
    st = AudioFormatGetPropertyInfo(kAudioFormatProperty_Encoders,
                                    sizeof(encoderSpecifier),
                                    &encoderSpecifier,
                                    &size);
    if (st) {
        NSLog(@"error getting audio format propery info: %d", (int)(st));
        return nil;
    }
    
    unsigned int count = size / sizeof(AudioClassDescription);
    AudioClassDescription descriptions[count];
    st = AudioFormatGetProperty(kAudioFormatProperty_Encoders,
                                sizeof(encoderSpecifier),
                                &encoderSpecifier,
                                &size,
                                descriptions);
    if (st) {
        NSLog(@"error getting audio format propery: %d", (int)(st));
        return nil;
    }
    
    for (unsigned int i = 0; i < count; i++) {
        if ((type == descriptions[i].mSubType) &&
            (manufacturer == descriptions[i].mManufacturer)) {
            memcpy(&desc, &(descriptions[i]), sizeof(desc));
            return &desc;
        }
    }
    
    return nil;
}

static OSStatus inInputDataProc(AudioConverterRef inAudioConverter, UInt32 *ioNumberDataPackets, AudioBufferList *ioData, AudioStreamPacketDescription **outDataPacketDescription, void *inUserData)
{
    KFAACEncoder *encoder = (__bridge KFAACEncoder *)(inUserData);
    UInt32 requestedPackets = *ioNumberDataPackets;
    //NSLog(@"Number of packets requested: %d", (unsigned int)requestedPackets);
    size_t copiedSamples = [encoder copyPCMSamplesIntoBuffer:ioData];
    if (copiedSamples < requestedPackets) {
        //NSLog(@"PCM buffer isn't full enough!");
        *ioNumberDataPackets = 0;
        return -1;
    }
    *ioNumberDataPackets = 1;
    //NSLog(@"Copied %zu samples into ioData", copiedSamples);
    return noErr;
}

- (size_t) copyPCMSamplesIntoBuffer:(AudioBufferList*)ioData {
    size_t originalBufferSize = _pcmBufferSize;
    if (!originalBufferSize) {
        return 0;
    }
    ioData->mBuffers[0].mData = _pcmBuffer;
    ioData->mBuffers[0].mDataByteSize = _pcmBufferSize;
    _pcmBuffer = NULL;
    _pcmBufferSize = 0;
    return originalBufferSize;
}


- (void) encodeSampleBuffer:(CMSampleBufferRef)sampleBuffer tranformImg:(CGImageRef)img{
    CFRetain(sampleBuffer);
    dispatch_async(self.encoderQueue, ^{
        if (!_audioConverter) {
            [self setupAACEncoderFromSampleBuffer:sampleBuffer];
        }
        CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
        CFRetain(blockBuffer);
        OSStatus status = CMBlockBufferGetDataPointer(blockBuffer, 0, NULL, &_pcmBufferSize, &_pcmBuffer);
        NSError *error = nil;
        if (status != kCMBlockBufferNoErr) {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        //NSLog(@"PCM Buffer Size: %zu", _pcmBufferSize);
        
        memset(_aacBuffer, 0, _aacBufferSize);
        AudioBufferList outAudioBufferList = {0};
        outAudioBufferList.mNumberBuffers = 1;
        outAudioBufferList.mBuffers[0].mNumberChannels = 1;
        outAudioBufferList.mBuffers[0].mDataByteSize = _aacBufferSize;
        outAudioBufferList.mBuffers[0].mData = _aacBuffer;
        AudioStreamPacketDescription *outPacketDescription = NULL;
        UInt32 ioOutputDataPacketSize = 1;
        status = AudioConverterFillComplexBuffer(_audioConverter, inInputDataProc, (__bridge void *)(self), &ioOutputDataPacketSize, &outAudioBufferList, outPacketDescription);
        //NSLog(@"ioOutputDataPacketSize: %d", (unsigned int)ioOutputDataPacketSize);
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        //记录开始时间
        if(0 == _timeBegin) {
            _timeBegin = pts.value;
        }

        NSData *data = nil;
        if (status == 0) {
            NSData *rawAAC = [NSData dataWithBytes:outAudioBufferList.mBuffers[0].mData length:outAudioBufferList.mBuffers[0].mDataByteSize];
            if (_addADTSHeader) {
                NSData *adtsHeader = [self adtsDataForPacketLength:rawAAC.length];
                NSMutableData *fullData = [NSMutableData dataWithData:adtsHeader];
                [fullData appendData:rawAAC];
                data = fullData;
            } else {
                data = rawAAC;
            }
        } else {
            error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
        }
        
        if(nil == _audioSpecific) {
            //音频配置信息
            _audioSpecific = [self GetAudioConfigSpecific];
        } else {
            UInt32 timeStamp = (UInt32)((pts.value - _timeBegin)/(pts.timescale/1000));
            
            //sequence header
            [self onOuptAACSequenceHeader:_audioSpecific time:timeStamp];
            
            //raw data
            [self onOutputAACData:data isRaw:YES time:timeStamp];
        }
        
        CFRelease(sampleBuffer);
        CFRelease(blockBuffer);
   });
}

-(NSData*)GetAudioConfigSpecific
{
    NSData* adts = [self adtsDataForPacketLength:0];
    std::string header((char*)adts.bytes, adts.length);

    //将adts里面的信息编成2位
    int profile = ((header[2]&0xc0)>>6)+1;
    int sample_rate = (header[2]&0x3c)>>2;
    int channel = ((header[2]&0x1)<<2)|((header[3]&0xc0)>>6);
    int config1 = (profile<<3)|((sample_rate&0xe)>>1);
    int config2 = ((sample_rate&0x1)<<7)|(channel<<3);
    
    char bytes[2];
    bytes[0] = config1;
    bytes[1] = config2;
    return [NSData dataWithBytes:bytes length:2];
}

-(void)onOuptAACSequenceHeader:(NSData*)headerData time:(UInt32)timeStamp
{
    if(0 == _configCount) {
        [self onOutputAACData:headerData isRaw:NO time:timeStamp];
    }
    _configCount++;
    if(CONFIG_COUNT_DOWN == _configCount) {
        _configCount = 0;
    }
}

-(void)onOutputAACData:(NSData*)aacData isRaw:(BOOL)isRawData time:(UInt32)timeStamp
{
    char* bytes = (char*)[aacData bytes];
    std::string aac(bytes, aacData.length) ;
    flv::AudioData audioData;
    audioData.GetHeader().SetSoundFormat(flv::SoundFormat::AAC);
    audioData.GetHeader().SetSoundRate(flv::SoundRate::HZ_44000);
    audioData.GetHeader().SetSoundSize(flv::SoundSize::SAMPLES_16_BIT);
    audioData.GetHeader().SetSoundType(flv::SoundType::MONO_SOUND);
    audioData.GetHeader().SetAacPacketType(isRawData ? flv::AacPacketType::AAC_RAW :
                                           flv::AacPacketType::AAC_SEQUENCE_HEADER);
    
    if (aac[0] == (char)0xff && ((aac[1] & 0xf0) == 0xf0)) {
        audioData.SetBody(aac.substr(7, aac.size() - 7));
    } else {
        audioData.SetBody(aac);
    }
    
    std::string audio;
    audioData.Encode(audio);
    
    //tag只用于本地测试，最终传输要传data
//    flv::Tag tag(flv::TagType::AUDIO, timeStamp, audio);
//    std::string outputData;
//    tag.Encode(outputData);
//    NSData* resultData = [NSData dataWithBytes:outputData.c_str() length:outputData.length()];
    
    NSData* resultData = [NSData dataWithBytes:audio.c_str() length:audio.length()];
    dispatch_async(self.callbackQueue, ^{
        [self.delegate encoder:self encodedData:resultData time:timeStamp];
    });
}

/**
 *  Add ADTS header at the beginning of each and every AAC packet.
 *  This is needed as MediaCodec encoder generates a packet of raw
 *  AAC data.
 *
 *  Note the packetLen must count in the ADTS header itself.
 *  See: http://wiki.multimedia.cx/index.php?title=ADTS
 *  Also: http://wiki.multimedia.cx/index.php?title=MPEG-4_Audio#Channel_Configurations
 **/
- (NSData*) adtsDataForPacketLength:(NSUInteger)packetLength {
    int adtsLength = 7;
    char *packet = (char*)malloc(sizeof(char) * adtsLength);
    // Variables Recycled by addADTStoPacket
    int profile = 2;  //AAC LC
    //39=MediaCodecInfo.CodecProfileLevel.AACObjectELD;
    int freqIdx = 4;  //44.1KHz
    int chanCfg = 1;  //MPEG-4 Audio Channel Configuration. 1 Channel front-center
    NSUInteger fullLength = adtsLength + packetLength;
    // fill in ADTS data
    packet[0] = (char)0xFF;	// 11111111  	= syncword
    packet[1] = (char)0xF9;	// 1111 1 00 1  = syncword MPEG-2 Layer CRC
    packet[2] = (char)(((profile-1)<<6) + (freqIdx<<2) +(chanCfg>>2));
    packet[3] = (char)(((chanCfg&3)<<6) + (fullLength>>11));
    packet[4] = (char)((fullLength&0x7FF) >> 3);
    packet[5] = (char)(((fullLength&7)<<5) + 0x1F);
    packet[6] = (char)0xFC;
    NSData *data = [NSData dataWithBytesNoCopy:packet length:adtsLength freeWhenDone:YES];
    return data;
}


@end
