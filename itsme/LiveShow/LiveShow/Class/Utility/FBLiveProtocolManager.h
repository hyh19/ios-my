//
//  FBLiveProtocolManager.h
//  LiveShow
//
//  Created by chenfanshun on 18/03/16.
//  Copyright © 2016年 FB. All rights reserved.
//

#import <Foundation/Foundation.h>

//开播协议规范：
//rtmp：内部服务器rtmp协议
//soup：内部服务器soup协议
//akamai-rtmp:使用内部rtmp协议，但是可以使用akamai的cdn
//
//播放协调规范：
//rtmp：内部服务器rtmp协议
//soup：内部服务器soup协议
//hls：内部服务器hls协议
//aws-hls：亚马逊cdn的hls协议
//akamai-rtmp：阿卡麦cdn的rtmp协议

/**
 *  管理开播，直播等协议和region参数
 */

@interface FBLiveProtocolManager : NSObject

-(void)setForceProtocol:(NSString*)protocol;

-(NSString*)getFroceProtocol;


/**
 *  获取region信息
 */
-(void)loadData;

/**
 *  获取开播协议
 *
 *  @return 开播协议名
 */
-(NSString*)getOpenLiveProtocol;

/**
 *  获取直播协议
 *
 *  @return 直播协议名
 */
-(NSString*)getPlayLiveProtocol;

/**
 *  获取当前region
 *
 *  @return 当前region
 */
-(NSInteger)getCurrentRegion;

/**
 *  是否可用region
 *
 *  @return <#return value description#>
 */
-(BOOL)isVaildRegion;

@end
