//
//  FlvAudioDataHeader.h
//  uShow
//
//  Created by 古原辉 on 16/4/13.
//  Copyright © 2016年 喻扬. All rights reserved.
//

#ifndef MEFlvAudioDataHeader_h
#define MEFlvAudioDataHeader_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, MEFlvAudioPacketType) {
    kMEFlvAacPacketSequenceHeader = 0,
    kMEFlvAacPacketRaw = 1
};

@interface MEFlvAudioDataHeader : NSObject

-(id)initWith:(UInt8)channelCount;

-(UInt8)getSoundFormat;
-(void)setSoundFormat:(UInt8)soundFormat;
-(UInt8)getSoundRate;
-(void)setSoundRate:(UInt8)soundRate;
-(UInt8)getSoundSize;
-(void)setSoundSize:(UInt8)soundSize;
-(UInt8)getSoundType;
-(void)setSoundType:(UInt8)soundType;
-(UInt8)getAacPacketType;
-(void)setAacPacketType:(UInt8)aacPacketType;
-(UInt32)getLength;

-(BOOL)encode:(UInt8 *)data length:(UInt32)length;
-(int)decode:(UInt8 *)data length:(UInt32)length;

@end

#endif /* FlvAudioDataHeader_h */
