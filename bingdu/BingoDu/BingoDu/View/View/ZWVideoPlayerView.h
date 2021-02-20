//
//  ZWVideoPlayerView.h
//  videoPlayerDemo
//
//  Created by SouthZW on 15/12/26.
//  Copyright © 2015年 SouthZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
/**
 视频操作类型
 */
typedef NS_ENUM (NSUInteger,ZWVideoOperationType)
{
    ZWVideoOperationScreenSize,  //全屏半屏切换
    ZWVideoOperationPlayOrPause,   //暂停or播放
    ZWVideoOperationBack,   //返回
};
@class ZWVideoPlayerView;
/**
 点击回调block
 */
typedef void (^videoOperatonCallBack)(ZWVideoPlayerView *videoView, ZWVideoOperationType operationType,BOOL open);

@interface ZWVideoPlayerView : UIView
-(id)initWithFrame:(CGRect) frame  videoUrl:(NSString*)videoUrl videoTitle:(NSString*)videoTitle callBack:(videoOperatonCallBack)videoOperatonCallBack;
@property (nonatomic,strong)AVPlayerLayer *playerLayer;

-(void)pauseOrPlayVideo:(BOOL)isPlay;

@property (nonatomic,assign)BOOL isPlaying;
@end
