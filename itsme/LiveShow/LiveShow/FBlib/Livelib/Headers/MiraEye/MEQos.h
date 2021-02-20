//
//  MEQos.h
//  MiraEye
//
//  Created by 古原辉 on 16/5/26.
//  Copyright © 2016年 uShow. All rights reserved.
//

#ifndef MEQos_h
#define MEQos_h

#import <Foundation/Foundation.h>

@interface MEQos : NSObject<NSMutableCopying>

-(void)setTimestamp:(uint32_t)timestamp;
-(uint32_t)getTimestamp;
-(void)setIncomingBytes:(uint64_t)value;
-(uint64_t)getIncomingBytes;
-(void)setIncomingPackets:(uint32_t)value;
-(uint32_t)getIncomingPackets;
-(void)setOutgoingBytes:(uint64_t)value;
-(uint64_t)getOutgoingBytes;
-(void)setOutgoingPackets:(uint32_t)value;
-(uint32_t)getOutgoingPackets;
-(void)setDroppedBytes:(uint64_t)value;
-(uint64_t)getDroppedBytes;
-(void)setDroppedPackets:(uint32_t)value;
-(uint32_t)getDroppedPackets;
-(void)setTotalBytes:(uint64_t)value;
-(uint64_t)getTotalBytes;
-(void)setTotalPackets:(uint32_t)value;
-(uint32_t)getTotalPackets;
-(uint64_t)getWaitingBytes;
-(uint32_t)getWaitingPackets;

@end

#endif /* MEQos_h */
