//
//  FlvVideoDataHeader.h
//  uShow
//
//  Created by 古原辉 on 16/4/13.
//  Copyright © 2016年 喻扬. All rights reserved.
//

#ifndef MEFlvVideoDataHeader_h
#define MEFlvVideoDataHeader_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, MEFlvVideoFrameType) {
    kMEFlvVideoKeyFrame = 0x1,
    kMEFlvVideoInterFrame = 0x2
};

typedef NS_ENUM(int, MEFlvAvcPacketType) {
    kMEFlvAvcPacketSequenceHeader = 0,
    kMEFlvAvcPacketNalu = 1
};

@interface MEFlvVideoDataHeader : NSObject

-(UInt8)getFrameType;
-(void)setFrameType:(UInt8)frameType;
-(UInt8)getCodecId;
-(void)setCodecId:(UInt8)codecId;
-(UInt8)getPacketType;
-(void)setPacketType:(UInt8)packetType;
-(UInt32)getCompositionTime;
-(void)setCompositionTime:(UInt32)compositionTime;
-(UInt32)getLength;

-(BOOL)encode:(UInt8 *)data length:(UInt32)length;
-(int)decode:(UInt8 *)data length:(UInt32)length;

@end

#endif /* FlvVideoDataHeader_h */
