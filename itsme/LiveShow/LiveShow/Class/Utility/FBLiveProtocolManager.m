//
//  FBLiveProtocolManager.m
//  LiveShow
//
//  Created by chenfanshun on 18/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import "FBLiveProtocolManager.h"
#import "FBLiveStreamNetworkManager.h"

#define MAX_REFETCH_COUNT     5

@interface FBLiveProtocolManager()

@property(nonatomic, assign)NSInteger   region;

@property(nonatomic, assign)NSInteger   refetchCount;

@property(nonatomic, copy)NSString*   currtForPlayProtocol;

@end

@implementation FBLiveProtocolManager

-(id)init
{
    if(self = [super init]) {
        _region = -1;
        _refetchCount = 0;
        self.currtForPlayProtocol = @"";
    }
    return self;
}

-(void)setForceProtocol:(NSString*)protocol
{
    self.currtForPlayProtocol = protocol;
}

-(NSString*)getFroceProtocol
{
    return _currtForPlayProtocol;
}

-(void)loadData
{
    __weak typeof(self)wSelf = self;
    [[FBLiveStreamNetworkManager sharedInstance] getRegionInfoSuccess:^(id result) {
        @try {
            NSArray* opts = result[@"opt"];
            if([opts count]) {
                NSDictionary* item = opts[0];
                NSInteger region = [item[@"region"] integerValue];
                wSelf.region = region;
                
                NSLog(@"my current region: %zd", region);
            }
        }
        @catch (NSException *exception) {
            [wSelf checkRefech];
            
            NSLog(@"fetch region exception");
        }
    } failure:^(NSString *errorString) {
        [wSelf checkRefech];
        
        NSLog(@"fetch region failed");
    }];
}

-(void)checkRefech
{
    _refetchCount++;
    if(_refetchCount <= MAX_REFETCH_COUNT) {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(loadData) userInfo:nil repeats:NO];
    }
}

-(NSString*)getOpenLiveProtocol
{
    //开播走rtmp协议
    return @"rtmp";
    //return @"soup";
}

/**
 *  获取直播协议
 *
 *  @return 直播协议名
 */
-(NSString*)getPlayLiveProtocol
{
    if([self.currtForPlayProtocol length]) {
        return self.currtForPlayProtocol;
    }
    
    //默认为hls，region不为6（6为中国地区）则使用aws-hls
    //NSString* protocol = @"rtmp";
    NSString* protocol = @"hls";
    if(_region != -1 && _region != 6) {
        protocol = @"aws-hls";
    }
    return protocol;
}

-(NSInteger)getCurrentRegion
{
    return _region;
}

-(BOOL)isVaildRegion
{
    return (_region != -1);
}

@end
